---
layout: post
title: "Создание сервиса авторизации и регистрации - Zapishi"
description: 'Начнем с сервиса авторизации и регистрации на рубях'
category: zapishi
tags: [auth, zapishi, mvp, rails, ruby, docker]
preview_image: "/assets/images/zapishi/auth-service.png"
published: true
pre_header: Авторизация и регистрация - Zapishi
pre_text: >
    Начнем с сервиса авторизации и регистрации на рубях

---

<!--more-->

Первое что я сделал это запилил docker image для рельсы, потому что создавать сервис авторизации  как видно из картинки 
я буду на Ruby on Rails. 

Рельса в этом плане удобна уже готовыми инструментами.

Особо чем-то этот сервис не отличается по настройке окружения, я тут создал docker-compose с двумя сервисами `backend` и `db`.
докер по умолчанию создает единую сеть между всеми сервисами, но чтобы при поднятии бэкенда, поднималась еще и база, я использовал `depends_on`

```yml
version: '3.2'

volumes:
  pg_data:

  
services:
  backend:
    build:
      context: ./backend
    ports:
      - "3000:3000"
    volumes:
      - ./backend:/app
    depends_on:
      - db

  db:
    image: postgres:14.5-alpine
    volumes:
      - pg_data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: auth
      POSTGRES_PASSWORD: postgres
```

Отдельно от всего я вынес копирование Gemfile потому что процесс скачивания зависимостей довольно долгий и может занимать какое-то время, а таким образом я его закешировал в слой докера что в будущем 
когда появиться CI/CD, ему не придется каждый раз собирать зависимости если они не менялись.


```docker
 FROM ruby:2.7.6-alpine AS builder
  RUN apk add \
    build-base \
    postgresql-dev
  COPY Gemfile* .
  RUN bundle install

 FROM ruby:2.7.6-alpine AS runner
  RUN apk add \
      tzdata \
      nodejs \
      postgresql-dev
  WORKDIR /app

  COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
  
  COPY . .

  EXPOSE 3000

  CMD ["rails", "server", "-b", "0.0.0.0"]

```

На начальном этапе я не подключаю сюда nginx потому что нужно побыстрее создать сервис авторизации и регистрации и для разработки этого пожалуй достаточно!

Для создания резистрации и авторизации на рубях я буду использовать gem devise 

```
# ...

gem "devise" <-- Авторизация и регистрация
```

### Как будет работать авторизация  

Пользователь логинится в сервисе авторизации и получает JWT, после чего его перекидывает в сервис записей с этим токеном и там он уже работает как авторизованный пользователь.
В JWT мы зашьем его публичный id и email, благодарая этому любой другой сервис сможет его распознать. А если по какой-то причине его нет в базе того сервиса в который он пошел, мы всегда сможем по 
внутреннему API auth сервиса через публичный ID узнать все об этом пользователе и добавить его в систему.

![jwt auth](/assets/images/zapishi/oauth-jwt-how-to-it-works.png)

## Думаю что стоит добавить еще один функционал для сервиса авторизации

А именно landing page, это будет сделать проще при текущих обстоятельствах и пока нет смысла разделять эти два домена, так что тут у нас получилась ситуация когда 
два домена находяться в одном сервисе. Об этом в следующем посте.


![2 domains in single service](/assets/images/zapishi/oauth-and-landing.png)
