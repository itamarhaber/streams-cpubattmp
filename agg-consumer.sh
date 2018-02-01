#!/bin/bash

eid="$"

while [ 1 ]; do
    rep=`redis-cli --csv XREAD BLOCK 0 STREAMS aggtemps $eid`
    IFS=',' read -ra arr <<< "$rep"

    # Extract fields
    eid=${arr[1]#\"}
    eid=${eid%-*}
    hid=${arr[3]#\"}
    hid=${hid%\"}
    cpu=${arr[5]#\"}
    cpu=${cpu%\"}
    cpu=$(printf "%.2f" "$cpu")
    bat=${arr[7]#\"}
    bat=${bat%\"}
    bat=$(printf "%.2f" "$bat")
    now=`date +%s`

    echo "temps.$hid.avgcpu $cpu $now" | nc -c localhost 2003
    echo "temps.$hid.avgbat $bat $now" | nc -c localhost 2003
    echo "Consumed aggregate stream $eid $hid $cpu $bat"
done
