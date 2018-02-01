#!/bin/bash

eid="$"

while [ 1 ]; do
    rep=`redis-cli --csv XREAD BLOCK 0 STREAMS temps $eid`
    IFS=',' read -ra arr <<< "$rep"

    # Extract fields
    eid=${arr[1]#\"}
    eid=${eid%-*}
    hid=${arr[3]#\"}
    hid=${hid%\"}
    cpu=${arr[5]#\"}
    cpu=${cpu%\"}
    bat=${arr[7]#\"}
    bat=${bat%\"}
    now=`date +%s`

    echo "temps.$hid.cpu $cpu $now" | nc -c localhost 2003
    echo "temps.$hid.bat $bat $now" | nc -c localhost 2003
    echo "Consumed raw stream $eid $hid $cpu $bat"
done
