# Environment includes
-include .env

# Required includes
include ./makefile-utils/make.d/colors.make
include ./makefile-utils/make.d/strings.make
include ./makefile-utils/make.d/helper.make

# Optional includes - comment them as you see fit
include ./makefile-utils/make.d/docker.make

# Makefile configuration
.DEFAULT_GOAL := help
SHELL := /bin/bash

# Your own targets starts here
WHOAMI := $$(whoami)

SUPPORTED_COMMANDS := mysql_connect
SUPPORTS_MAKE_ARGS := $(findstring $(firstword $(MAKECMDGOALS)), $(SUPPORTED_COMMANDS))
ifneq "$(SUPPORTS_MAKE_ARGS)" ""
  COMMAND_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  $(eval $(COMMAND_ARGS):;@:)
endif

copy_env: ## copy the .env file template to the root folder
	@printf ${LINE_BREAK}
	@printf "Copying env file..."
	@cp env.d/.env .env
	@printf "\t${GREEN}${CHECK_MARK}${RESET}${LINE_RETURN}"
	@printf "You should now start to fill the .env file, and run 'make install' when ready.${LINE_RETURN}"

install: ## installs the project and launch it
	@printf ${LINE_BREAK}

	@if [ -f "./docker.d/secrets/mysql/db_root_password" ]; then \
	printf "${RED}${COMPOSE_PROJECT_NAME} is already installed ! ${LINE_BREAK}you should not use 'make install' once installed.${RESET}${LINE_RETURN}"; \
	printf "If you still want to re-install the project, make sure to backup your database and delete the run/mysql folder.${LINE_RETURN}"; \
	exit; \
	fi;

	@printf "${BLUE}Installing ${COMPOSE_PROJECT_NAME}${RESET}${LINE_RETURN}"

	@printf "${GREEN}Generating secrets...${RESET}${LINE_BREAK}"
	@printf "${GREEN}${DOTTED_LINE}${RESET}${LINE_BREAK}"

	@mkdir -p ./docker.d/secrets/mysql

	@printf "Generating root secret..."
	@openssl rand -base64 12 > ./docker.d/secrets/mysql/db_root_password
	@printf "\t${GREEN}${CHECK_MARK}${RESET}${LINE_BREAK}"

	@printf ${LINE_BREAK}

	@${MAKE} --no-print-directory docker_launch

	@printf "${LINE_BREAK}"

mysql_connect: ## connects you to the database with the user given (it requires a secret file)
	@docker exec -ti ${COMPOSE_PROJECT_NAME}-mysql mysql --user="${COMMAND_ARGS}" --password="$$(cat ./docker.d/secrets/mysql/db_${COMMAND_ARGS}_password)"

.ONESHELL:
mysql_create_app_user: ## creates an applicative user
	@printf "${GREEN}Applicative user creation...${RESET}\n"
	@printf "${GREEN}${DOTTED_LINE}${RESET}\n"

	@printf "This will create a user able to create databases, insert, update, delete and call stored procedures.${LINE_RETURN}"

	@APP_USER_NAME=""
	@read -p "${YELLOW}What is the name of the user: ${RESET}" APP_USER_NAME
	
	@printf "${LINE_BREAK}"

	@printf "Generating $$APP_USER_NAME secret..."
	@openssl rand -base64 12 > ./docker.d/secrets/mysql/db_$${APP_USER_NAME}_password
	@printf "\t\t\t${GREEN}${CHECK_MARK}${RESET}${LINE_BREAK}"

	@printf "Creating $$APP_USER_NAME in database..."
	@docker exec -ti ${COMPOSE_PROJECT_NAME}-mysql mysql --user="root" --password="$$(cat ./docker.d/secrets/mysql/db_root_password)" -e "CREATE USER '$${APP_USER_NAME}'@'%' IDENTIFIED BY '$$(cat ./docker.d/secrets/mysql/db_$${APP_USER_NAME}_password)';" | grep -v -i "warning"
	@printf "\t\t\t${GREEN}${CHECK_MARK}${RESET}${LINE_BREAK}"

	@printf "Granting rights to $$APP_USER_NAME in database..."
	@docker exec -ti ${COMPOSE_PROJECT_NAME}-mysql mysql --user="root" --password="$$(cat ./docker.d/secrets/mysql/db_root_password)" -e "GRANT ALL PRIVILEGES ON *.* TO '$${APP_USER_NAME}'@'%';" | grep -v -i "warning"
	@docker exec -ti ${COMPOSE_PROJECT_NAME}-mysql mysql --user="root" --password="$$(cat ./docker.d/secrets/mysql/db_root_password)" -e "FLUSH PRIVILEGES;" | grep -v -i "warning"
	@printf "\t\t${GREEN}${CHECK_MARK}${RESET}${LINE_BREAK}"

	@printf ${LINE_BREAK}

	@printf "${ROCKET_SIGN} ${GREEN}Your user $$APP_USER_NAME has been created${RESET} ${ROCKET_SIGN}${LINE_BREAK}"
	@printf "Username: $$APP_USER_NAME${LINE_BREAK}"
	@printf "Password: $$(cat ./docker.d/secrets/mysql/db_$${APP_USER_NAME}_password)${LINE_RETURN}"
