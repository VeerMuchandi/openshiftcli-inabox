#!/bin/bash -fuh
#
sleep 10
for i in {01..$USER_COUNT}
do
  useradd user${i}
  echo -n $USER_PASSWORD| passwd user${i} --stdin
done
