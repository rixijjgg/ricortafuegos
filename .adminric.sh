#!/bin/bash
clear;
cd /etc/ricortafuegos/
token=`cat /etc/ricortafuegos/.token.txt`
while (( numero != 99 )); do
echo -e "\e[94m---------------------------------------------\e[0m"
echo -e "\e[91mRICORTAFUEGOS Ver. 1.1.3 \e[0m"
echo -e "\e[94m---------------------------------------------\e[0m"
echo ""
echo ""
echo -e "\e[93m1. - Buscar un registro por fecha \e[0m"
echo -e "\e[93m2. - Ejecutar ricortafuegos ahora\e[0m"
echo -e "\e[93m3. - Mostrar IPs que intentaron conectar desde un país concreto \e[0m"
echo -e "\e[93m4. - Comprobar si una IP está siendo bloqueada\e[0m"
echo -e "\e[93m41. - Mostrar número de accesos por IP al servidor web en el día\e[0m"
echo -e "\e[93m5. - Añadir IP a la lista blanca\e[0m"
echo -e "\e[93m51. - Añadir múltiples IPs a la lista blanca\e[0m"
echo -e "\e[93m52. - Recargar reglas para lista blanca\e[0m"
echo -e "\e[93m6. - Añadir IP a la lista negra\e[0m"
echo -e "\e[93m61. - Añadir múltiples IPs a la lista negra\e[0m"
echo -e "\e[93m62. - Recargar reglas para lista negra\e[0m"
echo -e "\e[93m9. - Introducir una IP y geolocalizar\e[0m"
echo -e "\e[92m---------------------------------------------\e[0m"
echo -e "\e[93m10. - Ejecutar Firehol\e[0m"
echo -e "\e[92m---------------------------------------------\e[0m"
echo -e "\e[91m99. - Volver al menú principal\e[0m"

read numero

