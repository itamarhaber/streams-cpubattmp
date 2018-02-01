#!/bin/bash

istats="istats --value-only"

while [ 1 ]; do
    cpu=`$istats cpu temp`
    bat=`$istats battery temp`

    id=`redis-cli --raw XADD temps "*" id $HOSTNAME cpu $cpu bat $bat`

    echo "Produced $id $cpu $bat"
done
