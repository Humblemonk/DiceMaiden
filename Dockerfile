FROM ruby:3.3.0-alpine3.19

COPY . /opt/dicemaiden
WORKDIR /opt/dicemaiden

RUN apk update
RUN apk add --no-cache curl wget bash git ruby ruby-bundler
RUN apk add --virtual build-dependencies build-base

RUN bundle install

CMD bundle exec ruby dice_maiden.rb 0 lite
