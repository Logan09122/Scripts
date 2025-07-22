#!/bin/bash

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly RESET='\033[0m'
declare logPath='./process_failures.log'
actualProcess=""

#Comprueba si el servicio esta activo
function checkStatus(){
	#Cuando son comandos no llevan los corchetes
        if pgrep -x $actualProcess ; then
                return 0
        else 
             	return 1
        fi
}

#Crea el log si no existe
if [ ! -f $logPath ]; then
    touch $logPath
fi

while true; do
	#itera por cada uno de los argumentos 
	for param in $@; do
		actualProcess=$param
		if ! checkStatus ; then
			echo -e '['$(date)'] Proceso '$actualProcess' '${RED}NO ACTIVO${RESET}' \n' >> $logPath
		else
			echo -e "$actualProcess esta ${GREEN}ACTIVO${RESET}"
		fi
	done
	sleep 5
done 

