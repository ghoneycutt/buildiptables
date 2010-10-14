#!/bin/bash
for host in $(ls hosts/)
do
    ./buildiptables $host
done