case "$numero" in

	1 ) 	clear;  	echo -e "\e[93mListado de registros:\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91m`ls /etc/ricortafuegos/registros_almacenados | cut -d "." -f1`\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[93mSeleccione una fecha para mostrar los accesos [dia][mes][año]\e[0m"
				echo -e "\e[93mejemplo 291219\e[0m"
				read fecha
				echo -e "\e[92m---------------------------------------------\e[0m"

				if [ -f /etc/ricortafuegos/registros_almacenados/$fecha.bk ]; then
					cat /etc/ricortafuegos/registros_almacenados/$fecha.bk
				echo -e "\e[92m---------------------------------------------\e[0m"
				else
					echo -e "\e[92m---------------------------------------------\e[0m"
					echo -e "\e[91mRegistro no encontrado\e[0m"
					echo -e "\e[92m---------------------------------------------\e[0m"
				fi
	;;

	2) 	clear;		ipblock.sh
	;;

	3) 	clear;		echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91mIntroduzca las dos primeras letras del país que desea consultar: \e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
			        read pais
			        regex='^[A-Z][A-Z]$'
        			while ! [[ $pais =~ $regex ]]; do
                			echo -e "\e[93mEntrada inválida mira este ejemplo:\e[0m"
					echo -e "\e[92m---------------------------------------------\e[0m"
                			echo -e "\e[91mES\e[0m"
                			echo -e "\e[92m---------------------------------------------\e[0m"
					echo -e "\e[93mPrueba de nuevo:\e[0m"
                			read pais
        			done
				bus=`grep $pais /etc/ricortafuegos/comparador.txt`
				if [ $? -gt 0 ]; then
					echo -e "\e[93m---- >> No hay entradas para $pais << ----\e[0m"
				else
					echo "$bus"
				fi
	;;

	4) 	clear;       	echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91mIntroduzca una dirección IP válida para saber si está siendo bloqueada por el cortafuegos\e[0m"
        			echo -e "\e[92m---------------------------------------------\e[0m"
				read comprueba
        			if [[ "$comprueba" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
                			iptables -nL | grep DROP | awk {'print $4'} | sort | uniq > /etc/ricortafuegos/comprueba.tmp

                			comprobador=/etc/ricortafuegos/comprueba.tmp
                			if [ -s $comprobador ]; then
                        			if [ `grep $comprueba /etc/ricortafuegos/comprueba.tmp` ]; then

                                			echo -e "\e[92m---------------------------------------------\e[0m"
							echo -e "\e[93m$comprueba está bloqueada por el cortafuegos \e[0m"
							echo -e "\e[92m---------------------------------------------\e[0m"
                        			else
                                			echo -e "\e[92m---------------------------------------------\e[0m"
							echo -e "\e[93m$comprueba no está bloqueada por el cortafuegos \e[0m"
                        				echo -e "\e[92m---------------------------------------------\e[0m"
						fi

                			else
                        			echo -e "\e[93mNo hay reglas en el cortafuegos \e[0m"
                			fi

        			else

                			echo -e "\e[92m---------------------------------------------\e[0m"
					echo -e "\e[91mIntroduzca una IP válida\e[0m"
        				echo -e "\e[92m---------------------------------------------\e[0m"
				fi
				rm $comprobador 2>> /dev/null
	;;

	41)     clear;  echo -e "\e[93mNúmero de accesos por IP:\e[0m"
			echo -e "\e[92m---------------------------------------------\e[0m"
               	        echo "`cat /var/log/apache2/access.log | awk '{print $1}' | sort -n | uniq -c | sort -nr | head -99`"
			echo -e "\e[92m---------------------------------------------\e[0m"
                ;;



	5) 	clear;		echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[93mEscriba una IP válida para introducir en la lista blanca\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
				read blanca

				if [[ "$blanca" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then

        				iptables -D INPUT -s $blanca -j DROP 2>> /dev/null
					if [ $? -lt 1 ]; then
						echo -e "\e[92m---------------------------------------------\e[0m"
						echo -e "\e[93mLa IP se encuentra en el cortafuegos, la regla será eliminada y añadida a la lista blanca\e[0m"
						echo -e "\e[92m---------------------------------------------\e[0m"
						sed -i '/'$blanca'/d' /etc/ricortafuegos/negra.txt
						sed -i '/'$blanca'/d' /etc/ricortafuegos/desconocidas.txt
					else
			 			echo -e "\e[92m---------------------------------------------\e[0m"
						echo -e "\e[93mLa IP no se encuentra en el cortafuegos, será añadida a la lista blanca\e[0m"
						echo -e "\e[92m---------------------------------------------\e[0m"
						sed -i '/'$blanca'/d' /etc/ricortafuegos/negra.txt
						sed -i '/'$blanca'/d' /etc/ricortafuegos/desconocidas.txt
					fi
						echo "$blanca" >> /etc/ricortafuegos/blanca.txt
						cat /etc/ricortafuegos/blanca.txt | sort | uniq  > /etc/ricortafuegos/blanca.tmp
						rm /etc/ricortafuegos/blanca.txt
						mv /etc/ricortafuegos/blanca.tmp /etc/ricortafuegos/blanca.txt
				else
  					echo -e "\e[92m---------------------------------------------\e[0m"
					echo -e "\e[91mIp no válida\e[0m"
					echo -e "\e[92m---------------------------------------------\e[0m"
				fi






	;;

	51)     clear;          nano /etc/ricortafuegos/blanca.tmp
                                clear
                                cat /etc/ricortafuegos/blanca.tmp >> /etc/ricortafuegos/blanca.txt
                                rm /etc/ricortafuegos/blanca.tmp
                                cat blanca.txt | sort | uniq > blanca.tmp
                                cat blanca.tmp | sort | uniq > blanca.txt
                                rm /etc/ricortafuegos/blanca.tm*
                                echo -e "\e[92m---------------------------------------------\e[0m"
                                echo -e "\e[93mEjecute ahora la actualización de la lista blanca (52) \e[0m"
                                echo -e "\e[92m---------------------------------------------\e[0m"

        ;;



	6) 	clear;		echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[93mEscriba una IP válida para introducir en la lista negra\e[0m"
	     			echo -e "\e[92m---------------------------------------------\e[0m"
				read negra

	        		if [[ "$negra" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then

					iptables -nL | grep DROP | awk {'print $4'} | sort | uniq > /etc/ricortafuegos/comprueba2.tmp

                			comprobador2=/etc/ricortafuegos/comprueba2.tmp
                			if [ -s $comprobador2 ]; then
                        			if [ `grep $negra /etc/ricortafuegos/comprueba2.tmp` ]; then

                                			echo -e "\e[92m---------------------------------------------\e[0m"
							echo -e "\e[93m$negra ya está bloqueada, se añadirá la IP a la lista negra pero no la regla al cortafuegos. \e[0m"
							echo -e "\e[92m---------------------------------------------\e[0m"
							sed -i '/'$negra'/d' /etc/ricortafuegos/blanca.txt

                        			else
                                			echo -e "\e[92m---------------------------------------------\e[0m"
							echo -e "\e[93m$negra no está bloqueada, Se añadirá la regla al cortafuegos y la IP a la lista negra  \e[0m"
							echo -e "\e[92m---------------------------------------------\e[0m"
							iptables -I INPUT -s $negra -j DROP 2>> /dev/null
							echo "$negra" >> /etc/ricortafuegos/negra.txt
							sed -i '/'$negra'/d' /etc/ricortafuegos/blanca.txt
                        			fi

                			else
                        			echo -e "\e[92m---------------------------------------------\e[0m"
						echo -e "\e[93mNo hay reglas en el cortafuegos \e[0m"
                			echo -e "\e[92m---------------------------------------------\e[0m"
					fi

        			else
					echo -e "\e[92m---------------------------------------------\e[0m"
                			echo -e "\e[91mIntroduzca una IP válida\e[0m"
					echo -e "\e[92m---------------------------------------------\e[0m"
        			fi

					cat /etc/ricortafuegos/negra.txt | sort | uniq  > /etc/ricortafuegos/negra.tmp
                        		rm /etc/ricortafuegos/negra.txt
                        		mv /etc/ricortafuegos/negra.tmp /etc/ricortafuegos/negra.txt
					rm $comprobador2 2>> /dev/null

	;;

	52) 	clear;		lb=/etc/ricortafuegos/blanca.txt
                                if [ ! -s $lb ]; then
                                	echo -e "\e[92m---------------------------------------------\e[0m"
					echo -e "\e[93mLista blanca vacía. No se realizarán cambios \e[0m"
					echo -e "\e[92m---------------------------------------------\e[0m"
                                else

                                      	echo -e "\e[93mDesbloqueando IPs:\e[0m"
					echo -e "\e[92m---------------------------------------------\e[0m"
                        		for IPZ in `cat /etc/ricortafuegos/blanca.txt`
                                		do
                                        	echo $IPZ
                                        	iptables -D INPUT -s $IPZ -j DROP 2>> /dev/null

                                		done
					echo -e "\e[92m---------------------------------------------\e[0m"
				fi


	;;
	61)     clear;		nano /etc/ricortafuegos/negra.tmp
				clear
				cat /etc/ricortafuegos/negra.tmp >> /etc/ricortafuegos/negra.txt
				rm /etc/ricortafuegos/negra.tmp
				cat negra.txt | sort | uniq > negra.tmp
				cat negra.tmp | sort | uniq > negra.txt
				rm /etc/ricortafuegos/negra.tm*
				echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[93mEjecute ahora la actualización de la lista negra (62) \e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"

				



	;;

	62) 	clear;		nb=/etc/ricortafuegos/negra.txt
                                if [ ! -s $nb ]; then
					echo -e "\e[92m---------------------------------------------\e[0m"
                                        echo -e "\e[93mLista negra vacía. No se realizarán cambios \e[0m"
					echo -e "\e[92m---------------------------------------------\e[0m"
                                else
					cat negra.txt | sort | uniq > /etc/ricortafuegos/negra.tmp
					iptables -nL | grep DROP | awk {'print $4'} | sort | uniq > /etc/ricortafuegos/iptables.tmp
					for g in `cat /etc/ricortafuegos/negra.tmp`
			                	do
                        				for h in `grep $g /etc/ricortafuegos/iptables.tmp`
                                				do
                                        				sed -i '/'$h'/d' /etc/ricortafuegos/negra.tmp
                                			done
                			done
				
					nbtmp=/etc/ricortafuegos/negra.tmp
				##quitamos lineas en blanco que molestan
					sed -ie '/^ *$/d' /etc/ricortafuegos/negra.tmp
					if [ ! -s $nbtmp ]; then
						echo -e "\e[92m---------------------------------------------\e[0m"
                                        	echo -e "\e[93mTodas las entradas de la lista negra ya se encuentan como reglas. No se añadirá nada \e[0m"
						echo -e "\e[92m---------------------------------------------\e[0m"
					else
						echo -e "\e[93mBloqueando IPs:\e[0m"
						echo -e "\e[92m---------------------------------------------\e[0m"
                        			for IPX in `cat /etc/ricortafuegos/negra.tmp`
                                			do
                                        			echo $IPX
                                        			iptables -I INPUT -s $IPX -j DROP 2>> /dev/null

                                			done
						echo -e "\e[92m---------------------------------------------\e[0m"
					fi
				fi
				rm /etc/ricortafuegos/iptables.tmp 2>> /dev/null
				rm $nbtmp 2>> /dev/null
				cat negra.txt | sort | uniq > negra.tmp 2>> /dev/null
                                cat negra.tmp | sort | uniq > negra.txt 2>> /dev/null
                                rm /etc/ricortafuegos/negra.tm* 2>> /dev/null
				sed -ie '/^ *$/d' /etc/ricortafuegos/negra.txt
				rm /etc/ricortafuegos/negra.txte 2>> /dev/null

	;;

	9)      clear;          echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[93mIntroduce la IP que quieres geolocalizar:\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
                                read geo

                                if [[ "$geo" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then

                                        curl -s -u $token: ipinfo.io/$geo
                                else
                                        echo -e "\e[92m---------------------------------------------\e[0m"
					echo -e "\e[91mIp no válida\e[0m"
                                echo -e "\e[92m---------------------------------------------\e[0m"
				fi






        ;;

	10)	clear;		echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91mVa a iniciar el proceso de descarga de listas | eliminación de reglas y adición de las nuevas.\e[0m"
                                echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[93mLa tarea puede llevar hasta 150 minutos para completarse.\e[0m"
                                echo -e "\e[93mDurante ese tiempo el servidor web estará suspendido:\e[0m"
                                echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[93m¿Desea continua? (S/N)\e[0m"
                                echo -e "\e[92m---------------------------------------------\e[0m"
				read tarea
                                if [ $tarea = 'S' ] || [ $tarea = 's' ]; then
                                        firehol.sh
                                else
                                        clear;
                                fi

	;;

	99)  	clear;     	echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[94m---------------------------------------------\e[0m"
				echo -e "\e[91mRICORTAFUEGOS Ver. 1.1.3 \e[0m"
				echo -e "\e[94m---------------------------------------------\e[0m"
				echo -e "\e[93mHasta pronto ;D\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"

	;;
	*) 	clear;  	echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91mSeleccione una opción válida\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
	;;
	esac

done

exit 0
