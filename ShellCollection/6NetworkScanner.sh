#!/bin/bash

#networkScanner
path="./response.json"

#Carga el archivo a un servidor ftp publico
function SendJson(){
	#servidor ftp SOLO para pruebas
	local url="ftp.dlptest.com"
	local user="dlpuser"
	local pass="rNrKYTX9g7z3RgJRmxWuGHbeu"

	#lo sube al servidor
ftp -n "$url" <<EOF
quote USER "$user"
quote PASS "$pass"
binary
put "$1"
quit
EOF
    	if [ $? -eq 0 ]; then
        	echo "json cargado correctamente"
        	return 0
    	else
        	echo "Error al subir el json"
        	return 1
    	fi
}

#escanea la red haciendo un barrido de ping a toda la subred
function Scan() {
   	local result=$(nmap "$1")
   	declare -a blocks=()
   	local actualBlock=""
	local total=$(tail -n1 <<< "$result" | awk '{print $6}' | tr -d '(')

	#------Data-----#

	local host
	declare -a ports=()
	declare -a states=()
	declare -a services=()

   	#prepara el json
    	echo '{"scan_summary":{"network":"'"$1"'","date":"'"$(date)"'","total_hosts_up":"'"$total"'"},"hosts":[]}' | jq '.' > "$path"

    	# Guarda los parrafos en bloques para ser procesados y los almacena en un array
    	while IFS= read -r line; do
        	if [[ $line == Nmap\ scan\ report\ for* ]]; then
                	# Solo agregar si no esta vacio
            		if [[ -n "$actualBlock" ]]; then
                		blocks+=("$actualBlock")
            		fi
            		actualBlock="$line"
        	else
            		actualBlock+="\n$line"
        	fi
    	done <<< "$result"

    	if [[ -n "$actualBlock" ]]; then
        	blocks+=("$actualBlock")
    	fi

	#Convierte en un bloque cada ip escaneada
    	for i in "${!blocks[@]}"; do
		#procesa los bloques obteniendo la data como host, puertos etc.
		while read -r line; do
			local nmapLine port state service
			local openPortsJson=""
			ports=()
			states=()
			services=()
			#Si el escaneo no obtuvo resultado continua al siguiente bloque
			if ! echo "$line" | grep -qE '(PORT|STATE|SERVICE)'; then
    				continue
			fi
			host=$(echo "$line" | awk '{print $5}')
			#obtiene toda la linea de ese puerto, empezando desde el 5
			nmapLines=$(echo -e "$line" | awk 'NR >= 5 {print $0}')

			#agrega cada puerto del bloque al array
			while IFS= read -r nline; do
				port=$(echo "$nline" | awk '{print $1}')
				ports+=("$port")
			done <<< "$nmapLines"

			#igual, obtiene los states y los agrega al array
			while IFS= read -r nline; do
				state=$(echo "$nline" | awk '{print $2}')
				states+=("$state")
			done <<< "$nmapLines"

			#servicios
			while IFS= read -r nline; do
				service=$(echo "$nline" | awk '{print $3}')
				services+=("$service")
			done <<< "$nmapLines"

			echo -e "lineas de puertos: \n$nmapLine"
			#construye el subarray del json
			for i in "${!ports[@]}"; do
				p="${ports[$i]}"
    				s="${services[$i]}"
    				t="${states[$i]}"

    				#Si cualquiera de los 3 esta vacio lo salta
    				if [[ -z "$p" || -z "$s" || -z "$t" ]]; then
        				continue
    				fi
    				openPortsJson+=$(printf '{"port":"%s","state":"%s","service":"%s"},' "${ports[$i]}" "${states[$i]}" "${services[$i]}")
			done

			openPortsJson="[${openPortsJson%,}]"
			hostEntry=$(cat <<EOF
{
  "ip": "$host",
  "status": "up",
  "open_ports": $openPortsJson
}
EOF
)

			tmpfile=$(mktemp)
			jq --argjson newEntry "$hostEntry" \
   				'.hosts += [$newEntry]' "$path" > "$tmpfile" && mv "$tmpfile" "$path"

		done <<< "${blocks[i]}"
    	done
	SendJson "$path"
}

#Obtiene la direccion de red
echo "Escaneando subred, por favor espere..."
IP=$(ip -o -4 addr show up | awk 'NR == 2 { print $2, $4 }' | awk '{print $2}')
Network=$(ipcalc $IP | awk 'NR == 2 {print $2}')
Scan $Network



