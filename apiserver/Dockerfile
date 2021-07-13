# Using Debian as base image instead of Alpine for faster container builds,
# even though the container is bigger.
#
# The grpc gem only works on Alpine if we compile it (as opposed to using
# precompiled binaries). However this takes forever: well over 10 minutes.
FROM ruby:3.0-slim

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN apt update && \
	apt install -y --no-install-recommends apt-transport-https ca-certificates curl python3 && \
	curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
	curl -fsSLo /usr/share/keyrings/cloud.google.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
	echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" > /etc/apt/sources.list.d/kubernetes.list && \
	echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
	apt update && \
	apt install -y --no-install-recommends kubectl google-cloud-sdk && \
	apt remove -y apt-transport-https ca-certificates curl && \
	apt autoremove -y && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN apt update && \
	apt install -y build-essential ca-certificates && \
	bundle config set without development && \
	bundle install -j 4 && \
	apt remove -y build-essential && \
	apt autoremove -y && \
	rm -rf /var/lib/apt/lists/*

COPY . .

EXPOSE 80

CMD ["./container-init.sh"]
