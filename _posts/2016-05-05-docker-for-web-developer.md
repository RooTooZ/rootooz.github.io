---
layout: post
title: "Зачем нужен Docker разработчику"
description: 'зачем нужен docker для разработчка'
category: develop
tags: [docker, ruby, develop]
excerpt_separator: <!--more-->
published: true
---
![Preview image](/assets/images/docker-compose.png)

<!--more-->

Когда работаешь над несколькими проектами, в разных средах, с разными зависимостями то появляется ряд проблем.
Нужно настраивать для каждого проекта свое окружение, ставить необходимые пакеты, как-то выкручиваться если 
одновременно нужны разные версии пакетов (Например Ruby 1.9 и Ruby 2.3) или порт который требуется серверу
уже занят.


Этого можно избежать с помощью **Docker контейнеров**.

Создавая для каждого проекта группу контейнеров мы можем подстроить окружение так как будет удобно для нас
не забивая при этом лишним свою основную сиситему. Для этого есть удобный инструмент **docker-compose**.
Его преимущество в том что оно создает несколько связанных контейнеров в одном проекте с помощью одного 
конфигурационного файла. 

Например в нашем проекте есть web сервер, сервер баз данных и допустим сервер поиска
например elasticsearch. Web сервер у нас будет обслуживать приложение на Ruby on Rails 4 версии c Nginx и Unicorn,
сервер баз данных например на PostgreSQL 9.4, а elasticsearch требует Java-машину. 

Есть и второй проект в котором есть также Web сервер и сервер базы данных а так же Redis сервер. Но во втором проекте нам нужен 
Ruby on Rails 2 версии который работает допустим на Ruby 1.8. Сервер базы данных тоже использует PostgreSQL но версии 8.3.
Итого у нас 2 проекта которые конфликтуют между собой зависимостями, мы конечно можем настроить все это на одной машине.
Перенастроив для PostgreSQL разных версий, порты, а для Ruby можно использовать rvm.

Мы поступим иначе, мы настроим эти проекты через docker-compose. 
В корне каждого проекта создаем 2 файла:

* docker-compose.yml
* Dockerfile

Начиная работать над проектом мы просто запускаем наш docker-compose, а при завершении работы останавливаем
группу контейнеров данного проекта. Таким образом мы получаем полностью настроенное окружение для каждого
проекта. Друг другу наши проекты не мешают, а еще настроив один раз конфигурацию docker-compose мы можем запускать
наше настроенное окружение на любом компьютере с Docker на борту. Т.е. очень простым становиться процесс деплоя, 
ведь на сервере наше приложение будет работать точно также как и у нас на компьютере.

## Примеры конфигураций

### Проект 1
**docker-compose.yml**

```YAML
web:
  build: .
  command: bundle exec foreman start -f Procfile
  ports:
    - "80:80"
  links:
    - db:db
    - elasticsearch:elasticsearch
  environment:
    REDIS_URL: redis://redis

db:
  image: postgres9.4
  ports:
    - "5433:5432"
  volumes_from:
    - postgres_data

elasticsearch:
  image: elasticsearch
```

**Dockerfile**

```Dockerfile
FROM ruby:2.2.0

RUN apt-get update -qq && apt-get install -qq -y zlib1g-dev libpcre3 libpcre3-dev unzip build-essential libpq-dev nodejs && \
    cd && NPS_VERSION=1.9.32.11 && wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip && \
    unzip release-${NPS_VERSION}-beta.zip && cd ngx_pagespeed-release-${NPS_VERSION}-beta/ && \
    wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz && tar -xzvf ${NPS_VERSION}.tar.gz && \
    cd && NGINX_VERSION=1.8.0 && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -xvzf nginx-${NGINX_VERSION}.tar.gz && cd nginx-${NGINX_VERSION}/ && \
    ./configure --add-module=$HOME/ngx_pagespeed-release-${NPS_VERSION}-beta --with-http_ssl_module --with-http_gzip_static_module && \
    make && make install

RUN apt-get install -y -qq nodejs nodejs-legacy npm && npm install -g bower && echo '{"allow_root": true}' > /root/.bowerrc

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
    BUNDLE_JOBS=2 \
    BUNDLE_PATH=/bundle

RUN gem install rake

EXPOSE 80
```

### Проект 2
**docker-compose.yml**

```YAML
web:
  build: .
  command: bundle exec foreman start -f Procfile
  ports:
    - "80:80"
  links:
    - db:db
    - redis:redis
  environment:
    REDIS_URL: redis://redis

db:
  image: postgres8.3
  ports:
    - "5433:5432"
  volumes_from:
    - postgres_data

redis:
  image: redis
```

**Dockerfile**

```Dockerfile
FROM ruby:1.8.0

RUN apt-get update -qq && apt-get install -qq -y nginx

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ENV BUNDLE_GEMFILE=$APP_HOME/Gemfile \
    BUNDLE_JOBS=2 \
    BUNDLE_PATH=/bundle

EXPOSE 80
```

