---
layout: post
title: "Бизнес требования - Zapishi"
description: 'Desc'
category: zapishi
tags: [event storming, zapishi]
preview_image: "/assets/images/zapishi/title.png"
published: true
pre_header: Бизнес требования - Zapishi
pre_text: >
    Давай распишем бизнес требования и выясним что мменно мы делаем для MVP

---

## Бизнесс требования

* Регистрация по email ( и паролю для MVP ) в дальнейшем убираем пароль и регистрация должна быть только по email а пароль устанавливается после подтверждения email
* Авторизация по email и паролю
* Создание записи в клчающее в себя заголовок (название) и сам текст записи, поддерживающий формат markdown
* Редактирование записи и заголовка может только автор
* Удаление записи может только автор
* Создание публичной ссылки для записи, все могут только просматривать

<!--more-->


Хоть и кажется что этих требований мало, работы нужно провести дофига!

# Разберем каждое требование на составляющие

```
Регистрация по email и паролю

Actor: User
Command: Account Create
Data: Account 
Event: Accounts.SignUp
```

```
Авторизация по email и паролю

Actor: User
Command: Account login
Data: Account
Event: Accounts.SignIn
```

```
Создание новой записи

Actor: User
Command: Record Create
Data: Record + Account public id
Event: Records.Created
```

```
Редактирование записи

Actor: User
Command: Record Update
Data: Record + Account public id
Event: Records.Updated
```

```
Удаление записи

Actor: User
Command: Record Delete
Data: Record public id + Account public id
Event: Records.Deleted
```

```
Чтение записи 

Actor: User (Author or Readed)
Command: Record Read
Data: Record + Account public id
Event: Records.Readed
```

```
Создание публичной ссылки 

Actor: User
Command: Record Publish
Data: Record + Public record ID
Event: Records.Published
```

```
Убрать публичную ссылку

Actor: User
Command: Record UnPublish
Data: Record + Public record ID
Event: Records.UnPublished
```

## Модель данных примерно выглядит так

![Data model](/assets/images/zapishi/data-model.png)

## Домены которые у нас будут они же будут и сервисами

Я пока выделил только 2 домена

![Domains](/assets/images/zapishi/domains.png)


Это домен где пользователи будут регистрироваться и авторизоываться
и второй домен для самих записей, пожалуй пока усложнять систему не хочется.

## Теперь выясним какие данные будут общими

Думаю что это будут `Account public_id`. Больше пока общих данных не будет.

## И последнее что стоит сделать это определить CUD и бизнесс события и какие данные будут ходить

![CUDEv and BEv](/assets/images/zapishi/cud-be-events.png)

| Event | Producer | Consumer |
| ---   | ---      | ---      |
| Accounts.SignUp | Account svc | Records svc |
| Accounts.SignIn | Account svc | ? |
| Records.Created | Records svc | ? |
| Records.Updated | Records svc | ? |
| Records.Deleted | Records svc | ? |
| Records.Readed  | Records svc | ? |
| Records.Published  | Records svc | ? |
| Records.UnPublished  | Records svc | ? |


Выходит что у нас только один Consumer и мы будем получать там только User public id и email


![CUDEv and BEv](/assets/images/zapishi/auth-signup-cosumer.png)
