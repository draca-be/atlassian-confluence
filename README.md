# 

[![Docker Pulls](https://img.shields.io/docker/pulls/draca/atlassian-confluence.svg)](https://hub.docker.com/r/draca/atlassian-confluence/)
[![Build Status](https://img.shields.io/docker/build/draca/atlassian-confluence.svg)](https://hub.docker.com/r/draca/atlassian-confluence/builds/)
[![Docker Stars](https://img.shields.io/docker/stars/draca/atlassian-confluence.svg)](https://hub.docker.com/r/draca/atlassian-confluence/)

This image enables you to run [Atlassian Confluence](https://www.atlassian.com/software/confluence).

It is based on [alpine-java](https://hub.docker.com/r/anapsix/alpine-java/) to provide an as small as possible image.

# Notice

In order to set up the autogeneration of images the repositories had to be restructured meaning that if you were using the old (application)-X.Y.Z style tags they are now obsolete, you should switch to the X.Y.Z style tags.

# Versions

There are tags available for latest, latest major, latest minor and individual versions. If for example you want to run the latest 6.8 version, you can use draca/atlassian-confluence:6.8

# Autogeneration

The images are autogenerated as soon as they appear for download on the Atlassian website. This means that sometimes things might break, be aware of this and as always test in staging environments first.

You can find the script that generates these in the [atlassian-generator](https://github.com/draca-be/atlassian-generator) repository. Feel free to create pull requests to that repository if you want to make improvements either to the script or the Dockerfile templates. Please do not make pull requests against this repository as they will be ignored.

# Environment variables

A number of environment variables are supported.

## Run as non-root

By default the application runs as a non-root user. You can influence which user by setting these variables. Note that the names need to be known inside the container so results might not be what you expect.

* RUN_USER
* RUN_GROUP

## Run behind a proxy

If you are running the application behind a reverse proxy you need to set these variables so that it knows where to redirect requests to.

* CONF_PROXY_NAME : the hostname (for example confluence.mycompany.com)
* CONF_PROXY_PORT : the port (for example 80 or 443)
* CONF_PROXY_SCHEME : either http or https
* CONF_CONTEXT_PATH : if the application isn't running on the root path (for example mycompany.com/confluence: set this to confluence)

## Disable mail

If you want to disable the incoming and outgoing mail on for example a staging server set DISABLE_NOTIFICATIONS to TRUE

## Memory

Change the default JVM memory size

* JVM_MINIMUM_MEMORY
* JVM_MAXIMUM_MEMORY

## Additional JVM args

If you need to pass additional args you can set the CONF_ARGS variable.

## Timezone

You can set the CONTAINER_TZ variable to set the default timezone in your container. Confluence inherits this if it is configured to use the system default.

# Self-signed certificates

The bane of every Atlassian Expert their existence! But fear no longer as this image can automatically import the certificates into the key database. It searches for files ending with .crt in /opt/atlassian/jira/certs so just mount a volume and Bob's your uncle.

If you don't know how to get the certificates here's a simple one-liner fetching the certificate from Google, replace the domain with the one you want to import from.

```
openssl s_client -connect google.com:443 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > google-public.crt
```

# Volumes

If you want to mount a volume or a directory to store your data outside of the container you should mount it over /opt/atlassian/confluence/data

# Usage

Example:

    docker run -it --rm -p 8090:8090 draca/atlassian-confluence

A very quick docker-compose file could be:

```
version: '3'
services:
  confluence:
    image: draca/atlassian-confluence
    environment:
      - DISABLE_NOTIFICATIONS=TRUE
      - CONF_ARGS=-Datlassian.plugins.enable.wait=300
    volumes:
      - ./data:/opt/atlassian/confluence/data
    ports:
      - 8090:8090
    restart: always

  confluencedb:
    image: postgres:9.6
    environment:
      - POSTGRES_PASSWORD=secret
      - POSTGRES_USER=confluence
      - POSTGRES_DB=confluence
    volumes:
      - ./db:/var/lib/postgresql/data
    restart: always
```

# Disclaimer

A lot of care was taking in creating these images however running them is at your own risk and no claims can be made should data loss occur. By using these images you confirm that you are complying by any and all of the licenses of the 3rd party software included in this build.