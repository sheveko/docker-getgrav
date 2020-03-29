#!/bin/bash
set -euo pipefail

if [[ "$1" == apache2* ]] || [ "$1" == php-fpm ]; then
	if [ "$(id -u)" = '0' ]; then
		case "$1" in
			apache2*)
				user="${APACHE_RUN_USER:-www-data}"
				group="${APACHE_RUN_GROUP:-www-data}"

				# strip off any '#' symbol ('#1000' is valid syntax for Apache)
				pound='#'
				user="${user#$pound}"
				group="${group#$pound}"
				;;
			*) # php-fpm
				user='www-data'
				group='www-data'
				;;
		esac
	else
		user="$(id -u)"
		group="$(id -g)"
	fi

	if [ ! -e /var/www/html/index.php ] && [ ! -e /var/www/html/bin/gpm ]; then

		echo >&2 "Grav not found in $PWD/html - copying now..."
		if [ -n "$(ls -A)" ]; then
			echo >&2 "WARNING: $PWD/html is not empty! (copying anyhow)"
		fi

        cp -rp /usr/src/grav-admin/. $PWD/html

        find $PWD/html -type f | xargs chmod 664
        find $PWD/html/bin -type f | xargs chmod 775
        find $PWD/html -type d | xargs chmod 775
        find $PWD/html -type d | xargs chmod +s

        # if the directory exists and Grav doesn't appear to be installed AND the permissions of it are root:root, let's chown it (likely a Docker-created directory)
		if [ "$(id -u)" = '0' ] && [ "$(stat -c '%u:%g' .)" = '0:0' ]; then
			chown -R "$user:$group" .
		fi

		echo >&2 "Complete! Grav has been successfully copied to $PWD/html"
	fi

    # START PSEUDO CRON
    /usr/local/bin/pseudo-cron.sh &

	# now that we're definitely done writing configuration, let's clear out the relevant envrionment variables (so that stray "phpinfo()" calls don't leak secrets from our code)
	for e in "${envs[@]}"; do
		unset "$e"
	done
fi

exec "$@"