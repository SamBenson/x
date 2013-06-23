#!/bin/bash
domain=$1;

includeWWW="n";
echo -e "Include www alias? (y/N) \c ";
read includeWWW;

defaultLocation="y"
echo -e "Use default location? (Y/n) \c ";
read defaultLocation;

if [ "${defaultLocation}" == "n" ]; then
	echo -e "Enter location: \c "
	read newLocation;
fi

defaultDir="y";
echo -e "Create default directory structure? (Y/n) \c ";
read defaultDir;

if ! grep "${domain}" /etc/apache2/sites-enabled >> /dev/null; then
	if [ "${defaultLocation}" == "n" ]; then
		path="${newLocation}/${domain}"
	else
		path="/var/www/${domain}"
	fi

	if [[ ! -e ${path} ]]; then
		if [ "${defaultDir}" == "n" ]; then
			mkdir ${path};
		else
			git clone https://github.com/SamBenson/compass-boilerplate.git ${path};
		fi
	fi

	if [[ "${includeWWW}" == "y" ]]; then
		serverAlias="ServerAlias www.${domain}"
	else
		serverAlias=""
	fi

        echo "
### ${domain}
<VirtualHost *:80>
        DocumentRoot ${path}
        ServerName ${domain}
	${serverAlias}
        <Directory ${path}>
                allow from all
                Options +Indexes
        </Directory>
</VirtualHost>" >> /etc/apache2/sites-enabled/${domain}

	echo "Testing configuration"
	apache2ctl configtest
	q="y";

	echo -e "Would you like me to restart the server? (Y/n) \c "
        read q

	if [ "${q}" != "n" ]; then
		service apache2 reload
	fi

	echo -e "Want to get started? (Y/n) \c "
        read q

        if [ "${q}" != "n" ]; then
                cd ${path} && guard
        fi

fi
