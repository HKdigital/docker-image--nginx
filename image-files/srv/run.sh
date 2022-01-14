#!/bin/bash

#
# @note
#   This script should be set as "CMD" of "ENTRY_POINT" in your Dockerfile
#
# @note
#   dumb-init is already specified in the Dockerfile as ENTRYPOINT
#   Otherwise use: #!/usr/bin/dumb-init /bin/bash
#

echo
echo "Running [run.sh] from image [hkdigital-nginx-2021a]"
echo "- $(date)"

if [ -z "${INSTALL_DEFAULTS}" ]; then
  # Install default files for http webserver
  export INSTALL_DEFAULTS="webserver";
fi

echo "- Using INSTALL_DEFAULTS [${INSTALL_DEFAULTS}]"

INSTALL_FILES_CONFIG="/srv/install-files/configs/${INSTALL_DEFAULTS}"

INSTALL_FILES_CONFIG_DEFAULTS="/srv/install-files/configs-defaults"

INSTALL_FILES_WEBROOT="/srv/install-files/webroots/${INSTALL_DEFAULTS}"

echo
echo "General settings"

# ............................................................. GENERAL SETTINGS

USER="www-data"

echo "- Setting up user ${USER} and group id"

usermod -u 1000 "${USER}"
groupmod -g 1001 "${USER}"

ROOT_FOLDER="/mnt";

echo "- Using ROOT_FOLDER=${ROOT_FOLDER}"

if [ ! -d "${ROOT_FOLDER}" ]; then
  mkdir -p "${ROOT_FOLDER}"
fi

# ............................................................... WEBROOT FOLDER

echo
echo "Setting up WEBROOT folder"

if [ -z "${WEBROOT_FOLDER}" ]; then
  WEBROOT_FOLDER="${ROOT_FOLDER}/webroot"
fi

echo "- Using WEBROOT_FOLDER=${WEBROOT_FOLDER}"

if [ ! -d "${WEBROOT_FOLDER}" ]; then
  echo "- Creating folder [${WEBROOT_FOLDER}]"
  mkdir -p "${WEBROOT_FOLDER}"
fi

if [ "${INSTALL_DEFAULTS}" != "none" ];
then
  #
  # Copy missing files and folders from to WEBROOT_FOLDER
  #
  echo "- Copy missing files from [${INSTALL_FILES_WEBROOT}] to [${WEBROOT_FOLDER}]"

  # Copy webroot folder
  rsync --ignore-existing --archive --relative \
    "${INSTALL_FILES_WEBROOT}/./" "${WEBROOT_FOLDER}" > /dev/null 2>&1
fi

if [ -d "${WEBROOT_FOLDER}" ]; then
  echo "- Updating filesystem rights"

  chown -R "${USER}":"${USER}" "${WEBROOT_FOLDER}" > /dev/null 2>&1

  find ${WEBROOT_FOLDER}/ \
    -type f -writable -print0 | xargs -0 --no-run-if-empty chmod 0660

  find ${WEBROOT_FOLDER}/ \
    -type d -writable -print0 | xargs -0 --no-run-if-empty chmod 0770
fi

# ................................................................ CONFIG FOLDER

echo
echo "Setting up config folder"

if [ -z "${CONFIG_FOLDER}" ]; then
  CONFIG_FOLDER="${ROOT_FOLDER}/config"
fi

echo "- Using CONFIG_FOLDER=${CONFIG_FOLDER}"

if [ ! -d "$CONFIG_FOLDER" ]; then
  echo "- Creating folder [${CONFIG_FOLDER}]"
  mkdir -p "$CONFIG_FOLDER"
fi

if [ "${INSTALL_DEFAULTS}" != "none" ];
then
  #
  # Copy missing files and folders from to CONFIG_FOLDER
  #
  echo "- Copy missing files from [${INSTALL_FILES_CONFIG}] to [${CONFIG_FOLDER}]"

  # Copy config folder
  rsync --ignore-existing --archive --relative \
    "${INSTALL_FILES_CONFIG}/./" "${CONFIG_FOLDER}" > /dev/null 2>&1


  # Copy default config/include folder
  rsync --ignore-existing --archive --relative \
    "${INSTALL_FILES_CONFIG_DEFAULTS}/./" "${CONFIG_FOLDER}" > /dev/null 2>&1
fi

echo "- Updating filesystem rights"

chown -R "${USER}":"${USER}" "$CONFIG_FOLDER" > /dev/null 2>&1

