#!/bin/bash

declare logPath="./ping_logs.log"

function testIP(){
local target="$1"
	#Valida la IP/Dominio ingresado
	if echo "$target" | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$|^[A-Za-z0-9.-]+\.(com|net|mx|org)$'; then
		result=$(ping -c 4 "$target" | awk 'NR==8')
		send=$(echo "$result" | awk -F',' '{print $1}' | awk '{print $1}')
		sent=$(echo "$result" | awk -F',' '{print $2}' | awk '{print $1}')
		lost=$(echo "$result" | awk -F',' '{print $3}' | awk '{print $1}')
		echo '['$(date)'] Host: '$target'  - Enviados: '$send' - Recibidos: '$sent' - Perdidos: '$lost' ' >> $logPath
		if [ $lost != "%0" ] ; then
			echo "Posible problema de red con $target"
		fi

	else
		echo "No es una IP ni un dominio valido, por favor intenta nuevamente."
		exit
	fi 
}


#Crea el log
if [ ! -f $logPath ]; then
    touch $logPath
fi

testIP "$1"

