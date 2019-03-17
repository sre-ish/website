#!/bin/bash

display_help(){
    echo "Usage: $0 --cert={`hostname -f`} --version={latest} --port={9001} --ldap_user={`whoami`}"; echo
    echo " The script accepts 4 arguments:"
    echo "   --cert:      The DN used for the certificate generation "
    echo "   --version:   Portainer version to deploy (ex: 1.20.2)"
    echo "   --port:      The port where the portainer web interface will listen (ex: 9003)"
    echo "   --ldap_user: An ldap user to be configured as Portainer administrator (only applicable if LDAP is in scope)"
    echo
    exit 1
}


# ---

portainer_deploy() {

  local_name="$1"
  port_version="$2"
  tcp_port="$3"
  user_admin="$4"

  echo "1) Create a unique self-signed certificate" | tee -a $LOG

  if [ ! -e $BASE/certs/localhost.crt ]; then
     openssl genrsa -out $CERTS/portainer.key 2048 >> $LOG 2>&1
     openssl ecparam -genkey -name secp384r1 -out $CERTS/portainer.key >> $LOG 2>&1
     openssl req -new -x509 -sha256 \
     -key $CERTS/portainer.key \
     -out $CERTS/portainer.crt \
     -days 3650 \
     -subj "/C=AU/ST=NSW/L=Sydney/O=MyInstitute/OU=MyDepartment/CN=$local_name" >> $LOG 2>&1 
  fi
  chmod 644 $CERTS/portainer.crt
  chmod 400 $CERTS/portainer.key

  # ---

  echo "2) Create the volume for persistent data" | tee -a $LOG
  vlm=`docker volume ls | grep portainer_data | awk '{print $2}'`
  if [ "X$vlm" == "Xportainer_data" ]; then
     echo "portainer_data volume already exists!" >> $LOG 2>&1
  else
     docker volume create portainer_data >> $LOG 2>&1
  fi

  # ---

  echo "3) Start Portainer Container" | tee -a $LOG

  docker run -d \
  --label owner=MyPortainer \
  --privileged \
  -p $tcp_port:9000 --name portainer \
  --restart always \
  -v $CERTS:/certs -v /var/run/docker.sock:/var/run/docker.sock \
  -v portainer_data:/data portainer/portainer:$port_version \
  -H unix:///var/run/docker.sock \
  -l owner=MyPortainer \
  --ssl --sslcert /certs/portainer.crt --sslkey /certs/portainer.key >> $LOG 2>&1

  # ---

  echo "4) Autogenerated admin password. Set initial password using API" | tee -a $LOG

  sleep 10
  admin_pass=`openssl rand -base64 14`
  echo "{}" | jq --arg pass $admin_pass '{"Username":"admin","Password":$pass}' > $TMP/.admin_data.json
  chmod 400 $TMP/.admin_data.json
  cp $TMP/.admin_data.json .
  chmod 700 .admin_data.json
  curl --capath $CERTS --cacert $CERTS/portainer.crt -d "@.admin_data.json" -X POST https://$local_name:$tcp_port/api/users/admin/init >> $LOG 2>&1

  # ---

  echo "5) Get Admin Token. Needed for following actions" | tee -a $LOG

  admin_token=`curl -s --capath $CERTS --cacert $CERTS/portainer.crt -d "@.admin_data.json" -X POST https://$local_name:$tcp_port/api/auth | jq --raw-output '.jwt'` >> $LOG 2>&1

  # ---
 
  if [ -e $TEMPLATE/.settings.json ]; then
    echo "6) LDAP configuration"
    chmod 700 $TEMPLATE/.settings.json
    cp $TEMPLATE/.settings.json .
    curl --capath $CERTS --cacert $CERTS/portainer.crt -d "@.settings.json" -X PUT https://$local_name:$tcp_port/api/settings -H "Authorization: Bearer $admin_token" >> $LOG 2>&1

    echo "6.1) Admin configuration" | tee -a $LOG
    if [ ! -z $user_admin ]; then
      echo '{}' | jq --arg user $user_admin --arg role 1 '{"Username":$user,"Role":$role|tonumber}' > $TMP/.admin_user.json
      echo '{}' | jq --arg userid 2 '{"AuthorizedUsers":[ $userid|tonumber ]}' > $TMP/.admin_id.json
      cp $TMP/.admin_user.json .
      chmod 700 .admin_user.json
      cp $TMP/.admin_id.json .
      chmod 700 .admin_id.json
      curl --capath $CERTS --cacert $CERTS/portainer.crt -d "@.admin_user.json" -X POST https://$local_name:$tcp_port/api/users -H "Authorization: Bearer $admin_token" >> $LOG 2>&1
      curl --capath $CERTS --cacert $CERTS/portainer.crt -d "@.admin_id.json" -X PUT https://$local_name:$tcp_port/api/endpoints/1/access -H "Authorization: Bearer $admin_token" >> $LOG 2>&1
    fi
  else
    echo "6) Will not integrate with a LDAP auth system, .settings.json missing!" | tee -a $LOG
  fi

  # ---

  echo "7) Define endpoint PublicURL" | tee -a $LOG

  curl --capath $CERTS --cacert $CERTS/portainer.crt -X PUT https://$local_name:$tcp_port/api/endpoints/1 -H "Authorization: Bearer $admin_token" -H "accept: application/json" -H "Content-Type: application/json" -d "{ \"PublicURL\": \"$local_name\"}"  >> $LOG 2>&1
  
  # ---

  # Final clean up
  rm -f .*json
  rm -f properties.xml

  echo "DONE! Go to https://$local_name:$tcp_port" | tee -a $LOG
  echo "DEBUG: Change \$LOG global variable (default is /dev/null, current setting is $LOG)" | tee -a $LOG
}


###
### Main
###

BASE=$PWD
TMP=$BASE/.tmp
TEMPLATE=$BASE/templates
CERTS=$TMP/certs
#LOG=$BASE/ict_portainer_deploy.log
LOG="/dev/null"


echo "----------------------------" | tee -a $LOG
echo "### Date: `date`" | tee -a $LOG
echo "### Running: $0 $@" | tee -a $LOG
echo "----------------------------" | tee -a $LOG

case $1 in
--help)
  display_help
  ;;
*)  
  dn=`hostname -f`
  version="latest"
  ldap_user=`whoami`
  port="9001"
  for var in "$@"; do
    if [[ $var =~ --cert=.*$ ]]; then
      dn=`echo $var | cut -f2 -d'='`
    fi

    if [[ $var =~ --version=.*$ ]]; then
      version=`echo $var | cut -f2 -d'='`
    fi

    if [[ $var =~ --ldap_user=.*$ ]]; then
      ldap_user=`echo $var | cut -f2 -d'='`
    fi

    if [[ $var =~ --port=.*$ ]]; then
      port=`echo $var | cut -f2 -d'='`
    fi
  done

  if [ ! -d $TMP ]; then
    mkdir -p $CERTS
  fi

  portainer_deploy $dn $version $port $ldap_user
;;
esac

exit 0

