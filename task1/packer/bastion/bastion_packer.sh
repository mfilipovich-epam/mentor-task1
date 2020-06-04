#!/bin/bash

#PHPadminldap
#yum update -y
dnf install -y  git php php-cgi php-mbstring php-common php-pear php-{gd,json,zip} php-ldap
setenforce 0
sed -i 's@enforcing@disabled@' /etc/selinux/config

git clone https://github.com/breisig/phpLDAPadmin.git /usr/share/phpldapadmin
cp /usr/share/phpldapadmin/config/config.php.example /usr/share/phpldapadmin/config/config.php

sudo sed -i '286 s@My@devopsldap@' /usr/share/phpldapadmin/config/config.php
sudo sed -i '293 s@// $servers@$servers@' /usr/share/phpldapadmin/config/config.php
sudo sed -i "293 s@127.0.0.1@$ldapserv_ip@" /usr/share/phpldapadmin/config/config.php
sudo sed -i '300 s@// $servers@$servers@' /usr/share/phpldapadmin/config/config.php
sudo sed -i "300 s@''@'$olcsuffix'@" /usr/share/phpldapadmin/config/config.php

chown -R apache:apache /usr/share/phpldapadmin

sudo cat > /etc/httpd/conf.d/phpldapadmin.conf << EOF
Alias /phpldapadmin /usr/share/phpldapadmin/htdocs

<Directory /usr/share/phpldapadmin/htdocs>
  <IfModule mod_authz_core.c>
    Require all granted
  </IfModule>
</Directory>
EOF

systemctl enable --now httpd

#SSSD
echo "$ldapserv_ip   $url" >> /etc/hosts

dnf install sssd sssd-tools -y
sudo cat > /etc/sssd/sssd.conf << EOF
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
ldap_tls_cacert = /etc/pki/tls/cacert.crt
ldap_tls_cacertdir = /etc/pki/tls
ldap_search_timeout = 50
ldap_network_timeout = 60
ldap_sudo_search_base = ou=SUDOers,$olcsuffix
ldap_access_order = filter
ldap_access_filter = (objectClass=posixAccount)
EOF

#openssl s_client -connect $url:636 -showcerts < /dev/null | openssl x509 -text

cp /tmp/ldapserver.crt  /etc/pki/tls/cacert.crt
chown root:root /etc/pki/tls/cacert.crt
chmod 644 /etc/pki/tls/cacert.crt

echo "BASE    $olcsuffix"  >> /etc/openldap/ldap.conf
echo "URI     ldaps://$url:636" >> /etc/openldap/ldap.conf
echo "SUDOERS_BASE    ou=SUDOers,$olcsuffix" >> /etc/openldap/ldap.conf
echo "TLS_CACERT      /etc/pki/tls/cacert.crt"  >> /etc/openldap/ldap.conf

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
[[ ! -z $ssh_auth ]] && sed -i ' s@PasswordAuthentication no@PasswordAuthentication yes@' /etc/ssh/sshd_config && systemctl restart sshd
EOF
chmod +x /etc/openldap/ssh_psw_auth.sh

systemctl enable --now sssd