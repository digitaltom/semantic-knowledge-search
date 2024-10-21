# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.5
FROM ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_DEPLOYMENT="1"

# Update gems and bundler
RUN gem update --system --no-document && \
    gem install -N bundler


# Throw-away build stage to reduce size of final image
FROM base as build

# Install packages needed to build gems and node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl git \
                    node-gyp pkg-config python-is-python3 libgomp1 libblas3 liblapack3 vim

# Install JavaScript dependencies
ARG NODE_VERSION=16.19.1
ARG YARN_VERSION=1.22.5
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

# Install application gems
COPY --link Gemfile Gemfile.lock ./
RUN bundle install && \
    bundle exec bootsnap precompile --gemfile && \
    rm -rf ~/.bundle/ $BUNDLE_PATH/ruby/*/cache $BUNDLE_PATH/ruby/*/bundler/gems/*/.git

# Install node modules
COPY --link package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy application code
COPY --link . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# remove compressed css + js to avoid:
# "content-type 'text/gz' is not 'text/css'"
RUN rm ./public/assets/application-*.css.gz
RUN rm ./public/assets/application-*.js.gz

# Final stage for app image
FROM base

# Install packages needed for deployment
# Last line are dependencies for sqlite vss0
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libsqlite3-0 && \
    apt-get install --no-install-recommends -y libgomp1 libblas3 liblapack3 vim curl && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Run and own the application files as a non-root user for security
RUN useradd rails --home /rails --shell /bin/bash
USER rails:rails

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=rails:rails /rails /rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
