#!/bin/bash

cat <<"EOF"

by M0rPH3U53
      
EOF

# Couleur ASSCI
BLEU='\033[34m'
ROUGE='\033[0;31m'
VERT='\033[0;32m'
GRIS='\033[0;90m'
RESET='\033[0m'
BLANC='\033[1;37m'
JAUNE='\033[0;33m'

echo -ne "${BLEU}[i]${RESET} ${BLANC}Nom:${RESET} "
read name
echo " "

# Cree dossier
mkdir -p ONVIF

# Recupere adresse réseau + CIDR
IP=$(ip route show | grep -E '^[0-9]' | head -1 | awk '{print $1}')

echo " "
echo -e "${VERT}[+]${RESET} ${BLANC}Réseau disponible${RESET} "
echo " "
echo "${IP}"
echo " "

# Interface réseau
echo -ne "${BLEU}[i]${RESET} ${BLANC}Network:${RESET} "
read network

# Découverte réseau d'appareil WS-Discover
echo -ne "🔍 ${BLANC}Scan WS-Discover${RESET}..."
urls=$(nmap -sU -sC -p 3702 --open ${network} | grep Address | grep -v MAC | awk '{print $3}')
echo -e "${JAUNE}100%${RESET}"

# Verifie si la variable est vide
if [ -z "${urls}" ]; then
    echo "❌ Aucun appareil WSD"
    exit 1
fi

# Chemin du fichier
dir=$(pwd)

echo " "
echo -e "${VERT}[+]${RESET} ${BLANC}Camera${RESET}"
echo " "
echo " "

# Recupere les info systeme de camera
for url in ${urls}; do
    echo "🎥 ${url}"
    curl -sS -X POST "${url}" \
        -H "Content-Type: application/soap+xml; charset=utf-8" \
        -H 'SOAPAction: "http://www.onvif.org/ver10/device/wsdl/GetDeviceInformation"' \
        --data-binary @- <<'EOF' > ${dir}/ONVIF/cameye-${name}.xml
<?xml version="1.0" encoding="UTF-8"?>
<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope"
              xmlns:tds="http://www.onvif.org/ver10/device/wsdl">
  <env:Body>
    <tds:GetDeviceInformation/>
  </env:Body>
</env:Envelope>
EOF
done

echo " "
echo -e "${VERT}[+]${RESET} Sauvegardé --> "${dir}"/ONVIF"
