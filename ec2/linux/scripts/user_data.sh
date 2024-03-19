#!/usr/bin/env bash

echo "Starting user_data.sh"

yum install -y sysstat
systemctl enable sysstat
systemctl start sysstat

yum install -y realmd sssd adcli samba-common-tools

echo "$(dig +short ${DOMAIN}) ${DOMAIN}" >> /etc/hosts

echo ${DOMAIN_ADMIN_PASSWORD} | realm join -v -U ${DOMAIN_ADMIN_USER} ${DOMAIN}

sed -i "/\[sssd\]/a default_domain_suffix = ${DOMAIN}" /etc/sssd/sssd.conf

sed -i s/"^PasswordAuthentication no"/"PasswordAuthentication yes"/g /etc/ssh/sshd_config
sed -i s/"^Allow"/"\#Allow"/g /etc/ssh/sshd_config

sed -i 's/auth required pam_wheel.so use_uid group=sugroup/#auth required pam_wheel.so use_uid group=sugroup/g' /etc/pam.d/su
echo "auth required pam_listfile.so onerr=fail item=group sense=allow file=/etc/login.group.allowed" >> /etc/pam.d/su
echo "%Domain\ Admins ALL=(ALL) ALL" >> /etc/sudoers

cat <<'EOF' >> /etc/login.group.allowed
root
wheel
Domain Admins@${DOMAIN}
EOF

systemctl restart sssd sshd

#additional:

${additional_user_data}


