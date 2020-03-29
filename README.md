# Docker image for the fast, simple and flexible file-based web-platform [Grav](https://getgrav.org/)

Originally, this image is based on [riftbit/getgrav](https://hub.docker.com/r/riftbit/getgrav) but using [php:7.4-apache](https://hub.docker.com/_/php) as the base image.

GitHub repository: [sheveko/docker-getgrav](https://github.com/sheveko/docker-getgrav)

## Volumes

The container has two mappings for external volumes:

- `/var/www/html` where the main installation lives
- `/usr/local/etc/php/conf.d` for php-settings

## Startup

Start this image with

    docker run \
        --publish 127.0.0.1:8080:80 \
        --volume grav_html:/var/www/html \
        sheveko/getgrav
