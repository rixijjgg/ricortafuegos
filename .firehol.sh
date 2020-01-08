#!/bin/bash

cd /etc/ricortafuegos

echo -e "\e[91mSuspendiendo servicio web\e[0m"
/etc/init.d/apache2 stop


echo -e "\e[91mDescargando listas \e[0m"
wget https://iplists.firehol.org/files/dm_tor.ipset https://iplists.firehol.org/files/tor_exits_1d.ipset https://iplists.firehol.org/files/firehol_level1.netset https://iplists.firehol.org/files/firehol_level2.netset https://iplists.firehol.org/files/firehol_level3.netset

rm .ips.txt
rm .ips2.txt

echo -e "\e[91mListas antiguas borradas\e[0m"

sed -e '/192.168.0.0/d; /#/d; /10.0.0.0/d; /127.0.0.0/d' firehol_level1.netset >> .ips.txt
sed '/#/d' firehol_level2.netset >> .ips.txt
sed '/#/d' firehol_level3.netset >> .ips.txt
sed '/#/d' dm_tor.ipset >> .ips.txt
sed '/#/d' tor_exits_1d.ipset >> .ips.txt
cat negra.txt >> .ips.txt
cat desconocidas.txt >> .ips.txt
echo -e "\e[91mCreadas las nuevas listas\e[0m"

cat .ips.txt | sort | uniq > .ips2.txt

##borrar archivos descargados
rm firehol_level*
rm dm_tor.ipset*
rm tor_exits*


##sacar la regla que queremos detener mientras se ejecute el script
grep ipblock.sh /etc/crontab > /etc/ricortafuegos/regla.tmp
### borrar la regla a eliminar temporalmente
sed '/ipblock.sh/d' /etc/crontab > /etc/ricortafuegos/crontab.tmp

rm /etc/crontab

###mantener el crontab activo pero sin la regla ipblock
cp /etc/ricortafuegos/crontab.tmp /etc/crontab
echo -e "\e[91mLa programación de ricortafuegos se interrumpirá hasta que la tarea termine\e[0m"

echo -e "\e[91mIntroduciendo reglas nuevas en el cortafuegos\e[0m"
iptables -F

for IPI in `cat .ips2.txt`
        do
#         echo $IPI
                iptables -I INPUT -s $IPI -j DROP

        done

###reincorporar el antiguo fichero crontab sin la regla
echo "`cat /etc/ricortafuegos/crontab.tmp`" > /etc/crontab
###reincorporar la regla temporalmente anulada durante la ejecucion
echo "`cat /etc/ricortafuegos/regla.tmp`" >> /etc/crontab

###borrar archivos de apoyo
rm /etc/ricortafuegos/crontab.tmp
rm /etc/ricortafuegos/regla.tmp

echo -e "\e[91mServidor Protegido, Se restaurará la programación anterior para ricortafuegos\e[0m"

echo -e "\e[91mReiniciando servicio web\e[0m"
/etc/init.d/apache2 restart

exit 0

