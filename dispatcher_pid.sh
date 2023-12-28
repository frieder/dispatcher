#!/bin/sh

#
# This script changes the uid/gid of the user "apache" to the values of the env variables PUID + PGID
# and then finds all files that belong to the old ID and changes ownership back to apache:apache. This is
# needed as otherwise files e.g. in /var/log/apache2 will be created with ID=100 which can cause issues
# on the host system.
#

set -e

OLD_PUID=$(id -u apache)
OLD_PGID=$(id -g apache)

NEW_PUID=${PUID:-1000}
NEW_PGID=${PGID:-1000}

if [ "$OLD_PUID" -ne "$NEW_PUID" ] || [ "$OLD_PGID" -ne "$NEW_PGID" ]; then
  echo "Updating apache ID from (${OLD_PUID}/${OLD_PGID}) to (${NEW_PUID}/${NEW_PGID})"
    apk --no-cache add shadow
    groupmod --gid ${PGID} apache
    usermod --uid ${PUID} --gid ${PGID} apache
    apk del shadow
    find / -maxdepth 5 -user "${OLD_PUID}" -not -path "/proc/*" -exec chown -R apache:apache {} \;
fi

sh /docker_entrypoint.sh "$@"
