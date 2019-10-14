FROM ruby:2.6.3

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Dependencies
RUN apt-get -y update && \
  apt-get install --fix-missing --no-install-recommends -qq -y \
  build-essential \
  postgresql-client \
  git \
  curl \
  ssh \
  imagemagick \
  nodejs \
  npm \
  yarn \
  tzdata \
  less

RUN mkdir /myapp
RUN mkdir /usr/local/nvm
WORKDIR /myapp

RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install -y nodejs

RUN node -v
RUN npm -v

COPY Gemfile Gemfile.lock package.json ./
RUN gem install bundler
RUN bundle install --verbose --jobs 20 --retry 5

RUN npm install -g yarn
RUN yarn install --check-files
RUN rails webpacker:install

COPY . /myapp

# Add a script to be executed every time the container starts
COPY entrypoint.sh /usr/bin
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process
# CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
CMD "bundle exec rails server -b 0.0.0.0"
