#!/bin/bash

#dnf update -y
setenforce 0
sed -i 's@enforcing@disabled@' /etc/selinux/config
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm -y
dnf install cyrus-sasl-devel make libtool autoconf libtool-ltdl-devel openssl-devel libdb-devel tar gcc perl perl-devel wget vim -y
useradd -r -M -d /var/lib/openldap -u 55 -s /usr/sbin/nologin ldap
wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-$ldap_ver.tgz
tar xzf openldap-$ldap_ver.tgz
cd openldap-$ldap_ver

./configure --prefix=/usr --sysconfdir=/etc --disable-static \
--enable-debug --with-tls=openssl --with-cyrus-sasl --enable-dynamic \
--enable-crypt --enable-spasswd --enable-slapd --enable-modules \
--enable-rlookups --enable-backends=mod --disable-ndb --disable-sql \
--disable-shell --disable-bdb --disable-hdb --enable-overlays=mod

make depend
make
make install

mkdir /var/lib/openldap /etc/openldap/slapd.d
chown -R ldap:ldap /var/lib/openldap
chown root:ldap /etc/openldap/slapd.conf
chmod 640 /etc/openldap/slapd.conf

cat > /etc/systemd/system/slapd.service << 'EOF' 
[Unit]
Description=OpenLDAP Server Daemon
After=syslog.target network-online.target
Documentation=man:slapd
Documentation=man:slapd-mdb

[Service]
Type=forking
PIDFile=/var/lib/openldap/slapd.pid
Environment="SLAPD_URLS=ldap:/// ldapi:/// ldaps:///"
Environment="SLAPD_OPTIONS=-F /etc/openldap/slapd.d"
ExecStart=/usr/libexec/slapd -u ldap -g ldap -h ${SLAPD_URLS} $SLAPD_OPTIONS

[Install]
WantedBy=multi-user.target
EOF

cp /usr/share/doc/sudo/schema.OpenLDAP  /etc/openldap/schema/sudo.schema

cat  > /etc/openldap/schema/sudo.ldif << 'EOF'
dn: cn=sudo,cn=schema,cn=config
objectClass: olcSchemaConfig
cn: sudo
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.1 NAME 'sudoUser' DESC 'User(s) who may  run sudo' EQUALITY caseExactIA5Match SUBSTR caseExactIA5SubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.2 NAME 'sudoHost' DESC 'Host(s) who may run sudo' EQUALITY caseExactIA5Match SUBSTR caseExactIA5SubstringsMatch SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.3 NAME 'sudoCommand' DESC 'Command(s) to be executed by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.4 NAME 'sudoRunAs' DESC 'User(s) impersonated by sudo (deprecated)' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.5 NAME 'sudoOption' DESC 'Options(s) followed by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.6 NAME 'sudoRunAsUser' DESC 'User(s) impersonated by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcAttributeTypes: ( 1.3.6.1.4.1.15953.9.1.7 NAME 'sudoRunAsGroup' DESC 'Group(s) impersonated by sudo' EQUALITY caseExactIA5Match SYNTAX 1.3.6.1.4.1.1466.115.121.1.26 )
olcObjectClasses: ( 1.3.6.1.4.1.15953.9.2.1 NAME 'sudoRole' SUP top STRUCTURAL DESC 'Sudoer Entries' MUST ( cn ) MAY ( sudoUser $ sudoHost $ sudoCommand $ sudoRunAs $ sudoRunAsUser $ sudoRunAsGroup $ sudoOption $ description ) )
EOF

mv /etc/openldap/slapd.ldif /etc/openldap/slapd.ldif.bak

cat > /etc/openldap/slapd.ldif << EOF
dn: cn=config
objectClass: olcGlobal
cn: config
olcArgsFile: /var/lib/openldap/slapd.args
olcPidFile: /var/lib/openldap/slapd.pid

dn: cn=schema,cn=config
objectClass: olcSchemaConfig
cn: schema

dn: cn=module,cn=config
objectClass: olcModuleList
cn: module
olcModulepath: /usr/libexec/openldap
olcModuleload: back_mdb.la

include: file:///etc/openldap/schema/core.ldif
include: file:///etc/openldap/schema/cosine.ldif
include: file:///etc/openldap/schema/nis.ldif
include: file:///etc/openldap/schema/inetorgperson.ldif
include: file:///etc/openldap/schema/ppolicy.ldif
include: file:///etc/openldap/schema/sudo.ldif

