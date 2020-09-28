# Environment includes
-include .env

# Required includes
include ./makefile-utils/make.d/colors.make
include ./makefile-utils/make.d/strings.make
include ./makefile-utils/make.d/helper.make

# Optional includes - comment them as you see fit
include ./makefile-utils/make.d/makefile_tester.make
include ./makefile-utils/make.d/docker.make

# Makefile configuration
.DEFAULT_GOAL := help
SHELL := /bin/bash

# Your own targets starts here
WHOAMI := $$(whoami)

copy_env: ## copy the .env file template to the root folder
	@printf ${LINE_BREAK}
	@printf "Copying env file... ${LINE_BREAK}"
	@cp env.d/.env .env
	@printf "${GREEN}Env file copied ${CHECK_MARK}${RESET}${LINE_RETURN}"

install:
	@printf ${LINE_BREAK}

	@printf "${BLUE}Installing ${COMPOSE_PROJECT_NAME}${RESET}${LINE_RETURN}"

	@printf "${GREEN}Generating secrets...${RESET}${LINE_BREAK}"
	@printf "${GREEN}${DOTTED_LINE}${RESET}${LINE_BREAK}"

	@mkdir -p ./docker.d/secrets/mysql

	@printf "Generating db_root_password..."
	@openssl rand -base64 12 > ./docker.d/secrets/mysql/db_root_password
	@printf "\t${GREEN}${CHECK_MARK}${RESET}${LINE_BREAK}"

	@printf "Generating db_dba_password..."
	@openssl rand -base64 12 > ./docker.d/secrets/mysql/db_dba_password
	@printf "\t${GREEN}${CHECK_MARK}${RESET}${LINE_BREAK}"

	@printf ${LINE_BREAK}

	@${MAKE} --no-print-directory docker_launch

	@printf "${LINE_BREAK}"