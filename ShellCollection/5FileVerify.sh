#!/bin/bash

RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'

#Verificador de permisos de archivos pasados por parametro siendo una carpeta
type=""
perm=""
unsecure=("666" "777" "757" "733")

#Obtiene el tipo de archivo
function getType(){
	type=$(stat -c %F $1)
}

#obtiene los permisos
function getPermission(){
	perm=$(stat -c %a $1)
   	special_bit=$(echo "$perm" | cut -c1)

   	if [ "$special_bit" == "4" ]; then
        	echo -e "${RED}setuid${NC} activo"
   	elif [ "$special_bit" == "2" ]; then
        	echo -e "${RED}setgid${NC} activo"
    	elif [ "$special_bit" == "1" ]; then
        	echo -e "${RED}sticky bit${NC} activo"
   	else
        	echo -e "${GREEN}Sin permisos especiales${NC}"
    	fi
}

function checkFile(){
	echo "["$(date)"] Verificando $1..."
	getType $1
	if [[ $type == "fichero regular" ]]; then
		getPermission $1
		for param in "${unsecure[@]}"; do
			if [ "$perm" == "$param"  ]; then
				echo -e "${RED}[!] Archivo inseguro:${NC} $1 \n Tipo: $type \n Permisos: "$(stat -c %A $1
)" \n Usuario/Grupo Propietario: "$(stat -c "%U %G" $1)""
			fi
		done
	elif [[ $type == "directorio" ]]; then
		for i in $(find $1 -type f); do
			getPermission "$i"
			for j in "${unsecure[@]}"; do 
				if [ "$perm" == "$j" ]; then 
					echo -e "${RED}[!] Archivo inseguro:${NC} $i \n Permisos: "$(stat -c %A $i
)" \n Usuario/Grupo Propietario: "$(stat -c "%U %G" $i)""

				fi
			done
		done
	else
		echo -e "${RED}Fichero invalido, intenta de nuevo${NC}"
		exit
	fi
}

checkFile $1