dn: olcDatabase=frontend,cn=config
objectClass: olcDatabaseConfig
objectClass: olcFrontendConfig
olcDatabase: frontend
olcAccess: to dn.base="cn=Subschema" by * read
olcAccess: to * 
  by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage 
  by * none

dn: olcDatabase=config,cn=config
objectClass: olcDatabaseConfig
olcDatabase: config
olcRootDN: cn=config
olcAccess: to * 
  by dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage 
  by * none
EOF

sleep 3

slapadd -n 0 -F /etc/openldap/slapd.d -l /etc/openldap/slapd.ldif
chown -R ldap:ldap /etc/openldap/slapd.d

systemctl daemon-reload
systemctl enable --now slapd

sleep 3

cat > enable-ldap-log.ldif << EOF
dn: cn=config
changeType: modify
replace: olcLogLevel
olcLogLevel: stats
EOF

ldapmodify -Y external -H ldapi:/// -f enable-ldap-log.ldif
echo "local4.* /var/log/slapd.log" >> /etc/rsyslog.conf
systemctl restart rsyslog

pswroot=$(slappasswd -s $psw_root) 

cat > rootdn.ldif << EOF
dn: olcDatabase=mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: mdb
olcDbMaxSize: 42949672960
olcDbDirectory: /var/lib/openldap
olcSuffix: $olcsuffix
olcRootDN: cn=admin,$olcsuffix
olcRootPW: $pswroot
olcDbIndex: uid pres,eq
olcDbIndex: cn,sn pres,eq,approx,sub
olcDbIndex: mail pres,eq,sub
olcDbIndex: objectClass pres,eq
olcDbIndex: loginShell pres,eq
olcDbIndex: sudoUser,sudoHost pres,eq
olcAccess: to attrs=userPassword,shadowLastChange,shadowExpire
  by self write
  by anonymous auth
  by dn.subtree="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage 
  by dn.subtree="ou=system,$olcsuffix" read
  by * none
olcAccess: to dn.subtree="ou=system,$olcsuffix" by dn.subtree="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage
  by * none
olcAccess: to dn.subtree="$olcsuffix" by dn.subtree="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage
  by users read 
  by * none
EOF
ldapadd -Y EXTERNAL -H ldapi:/// -f rootdn.ldif

#openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
#-subj "/C=US/ST=stage/L=devops/O=devopslab/CN=ldap.devopslab.com" \
#-keyout /etc/pki/tls/ldapserver.key -out /etc/pki/tls/ldapserver.crt

cp /tmp/ldapserver.key  /etc/pki/tls/ldapserver.key
cp /tmp/ldapserver.crt  /etc/pki/tls/ldapserver.crt
chmod 644 /etc/pki/tls/ldapserver.crt
chmod 600 /etc/pki/tls/ldapserver.key
chown ldap:ldap /etc/pki/tls/{ldapserver.crt,ldapserver.key}

cat > add-tls.ldif << EOF
dn: cn=config
changetype: modify
add: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/pki/tls/ldapserver.crt
-
add: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/pki/tls/ldapserver.key
-
add: olcTLSCertificateFile
olcTLSCertificateFile: /etc/pki/tls/ldapserver.crt
EOF
ldapadd -Y EXTERNAL -H ldapi:/// -f add-tls.ldif

echo "TLS_CACERT     /etc/pki/tls/ldapserver.crt" >> /etc/openldap/ldap.conf

cat > basedn.ldif << EOF
dn: $olcsuffix
objectClass: dcObject
objectClass: organization
objectClass: top
o: devopslab com
dc: ldap

dn: ou=groups,$olcsuffix
objectClass: organizationalUnit
objectClass: top
ou: groups

dn: ou=people,$olcsuffix
objectClass: organizationalUnit
objectClass: top
ou: people
EOF

ldapadd -Y EXTERNAL -H ldapi:/// -f basedn.ldif

pswuser=$(slappasswd -s $psw_user) 

cat > users.ldif << EOF
dn: uid=$user,ou=people,$olcsuffix
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: $user
cn: $user
sn: $user
loginShell: /bin/bash
uidNumber: 10005
gidNumber: 10005
homeDirectory: /home/$user
userPassword: $pswuser
shadowMax: 60
shadowMin: 1
shadowWarning: 7
shadowInactive: 7
shadowLastChange: 0

dn: cn=users,ou=groups,$olcsuffix
objectClass: posixGroup
cn: users
gidNumber: 10005
memberUid: $user
EOF

ldapadd -Y EXTERNAL -H ldapi:/// -f users.ldif

