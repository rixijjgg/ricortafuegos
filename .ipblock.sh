#!/bin/bash

####Instalador////

ricortafuegos=/etc/ricortafuegos
if [ ! -d "$ricortafuegos" ]; then

	echo -e "\e[91mRicortafuegos será instalado en /etc/ricortafuegos\e[0m"
	mkdir /etc/ricortafuegos
	mkdir /etc/ricortafuegos/registros_almacenados
	cp .ipblock.sh /bin/ipblock.sh
	cp .registros.sh /bin/registros.sh
	touch /etc/ricortafuegos/blanca.txt
	touch /etc/ricortafuegos/negra.txt
	touch /etc/ricortafuegos/.ips.txt
	touch /etc/ricortafuegos/.ips2.txt
####programamos un menú para añadir nuestro script al crontab de sistema

	while (( correcto != 99 )); do
		echo -e "\e[93m¿Cada cuantos minutos desea que se ejecute?\e[0m"
		read minutos
		if (( $minutos < 1 )) || (( $minutos > 59 )); then
			echo -e "\e[93mescriba un número válido\e[0m"

		else
			echo "*/$minutos * * * *       root    /bin/ipblock.sh" >> /etc/crontab
			echo "50 23 * * *       root    /bin/registros.sh" >> /etc/crontab
			echo "@reboot       root    /bin/desconocidasreboot.sh" >> /etc/crontab
			correcto=99
		fi

	done
	while (( correcto1 != 99 )); do
               	echo -e "\e[93mEscribe tu token de ipinfo.io\e[0m"
               	read token
               	echo "$token" > /etc/ricortafuegos/.token.txt
		correcto1=99

       	done

##Añadimos las reglas de borrado de paises, para ello usamos una expresión regular:
	echo -e "\e[93mEscribe en MAYÚSCULA las dos primeras iniciales de los paises con acceso permitido a tu servidor\e[0m"
        read regla
	regex='^[A-Z]{2}([\ ][A-Z]{2})*$'
	while ! [[ $regla =~ $regex ]]; do
                echo -e "\e[93mEntrada inválida mira este ejemplo:\e[0m"
                echo -e "\e[91mES RU USA\e[0m"
                echo -e "\e[93mPrueba de nuevo:\e[0m"
                read regla
        done

        for b in $regla; do
                echo -n "/'$b'/d;" >> /etc/ricortafuegos/.regla.tmp
        done

        echo -n "`cat /etc/ricortafuegos/.regla.tmp`" | sed -e 's/.$//' > /etc/ricortafuegos/.regla.tmp2
        rm /etc/ricortafuegos/.regla.tmp
        sed "s/^/sed -ie '/" /etc/ricortafuegos/.regla.tmp2 | sed "s/$/' comparador.tmp9/" > /etc/ricortafuegos/.regla1.txt
        sed "s/^/sed -ie '/" /etc/ricortafuegos/.regla.tmp2 | sed "s/$/' comparador.tmp8/" > /etc/ricortafuegos/.regla2.txt
        sed "s/^/sed -ie '/" /etc/ricortafuegos/.regla.tmp2 | sed "s/$/' comparador.tmp7/" > /etc/ricortafuegos/.regla3.txt
        rm /etc/ricortafuegos/.regla.tmp2

###mail para avisos de error
	echo -e "\e[93mEscriba un email para que ricortafuegos le avise si ocurre algún problema (es necesario tener instalado mutt)\e[0m"
	read mail
	echo "$mail" > /etc/ricortafuegos/.mail.txt
	echo -e "\e[93mEscriba un nombre que identifique a su equipo:\e[0m"
	read equipo
	echo "$equipo" > /etc/ricortafuegos/.equipo.txt
	echo -e "\e[93mLa instalación se ha completado, el programa se ejecutará cada $minutos minutos\e[0m"
	exit 0

fi
################################
##########FIN DEL INSTALADOR/////////////
cd /etc/ricortafuegos/

comparador=/etc/ricortafuegos/comparador.txt
desconocidas=/etc/ricortafuegos/desconocidas.txt
token=`cat /etc/ricortafuegos/.token.txt`
echo -e "\e[91mIniciando programa\e[0m"

###La ultima parte del sed quita los espacios en blanco que causan problemas
echo "`cat /var/log/apache2/access.log | awk '{print $1}' | sort -n | uniq -c | sort -nr | head -99`" | awk '{print $2}' | sed -e '/192.168.1./d; /^ *$/d' > accesos.txt
#echo "`cat /var/log/apache2/access.log | awk '{print $1}' | sort -n | uniq -c | sort -nr | head -99`" | awk '{print $2}' | sed '/192.168.1./d' > accesos.txt

