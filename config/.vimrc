set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'mattn/emmet-vim'
Plugin 'scrooloose/nerdtree'
Plugin 'airblade/vim-gitgutter'
Plugin 'itchyny/lightline.vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tpope/vim-commentary'
Plugin 'w0rp/ale'
Plugin 'google/vim-maktaba'
Plugin 'google/vim-codefmt'
Plugin 'google/vim-glaive'
Plugin 'artur-shaik/vim-javacomplete2'
Plugin 'jiangmiao/auto-pairs'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'tpope/vim-surround'
Plugin 'sheerun/vim-polyglot'
call vundle#end()

call glaive#Install()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting.
syntax on

" Sets the theme for the editor.
if $TERM_PROGRAM == "iTerm.app"
    colorscheme peachpuff
    set background=light

    " Fix Bad Spelling highlight color. Default bg is white - hard to read.
    highlight SpellBad ctermbg=196
else
    colorscheme desert
    set background=dark
endif

" Italicize comments.
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"
highlight Comment gui=italic cterm=italic

" Set utf8 as standard encoding and en_US as the standard language.
set encoding=utf8

" Use Unix as the standard file type.
set ffs=unix,dos,mac

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember.
set history=700

" Enable indentation.
filetype plugin indent on

" Set to autoread when a file is changed from the outside.
set autoread

" With a map leader it's possible to do extra key combinations
" like <leader>w saves the current file.
let mapleader = ","
let g:mapleader = ","

" Fast saving.
nmap <leader>w :w!<cr>

" Fast switching between windows.
nmap <leader>t <C-w>w

" :W sudo saves the file.
" (useful for handling the permission-denied error)
command W w !sudo tee % > /dev/null

" <leader>l redraws the screen and removes any search highlighting.
nnoremap <leader>l :nohl<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set 7 lines to the cursor - when moving vertically using j/k.
set so=7

" Turn on the WiLd menu.
set wildmenu

" Ignore compiled files.
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
else
    set wildignore+=.git\*,.hg\*,.svn\*
endif

" Always show the current position.
set ruler

" Always show the line numbers.
set nu

" Toggle relative numbers.
function! NumberToggle()
    if(&relativenumber == 1)
        set norelativenumber
    else
        set relativenumber
    endif
endfunc

nnoremap <leader>nt :call NumberToggle()<cr>

" Set column width to be 80 characters and highlight it.
highlight ColorColumn ctermbg=235 guibg=#2c2d27
set colorcolumn=80

" Height of the command bar.
set cmdheight=2

" A buffer becomes hidden when it is abandoned.
set hid

" Configure backspace so it acts as it should act.
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case when searching.
set ignorecase

" When searching, try to be smart about cases.
set smartcase

" Highlight search results.
set hlsearch

" Makes search act like search in modern browsers.
set incsearch

" Don't redraw while executing macros (good performance config).
set lazyredraw

" For regular expressions, turn magic on.
set magic

" Add a bit extra margin to the left.
set foldcolumn=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs.
set expandtab

" Be smart when using tabs.
set smarttab

" 1 tab = 4 spaces.
set shiftwidth=4
set tabstop=4

" However, use 2 spaces for JavaScript files.
autocmd Filetype javascript setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2 colorcolumn=120

" Use 2 spaces for Java files (Formatting according to Google-Java-Format).
autocmd Filetype java setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2 colorcolumn=101

" Linebreak on 120 characters.
set lbr
set tw=120

" Set autoindent, smartindent and wrap lines.
set ai
set si
set wrap

""""""""""""""""""""""""""""""
" => Status line
""""""""""""""""""""""""""""""
" Always show the status line.
set laststatus=2

" Settings for 'lightline' plugin.
let g:lightline = {
            \     'active': {
            \         'left': [['mode', 'paste' ], ['readonly', 'filename', 'modified']],
            \         'right': [['lineinfo'], ['percent'], ['fileformat', 'fileencoding']]
            \     }
            \ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character.
map 0 ^

" Map 'Ctrl-O' to ':NerdTreeToggle'
map <C-o> :NERDTreeToggle<CR>

" Remap 'Esc' key.
:imap jk <Esc>

" Move a line of text using ALT+[jk] or Comamnd+[jk] on mac.
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

if has("mac") || has("macunix")
    nmap <D-j> <M-j>
    nmap <D-k> <M-k>
    vmap <D-j> <M-j>
    vmap <D-k> <M-k>
endif

" Delete trailing white space on save.
func! DeleteTrailingWS()
    exe "normal mz"
    %s/\s\+$//ge
    exe "normal `z"
endfunc

autocmd BufWrite * :call DeleteTrailingWS()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Linting Markdown settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Treat `.md` as Markdown.
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" Enable fenced code block syntax highlighting in Markdown.
let g:markdown_fenced_languages = ['c', 'cpp', 'python', 'java', 'bash=sh', 'sql']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => vim/codefmt settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable codefmt's default mappings on the <Leader>= prefix.
Glaive codefmt plugin[mappings]
Glaive codefmt google_java_executable="java -jar /Users/mohitsakhuja/google-java-format-1.6-all-deps.jar"

augroup autoformat_settings
    autocmd FileType bzl AutoFormatBuffer buildifier
    autocmd FileType c,cpp,proto AutoFormatBuffer clang-format
    autocmd FileType dart AutoFormatBuffer dartfmt
    autocmd FileType go AutoFormatBuffer gofmt
    autocmd FileType gn AutoFormatBuffer gn
    autocmd FileType html,css,json AutoFormatBuffer js-beautify
    autocmd FileType java AutoFormatBuffer google-java-format
    autocmd FileType python AutoFormatBuffer autopep8
    autocmd FileType markdown AutoFormatBuffer mdl
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => ALE settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use ESLint for linting graphql, js and jsx files.
let g:ale_linters = {
            \  'graphql': ['eslint'],
            \  'javascript': ['eslint'],
            \  'jsx': ['eslint']
            \}

" Use ESLint for fixing graphql, js and jsx files.
let g:ale_fixers = {
            \  'graphql': ['eslint'],
            \  'javascript': ['eslint'],
            \  'jsx': ['eslint']
            \}

" Display errors.
let g:ale_sign_column_always = 1

" Fix errors on saving.
let g:ale_fix_on_save = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Emmet settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:user_emmet_settings = {
  \  'javascript.jsx' : {
    \      'extends' : 'jsx',
    \  },
  \}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Returns true if paste mode is enabled.
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    en
    return ''
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Miscellaneous
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Fix Python Path (for YCM).
let g:ycm_path_to_python_interpreter="/usr/local/bin/python3"

" Silence the warning displayed due to difference in python versions.
if has('python3')
    silent! python3 1
endif

" Settings for C/C++ semantic completion.
let g:ycm_global_ycm_extra_conf = "~/.vim/bundle/YouCompleteMe/third_party/ycmd/.ycm_extra_conf.py"

" Required by vim-javacomplete2.
autocmd FileType java setlocal omnifunc=javacomplete#Complete

" Settings for vim-commentary.
autocmd FileType javascript.jsx setlocal commentstring={/*\ %s\ */}

" Open NERDTree by default.
let g:nerdtree_tabs_open_on_console_startup = 1

" Show hidden files in NERDTree by default.
let NERDTreeShowHidden=1

" Hide byte files.
let NERDTreeIgnore = ['\.pyc$', '\.class$', '\.o$', '\.swp$']

" Sort files.
let NERDTreeSortOrder=['\.c$']

