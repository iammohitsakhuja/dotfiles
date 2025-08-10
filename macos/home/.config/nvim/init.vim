" Taken from here: https://hackernoon.com/changing-to-neovim-28cda0ad35c
set runtimepath^=/.vim runtimepath+=~/.vim/after

let &packpath = &runtimepath

source ~/.vimrc
