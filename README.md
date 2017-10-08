# docker-nwnx2server
Containerization of NWNX2 server on Linux.

Base image is in [docker-nwnserver](https://github.com/jakkn/docker-nwnserver)

## Run
```
docker-compose up -d
```

#### Note
Options to nwserver can be given in the following ways:
- Using `docker-compose.yml` the default script can be changed to `compose-nwnstartup.sh` and will pass on any arguments from the compose file to nwserver. This is the recommended procedure.
- Using the default script `nwnstartup.sh`. This will try to load a module named `module.mod`

## Dependencies
- [Docker](https://docs.docker.com/engine/installation/)
- [Compose](https://docs.docker.com/compose/install/)

## References
[NWNX2](https://github.com/nwnx/nwnx2-linux)
