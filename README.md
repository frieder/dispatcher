# Adobe Dispatcher Container Image

A container image to run Adobe Dispatcher in a container. It is based on the 
container images provided by Adobe's SDK but adds the capability to change
the user and group ID of the Apache user inside the container via environment
variables at startup. This is useful to prevent issues on Linux-based host 
systems where ID 100 is assigned to system/service accounts.

Also check out https://github.com/frieder/aem for a container image of Adobe
Experience Manager (AEM) and https://github.com/frieder/aemdev for an example 
project how to use these containers in an actual development environment both
locally and on AWS cloud.

# How To Use

> The namespace `frieder/*` and the registry `ghcr.io` are just for demo purposes.
> Replace it with your company namespace and push it to your own private registry.

First you have to log into your corporate container registry.

```shell
export TOKEN=***
export USER=frieder
# docker.io | ghcr.io | ...
export REGISTRY=ghcr.io

echo ${TOKEN} | docker login ${REGISTRY} -u ${USER} --password-stdin
```

Next you can pull the images from your container registry. We distinguish between a
`stable` version representing the installation on production and `latest` being in
sync with the Cloud Manager dev environment. This way you can test your code against
the next SDK version prior to upgrading production. In addition to these two tags we
also use the version of the SDK (e.g. 2023.12) instead of the actual version (e.g. 2.0.193).
The reason for this is that it is usually easier for developers to identify the correct 
dispatcher image for the respective AEM SDK this way.

```shell
export NAMESPACE=frieder

docker pull ${REGISTRY}/${NAMESPACE}/dispatcher:stable
docker pull ${REGISTRY}/${NAMESPACE}/dispatcher:2023.11

docker pull ${REGISTRY}/${NAMESPACE}/dispatcher:latest
docker pull ${REGISTRY}/${NAMESPACE}/dispatcher:2023.12
```

Once you are able to successfully pull the container image from the registry you can
then start the containers. Please adapt the arguments according to your needs.

```shell
PUID=$(id -u)
PGID=$(id -g)

docker run -d \
  --name dispatcher \
  -e PUID="${PUID}" \
  -e PGID="${PGID}" \
  -e AEM_HOST="publish" \
  -e AEM_IP="*" \
  -e AEM_PORT="4000" \
  -e ALLOW_CACHE_INVALIDATION_GLOBALLY="true" \
  -e DISP_RUN_MODE="dev" \
  -e ENVIRONMENT_TYPE="dev" \
  -e HOT_RELOAD="true" \
  -e REWRITE_LOG_LEVEL="debug" \
  -p 8000:80 \
  -v $(pwd)/dispatcher/logs:/var/log/apache2 \
  -v $(pwd)/dispatcher/cache:/mnt/var/www \
  -v <path/to/archetype/project/dispatcher/src>:/mnt/dev/src:ro \
  ${REGISTRY}/${NAMESPACE}/dispatcher:stable
```

Once the containers are created you can use the following commands to start/stop
the containers.

```shell
docker start dispatcher
docker stop dispatcher (-t 30)
```

# How To Build

Before you can start building the image you must have the original dispatcher container 
image available in some private container registry. The build pipeline at 
[.github/workflows/build.yml](.github/workflows/build.yml) shows how to download the SDK
archive first, then load the container images from
the archive and finally pushing it to a private container registry. Once available,
the new container image can be built by running the following command.

```shell
docker build \
  --build-arg PARENT="ghcr.io/frieder/dispatcher:adobe-latest" \
  --tag ghcr.io/frieder/dispatcher:latest \
  .
```

The value of ´PARENT´ must point to an existing image in a private registry (e.g. `adobe-2.0.193`,
`adobe-latest` or `adobe-2023.12`). Also consider using 
[Docker buildx](https://docs.docker.com/engine/reference/commandline/buildx/)
to create native container images for different platforms like `amd64` and `arm64`. This
can greatly improve the performance of the local AEM container instance (e.g. when
using Macbooks). An example on how to do this can also be found in the GH build pipeline.