#############DE LOS ACCESOS BORRAMOS LAS ENTRADAS DE LA LISTA BLANCA
#####
for g in `cat accesos.txt`
                do
                        for h in `grep $g /etc/ricortafuegos/blanca.txt`
                                do
                                        sed -i '/'$h'/d' /etc/ricortafuegos/accesos.txt
                                done
                done  


#####################

###saber si hay accesos
com=`ls -l accesos.txt | awk '{print $5}'`
if [ $com -lt 4 ]; then

	echo -e "\e[93mNo hay accesos por ahora.\e[0m"

        exit 1

fi

####si hay accesos comprobamos si existen registros anteriores
if [ ! -s "$comparador" ] && [ ! -s "$desconocidas" ]; then
	echo -e "\e[93mComprobando accesos:\e[0m"
###comprobamos con nuestra API y sacamos el pais
	for IP in `cat accesos.txt`
        	do
		echo $IP
                curl -s -u $token: ipinfo.io/$IP | grep country | cut -c15-16 >> pais.tmp
                done
####Ahora, ponemos el pais junto a su IP
	paste -d : pais.tmp accesos.txt > comparador.txt
####borramos el archivo de apoyo
	rm pais.tmp
	rm accesos.txt
####Quitamos las IPS que pertenecen a España y guardamos en un nuevo archivo persistente para que solo queden las extranjeras
	cp comparador.txt comparador.tmp9
	cat .regla1.txt | bash 
	cat comparador.tmp9 | awk -F ':' '{ print $2 }' > desconocidas.txt
	rm comparador.tmp9*
#####Si tras borrar los accesos de España, desconocidas queda vacio el programa termina de lo contrario cortafuegos
	if [ ! -s "$desconocidas" ]; then
		 echo -e "\e[93mLos accesos cumplen las reglas, no se bloqueará nada.\e[0m"
		exit 2
	else
		echo -e "\e[93mBloqueando IPs:\e[0m"
                        for IP1 in `cat desconocidas.txt`
                                do
                                        echo $IP1
                                        iptables -I INPUT -s $IP1 -j DROP

                                done
		exit 3

	fi
fi
#########Ahora debemos tomar en cuenta que desconocidas puede no tener contenido y comparador si

if [ -s "$comparador" ] && [ -s "$desconocidas" ]; then

####sacamos las ips que ya se han comprobado anteriormente sin el país
	echo "`cat comparador.txt`" | awk -F ':' '{ print $2 }' > comparador.tmp
	echo -e "\e[93mLas IPs serán comparadas con las existentes:\e[0m"
###copiamos también los accesos para trabajar con un fichero temporal
	cp accesos.txt accesos.tmp
########buscamos coincidencias entre accesos y comparador y borramos las mismas de comparador para dejar solo los nuevos accesos.
	for a in `cat accesos.tmp`
		do
			for b in `grep $a /etc/ricortafuegos/comparador.tmp`
				do
					sed -i '/'$b'/d' /etc/ricortafuegos/accesos.tmp
				done
		done
####si accesos queda vacío entonces no tenemos nada nuevo y salimos
	acctmp=`ls -l /etc/ricortafuegos/accesos.tmp | awk '{print $5}'`
	if [ $acctmp -lt 4 ]; then
		echo -e "\e[93mNo hay accesos nuevos.\e[0m"
####BORRAMOS FICHEROS ANTES DE SALIR
		rm comparador.tmp
		rm accesos.*
		exit 4
###si accesos tiene contenido entonces.....
	else
###sacamos los paises de las direcciones nuevas
		 echo -e "\e[93mGeolocalizando nuevos accesos:\e[0m"
		for IP2 in `cat accesos.tmp`
                do
		echo $IP2
                curl -s -u $token: ipinfo.io/$IP2 | grep country | cut -c15-16 >> pais.tmp
                done
####Ahora, ponemos el pais junto a su IP
        paste -d : pais.tmp accesos.tmp > comparador.tmp2
##borramos la parte que no nos interesa del fichero (El país) y las ips con origen en España para dejar una lista de IPs desconocidas
###TANTO EL COMPARADOR COMO LAS IPS DESCONOCIDAS SON ARCHIVOS TEMPORALES PARA NO VOLVER A INTRODUCIR DATOS QUE YA ESTABAN EN EL CORTAFUEGOS
	cp comparador.tmp2 comparador.tmp8 
	cat .regla2.txt | bash
	cat comparador.tmp8| awk -F ':' '{ print $2 }' > desconocidas.tmp
	rm comparador.tmp8
		###Comprobamos si desconocidas.tmp ha quedado vacío
		destmp=/etc/ricortafuegos/desconocidas.tmp
        	if [ ! -s "$destmp" ]; then
                	echo -e "\e[93mTodos los accesos cumplen las reglas.\e[0m"
