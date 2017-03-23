#!/bin/bash

cleanup()
{
	pkill -KILL -f "/usr/bin/ruby /usr/bin/puma -p 8080 -t 1:1 -e production"
}
trap "cleanup; exit" INT QUIT TERM EXIT

# Fix up permissions to point to new uid/gid of mersdk
mkdir -p /home/deploy/installroot
chown -R mersdk.mersdk /home/deploy/installroot
chown -R mersdk.mersdk /srv/mer/targets/*
find /home/mersdk | grep -v "/home/mersdk/share" | xargs chown mersdk.mersdk

# Run web server of build engine as mersdk in background:
su mersdk -c "cd /usr/lib/sdk-webapp-bundle; /usr/bin/ruby /usr/bin/puma -p 8080 -t 1:1 -e production" &

# Run SSH Server of build engine as root:
/usr/sbin/sshd -p 2222 -D -e -f /etc/ssh/sshd_config_engine
