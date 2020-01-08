#!/bin/bash
ricortafuegos=/etc/ricortafuegos

if [ -d "$ricortafuegos" ]; then

	echo -e "\e[91mATENCIÓN el programa ya está instalado en su sistema. ¿Desea borrar los ficheros y volver a instalar?\e[0m"
	echo -e "\e[93m¿Desea continua? (S/N)\e[0m"
        read decide
	        if [ $decide = 'S' ] || [ $decide = 's' ]; then
####borramos los archivos anteriores:

			rm /bin/admin.sh
			rm /bin/adminocc.sh
			rm /bin/adminric.sh
			rm /bin/firehol.sh
			rm /bin/desconocidasreboot.sh
			rm /bin/ipblock.sh
			rm /bin/registros.sh
			rm -R /etc/ricortafuegos/
			iptables -F
#####Borramos también las entradas de crontab:
			sed -e '/ipblock.sh/d; /registros.sh/d; /desconocidasreboot.sh/d' /etc/crontab > .crontab.tmp
##borramos el crontab de sistema:
			rm /etc/crontab
##copiamos el crontab sin las entradas anteriores
			cp .crontab.tmp /etc/crontab
			rm .crontab.tmp
#####Copiamos los archivos nuevos y ejecutamos el script de .ipblock:

                	cp .admin.sh /bin/admin.sh
			cp .adminocc.sh /bin/adminocc.sh
			cp .adminric.sh /bin/adminric.sh
			cp .firehol.sh /bin/firehol.sh
			cp .desconocidasreboot.sh /bin/desconocidasreboot.sh
			./.ipblock.sh

			echo -e "\e[93mPrograma instalado con éxito\e[0m"

			exit 0

                else
                	clear
			echo -e "\e[93mNingún cambio realizado\e[0m"
			exit 1

                fi


else

	echo -e "\e[93mNo se han encontrado archivos anteriores. Instalación en curso\e[0m"
	cp .admin.sh /bin/admin.sh
        cp .adminocc.sh /bin/adminocc.sh
        cp .adminric.sh /bin/adminric.sh
        cp .firehol.sh /bin/firehol.sh
        cp .desconocidasreboot.sh /bin/desconocidasreboot.sh
        ./.ipblock.sh
	echo -e "\e[93mEl programa se ha instalado con éxito\e[0m"
	exit 2

fi
