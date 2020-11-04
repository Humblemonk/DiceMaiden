FROM ruby:2.7.2-alpine3.12

COPY . /opt/dice_maiden
WORKDIR /opt/dice_maiden

RUN bundle install

CMD bundle execute ruby dice_maiden.rb 0 lite
