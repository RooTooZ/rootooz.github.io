---
layout: post
title: Vim для разработчика Ruby on Rails и PHP
date: 
  "2015-10-23 15:10": null
categories: my
published: true
---

## Собираем

### Vim
С перва нам надо избваиться от того вима что установлен в системе, потому что в нем нет поддержки некоторых пакетов

{% highlight bash %}
sudo apt-get remove vim-tiny vim-common vim-gui-common
{% endhighlight %}

Если deb установим нужные пакеты
{% highlight bash %}
sudo apt-get install -y libncurses5-dev libgnome2-dev libgnomeui-dev \
libgtk2.0-dev libatk1.0-dev libbonoboui2-dev \
libcairo2-dev libx11-dev libxpm-dev libxt-dev python-dev \
ruby-dev mercurial libperl-dev liblua5.2-dev  
{% endhighlight %}

Соберем наконец таки вим с нужными флагами
{% highlight bash %}
mkdir -p ~/programms
cd ~/programms
hg clone https://code.google.com/p/vim/
cd vim

./configure --with-features=huge \
--enable-multibyte \ 
--enable-rubyinterp \
--enable-pythoninterp \
--with-python-config-dir=/usr/lib/python2.7/config \
--enable-perlinterp \
--enable-luainterp \
--enable-gui=gtk2 --enable-cscope --prefix=/usr

make distclean
make
sudo make install
{% endhighlight %}

Для корректной работы поиска по файлам и классам нужно поствить exuberant ctags        
{% highlight bash %}
cd ~/programms   
wget http://prdownloads.sourceforge.net/ctags/ctags-5.8.tar.gz 
tar -zxvf ctags-5.8.tar.gz

cd ctags-5.8
make
sudo make install
{% endhighlight %}

### RVM

Для начала поставим rvm и необходымый ruby, себе я поставлю 2.2.1

{% highlight bash %}

curl -L get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
rvm requirements

rvm install 2.2.1
rvm use 2.2.1 --dfault
gem install rails --no-ri --no-rdoc
gem install bundler

{% endhighlight %}

Теперь можно установить [[dotfiles]](https://github.com/skwp/dotfiles)


## Настраиваем

После установки у нас появился ~/.vimrc

Добавим в него дополнительные настройки

{% highlight ruby %}
" Settings RooTooZ

" Enable AutoComplPop.
let g:acp_enableAtStartup = 1

" Bind autocomplete to Ctrl+Space
inoremap <C-@> <C-n>

set t_Co=256

Bundle 'flazz/vim-colorschemes'
Bundle 'vim-scripts/dbext.vim'
Bundle 'airblade/vim-gitgutter'
Bundle 'Chiel92/vim-autoformat'

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif 
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
map <C-l> :NERDTreeToggle<CR>
map <C-k> :NERDTreeFind<CR>
noremap <F3> :Autoformat<CR>

colorscheme gruvbox
"colorscheme jellybeans 
"colorscheme hybrid 
set background=dark

let g:lightline = {
      \ 'colorscheme': 'jellybeans',
      \ 'active': {        
      \   'left': [ [ 'mode', 'paste' ],  
      \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ]
      \ },                 
      \ 'component_function': {
      \   'fugitive': 'MyFugitive',
      \   'readonly': 'MyReadonly',
      \   'filename': 'MyFilename',
      \ },
      \ 'separator': { 'left': '⮀', 'right': '⮂' },
      \ 'subseparator': { 'left': '⮁', 'right': '⮃' }
      \ }


let g:formatdef_astyle_php = '"php_beautifier --filters \"ArrayNested Pear(add_header=php)\""' 
let g:formatters_php = ['astyle_php']
let g:autoformat_verbosemode = 1

{% endhighlight %}

### Настроим автодополнение

Для этого зайдем в наш проект и 

{% highlight bash %}
ctags -R --exclude=".git" .
{% endhighlight %}

Для того чтобы работал **ag** нужно поставить еще **the_silver_searcher**

{% highlight bash %}
sudo apt-get install silversearcher-ag
{% endhighlight %}

Теперь у нас есть Vim с поддержкой авто дополнения к PHP и Rails
