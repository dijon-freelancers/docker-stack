FROM node:lts

RUN apt-get update && \
	apt-get install -y \
		curl \
		apt-transport-https \
		gnupg \
		apt-utils

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get -y update && \
	apt install -y nodejs yarn

ARG PROJECT_SOURCE_DIR
WORKDIR $PROJECT_SOURCE_DIR

RUN if [ ! -f public/build/manifest.json ]; then \
		yarn init; \
		yarn add --dev @symfony/webpack-encore; \
		yarn install; \
	fi