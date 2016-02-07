#!/bin/bash 

. /etc/jelastic/environment

SED=$(which sed);

CASSANDRA_ENV_FILE="${OPENSHIFT_CASSANDRA_DIR}/versions/${Version}/conf/cassandra-env.sh";

[ -z "$XMS" ] && { XMS=32; }
memory_total=`free -m | grep Mem | awk '{print $2}'`;
[ -z "$XMX" ] && { let "XMX=(memory_total-35)/2"; XMX="${XMX}M";  }
$SED -i "s/MAX_HEAP_SIZE=.*/MAX_HEAP_SIZE=${XMX}/" $CASSANDRA_ENV_FILE;
