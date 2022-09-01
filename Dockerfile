FROM ruby:2-alpine

WORKDIR /app

COPY . . 

RUN apk update && apk add --no-cache g++ make libc-dev
RUN gem install jekyll bundler:1.13.6 && bundle install

CMD bundle exec jekyll serve -H 0.0.0.0 --watch -D -l --unpublished --future

