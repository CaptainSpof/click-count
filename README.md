# Click Count application

> :warning: **We be WIPing**: CI/CDfication of this project is under process

## How to build ?

### Nix

For nix users, a `default.nix` file is available. Used in combination with `direnv` and `nix-direnv` it should provides the necessary dependencies to build the .war archive.

```bash
mvn clean package
```

### Docker

To build a Docker image run:

``` bash
docker build . -t click-count
```

> **_NOTE:_**  Currently, the image assume the project has been built and a ./target directory is present


## How to run ?

To run the project, first launch a Redis running in port 6379:

``` bash
docker run --name redis --rm -p 6379:6379 redis
```

then fire up the ~click-count~ container:

``` bash
docker run --name click-count --rm --net=host click-count
```

> **_NOTE:_**  Here, we share host network with the container, this is in order to quickly get access to redis. Setting up a proper shared network is recommended.