###acumulamos el comparador
			cat comparador.tmp2 >> comparador.txt
#######borramos los archivos temporales	
			rm comparador.tm*
			rm pais*
			rm accesos*
			rm desconocidas.tmp
                	exit 5
		else
		###Si no ha quedado vacio metemos en el cortafuegos solo ips nuevas
			echo -e "\e[93mBloqueando IPs:\e[0m"
                        for IP3 in `cat desconocidas.tmp`
                                do
                                        echo $IP3
                                        iptables -I INPUT -s $IP3 -j DROP

                                done
###acumulamos datos en archivos persistentes
			cat comparador.tmp2 >> comparador.txt
			cat desconocidas.tmp >> desconocidas.txt
###borramos los archivos temporales
			rm comparador.tm*
                        rm pais*
                        rm accesos*
                        rm desconocidas.tmp
			exit 6

		fi


	fi


fi

#### si el comparador está vacío pero desconocidas no, es porque hemos perdido datos
### procedemos a avisar al administrador del sistema

if [ ! -s "$comparador" ] && [ -s "$desconocidas" ]; then
	mail=`cat /etc/ricortafuegos/.mail.txt`
	equipo=`cat /etc/ricortafuegos/.equipo.txt`
	echo -e "\e[93m¡¡¡¡¡¡¡ Se ha perdido el comparador !!!!!\e[0m"
	echo -e "\e[93m¡¡¡¡¡¡¡ Se requiere la atención del administrador ¡¡¡¡¡¡¡¡\e[0m"
#####Avisamos por correo al admin para avisar de que se requiere su atención
	echo "Ricortafuegos ha perdido las referencias del comparador, se requiere la atención del administrador" | mutt -s "$equipo: ricortafuegos" $mail
	exit 7
fi

if [ -s "$comparador" ] && [ ! -s "$desconocidas" ]; then
####sacamos las ips que ya se han comprobado anteriormente sin el país
        echo "`cat comparador.txt`" | awk -F ':' '{ print $2 }' > comparador.tmp
        echo -e "\e[93mLas IPs serán comparadas con las existentes:\e[0m"
###copiamos también los accesos para trabajar con un fichero temporal
        cp accesos.txt accesos.tmp
########buscamos coincidencias entre accesos y comparador y borramos las mismas de comparador para dejar solo los nuevos acceso$
        for c in `cat accesos.tmp`
                do
                        for d in `grep $c /etc/ricortafuegos/comparador.tmp`
                                do
                                        sed -i '/'$d'/d' /etc/ricortafuegos/accesos.tmp
                                done
                done
####si accesos queda vacío entonces no tenemos nada nuevo y salimos
        acctmp1=/etc/ricortafuegos/accesos.tmp
        if [ ! -s "$acctmp1" ]; then
                echo -e "\e[93mNo hay accesos nuevos.\e[0m"
###borramos temporales
		rm accesos*
		rm comparador.tm*
                exit 8
###si accesos tiene contenido entonces.....
        else
###sacamos los paises de las direcciones nuevas
###sacamos los paises de las direcciones nuevas
                for IP4 in `cat accesos.tmp`
                do
		echo $IP4
                curl -s -u $token: ipinfo.io/$IP4 | grep country | cut -c15-16 >> pais.tmp
                done
####Ahora, ponemos el pais junto a su IP
        paste -d : pais.tmp accesos.tmp > comparador.tmp2
##borramos la parte que no nos interesa del fichero (El país) y las ips con origen en España para dejar una lista de I$
###TANTO EL COMPARADOR COMO LAS IPS DESCONOCIDAS SON ARCHIVOS TEMPORALES PARA NO VOLVER A INTRODUCIR DATOS QUE YA ESTA$
        cp comparador.tmp2 comparador.tmp7 
	cat .regla3.txt | bash
	cat comparador.tmp7 | awk -F ':' '{ print $2 }' > desconocidas.txt
	rm comparador.tmp7
######acumulamos en los archivos persistente
	cat comparador.tmp2 >> comparador.txt


###Comprobamos si desconocidas.tmp ha quedado vacío

                if [ ! -s "$desconocidas" ]; then
                        echo -e "\e[93mTodos los accesos cumplen las reglas.\e[0m"
			rm comparador.tm*
			rm accesos*
			rm pais*
                        exit 9
                else
                ###Si no ha quedado vacio metemos en el cortafuegos solo ips nuevas
                        echo -e "\e[93mBloqueando IPs:\e[0m"
                        for IP5 in `cat desconocidas.txt`
                                do
                                        echo $IP5
                                        iptables -I INPUT -s $IP5 -j DROP

                                done
			rm comparador.tm*
                        rm accesos*
                        rm pais*
                        exit 10

                fi


        fi


fi
