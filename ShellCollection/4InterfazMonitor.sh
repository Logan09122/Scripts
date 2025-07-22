#!/bin/bash

#Monitor de ancho de banda por interfaz de red
rx=""
tx=""

function getBytes(){
	local mbR
	local mbT
	while true; do
		rx=$(cat /proc/net/dev | grep "$1" | awk -F' ' '{print $2}')
		tx=$(cat /proc/net/dev | grep "$1" | awk -F' ' '{print $10}')
		rxMb=$(awk -v rx=$rx -v mb=$mbR 'BEGIN { mb = rx / 1024 / 1024; printf "%.2f", mb }')
		txMb=$(awk -v tx=$tx -v mb=$mbT 'BEGIN { mb = tx / 1024 / 1024; printf "%.2f", mb }')
		echo -e  "Interfaz: $1 \n ["$(date)"] RX: $rxMb mb/s | TX: $txMb mb/s"
		sleep 2
	done
}


getBytes $1










