# kivera-docker

### Build Image


```docker build -t kivera-proxy --build-arg version=latest .```

### Run Image

Create a local directory (i.e. files/) which contains your Kivera credentials file (named *credentials.json*). This directory will be mounted to the container.

```
docker run -it \
    -v $PWD/files:/opt/kivera/etc  \
    --user root \
    kivera-proxy
```

### Customise Image

The Dockerfile installs Fluentd and the fluent-plugin-out-kivera plugin by default, which sends proxy logs to the Kivera logging platform. If you wish to implement your own logging solution, replace the commands under the *Configure logging agent* block in the Dockerfile to install/configure your own tooling, and edit the *custom.sh* script with the command/s to start your logging service at run time.
