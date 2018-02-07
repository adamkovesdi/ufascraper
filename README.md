# UFA scraper

*DISCLAIMER: Work in progress, full functionality is present, could use some polishing.*

These are a collection of Ruby applications for scraping a forum classifieds section, collecting all new posts to a database and then serving that data as a custom formatted web page.

## Technologies

- Nokogiri Ruby gem for scraping web pages
- Sinatra framework for serving the data
- Redis database as a backend storage for all the data
- pushjet.io for sending notifications to various mobile devices
- Docker compose for hosting the whole platform including all microservices in a quickly deployable fashion

## System architecture 

![overview](diagrams/overview.png)

## System components

### 1. collect

This module is responsible for periodically downloading forum webpages and scraping them collecting all new posts and pushing those to redis DB.

### 2. serve

This module serves the data from redis DB as a custom formatted table based web page.
It listens on port 4567 of the serve container which can be published for outside access. By default docker-compose file is taking care of this.

### 3. notify

This module periodically parses the last 2000 entries in the redis DB and looks for pre-defined keywords and sends a pushjet.io notification when a match is found. It keeps track of notifications already sent in redis to avoid duplicate alerts. 

### 4. redis

Box standard redis container with host bind mount data volume in append only format to keep track of all persistent data.

## Docker-compose file

This docker-compose.yml is used to bring the whole stack up.

```
version: "2"
services:
  collect:
    build: ./collect
    image: adamkov/collectufa
    command: ruby collect.rb
    depends_on:
      - redis
    links:
      - redis
  serveufa:
    build: ./serveufa
    image: adamkov/serveufa
    command: ruby serveufa.rb -o 0.0.0.0
    ports:
      - "4567:4567"
    depends_on:
      - redis
    links:
      - redis
  redis:
    container_name: redis
    image: redis:alpine
    command: redis-server --appendonly yes
    volumes:
      - ./redisdata:/data
```

*TODO: add notify to the docker-compose stack*

## Links, references

- TODO
