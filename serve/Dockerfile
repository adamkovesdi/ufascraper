FROM ruby:latest
MAINTAINER adamkov

RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev

COPY Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install

ENV app /app
RUN mkdir $app
WORKDIR $app
ADD . $app

USER nobody
EXPOSE 4567
CMD ruby serveufa.rb -o 0.0.0.0 
