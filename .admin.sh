#!/bin/bash
 

while (( numero != 99 )); do

	echo -e "\e[94m---------------------------------------------\e[0m"
	echo -e "\e[91mMenú de administrador Ver. 1.0.1 \e[0m"
	echo -e "\e[94m---------------------------------------------\e[0m"
	echo ""
	echo -e "\e[93m6. - Comandos OCC\e[0m"
	echo -e "\e[93m7. - Ricortafuegos\e[0m"
	echo -e "\e[91m99. - Salir \e[0m"

	read numero

	case "$numero" in

		
		6) 	clear;	adminocc.sh

		;;
		7) 	clear;	adminric.sh 

		;;

		8)      clear;  

                ;;

		99) 	clear;	echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91mEs posible que necesite reiniciar algunos servicios pertinentes.\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
		;;
		* ) 	clear; 	echo -e "\e[92m---------------------------------------------\e[0m"
				echo -e "\e[91mSeleccione una opción válida.\e[0m"
				echo -e "\e[92m---------------------------------------------\e[0m"
		;;

	esac

done
echo -e "\e[92m---------------------------------------------\e[0m"
echo -e "\e[91mHasta pronto.\e[0m"
echo -e "\e[92m---------------------------------------------\e[0m"
exit 0
