# Click Count application

`click-count` is a mission critical app that allows to count on button click.

It is a Java web application, running in a Tomcat 7 application server.

Take a look at this project [technical stacks](./infra/TECHNICAL_STACK.md).

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

> **_NOTE:_**  Currently, the image assumes the project has been built and a ./target directory is present.


## How to run ?

To run the project locally, first start a `redis` instance, running in port 6379:

``` bash
docker run --name redis --rm -p 6379:6379 redis
```

then, fire up the `click-count` container:

``` bash
docker run --env REDIS_HOST=localhost --name click-count --rm --net=host click-count
```

alternatively, you can download a docker image from DockerHub:

``` bash
docker run --env REDIS_HOST=localhost --name click-count --rm --net=host captainspof/click-count
```

> **_NOTE:_**  Here, we share host network with the container, this is in order to quickly get access to redis. Setting up a proper, shared network is recommended.

you should be able to reach the application at ~localhost:8000~.

## How to deploy ?

### Deploy to staging environment

In order to deploy a new version to staging environment, simply create a pre-release to the commit you want to deploy. Github Actions will take care of the rest.

### Deploy to production environment

Where you're satisfied with your version, merge it master. Then, create a release to the master branch, Github Actions will ship it to production for you.

> **_NOTE:_**  Merging to master will require approbation from a pair.

## How to manage the infrastructure ?

Terraform takes care of the infrastructure. To learn more, visit the README in the `infra` directory. [Here](./infra/README.md).
