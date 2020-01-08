#!/bin/bash
cd /etc/ricortafuegos/
###ESTE SCRIPT SE EJECUTA DIARIAMENTE A LAS 23.50
##borramos las coincidencias anteriores
####sacamos las ips que ya se han comprobado anteriormente sin el país
echo "`cat /var/log/apache2/access.log | awk '{print $1}' | sort -n | uniq -c | sort -nr | head -99`" | awk '{print $2}' | sed '/192.168.1./d' > registros.tmp
###una vez borrado, copiamos nuestro archivo a los registros añadiendo la fecha:

dt=`date +%d%m%y`

cp registros.tmp /etc/ricortafuegos/registros_almacenados/$dt.bk

rm registros.tmp

exit 0
