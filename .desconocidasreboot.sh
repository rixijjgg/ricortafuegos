#!/bin/bash

cd /etc/ricortafuegos

sleep 90

for IPD in `cat desconocidas.txt`
        do
#         	echo $IPD
                iptables -I INPUT -s $IPD -j DROP

        done

exit 0
