#!/bin/bash

SED=$(which sed);
GREP=$(which grep);

#
# This is an example of reset password hook in Jelastic
#

#$J_OPENSHIFT_APP_ADM_USER        ;   Operate this variable for the username
#$J_OPENSHIFT_APP_ADM_PASSWORD    ;   Use this varible for your password

function _setPassword() {
        new_passwd_file=$(mktemp);
        old_passwd_file=$(mktemp);
        cassanra_conf="/opt/repo/versions/2.0.8/conf/cassandra.yaml";
        cqlsh_app="/opt/repo/versions/2.0.8/bin/cqlsh";

        echo ALTER USER cassandra WITH PASSWORD \'$J_OPENSHIFT_APP_ADM_PASSWORD\'\; > $new_passwd_file;
        echo UPDATE system_auth.credentials set salted_hash=\'\$2a\$10\$vbfmLdkQdUz3Rmw.fF7Ygu6GuphqHndpJKTvElqAciUJ4SZ3pwquu\' where username=\'cassandra\'\; > $old_passwd_file;

        export CQLSH_HOST=$OPENSHIFT_CASSANDRA_DB_HOST;
        export CQLSH_PORT=$OPENSHIFT_CASSANDRA_DB_PORT;

        # Init data neede for password auth
        $SED -i 's/authenticator: AllowAllAuthenticator/authenticator: PasswordAuthenticator/g'     $cassanra_conf;
        service cartridge restart > /dev/null 2>&1;

        #while netstat -lnt | awk '$4 ~ /:'"${OPENSHIFT_CASSANDRA_DB_PORT}"'$/ {exit 1}'; do sleep 1; done;
        sleep 10;
        $SED -i 's/authenticator: PasswordAuthenticator/authenticator: AllowAllAuthenticator/g'     $cassanra_conf;
        service cartridge restart > /dev/null 2>&1;
        sleep 10;
        #while netstat -lnt | awk '$4 ~ /:'"${OPENSHIFT_CASSANDRA_DB_PORT}"'$/ {exit 1}'; do sleep 1; done;
        [ -f "$old_passwd_file" ] && $cqlsh_app  --file $old_passwd_file;
        $SED -i 's/authenticator: AllowAllAuthenticator/authenticator: PasswordAuthenticator/g'     $cassanra_conf;
        service cartridge restart > /dev/null 2>&1;
        sleep 10;
        #while netstat -lnt | awk '$4 ~ /:'"${OPENSHIFT_CASSANDRA_DB_PORT}"'$/ {exit 1}'; do sleep 1; done;
        [ -f "$new_passwd_file" ] && $cqlsh_app -u $J_OPENSHIFT_APP_ADM_USER -p "cassandra"  --file $new_passwd_file;
}

