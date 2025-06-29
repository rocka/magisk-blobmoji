#!/usr/bin/bash

set -euxo pipefail

REPO='https://github.com/DavidBerdik/blobmoji2'
TAG='blobmoji-16r3'
URL="${REPO}/releases/download/${TAG}/NotoColorEmoji.ttf"
SHA256='3f447e443c6114ca877d324061f3f31e696b14c5d3cef2c63b00a818bc63a58a'
OUT_DIR='system/fonts'
OUT_FILE="${OUT_DIR}/NotoColorEmoji.ttf"

if [[ ! -f "${OUT_FILE}" ]]
then
    echo 'downloading font file...'
    mkdir -p "${OUT_DIR}"
    curl -o "${OUT_FILE}" -L "${URL}"
fi

if ! sha256sum -c <<<"${SHA256}  ${OUT_FILE}"
then
    echo 'checksum mismatch'
    exit 1
fi

FILE_LIST=(
META-INF
system
module.prop
)

declare -A MODULE
MODULE=(
['id']=''
['name']=''
['version']=''
['versionCode']=''
['author']=''
)

mapfile -t LINES < module.prop
for LINE in "${LINES[@]}"
do
    IFS='=' read -r KEY VALUE <<< "${LINE}"
    MODULE["${KEY}"]="${VALUE}"
done

MODULE_FILE="${MODULE['id']}-${MODULE['version']}.zip"

if [[ -f "${MODULE_FILE}" ]]
then
    rm "${MODULE_FILE}"
fi
zip -r "${MODULE_FILE}" "${FILE_LIST[@]}"
