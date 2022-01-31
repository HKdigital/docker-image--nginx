
# About

The image generated by this project can be used to run an NGINX server.

The docker image contains default configurations for different setups. The default configuration that is installed is `webserver`.

An interesting configuration is `spa-with-prerender` for public websites. This requires an additional docker container for the prerendering. See the examples folder for more details.

# Usage

## Just try it out (using docker-compose)

Below an example of using the image in a docker-compose file.

In the `/examples` folder, you'll find more `docker-files` for the different setups.

```yaml
version: "3.9"

services:
  website:
    image: hkdigital/nginx-2021a   # docker-hub
    # image: hkdigital-nginx-2021a   # local
    
    restart: always # "no"|always|on-failure|unless-stopped

    ports:
      # Let docker choose port numbers on the host
      # - "80"

      # host-port -> container port
      - "1080:80"

    volumes:
      - ./volumes:/mnt # contains: webroot, config, certificates, log, media
```

### Check NGINX config and reload NGINX when ok

Using the container script

```
docker-compose exec website /srv/check-nginx-config-and-reload.sh
```

This can be done manually too

```bash
docker-compose exec website nginx -t -c /@config/nginx.conf
docker-compose exec website nginx -s reload
```

# Build locally

Clone the latest commit from github into a local working directory

```bash
git clone --depth 1 \
  git@github.com:hkdigital/docker-images--nginx-2021a.git \
  hkdigital-nginx-2021a
```

Build the docker image

```bash
./build-latest-image.sh
docker image ls
# Shows hkdigital-nginx-2021a
```

## Extra: push to docker hub

This is a generic instruction to push your images to `docker hub`. You must setup a (free) docker hub account and create the repository.

```bash
docker tag <existing-image> <hub-user>/<repo-name>[:<tag>]
docker push <hub-user>/<repo-name>:<tag>
```

e.g.

```bash
docker tag hkdigital-nginx-2021a hkdigital/nginx-2021a
docker push hkdigital/nginx-2021a
```

# Buy me a coffee

If you like my work, please support me:

https://www.buymeacoffee.com/hkjens