cat > sudoersou.ldif << EOF
dn: ou=SUDOers,$olcsuffix
objectclass: organizationalunit
ou: SUDOers
description: devopslab SUDO Entry
EOF
ldapadd -Y EXTERNAL -H ldapi:/// -f sudoersou.ldif

export SUDOERS_BASE="ou=SUDOers,$olcsuffix"
echo $SUDOERS_BASE

cat > modified-sudoer2ldif.ldif << EOF
dn: cn=defaults,ou=SUDOers,$olcsuffix
objectClass: top
objectClass: sudoRole
cn: defaults
description: SUDO via LDAP
sudoOption: !visiblepw
sudoOption: always_set_home
sudoOption: match_group_by_gid
sudoOption: always_query_group_plugin
sudoOption: env_reset
sudoOption: env_keep =  "COLORS DISPLAY HOSTNAME HISTSIZE KDEDIR LS_COLORS"
sudoOption: env_keep += "MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE"
sudoOption: env_keep += "LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES"
sudoOption: env_keep += "LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE"
sudoOption: env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"
sudoOption: env_keep+=SSH_AUTH_SOCK
sudoOption: secure_path = /sbin:/bin:/usr/sbin:/usr/bin

dn: cn=sudo,ou=SUDOers,$olcsuffix
objectClass: top
objectClass: sudoRole
cn: sudo
sudoUser: $user
sudoHost: ALL
sudoRunAsUser: ALL
sudoCommand: ALL
EOF

ldapadd -Y EXTERNAL -H ldapi:/// -f modified-sudoer2ldif.ldif

bind=$(slappasswd -s $psw_bind) 

cat > bindDNuser.ldif << EOF
dn: ou=system,$olcsuffix
objectClass: organizationalUnit
objectClass: top
ou: system

dn: cn=readonly,ou=system,$olcsuffix
objectClass: organizationalRole
objectClass: simpleSecurityObject
cn: readonly
userPassword: $bind
description: Bind DN user for LDAP Operations
EOF

ldapadd -Y EXTERNAL -H ldapi:/// -f bindDNuser.ldif

#SSSD
echo "127.0.0.1   $url" >> /etc/hosts

dnf install sssd sssd-tools -y
cat > /etc/sssd/sssd.conf << EOF
[sssd]
services = nss, pam, sudo
config_file_version = 2
domains = default

[sudo]

[nss]

[pam]
offline_credentials_expiration = 60

[domain/default]
ldap_id_use_start_tls = True
cache_credentials = True
ldap_search_base = $olcsuffix
id_provider = ldap
auth_provider = ldap
chpass_provider = ldap
access_provider = ldap
sudo_provider = ldap
ldap_uri = ldap://$url
ldap_default_bind_dn = cn=readonly,ou=system,$olcsuffix
ldap_default_authtok = $psw_bind
ldap_tls_reqcert = demand
ldap_tls_cacert = /etc/pki/tls/ldapserver.crt
ldap_tls_cacertdir = /etc/pki/tls
ldap_search_timeout = 50
ldap_network_timeout = 60
ldap_sudo_search_base = ou=SUDOers,$olcsuffix
ldap_access_order = filter
ldap_access_filter = (objectClass=posixAccount)
EOF

#openssl s_client -connect $url:636 -showcerts < /dev/null | openssl x509 -text

echo "BASE    $olcsuffix"  >> /etc/openldap/ldap.conf
echo "URI     ldaps://$url:636" >> /etc/openldap/ldap.conf
echo "SUDOERS_BASE    ou=SUDOers,$olcsuffix" >> /etc/openldap/ldap.conf

authselect select sssd --force

echo "sudoers:    files sss" >> /etc/nsswitch.conf

dnf install oddjob-mkhomedir
systemctl enable --now oddjobd

echo "session optional pam_oddjob_mkhomedir.so skel=/etc/skel/ umask=0022" >> /etc/pam.d/system-auth
systemctl restart oddjobd
chmod 600 -R /etc/sssd

echo "@reboot /etc/openldap/ssh_psw_auth.sh" >> /var/spool/cron/root
cat > /etc/openldap/ssh_psw_auth.sh << 'EOF'
#!/bin/bash
ssh_auth=$(grep 'PasswordAuthentication no' /etc/ssh/sshd_config)
[[ ! -z $ssh_auth ]] && sed -i ' s;PasswordAuthentication no;PasswordAuthentication yes;' /etc/ssh/sshd_config && systemctl restart sshd
EOF
chmod +x /etc/openldap/ssh_psw_auth.sh

systemctl enable --now sssd