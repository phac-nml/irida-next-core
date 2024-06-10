# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.3.1
FROM ghcr.io/rails/devcontainer/images/ruby:$RUBY_VERSION

# Install JavaScript dependencies
ARG NODE_VERSION=20.14.0
ARG PNPM_VERSION=9.2.0
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g pnpm@$PNPM_VERSION && \
    rm -rf /tmp/node-build-master
