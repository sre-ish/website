# DISCLAIMER: README file for PORTAINER_DEPLOY.SH

## SECTION 1: BASIC INFORMATION

### Q: WHAT IS PORTAINER_DEPLOY.SH ?

A: A bash script to deploy portainer in a resource 
   such as your labtop or a virtal machine.

---

### Q: WHAT ARE THE REQUIREMENTS TO RUN PORTAINER_DEPLOY.SH ?

A: portainer_deploy.sh assumes that docker service is up
   and running.

---

### Q: HOW TO RUN PORTAINER_DEPLOY.SH ?

A: Execute "./portainer_deploy.sh". 
   Execute "./portainer_deploy.sh --help" to understand how
   to run the script with custom options.

---

### Q: HOW TO ACCESS PORTAINER WEB INTERFACE ?

A: Via "https://FQDN:9001 (for a default instalation)

---

### Q: WHAT LOGIN CREDENTIALS SHOULD I USE ON FIRST LOGIN 

A: Check .tmp/.admin_data.json. Change the admin password
   after the first login or consider to delete this information
   after a sucessfull definition of an LDAP user as portainer
   administrator.

## SECTION 2: ADVANCED INFORMATION

### Q: WHAT DOES PORTAINER_DEPLOY.SH DO ?

A: The following operations are executed:
   - Creates a unique self-signed certificate (available under .tmp/certs)
   - Creates the docker volume for persistent data
   - Starts Portainer Container via docker CLI
   - Autogenerates an admin password and set its using curl to raise requests to Portainer API (see .tmp/.admin_data.json)
   - Requests Admin Token (needed to continue to interact with the Portainer API)
   - Defines the PublicURL endpoint
 
---

### Q: WHAT ARE PORTAINER_DEPLOY.SH DEFAULT OPTIONS ?

A: The default options are showed by running "./portainer_deploy.sh --help" 
   Using the default options, ./portainer_deploy.sh will
   - Instals the latest version of portainer available from DockerHub
   - Sets-up portainer web interface listening on port 9001/TCP
   - Uses a self-sign certificate for HTTPS (with the FQDN as DN)

--- 
 
### Q: HOW TO CHANGE PORTAINER DEFAULT OPTIONS ?

A: Run "./portainer_deploy.sh --help" to understand how to customize the default 
   options. Arguments are not mandantory and can be provided in any sequence. 
   - Ex: "./portainer_deploy.sh --port=9003 --version=1.19.2"
   - Ex: "./portainer_deploy.sh --version=1.19.2 --port=9003 --cert=myalias.url"


## SECTION 3: LDAP INTEGRATION

### Q: HOW TO AUTHENTICATE USING LDAP ?  

A: LDAP integration will be triggered if templates/.settings.json exists.
   templates/.settings.json is a json file with the ldap infrastructure 
   definitions. It should contain information regarding the user account 
   (and password) allowed to query the ldap information, the ldap server
   details and the BASEDN for the search. See the example provided.

### Q : IS IT POSSIBLE TO DEFINE A LDAP USER AS PORTAINER ADMINISTRATOR ?

A: Yes! Use the "--ldap_user=" option. See "./portainer_deploy.sh --help"
   for details.

## SECTION 4: SECURITY

### WARNING
portainer_deploy.sh relies on a couple of files with sensitive information. They are:
- .tmp/certs: the public and private certificate keys. They are needed to communicate 
via curl to Portainer API. 
- .tmp/.admin_data.json: a admin password generated on the flu to allow a the generate 
of Admin Tokens allowing to communicate via curl to Portainer API. It also allows a first
login into the web interface.
- templates/.settings.json: used for the LDAP integration. It holds details of the LDAP
infrastructure that Portainer will use for A&A purposes. 
- By default, the script logs to /dev/null. If you need to change that setting for 
troubleshooting purposes, please be aware that the log file may potentially capture 
sensitive information.

It is your responsibility to ensure that the appropriate controls are applied to the above
content. Consider moving to other save locations or deleting those contents after instalation.
