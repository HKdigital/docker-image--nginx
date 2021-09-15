# ........................................................................ About

# This docker image contains an NGINX webserver and some standard
# configuration settings
# - Sets /etc/security/limits.conf
# - Sets /etc/sysctl.conf
#
# Jens Kleinhout
# hkdigital.nl

# ......................................................................... FROM

FROM hkdigital/debian-slim-2021a

MAINTAINER Jens Kleinhout "hello@hkdigital.nl"

# .......................................................................... ENV

# Update the timestamp below to force an apt-get update during build
ENV APT_SOURCES_REFRESHED_AT 2021-09-15_10h05

# ........................................................................ NGINX

#  Install nginx, keep existing config files
#
#  @see https://raphaelhertzog.com/
#         2010/09/21/debian-conffile-configuration-file-managed-by-dpkg/

RUN apt-get -qq update && \
    apt-get -o Dpkg::Options::="--force-confold" -qq -y \
    install nginx > /dev/null

# ............................................................ COPY /image-files

# Copy files and folders from project folder "/image-files" into the image
# - The folder structure will be maintained by COPY
#
# @note
#    No star in COPY command to keep directory structure
#    @see http://stackoverflow.com/
#        questions/30215830/dockerfile-copy-keep-subdirectory-structure

# Update the timestamp below to force copy of image-files during build
ENV IMAGE_FILES_REFRESHED_AT 2021-09-15_10h05

COPY ./image-files/ /

# ................................................................. EXPOSE PORTS

# @note the expose command does not publish the ports (documentation only)
EXPOSE 80 443
