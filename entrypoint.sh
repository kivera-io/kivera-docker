#!/bin/bash

export CERT_SUBJ="${CERT_SUBJ:-/C=AU/ST=NSW/L=Sydney/O=Kivera/OU=IT/CN=kivera.io}"
export LOCAL_MOUNT="${LOCAL_MOUNT:-/mnt/kivera}"
export LOCAL_CREDENTIALS="${LOCAL_CREDENTIALS:-$LOCAL_MOUNT/credentials.json}"
export LOCAL_CA="${LOCAL_CA:-$LOCAL_MOUNT/ca.pem}"
export LOCAL_CA_CERT="${LOCAL_CA_CERT:-$LOCAL_MOUNT/ca-cert.pem}"

if [[ ! -f "${LOCAL_CA}" || ! -f "${LOCAL_CA_CERT}" ]]; then
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
else
    export KIVERA_CA=$LOCAL_CA
    export KIVERA_CA_CERT=$LOCAL_CA_CERT
fi

if [[ ! -f "${LOCAL_CREDENTIALS}" ]]; then
    printf "%s" "${KIVERA_CREDENTIALS}" > /opt/kivera/etc/credentials.json
    export KIVERA_CREDENTIALS=/opt/kivera/etc/credentials.json
else
    export KIVERA_CREDENTIALS=$LOCAL_CREDENTIALS
fi

# Start custom logging process
/home/kivera/custom.sh &

# Start Kivera
kivera 2>&1 | tee -a "${KIVERA_LOGS_FILE}"
