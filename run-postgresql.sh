#!/bin/bash
#
# supervisord compatible script to launch postgresql 
# 
PG_VERSION=${PG_VERSION:-$(/usr/share/postgresql-common/supported-versions installed)}
PG_DATADIR=${PG_DATADIR:-/var/lib/postgresql/${PG_VERSION}/main}
PG_CONFIG=${PG_CONFIG:-/etc/postgresql/${PG_VERSION}/main/postgresql.conf}

if [ -d /var/run/postgresql ]; then
    chmod 2775 /var/run/postgresql
else
    install -d -m 2775 -o postgres -g postgres /var/run/postgresql
fi

/usr/lib/postgresql/$PG_VERSION/bin/postgres -D $PG_DATADIR -c config_file=${PG_CONFIG}
