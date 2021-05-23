#!/bin/bash

CERTIFICATES_FOLDER=/@certificates
CERT_NAME="self-signed"
CERT_BASE_PATH="${CERTIFICATES_FOLDER}/${CERT_NAME}"

REQ_FILE_PATH="/tmp/${CERT_NAME}.pem"
SUBJECT="/C=NL/ST=Gelderland/L=Ophemert/O=ACME/OU=IT/CN=*"
DAYS=3650

if [ -d "${CERTIFICATES_FOLDER}" ] && [ ! -f "${CERT_BASE_PATH}.key" ];
then
  echo "- Creating self signed certificate in folder [${CERTIFICATES_FOLDER}]"

  echo "- Creating certificate key..."

  openssl ecparam \
          -out "${CERT_BASE_PATH}.key" \
          -name secp384r1 \
          -genkey

  echo "- Creating certificate request..."

  openssl req -new \
          -key "${CERT_BASE_PATH}.key" \
          -out "${REQ_FILE_PATH}" \
          -sha256 \
          -subj "${SUBJECT}"

  echo "- Sign certificate request and ..."

  echo "- Create signed certificate..."

  openssl x509 \
          -trustout \
          -signkey "${CERT_BASE_PATH}.key" \
          -days "${DAYS}" \
          -req -sha256 \
          -in "${REQ_FILE_PATH}" \
          -out "${CERT_BASE_PATH}.crt"

  echo "- Remove certificate request file..."

  rm "${REQ_FILE_PATH}"
elif [ ! -d "${CERTIFICATES_FOLDER}" ];
then
  echo
  echo "! Cannot create self signed certificate."
  echo "  Folder [${CERTIFICATES_FOLDER}] does not exist."
else
  echo
  echo "- Skip creation of self signed certificate (already exists)."
fi