#!/bin/bash

SED=$(which sed);
GREP=$(which grep);

. /etc/jelastic/environment

function _setPassword() {
        return 0;
        new_passwd_file=$(mktemp);
        old_passwd_file=$(mktemp);
        cassanra_conf="/opt/repo/versions/${Version}/conf/cassandra.yaml";
        cqlsh_app="/opt/repo/versions/${Version}/bin/cqlsh";

        echo ALTER USER cassandra WITH PASSWORD \'$J_OPENSHIFT_APP_ADM_PASSWORD\'\; > $new_passwd_file;
        echo UPDATE system_auth.roles set salted_hash=\'\$2a\$10\$vbfmLdkQdUz3Rmw.fF7Ygu6GuphqHndpJKTvElqAciUJ4SZ3pwquu\' where role=\'cassandra\'\; > $old_passwd_file;

        export CQLSH_HOST=$OPENSHIFT_CASSANDRA_DB_HOST;
        export CQLSH_PORT=9042;

        $SED -i 's/authenticator: PasswordAuthenticator/authenticator: AllowAllAuthenticator/g'     $cassanra_conf;
        service cartridge restart > /dev/null 2>&1;

        [ -f "$old_passwd_file" ] && $cqlsh_app  --file $old_passwd_file;
        $SED -i 's/authenticator: AllowAllAuthenticator/authenticator: PasswordAuthenticator/g'     $cassanra_conf;
        service cartridge restart > /dev/null 2>&1;
        
        [ -f "$new_passwd_file" ] && $cqlsh_app -u $J_OPENSHIFT_APP_ADM_USER -p "cassandra"  --file $new_passwd_file;
}
