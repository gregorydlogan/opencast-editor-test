#!/bin/bash

# That is list the files of type directory whose name does not contain
# a non-digit. So we only process automated deployments.
# 
# Without LC_ALL=C, some find implementations, including GNU find could
# also list files whose name contains sequences of bytes that don't form
# valid characters in the current locale (like a répertoire encoded in
# iso8859-1 (mkdir $'r\xe9pertoire') in a locale that uses UTF-8 as charset).
DEPLOYMENTS=$(LC_ALL=C find . -maxdepth 1 ! -name '*[!0-9]*' -type d -printf '%P\n')

for instance in $DEPLOYMENTS
do
  if [ "OPEN" != "$(gh pr view $instance --repo $1 --json state -q '.state')" ]; then
    rm -rf $instance
  else
    #Keep the last two deploys for each instance that's still open
    find "$instance" -maxdepth 1 -mindepth 1 -type d -printf '%p\n' | sort -r | tail -n +3 | xargs rm -rf
  fi
done
