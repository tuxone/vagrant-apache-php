#!/bin/bash

apache_config_file="/etc/apache2/envvars"
apache_vhost_file="/etc/apache2/sites-available/vagrant_vhost.conf"
php_config_file="/etc/php5/apache2/php.ini"
project_web_root="src"

# Update package lists

apt-get update

# Basic network

IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
sed -i "s/^${IPADDR}.*//" /etc/hosts
echo ${IPADDR} ubuntu.localhost >> /etc/hosts

# Basic tools

apt-get -y install git vim

# Install and confiugre Apache

apt-get -y install apache2

sed -i "s/^\(.*\)www-data/\1vagrant/g" ${apache_config_file}
chown -R vagrant:vagrant /var/log/apache2

if [ ! -f "${apache_vhost_file}" ]; then
	cat << EOF > ${apache_vhost_file}
<VirtualHost *:80>
    DocumentRoot /vagrant/${project_web_root}
    LogLevel debug

    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined

    <Directory /vagrant/${project_web_root}>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
fi

a2dissite 000-default
a2ensite vagrant_vhost

a2enmod rewrite

service apache2 reload
update-rc.d apache2 enable

# Install and confiugre PHP

apt-get -y install php5 php5-curl

sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" ${php_config_file}
sed -i "s/display_errors = Off/display_errors = On/g" ${php_config_file}

exit 0
