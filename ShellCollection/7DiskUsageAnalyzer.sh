#!/bin/bash


#Checa el espacio de los mounts donde envia una alerta si estan al limite

json="./response.json"
function Send(){
	local status=""
	local stamp=$(date -u +%Y-%m-%dT%H:%M:%S%Z)

	if [[ $1 -ge 90 ]]; then
		status="CRITICAL"
	elif [[ $1 -ge 70 ]]; then
		status="WARNING"
	fi

	#parsing a json
	jq -n \
 		--arg stamp "$stamp" \
 		--arg mount "$2" \
  		--arg usage "$1%" \
  		--arg status "$status" \
  		'{timestamp:$stamp, mount:$mount, usage:$usage, status:$status}' >> "$json"


	#envia al webhook
	code=$(curl -w "%{http_code}"  -X POST -H "Content-Type: application/json" -d "@json" https://webhook.url/...)
	if [ $code -eq 200 ]; then
		echo "Alerta recibida"
		return 0
	else
		echo "Error al enviar"
		return 1
	fi
}

while read -r line; do
	usage=$(echo "$line"| awk '{print $5}' | tr -d '%')
	mount=$(echo "$line" | awk '{print $6}')
	#obtiene el porcentaje y mount para poder enviarlos si es mayor a 7 como alert
	[[ $usage -ge 70 ]] && Send $usage "$mount"
done < <(df -h)
