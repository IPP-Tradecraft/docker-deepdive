# Makefile for building and running a deepdive instance
#
# Copyright (C) 2016 Scott Phillpott <scott@ipptradecraft.com>
# Copyright (C) 2016 Ahmed Masud <ahmed.masud@trustifier.com>
# See LICENSE for usage details
#
# @@help main
#
# make help 	-- displays this help
#
# User mode:
#
# 	make		-- builds a docker image named <image-name>:latest
# 	make run	-- builds and runs a docker image named <image-name>:latest
#
# ** Note that in user mode all existing docker-deepdive images are removed 
#
# -----------------------------------------------------------------------------
# Developer mode (assumed if .git is present):
#
# 	make		-- build image from the current git branch
# 	make run 	-- build & run image from the current git branch
# 			   NOTE: the executed image gets deleted upon exit
#
# 	make latest	-- build image as latest from current git branch
# 	make run-latest	-- build & run image as latest from current git branch
#
# @@end-help

# @@help parameters
# 
# You can provide RUN, IMAGE and TAG as part of the build process:
#
# For example
#
# 	make TAG=3.5 (tag the image as 3.5)
# 	make IMAGE=foo TAG=bar (create image named 'foo' tagged as 'bar')
# 	make ROOT=<PATH | URL> (create image from path or URL instead of pwd)
#
# Use RUNAS to specify the instance name (defaults to docker-deepdive-instance)
#
# DATADIR default is ~/.docker-deepdive ... Put data in subdirectory called
# ${DATADIR}/input, deepdive will push batch results into ${DATADIR}/output
# 
# Use DATADIR to specify the path of data directory (input and output will be
# pushed in ${DATADIR}/input and ${DATADIR}/output respectively
# 
# For example
#
# 	make run RUNAS=my-deepdive-instance DATADIR=/var/lib/deepdive/foo
#
# @@end-help


ROOTDIR:=.
IMAGE:=docker-deepdive
TAG:=latest
RUNAS:=docker-deepdive-instance
#
# on a production system set DATADIR to /var/lib/docker-deepdive
#
DATADIR:=~/.docker-deepdive
#
# User inside the container ... 
#
DEEPDIVER=deepdiver

####### do not edit below this #####

MAKEFLAGS += -rR --no-print-directory
 
DOCKER=docker
MKDIR_P=mkdir -p
PERL=perl -w

# @@help verbosity
#
# Make flag increase make verbosity by setting V=1 
# For example, 
#
# 	make V=1 build
#
# @@end-help 

ifeq ($(V),)
Q=@
e=(echo $(1) 1>&2)

S=([ -n "$(1)" ] && (							\
	echo -ne "	\e[0;37m[\e[32m"; echo -ne $(1); 		\
	if [ -n '$(2)' ] ; then $(if $(2),./scripts/spin-tee.sh -L $(if $(3), $(3), /dev/null) -- $(2), :);  \
		rv=$$?; if [ $$rv -eq 0 ]; then				\
			echo -e "\e[0;37m:\e[1;34m Success\e[0m]";	\
		else 							\
			echo -e "\e[0;37m:\e[0;31m Failure\e[0m]";	\
			exit $$rv;					\
		fi;							\
	else echo -e "\e[0;37m]"; fi) 1>&2)
T=(echo -e "      -=|\e[0;31m$(1)\e[0;37m |=-"; $(if $(2), echo 1>&2; $(2) | sed -e '$(if $(3),$(3),s/^/\t/)' 1>&2, :))

else
Q=
S=$(if $(2),$(2),:)
e=
T=(echo $(1))
endif

export Q
export E
export e

PHONY=


# Suppress entering/leaving messages

PHONY += default 


default::
	@$(if $(Q),$(call e),:)
	$(Q)$(MAKE) build  
	@$(if $(Q),$(call e),:)

PHONY += help
help::
	$(Q)$(PERL) scripts/help.pl Makefile | $${PAGER:-less -XeF --prompt "Use j/k to scroll, quits at the end"}

maintainer-clean:: clean
	$(Q)$(RM) -r .deps 


PHONY+=space

PHONY+= build

build: 
	$(Q)$(call S, DOCKER BUILD, $(DOCKER) build -t $(IMAGE):$(TAG) $(ROOTDIR), build-log ) || \
		$(call T, Error: docker build log, tac build-log | grep -m1 Step -B10 | tac)

PHONY+=run
run: 
	$(Q)$(call e); $(MAKE) build clean-instance run-instance; $(call e)

stop:
	$(Q)$(call e); $(MAKE) stop-instance; $(call e)

start:
	$(Q)$(call e); $(MAKE) start-instance; $(call e)

clean:
	$(Q)$(call e); $(MAKE) stop-instance clean-instance; $(call e)

status:
	$(Q)INSTANCEID="$$($(DOCKER) ps -q -f 'name=$(RUNAS)')";  test -n "$${INSTANCEID}" && \
		( echo "Instance is running as $(RUNAS) (id: $${INSTANCEID})" )  || ( echo "Instance is not running" )

run-instance:
	$(Q)test -z "$$($(DOCKER) ps -qa -f 'name=$(RUNAS)')" || \
		( echo "Please remove the instance before issuing make run" 1>&2 && exit 127 )
	$(Q)$(call S, CREATING DATA DIR $(DATADIR), mkdir -p $(DATADIR))
	$(Q)$(call S, DOCKER RUN $(RUNAS), \
		$(DOCKER) run -v $(DATADIR):/var/lib/docker-deepdive -tid --name $(RUNAS) $(IMAGE):$(TAG), instance-id) \
	 && $(call S, $(RUNAS) is running)
	$(MAKE) attach-help


clean-instance:
	$(Q)test -z "$$($(DOCKER) ps -q -f 'name=$(RUNAS)')" || \
		( echo "Please stop the instance before issuing make clean-instance" 1>&2 && exit 127 )
	$(Q)$(call S, 'DOCKER CLEAN', $(DOCKER) rm $(RUNAS) || echo $(RUNAS), instance-id )

start-instance:
	$(Q)$(call S, 'DOCKER START', $(DOCKER) start $(RUNAS), instance-id)

stop-instance:
	$(Q)test -n "$$($(DOCKER) ps -q -f 'name=$(RUNAS)')" && $(call S, 'DOCKER STOP', $(DOCKER) stop $(RUNAS)) || true

attach: attach-help

attach-help:
	@echo -e "\n\n	Use \e[1mdocker exec -ti $(RUNAS) su - $(DEEPDIVER)\e[0m to attach to the deepdive processing environment.\n"
	@echo -e "\n\n	Use \e[1mdocker exec -ti $(RUNAS) /bin/bash\e[0m to attach to the raw instance.\n"

.deps:
	$(Q)$(MKDIR_P) $@

first-time-help:
	$(Q)test -f .deps/first-time-help || ($(MAKE) help && mkdir .deps && touch .deps/first-time-help)

.PHONY: $(PHONY)
