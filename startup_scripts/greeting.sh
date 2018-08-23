#!/bin/bash

# Script to show 'Good morning', 'Good afternoon', 'Good evening' or
# 'Goodnight' on the basis of system time.
# Can safely delete this file, if it is unwanted.

time=`date +%H`

if [ $time -ge 4 -a $time -lt 12 ] ; then
    echo "Good morning, $USER"
elif [ $time -ge 12 -a $time -lt 16 ] ; then
    echo "Good afternoon, $USER"
elif [ $time -ge 16 -a $time -lt 21 ] ; then
    echo "Good evening, $USER"
elif [ $time -ge 21 -o $time -lt 4 ] ; then
    echo "Goodnight, $USER"
fi

