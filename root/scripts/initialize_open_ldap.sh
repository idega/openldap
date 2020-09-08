#!/bin/bash

#
# Managing root credentials
#
sudo slappasswd
# Modify password on /etc/ldap/slapd.d/ldap.idega.is.ldif
sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/openldap/slapd.d/ldap.idega.is.ldif;

#
# Additional libs
#
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f cosine.ldif;
sudo ldapadd -Y EXTERNAL -H ldapi:/// -f inetorgperson.ldif;

#
# Setting directory configuration
#
sudo chown ldap:ldap /etc/openldap/slapd.d/base.ldif;
sudo ldapadd -x -D cn=ldapadm,dc=ldap,dc=idega,dc=is -W -f /etc/openldap/slapd.d/base.ldif;

#
# Linking certificates
#
sudo mkdir -p /etc/openldap/certs/certbot-copy;
sudo ln -s /etc/letsencrypt/live/ldap.idega.is/cert.pem /etc/openldap/certs/certbot-copy/
sudo ln -s /etc/letsencrypt/live/ldap.idega.is/chain.pem /etc/openldap/certs/certbot-copy/
sudo ln -s /etc/letsencrypt/live/ldap.idega.is/privkey.pem /etc/openldap/certs/certbot-copy/
sudo ln -s /etc/letsencrypt/live/ldap.idega.is/fullchain.pem /etc/openldap/certs/certbot-copy/
sudo chown -R ldap:ldap /etc/openldap/certs/certbot-copy/
sudo chown -R ldap:ldap /etc/letsencrypt/live/ldap.idega.is/

#
# Importing certificates
#
sudo chown ldap:ldap /etc/openldap/slapd.d/certs.ldif;
sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/openldap/slapd.d/certs.ldif;

#
# Configure domain
#
sudo chown ldap:ldap /etc/openldap/slapd.d/domain.ldif;
sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/openldap/slapd.d/domain.ldif;
