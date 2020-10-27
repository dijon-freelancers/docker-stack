# Symfony stack

The goal of this project is to provide a simple, easy to use, docker stack for Symfony, usable in development, or production
environment.

## Features
* Auto-deployed, ready to use, stack for Symfony 4/5 applications.
* Two modes : development and production :
    * development mode goes with simple HTTP flow and a node image to watch/build live your Webpack packages.
    * production mode goes with automated SSL certificates via Letsencrypt, HTTPS enforced, and no dev images.
* Secured MySQL database and automated MySQL user creation for your application.

## Prerequisites
* A working docker installation.
* A directory with your symfony project.
* GNU make installed.

## What will be deployed
* PHP 7-fpm
* MySQL 8.0
* NginX latest
* Traefik latest
    * with Traefik dashboard enabled. *(You can access it with `https://traefik.DOMAIN`)*
    * with automated SSL certification and enforcement on production environments
    * with simple HTTP for development environments.
* Node lts
    * only for development environment
    * with automated yarn installation and yarn dev server

## Installation

### Initialisation
You can clone and initialize the project with :
```bash
git clone https://github.com/AdrienGras/docker-stack.git
cd docker-stack
git submodule init
git submodule update --remote
```

Now that your project is ready, it is time to get your environment ready.

```bash
make copy_env
```

This will prepare for you an empty `.env` file.

Open the `.env` file and complete the parameters. Here is a complete list of environment parameters :

| Parameter | Description |
|-----------|-------------|
| `COMPOSE_FILE` | The list of docker compose file to build and use. **You should not modify this unless you know exactly what you do** |
| `COMPOSE_PROJECT_NAME` | The name of the project. This must only contain alphanumerical values and `-`. |
| `TIMEZONE` | The timezone for containers. |
| `SOURCE_PATH` | The path to your symfony project root *(i.e. the base folder, not the public one.)*. |
| `DOMAIN` | The domain for your project. You can use `localhost` for local development. |
| `SSL_CERT_EMAIL` | Email used for the domain SSL certificate generation. |
| `PROXY_CREDENTIALS` | Credentials to access the proxy. You can generate it with `make create_proxy_credentials`. |

### Stack installation
Now, you can launch the installation of the project :

```bash
make install
```

This will :
* Create MySQL root password secret.
* Create docker `proxy-bridge` public network.
* Build docker containers.
* Launch the containers.

Now, your stack should be up and running. You can test it by using the `DOMAIN` you provided in the `.env` file with a web browser.

> **Note** : You will have to wait 15-20 seconds before connecting to MySQL due to system database intialization.

> **Note** : If you just pulled your sources, your Symfony project may not have vendors, you can install them using `docker exec -ti <COMPOSE_PROJECT_NAME>-php bash -c 'composer install'`.
> You Also certainly will have to load fixtures, or initialize other modules. You can use the previous command replacing `composer install` by whatever composer or Symfony command you like.

> **Note** : If you are running `webpack-encore`, you will need to do `make yarn_force_install` after the stack installation to be able to have the yarn dev server watching your changes.

### (Optional) Create a database user for your app
This project comes with a user generator for MySQL, simply use :

```bash
make mysql_create_app_user
```

This will ask you the username of the user, create it with rights, and display you the username and the password to put in your Symfony `.env` file.

## Deploy in production
As previously said, this stack is ready for production. 

### Adding the override parameters
First, you need to open the `.env` file, and replace the `COMPOSE_FILE=...` line with this one :
```bash
COMPOSE_FILE=docker.d/compose/docker-compose.yml:docker.d/compose/mysql.docker-compose.yml:docker.d/compose/php.docker-compose.yml:docker.d/compose/node.docker-compose.yml:docker.d/compose/nginx.docker-compose.yml:docker.d/compose/traefik.docker-compose.yml:docker.d/compose/docker-compose.override.yml
```
This will use the `docker-compose.override.yml` file containing instruction to secure your stack.

### Do a deployment
Once you have updated your sources and all your needs before a deployment, you can do : 
```bash
make deploy
```

This will :
- stop the stack
- do a `yarn production` to build and ready your assets for production.
- start the stack
- stop the yarn watcher *(useless in production)*

> **Note** : If you have additional commands, related to database for example, you can do them before or after the deployment.
> In this case, you may want to script the procedure and use the different make commands available, or docker ones if necessary.
> You can look inside the `Makefile` to see how it works.

## Administrating the stack

### Connect the database
You can connect the database using :

```bash
make mysql_connect USERNAME
```
Where `USERNAME` is either `root` for a root connection, or a username created with the previous command.

### Reset the stack
If you want to reset (i.e. go with a fresh install) the stack, simply use :

```bash
make install
```
If the project is already installed, it will dipslay information about project reset.

## Commands
This repository is built on top of [XSlender/Makefile-utils](https://github.com/XSlender/makefile-utils) that provides Makefiles utilities.  
You can go on it to get a full list of provided commands.

Here is the list of `make` targets *(aka: make commands)* for this repository :

| Command | Description |
|---------|-------------|
| `copy_env`                       | copy the .env file template to the root folder |
| `create_proxy_credentials`       | creates the Traefik proxy credentials to put in the .env file |
| `install`                        | installs the project and launch it |
| `up`                             | shorthand to launch the project |
| `down`                           | shorthand to stop the project |
| `deploy`                         | deploys the stack for production environment |
| `mysql_connect`                  | connects you to the database with the user given (it requires a secret file) |
| `mysql_create_app_user`          | creates an applicative user |
| `yarn_force_install`             | forces the installation for webpack encore |
| `yarn_build`                     | builds the assets for webpack production |

## To-do
* Deploy automated rules for main firewalls (ufw, iptables)
* Deploy VPN to connect to the database other than with console.
* Automated database backups.