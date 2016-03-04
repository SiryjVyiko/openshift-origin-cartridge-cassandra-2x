#!/bin/bash 

. /etc/jelastic/environment

if [ -e ${OPENSHIFT_CASSANDRA_DIR}/versions/${Version}/bin/variablesparser.sh ]; then
      . ${OPENSHIFT_CASSANDRA_DIR}/versions/${Version}/bin/variablesparser.sh
fi

SED=$(which sed);

CASSANDRA_ENV_FILE="${OPENSHIFT_CASSANDRA_DIR}/versions/${Version}/conf/cassandra-env.sh";

memory_total=`free -m | grep Mem | awk '{print $2}'`;
[ -z "$XMX" ] && { let "XMX=(memory_total-35)/2"; XMX="${XMX}M";  }
[ -z "$XMS" ] && { XMS=${XMX}; }
$SED -i "s/MAX_HEAP_SIZE=.*/MAX_HEAP_SIZE=${XMX}/" $CASSANDRA_ENV_FILE;
$SED -i "s/MIN_HEAP_SIZE=.*/MIN_HEAP_SIZE=${XMS}/" $CASSANDRA_ENV_FILE;
