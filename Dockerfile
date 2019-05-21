FROM bitriseio/docker-bitrise-base:latest

# Important!  Update this no-op ENV variable when this Dockerfile
# is updated with the current date. It will force refresh of all
# of the base images and things like `apt-get update` won't be using
# old cached versions when the Dockerfile is built.
ENV REFRESHED_AT=2019-05-21 \
    HELM_LATEST_VERSION="v2.14.0" \
    DEBIAN_FRONTEND=noninteractive

RUN echo "deb http://packages.erlang-solutions.com/ubuntu xenial contrib" >> /etc/apt/sources.list \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - \ 
    && apt-key adv --fetch-keys http://packages.erlang-solutions.com/ubuntu/erlang_solutions.asc \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6B05F25D762E3157 \
    && export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" \
    && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-get -qq update \
    # Install Elixir
    && apt-get install -y erlang-dev erlang-parsetools elixir \
    # Install nodejs
    && curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - \
    && apt-get install -y nodejs \
    # Install gcloud
    && apt-get install -y google-cloud-sdk \
    # Install kubectl
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    # Install Helm
    && wget http://storage.googleapis.com/kubernetes-helm/helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
    && tar -xvf helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
    && mv linux-amd64/helm /usr/local/bin \
    # Cleanup
    && rm -f /helm-${HELM_LATEST_VERSION}-linux-amd64.tar.gz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install local Elixir hex and rebar
RUN /usr/bin/mix local.hex --force && \
    /usr/bin/mix local.rebar --force

RUN elixir -v
RUN node --version
RUN npm --version
RUN kubectl version --client
RUN helm version --client