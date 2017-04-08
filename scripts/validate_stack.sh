#!/bin/sh

# Checks if ELK is up (last container in stack to start)

attempts=16
sleeptime=15

until curl -s --head "${HOST_IP}:9200";
do
  echo "Attempt ${attempts}..."

  if [ $attempts -eq 0 ]
  then
    break
  fi

  echo "Waiting ${sleeptime} more seconds to see if things are working..."

  sleep $sleeptime
  let attempts-=1
done
