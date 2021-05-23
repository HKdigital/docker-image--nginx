
## About

  The image generated by this project can be used as to run an NGINX server or as base image for other Docker images.

  Jens Kleinhout
  HKdigital

# Usage

## Run a website

See the `/examples` folder.

## Use the image locally

### Clone the repository

```bash
git clone --depth 1 git@bitbucket.org:hkdigital/hkdigital-nginx-2021a.git
```

### Build docker image locally

```bash
./build-latest-image.sh
```

## Howto

### What does this container do?

When you run a container that was created from this image, by default it will run the command "sleep infinity".

So the container runs a never ending process, that does nothing.

If you want to do something more useful, you should specify a COMMAND to execute.

### How does it work?

E.g. the following command runs a container

    docker run --rm hkdigital-nginx-2021a

This command will run the script [/srv/boot.sh] inside the container, which in turn will execute the script [/srv/run.sh].

By default run.sh will execute the command `sleep infinity`.

Press ctrl-c to quit

## Use cases (docker-compose)

### Run using docker-compose

Below an example of using the image in a docker-compose file. More examples can be found in the `/examples` folder.

```yaml
version: "3"

services:
  website:
    image: hkdigital-nginx-2021a     # local
    # image: hkdigital/nginx-2021a   # docker-hub
    
    restart: on-failure # "no"|always|on-failure|unless-stopped

    ports:
      # Let docker choose port numbers on the host
      # - "80"

      # host-port -> container port
      - "10080:80"

    volumes:
      - website:/mnt

volumes:
  website:
```

### Run bash in a running container

Run the following command to run [bash] inside the container

```
docker-compose exec webserver bash
```

### CHeck NGINX config and reload NGINX when ok

Using the container script

```
docker-compose exec website /srv/check-nginx-config-and-reload.sh
```

### Manually check NGINX config in a running container

```bash
docker-compose exec website nginx -t -c /@config/nginx.conf
```

### Manually reload NGINX in a running container

```bash
docker-compose exec website nginx -s reload
```
