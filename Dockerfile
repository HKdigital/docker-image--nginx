# ........................................................................ About
#
# @see README at https://github.com/HKdigital/docker-image--nginx
#

# ......................................................................... FROM

FROM hkdigital/debian-slim

MAINTAINER Jens Kleinhout "hello@hkdigital.nl"

# .......................................................................... ENV

# Update the timestamp below to force an apt-get update during build
ENV APT_SOURCES_REFRESHED_AT 2023-05-22_10h50

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
ENV IMAGE_FILES_REFRESHED_AT 2023-05-22_10h50

COPY ./image-files/ /

# ................................................................. EXPOSE PORTS

# @note the expose command does not publish the ports (documentation only)
EXPOSE 80 443
