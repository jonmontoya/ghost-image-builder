# Ghost Image Builder

This script configures and builds a docker image for ghost meant to be used with an external volume for persistent storage and automatic SSL certificate generation.

## Build Dependencies
- Docker 17.x.x - It may work with other versions, but is untested.
- jq

## Build an Image
Edit config.json for your site's url and your e-mail address. You can specify any valid ghost configuration options that would be in the [Ghost Configuration File](https://docs.ghost.org/docs/config#section-configuration-options) and they will be merged into the config in the container.

`config.json`

```json
{
  "url": "http://example.com",
  "mail": {
      "from": "'First Last' <name@example.com>"
  }
}

```

The script takes your desired image name as the argument. If you don't specify an image name the image name will fall back to a default image name. If your site is example.com then your default image name will be named example_com_ghost.

`./build_image.sh my_image_name:latest`

```bash
Building Ghost Docker Image
===========================
URL: http://example.com
EMAIL: name@example.com
DOMAIN_NAME: example.com
SSL: false
IMAGE_NAME: my_image_name:latest
===========================
Sending build context to Docker daemon  121.9kB
Step 1/31 : FROM alpine:3.5
 ---> 4a415e366388

[...]

Successfully built 0e242f18eb86
Successfully tagged my_image_name:latest
```

`docker images`

```
REPOSITORY                                                          TAG                 IMAGE ID            CREATED             SIZE
my_image_name:latest                                                latest              0e242f18eb86        About an hour ago   611MB
```

## SSL

If an https protocol is used in your url the produced container will use certbot to create your ssl certificate using the provided e-mail address. In order for this to work be sure that your domain name is pointing to the ip address your container is running from and that both ports 80 and 443 are exposed.

An auto renewal process will run every 12 hours to renew the certificate.  This process depends on your container being configured to auto restart.

## Persistent Storage

The container counts on having an external volume mounted in the container on `/ghost_vol` to persist data to, like the ghost database and the associated ssl certificates.

## Running your Container

This script was meant to build an image for general usage, how you run your container is up to you.

### Local Example

Here's an example of how to bring up a container locally at [http://localhost:8080](http://localhost:8080) using a docker volume mounted for persistent storage.  The command will create the volume if it doesn't already exist.

```bash
docker run \
--name my_image_name \
-p 127.0.0.1:8080:80 \
--mount source=example_com_ghost_vol,target=/ghost_vol \
my_image_name:latest
```
