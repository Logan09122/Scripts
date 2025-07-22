#!/bin/bash

#Practica 1
#Objectivo: un script que imprima cuantos archivos .sh .txt y .log hay
#en un directorio dado como parametro

#Output esperado:
#Archivos .sh: 3
#Archivos .log: 5
#Archivos .txt: 2

log=0
sh=0
txt=0

function calculate(){
	if [ -e $1 ]; then
		local result="$(find $1 -type f | grep -E '\.(log|sh|txt)$' | while read -r file; do basename "$file"; done )"
		for count in $result; do
			local ext="$(cut -d '.' -f2 <<< "$count")"
			if [ $ext == "log" ]; then
				((log++))
			elif [ $ext == "sh" ]; then
				((sh++))
			elif [ $ext == "txt" ]; then
				((txt++))
			fi
		done 
		echo "Archivos .sh: $sh"
		echo "Archivos .log: $log"
		echo "Archivos .txt: $txt"
	else
		echo "Usa un directorio valido"
		return 1
	fi
}

calculate $1
