#!/bin/bash

export CERT_SUBJ="${CERT_SUBJ:-/C=AU/ST=NSW/L=Sydney/O=Kivera/OU=IT/CN=kivera.io}"

if [[ ! -f "${KIVERA_CA_CERT}" || ! -f "${KIVERA_CA}" ]]; then
    if [[ "${KIVERA_CA}" == "/opt/kivera/etc/ca.pem" ]]; then
        openssl ecparam -name prime256v1 -genkey -out /opt/kivera/etc/ca.pem
    else
        printf "%b" "${KIVERA_CA}" > /opt/kivera/etc/ca.pem
        export KIVERA_CA=/opt/kivera/etc/ca.pem
    fi
    if [[ "${KIVERA_CA_CERT}" == "/opt/kivera/etc/ca-cert.pem" ]]; then
        openssl req -new -x509 -key /opt/kivera/etc/ca.pem -out /opt/kivera/etc/ca-cert.pem -subj "${CERT_SUBJ}" -days 3652
    else
        printf "%b" "${KIVERA_CA_CERT}" > /opt/kivera/etc/ca-cert.pem
        export KIVERA_CA_CERT=/opt/kivera/etc/ca-cert.pem
    fi
fi

if [[ ! -f "${KIVERA_CREDENTIALS}" ]]; then
    printf "%s" "${KIVERA_CREDENTIALS}" > /opt/kivera/etc/credentials.json
    export KIVERA_CREDENTIALS=/opt/kivera/etc/credentials.json
fi

# Start custom logging process
/custom.sh &

# Start Kivera
"${KIVERA_PATH}"/kivera 2>&1 | tee -a "${KIVERA_LOGS_FILE}"
