#!/bin/bash -fuh
#
sleep 10
for ((i=1; i<=$USER_COUNT; i++))
do
  useradd user${i}
  echo -n $USER_PASSWORD| passwd user${i} --stdin
done
