### Planner

A "Simple" Todo App.
This will be similar to a trello clone

### Getting Started

Docker and docker-sync has been used to create a consistent dev environment.
Install [Docker](https://docs.docker.com/get-docker/) and [docker-sync](http://docker-sync.io/) and then run

```bash
	bash bin/planner go
```

This will build the docker container and gets you into the docker bash. Once inside the docker container, install the dependencies

```bash
	npm i
```

and then install the dependency for the packages

```bash
	npm run bootstrap
```

### Build the Database

```bash
cd packages/database
```

This will build and migrate the database

```bash
	npm run migrate
```
