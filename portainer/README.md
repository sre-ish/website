# DISCLAIMER: README file for PORTAINER_DEPLOY.SH

## SECTION 1: BASIC INFORMATION

Q: WHAT IS PORTAINER_DEPLOY.SH ?

A: A bash script to deploy portainer in a resource 
   such as your labtop or a virtal machine.

---

Q: WHAT ARE THE REQUIREMENTS TO RUN PORTAINER_DEPLOY.SH ?

A: portainer_deploy.sh assumes that docker service is up
   and running.

---

Q: HOW TO RUN PORTAINER_DEPLOY.SH ?

A: Execute "./portainer_deploy.sh". 
   Execute "./portainer_deploy.sh --help" to understand how
   to run the script with custom options.

---

Q: HOW TO ACCESS PORTAINER WEB INTERFACE ?

A: Via "https://<FQDN>:9001 (for a default instalation)

---

Q: WHAT LOGIN CREDENTIALS SHOULD I USE ON FIRST LOGIN 

A: Check .tmp/.admin_data.json. Change the admin password
   after the first login.

## SECTION 2: ADVANCED INFORMATION

Q: WHAT DOES PORTAINER_DEPLOY.SH DO ?

A: Creates a unique self-signed certificate (available under .tmp/certs)
   Creates the docker volume for persistent data
   Starts Portainer Container via docker CLI
   Autogenerates an admin password and set its using curl to raise requests 
   to Portainer API (see .tmp/.admin_data.json)
   Requests Admin Token (needed to continue to interact with the Portainer API)
   Defines the PublicURL endpoint
 
---

Q: WHAT ARE PORTAINER_DEPLOY.SH DEFAULT OPTIONS ?

A: The default options are showed by running "./portainer_deploy.sh --help" 
   Using the default options, ./portainer_deploy.sh will
   - Install the latest version of portainer available from DockerHub
   - Set-up portainer web interface listening on port 9001/TCP
   - Use a self-sign certificate for HTTPS (with the FQDN as DN)

--- 
 
Q: HOW TO CHANGE PORTAINER DEFAULT OPTIONS ?

A: Run "./portainer_deploy.sh --help" to understand how to customize the default 
   options. Arguments are not mandantory and can be provided in any sequence. 
   - Ex: "./portainer_deploy.sh --port=9003 --version=1.19.2"
   - Ex: "./portainer_deploy.sh --version=1.19.2 --port=9003 --cert=myalias.url"


## SECTION 3: LDAP INTEGRATION

Q: HOW TO AUTHENTICATE USING LDAP?  

A: LDAP integration will be triggered if templates/.settings.json exists.
   templates/.settings.json is a json file with the ldap infrastructure 
   definitions. See the example provided.
 

## SECTION 4: SECURITY

W: The public and private certificate keys are created in '.tmp/certs'. 
   They are needed to communicate via curl to Portainer API. Ensure the 
   approproate controls are applied regarding access to that content and 
   consider change it to a protected external location.

W: ./portainer_deploy.sh generates a default admin password to allow a 
   first login, and to be able to generate an Admin Token to allow it
   to communicate via curl to Portainer API (see .tmp/.admin_data.json).
   Ensure the approproate controls are applied regarding access to that 
   content and consider change the admin password on first login.
 
