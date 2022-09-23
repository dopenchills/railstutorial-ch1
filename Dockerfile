# syntax=docker/dockerfile:1
FROM ruby:2.7.6

WORKDIR /myapp

# preprare yarn
RUN wget --quiet -O - /tmp/pubkey.gpg https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

# prepare node
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get install -yq postgresql-client sqlite3 imagemagick yarn nodejs --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

RUN echo 'gem: --no-document' >> ~/.gemrc
RUN gem update --system
RUN gem install bundler -v 2.2.17
RUN gem install rails -v 6.0.4

# nokogiriが動くようになる
RUN bundle config set force_ruby_platform true
RUN bundle _2.2.17_ install

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Use docker-compose
# Configure the main process to run when running the image
# CMD ["rails", "server", "-b", "0.0.0.0"]
