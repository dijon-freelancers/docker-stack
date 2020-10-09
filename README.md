# Symfony stack

The goal of this project is to provide a simple, easy to use, docker stack for Symfony, usable in development, or production
environment.

## Features
* Auto-deployed, ready to use, stack for Symfony 4/5 applications.
* Two modes : development and production :
    * development mode goes with simple HTTP flow and a node image to build your Webpack packages.
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

> For production environment, you want to use `make copy_env_prod` instead.

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

## Create a database user for your app
This project comes with a user generator for MySQL, simply use :

```bash
make mysql_create_app_user
```

This will ask you the username of the user, create it with rights, and display you the username and the password to put in your Symfony configuration.

## Connect the database
You can connect the database using :

```bash
make mysql_connect USERNAME
```
Where `USERNAME` is either `root` for a root connection, or a username created with the previous command.

## Reset the stack
If you want to reset (i.e. go with a fresh install) the stack, simply use :

```bash
make install
```
If the project is already installed, it will dipslay information about project reset.

## Commands
This repository is built on top of [XSlender/Makefile-utils](https://github.com/XSlender/makefile-utils) that provides Makefiles utilities.  
You can go on it to get a full list of provided commands.

Here is the list of commands for this repository :

| Command | Description |
|---------|-------------|
| `copy_env`                      | copy the .env file template to the root folder. |
| `copy_env_prod`                 | copy the .env file template to the root folder for production environment. |
| `install`                       | installs the project and launch it. |
| `mysql_connect`                 | connects you to the database with the user given (it requires a secret file). |
| `mysql_create_app_user`         | creates an applicative user. |
| `create_proxy_credentials`      | creates the Traefik proxy credentials to put in the .env file. |

## To-do
* Deploy automated rules for main firewalls (ufw, iptables)
* Deploy VPN to connect to the database other than with console.
* Automated database backups.