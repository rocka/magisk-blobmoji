#!/usr/bin/bash

set -euxo pipefail

REPO='https://github.com/C1710/blobmoji'
TAG='v15.1-beta1'
URL="${REPO}/releases/download/${TAG}/Blobmoji.ttf"
SHA256='61b588efe9960443a89de442feeab863744dea9dd169cba08c66762eb4d6952b'
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
