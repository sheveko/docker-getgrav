#!/bin/bash

echo "Starting pseudo cronjob for grav"

while true
do
    sleep 60
    #echo "calling grav scheduler for jobs"
    cd /var/www/html
    bin/grav scheduler 1>> /dev/stdout 2>/dev/stderr
done