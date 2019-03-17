1) WHAT IS PORTAINER_DEPLOY.SH ?
   a) A bash script to deploy portainer in a resource such as your 
      labtop or a virtal machine.


2) HOW TO RUN PORTAINER_DEPLOY.SH ?
   a) Execute "./portainer_deploy.sh". 
      Default options assume:
      - Install the latest version of portainer available from DockerHub
      - Portainer web interface available on port 9001/TCP
      - Use a self-sign certificate for HTTPS (use the FQDN as provided by 'hostname -f')
   b) Execute "./portainer_deploy.sh --help" to customize default options. 
      Usage: ./portainer_deploy.sh --cert={bing.home} --version={latest} --admin_user={gborges} --port={9001}
      Arguments can be provided in any order and number
        Ex: ./portainer_deploy.sh --port=9003 --version=1.19.2
        Ex: ./portainer_deploy.sh --version=1.19.2 --port=9003 --cert=myalias.url


3) HOW TO ACCESS PORTAINER WEB INTERFACE ?
   a) HTTPS://<FQDN>:9001 (for a default instalation)

3) HOW DOES IT WORK
   a) Creates a unique self-signed certificate
      - Available under .tmp/certs
   b) Creates the docker volume for persistent data
   c) Start Portainer Container
   d) Autogenerates admin password and set its using Portainer API. 
      This allows a first login as user 'admin' (see .tmp/.admin_data.json for password)
   e) Get Admin Token (needed for following operations using the Portainer API)
   f) Defines the PublicURL endpoint
 

