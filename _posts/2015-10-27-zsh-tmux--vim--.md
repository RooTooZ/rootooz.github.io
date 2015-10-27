---
layout: post
title: "zsh, tmux и Vim для программиста"
description: "zsh, tmux, rootooz, vim для программиста"
category: 
tags: [vim, zsh, tmux]
excerpt_separator: <!--more-->

---
![My helpful screenshot](/assets/images/zsh_vim_preview.png)
<!--more-->

## Установим и настроим tmux

Для работы tmux нам понадобиться tmux, в deb он ставиться из репозитория

{% highlight bash %}
sudo apt-get install libevent-dev
{% endhighlight %}

Далее возьмем последнюю версию с Github

{% highlight bash %}
cd ~/programms
git clone https://github.com/tmux/tmux.git

cd tmux
sh autogen.sh
./configure && make
sudo make install
{% endhighlight %}

## ZSH ставиться из репозиториев

{% highlight bash %}
sudo apt-get install zsh
{% endhighlight %}

После чего стоит зайти в папку ~/.yadr и обновить

{% highlight bash %}
cd ~/.yadr
git pull --rebase
rake update
{% endhighlight %}

И так у нас уже есть vim, zsh и tmux, но это еще не все. Есть одна пролблема с терминалами цветностью 256. Начнем настройку
