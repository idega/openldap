#!/bin/bash
echo "--------------------------------------------------------------------------------"
echo "Installing SYMAS OpenLDAP server..."
echo "--------------------------------------------------------------------------------"
wget -q https://repo.symas.com/configs/SOFL/rhel8/sofl.repo -O /etc/yum.repos.d/sofl.repo
yum -y erase openldap-clients openldap-servers
yum -y update
yum -y install symas-openldap-clients symas-openldap-servers

echo "--------------------------------------------------------------------------------"
echo "Initializing database..."
echo "--------------------------------------------------------------------------------"
cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
chown -R ldap:ldap /var/lib/ldap/*
restorecon -F -R /var/lib/ldap/*

echo "--------------------------------------------------------------------------------"
echo "Starting up server..."
echo "--------------------------------------------------------------------------------"
systemctl enable slapd
systemctl restart slapd

echo "--------------------------------------------------------------------------------"
echo "Pulling configurations..."
echo "--------------------------------------------------------------------------------"
wget https://raw.githubusercontent.com/idega/openldap/master/etc/openldap/slapd.d/base.ldif -P /etc/openldap/slapd.d/
wget https://raw.githubusercontent.com/idega/openldap/master/etc/openldap/slapd.d/certs.ldif -P /etc/openldap/slapd.d/
wget https://raw.githubusercontent.com/idega/openldap/master/etc/openldap/slapd.d/domain.ldif -P /etc/openldap/slapd.d/
wget https://raw.githubusercontent.com/idega/openldap/master/etc/openldap/slapd.d/ldap.idega.is.ldif -P /etc/openldap/slapd.d/
wget https://raw.githubusercontent.com/idega/openldap/master/etc/openldap/slapd.d/monitor.ldif -P /etc/openldap/slapd.d/
chown ldap:ldap /etc/openldap/slapd.d/*.ldif 
chmod go-rwx /etc/openldap/slapd.d/*.ldif 
restorecon -F /etc/openldap/slapd.d/*.ldif

echo "--------------------------------------------------------------------------------"
echo "Generating random password for LDAP administrator..."
echo "--------------------------------------------------------------------------------"
LDAP_ADMIN_PASSWORD=$(date | base64)
LDAP_PASSWORD_HASH=$(slappasswd -s $LDAP_ADMIN_PASSWORD)
sed -i "s/olcRootPW: .*/olcRootPW: ${LDAP_PASSWORD_HASH}/g" /etc/openldap/slapd.d/ldap.idega.is.ldif
echo "LDAP administrator hash is: $LDAP_PASSWORD_HASH"
echo "LDAP administrator password is: $LDAP_ADMIN_PASSWORD"

echo "--------------------------------------------------------------------------------"
echo "Configuring OpenLDAP server..."
echo "--------------------------------------------------------------------------------"
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif
ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/openldap/slapd.d/ldap.idega.is.ldif
ldapmodify -Y EXTERNAL -H ldapi:/// -f /etc/openldap/slapd.d/domain.ldif;
ldapadd -x -D cn=ldapadm,dc=ldap,dc=idega,dc=is -W -f /etc/openldap/slapd.d/base.ldif
