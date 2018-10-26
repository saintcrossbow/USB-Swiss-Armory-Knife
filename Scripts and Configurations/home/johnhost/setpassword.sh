#!/bin/bash
# Create sample md5 to crack
if [ "$1" == "" ]; then
  echo "No password specified"
else
  echo -n $1 | md5sum | cut -d - -f 1 > target.txt
fi