find ${CONFIG_FOLDER}/ \
  -type f -writable -print0 | xargs -0 --no-run-if-empty chmod 0660

find ${CONFIG_FOLDER}/ \
  -type d -writable -print0 | xargs -0 --no-run-if-empty chmod 0770

# .......................................................... CERTIFICATES FOLDER

echo
echo "Setting up certificates folder"

if [ -z "${CERTIFICATES_FOLDER}" ]; then
  CERTIFICATES_FOLDER="${ROOT_FOLDER}/certificates"
fi

echo "- Using CERTIFICATES_FOLDER=${CERTIFICATES_FOLDER}"

if [ ! -d "$CERTIFICATES_FOLDER" ]; then
  echo "- Creating folder [${CERTIFICATES_FOLDER}]"
  mkdir -p "$CERTIFICATES_FOLDER"
fi

echo "- Updating filesystem rights"

chown -R "${USER}":"${USER}" "$CERTIFICATES_FOLDER" > /dev/null 2>&1

# ................................................................... LOG FOLDER

echo
echo "Setting up log folder"

if [ -z "${LOG_FOLDER}" ]; then
  LOG_FOLDER="${ROOT_FOLDER}/log"
fi

echo "- Using LOG_FOLDER=${LOG_FOLDER}"

if [ ! -d "$LOG_FOLDER" ]; then
  echo "- Creating folder [${LOG_FOLDER}]"
  mkdir -p "$LOG_FOLDER"
fi

echo "- Updating log folder filesystem rights"

chown -R "${USER}":"${USER}" "$LOG_FOLDER" > /dev/null 2>&1

find ${LOG_FOLDER}/ \
  -type f -writable -print0 | xargs -0 --no-run-if-empty chmod 0660

find ${LOG_FOLDER}/ \
  -type d -writable -print0 | xargs -0 --no-run-if-empty chmod 0770

# ................................................................. MEDIA FOLDER

echo
echo "Setting up media folder"

if [ -z "${MEDIA_FOLDER}" ]; then
  MEDIA_FOLDER="${ROOT_FOLDER}/media"
fi

echo "- Using MEDIA_FOLDER=${MEDIA_FOLDER}"

if [ ! -d "$MEDIA_FOLDER" ]; then
  echo "- Creating MEDIA_FOLDER folder [${MEDIA_FOLDER}]"
  mkdir -p "$MEDIA_FOLDER"
fi

echo "- Updating MEDIA_FOLDER filesystem rights"

chown -R "${USER}":"${USER}" "$MEDIA_FOLDER" > /dev/null 2>&1

find ${MEDIA_FOLDER}/ \
  -type f -writable -print0 | xargs -0 --no-run-if-empty chmod 0660

find ${MEDIA_FOLDER}/ \
  -type d -writable -print0 | xargs -0 --no-run-if-empty chmod 0770

ln -sf --no-target-directory "${MEDIA_FOLDER}" "/@media"

# .............................................. Create or update symbolic links

ln -sf --no-target-directory "${WEBROOT_FOLDER}" "/@webroot"
ln -sf --no-target-directory "${MEDIA_FOLDER}" "/@media"
ln -sf --no-target-directory "${CONFIG_FOLDER}" "/@config"
ln -sf --no-target-directory "${CERTIFICATES_FOLDER}" "/@certificates"
ln -sf --no-target-directory "${LOG_FOLDER}" "/@log"

# ............................................... CREATE SELF SIGNED CERTIFICATE

if [ "${INSTALL_DEFAULTS}" != "none" ];
then
  #
  # Generate self-signed certificates in CERTIFICATES_FOLDER if missing
  #

  echo
  echo "- Generate self-signed certificates in /@certificates (if missing)"

  /srv/create-self-signed-certificate.sh
fi

# .................................................................. START NGINX

echo
echo "Running NGINX"

CONFIG_FILE="${CONFIG_FOLDER}/nginx.conf"
CONFIG_RESULT=$(nginx -t -c "${CONFIG_FILE}" 2>&1)

if [[ "${CONFIG_RESULT}" =~ "failed" ]]; then
  echo
  echo "====> NGINX configuration error <===="
  echo
  echo "${CONFIG_RESULT}"
  echo
  echo "=> Failed to start NGINX -> sleep infinity"
  echo
  sleep infinity
fi

# echo "Test -> sleep infinity"
# sleep infinity

cd "${CONFIG_FOLDER}"

# /usr/sbin/nginx -t -c "${CONFIG_FOLDER}/nginx.conf"

exec /usr/sbin/nginx -c "${CONFIG_FILE}"
