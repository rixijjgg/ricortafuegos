#!/bin/bash

while (( numero != 99 )); do
	echo -e "\e[94m---------------------------------------------\e[0m"
	echo -e "\e[91mMenú OCC Ver. 1.0.1  \e[0m"
	echo -e "\e[94m---------------------------------------------\e[0m"
	echo ""
	echo ""
	echo -e "\e[93m1. - Último login de un usuario\e[0m"
	echo -e "\e[93m11. - Mostrar número de accesos e IP de un usuario concreto\e[0m"
	echo -e "\e[93m12. - Crear un nuevo usuario\e[0m"
	echo -e "\e[93m13. - Borrar un usuario\e[0m"
	echo -e "\e[93m14. - Cambiar contraseña de usuario\e[0m"
	echo -e "\e[93m15. - Escanear archivos de owncloud manualmente:\e[0m"
	echo -e "\e[93m21. - Owncloud en modo mantenimiento\e[0m"
	echo -e "\e[93m22. - Oncloud salir de mantenimiento\e[0m"
	echo -e "\e[91m99. - Volver al menú principal\e[0m"

	read numero

	case "$numero" in

		1 ) clear;  	echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91mUsuarios disponibles:\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
				echo ""
				find /var/www/html/owncloud/data -maxdepth 1 -type d -name "*" -a ! -name "avatars" -a ! -name "files_external" -a ! -name "appdata_*" | cut -c29-100
				echo ""
				echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91mEscriba el nombre del usuario para visualizar el acceso: \e[0m"
				echo -e "\e[91m('cancelar' para volver al menú principal)\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"

				read nombre

        			if [ $nombre = 'cancelar' ]; then
                			clear;
        			else
                			echo -e "\e[92m---------------------------------------------\e[0m"
					sudo -u www-data php7.0 /var/www/html/owncloud/console.php user:lastseen $nombre
					echo -e "\e[92m---------------------------------------------\e[0m"
					sleep 5; clear
        			fi
		;;
		11 )     clear;  echo -e "\e[92m---------------------------------------------\e[0m"
                                echo -e "\e[91mUsuarios sobre los que puede consultar:\e[0m"
                                echo -e "\e[92m---------------------------------------------\e[0m"
                                find /var/www/html/owncloud/data -maxdepth 1 -type d -name "*" -a ! -name "avatars" -a ! -name "files_external" -a ! -name "appdata_*" | cut -c29-100
                                echo -e "\e[92m---------------------------------------------\e[0m"
                                echo -e "\e[93mEscriba el nombre del usuario para consultar accesos: \e[0m"
                                echo -e "\e[93m('cancelar' para volver al menú principal)\e[0m"
                                echo -e "\e[92m---------------------------------------------\e[0m"
                                read nombrea

                                if [ $nombrea = 'cancelar' ]; then
                                        clear
                                else
                                        echo -e "\e[92m---------------------------------------------\e[0m"
                                        echo "`grep $nombrea /var/log/apache2/access.log | awk '{print $1}' | sort -n | uniq -c | sort -nr | head -99`"
                                        echo -e "\e[92m---------------------------------------------\e[0m"
                                fi
                ;;


		12 ) clear;	echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91mUsuarios existentes:\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
				find /var/www/html/owncloud/data -maxdepth 1 -type d -name "*" -a ! -name "avatars" -a ! -name "files_external" -a ! -name "appdata_*" | cut -c29-100
				echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[93mEscriba el nombre de login para el usuario: \e[0m"
				echo -e "\e[93m('cancelar' para volver al menú principal)\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
				read nombre
				echo""
				echo -e "\e[93mAñada el usuario a un grupo:\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
				read grupo

				echo -e "\e[93mEscriba una dirección de correo electrónico:\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
				read correo

				echo -e "\e[93mEscriba el nombre real del usuario\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
				read real

        			if [ $nombre = 'cancelar' ]; then
                			clear;
        			else
                			echo -e "\e[92m---------------------------------------------\e[0m"
					sudo -u www-data php7.0 /var/www/html/owncloud/console.php user:add --display-name="$real" --email $correo --group="$grupo" $nombre
					echo -e "\e[92m---------------------------------------------\e[0m"
					sleep 5; clear;
        			fi
		;;

		13 ) clear;  	echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91mUsuarios existentes:\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
				find /var/www/html/owncloud/data -maxdepth 1 -type d -name "*" -a ! -name "avatars" -a ! -name "files_external" -a ! -name "appdata_*" | cut -c29-100
				echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[93mEscriba el nombre del usuario a eliminar: \e[0m"
				echo -e "\e[93m('cancelar' para volver al menú principal)\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
				read nombre
     				if [ $nombre = 'cancelar' ]; then
                			clear
				else
					echo -e "\e[92m---------------------------------------------\e[0m"
					sudo -u www-data php7.0 /var/www/html/owncloud/console.php user:delete $nombre
					echo -e "\e[92m---------------------------------------------\e[0m"
					sleep 3; clear

				fi

		;;
		14 ) clear;  	echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91mUsuarios existentes:\e[0m"
				echo -e "\e[93m(Cancelar) para volver al menú\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
				find /var/www/html/owncloud/data -maxdepth 1 -type d -name "*" -a ! -name "avatars" -a ! -name "files_external" -a ! -name "appdata_*" | cut -c29-100

				read nombre
     				if [ $nombre = 'cancelar' ]; then
                			clear
        			else
					echo -e "\e[92m---------------------------------------------\e[0m"
					sudo -u www-data php7.0 /var/www/html/owncloud/console.php user:resetpassword $nombre
					echo -e "\e[92m---------------------------------------------\e[0m"
					sleep 3; clear

        			fi

		;;
		15 )     clear; echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[93mUsuarios administrables:\e[0m"
                                echo -e "\e[92m---------------------------------------------\e[0m"
				find /var/www/html/owncloud/data -maxdepth 1 -type d -name "*" -a ! -name "avatars" -a ! -name "files_external" -a ! -name "appdata_*" | cut -c29-100
				echo -e "\e[92m---------------------------------------------\e[0m"
                                echo -e "\e[93mEscriba el nombre del usuario cuyos archivos serán reescaneados:\e[0m"
                                echo -e "\e[93m('cancelar' para volver al menú principal)\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
                                read nombre

                                if [ $nombre = 'cancelar' ]; then
                                        clear
                                else
                                        echo -e "\e[92m---------------------------------------------\e[0m"
					sudo -u www-data php7.0 /var/www/html/owncloud/console.php files:scan $nombre
					echo -e "\e[92m---------------------------------------------\e[0m"
                                        sleep 5; clear
                                fi
                ;;

		21 )     clear; echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91mSe va a proceder a ACTIVAR el modo mantenimiento\e[0m"
                                echo -e "\e[93m¿Desea continua? (S/N)\e[0m"
                                echo -e "\e[92m---------------------------------------------\e[0m"
				read mantenia
                                if [ $mantenia = 'S' ] || [ $mantenia = 's' ]; then
                                        echo -e "\e[92m---------------------------------------------\e[0m"
					sudo -u www-data php7.0 /var/www/html/owncloud/console.php maintenance:mode --on
                                        echo -e "\e[92m---------------------------------------------\e[0m"
					sleep 2; clear
                                else
                                        clear
                                fi

                ;;

		22 )	clear; 	echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91mSe va a proceder a DESACTIVAR el modo mantenimiento\e[0m"
                               	echo -e "\e[93m¿Desea continua? (S/N)\e[0m"
                               	echo -e "\e[92m---------------------------------------------\e[0m"
				read mantenid
                               	if [ $mantenid = 'S' ] || [ $mantenid = 's' ]; then
                               		echo -e "\e[92m---------------------------------------------\e[0m"
					sudo -u www-data php7.0 /var/www/html/owncloud/console.php maintenance:mode --off
                                	echo -e "\e[92m---------------------------------------------\e[0m"
					sleep 2; clear
                                else
                                        clear
                                fi
                ;;



		99 ) 	clear;
		;;
		*) 	clear;  echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91mSeleccione una opción válida\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
		;;

	esac

done

exit 0
