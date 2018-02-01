#!/bin/bash

# Do `gem install iStats` before
istats="istats --value-only"

while [ 1 ]; do
    cpu=`$istats cpu temp`
    bat=`$istats battery temp`

    id=`redis-cli --raw --eval aggregator.lua temps aggtemps , id $HOSTNAME cpu $cpu bat $bat`  

    echo "Produced and processed $id $cpu $bat"
done
