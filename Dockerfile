FROM ruby:2.7.2-alpine3.12

COPY . /opt/DiceMaiden
WORKDIR /opt/DiceMaiden

RUN apk update
RUN apk add --no-cache curl wget bash git ruby ruby-bundler sqlite-dev
RUN apk add --virtual build-dependencies build-base

RUN bundle install

CMD bundle exec ruby dice_maiden.rb 0 lite
