#!/bin/bash


USER=${USER:-deepdiver}

fix_postgres_perms() {
	set -x
	local pgversion=$(/usr/share/postgresql-common/supported-versions installed)
	# add  deepdiver user to postgresql and trust all connections to localhost
	sudo -u postgres /etc/init.d/postgresql start
	sleep 30 
	sudo -u postgres dropuser --if-exists $USER || sudo -u postgres dropuser $USER || true
	sudo -u postgres createuser --superuser $USER || true
	tmp=$(mktemp /tmp/pg_hba.conf.XXXXXXX)
	trap "rm -f $tmp" EXIT
	{
		echo 'host	all	all	127.0.0.1/32	trust'
		echo 'host	all	all	::1/128	trust'
		sudo cat /etc/postgresql/$pgversion/main/pg_hba.conf
	} >$tmp
	sudo tee /etc/postgresql/$pgversion/main/pg_hba.conf <$tmp >/dev/null
	sudo -u postgres /etc/init.d/postgresql stop
}

fix_postgres_perms
