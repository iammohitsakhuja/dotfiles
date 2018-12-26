set nocompatible
filetype off

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf', { 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'scrooloose/nerdtree'
Plug 'airblade/vim-gitgutter'
Plug 'itchyny/lightline.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'jiangmiao/auto-pairs'
Plug 'mattn/emmet-vim'
Plug 'sheerun/vim-polyglot'
Plug 'Valloric/YouCompleteMe'
Plug 'artur-shaik/vim-javacomplete2', { 'for': 'java' }
Plug 'ap/vim-css-color', { 'for': ['css', 'scss'] }
Plug 'w0rp/ale'
Plug 'rizzatti/dash.vim'
Plug 'challenger-deep-theme/vim', { 'as': 'challenger-deep' }
Plug 'joshdick/onedark.vim', { 'as': 'onedark' }
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting.
syntax on

" Sets the theme for the editor.
colorscheme onedark
if $TERM_PROGRAM != "Apple_Terminal"
    if has('nvim') || has('termguicolors')
        set termguicolors
    endif
endif

" Italicize comments.
let &t_ZH="\e[3m"
let &t_ZR="\e[23m"
highlight Comment gui=italic cterm=italic

" Set utf8 as standard encoding and en_US as the standard language.
set encoding=utf8

" Use Unix as the standard file type.
set ffs=unix,dos,mac

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember.
set history=700

" Enable indentation.
filetype plugin indent on

" Set to autoread when a file is changed from the outside.
set autoread

" With a map leader it's possible to do extra key combinations like <leader>w saves the current file.
let mapleader = ","
let g:mapleader = ","

" Fast saving.
nmap <leader>w :w!<cr>

" Fast switching between windows.
nmap <leader>t <C-w>w

" :W sudo saves the file. Useful for handling the permission-denied error.
command W w !sudo tee % > /dev/null

" <leader>l redraws the screen and removes any search highlighting.
nnoremap <leader>l :nohl<cr>

" <leader>F shortcut for :Files command of Fzf.
nnoremap <leader>F :Files<cr>

" Toggle relative numbers.
nnoremap <leader>nt :call NumberToggle()<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

" Set column width to be 120 characters and highlight it.
highlight ColorColumn ctermbg=235 guibg=#464b59
set colorcolumn=120

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

" Faster scrolling.
set nocursorline

" For regular expressions, turn magic on.
set magic

" Add a bit extra margin to the left.
set foldcolumn=1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use spaces instead of tabs.
set expandtab

" Be smart when using tabs.
set smarttab

" 1 tab = 4 spaces.
set shiftwidth=4
set tabstop=4

" Use 2 spaces for JavaScript files.
autocmd Filetype javascript setlocal expandtab tabstop=2 shiftwidth=2 softtabstop=2

" Set colorcolumn to be at 81 characters for Markdown files.
autocmd Filetype markdown setlocal colorcolumn=81

" Linebreak on 150 characters.
set lbr
set tw=150

" Set autoindent, smartindent and wrap lines.
set ai
set si
set wrap

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Status line
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Always show the status line.
set laststatus=2

" Settings for 'lightline' plugin.
let g:lightline = {
            \     'active': {
            \         'left': [['mode', 'paste' ], ['readonly', 'filename', 'modified']],
            \         'right': [['lineinfo'], ['percent'], ['fileformat', 'fileencoding']]
            \     },
            \     'colorscheme': 'challenger_deep'
            \ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character.
map 0 ^

" Map 'Ctrl-O' to ':NERDTreeToggle'
map <C-o> :NERDTreeToggle<CR>

" Remap 'Esc' key.
:imap jk <Esc>

" Move lines of text using Ctrl+[jk].
nmap <C-j> mz:m+<cr>`z
nmap <C-k> mz:m-2<cr>`z
vmap <C-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <C-k> :m'<-2<cr>`>my`<mzgv`yo`z

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Linting Markdown settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Treat `.md` as Markdown.
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" Enable fenced code block syntax highlighting in Markdown.
let g:markdown_fenced_languages = ['c', 'cpp', 'python', 'java', 'bash=sh', 'sql']

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => ALE settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:ale_linter_aliases = {
            \   'bash': 'sh',
            \   'csh': 'sh',
            \   'zsh': 'sh',
            \}

let g:ale_linters = {
            \   'sh': ['shell'],
            \   'c': ['clang'],
            \   'cpp': ['clang'],
            \   'css': ['stylelint'],
            \   'html': ['stylelint'],
            \   'java': ['javac'],
            \   'javascript': ['eslint'],
            \   'json': [],
            \   'markdown': ['mdl'],
            \   'python': [],
            \   'scss': ['stylelint'],
            \}

let g:ale_fixers = {
            \   '*': ['remove_trailing_lines', 'trim_whitespace'],
            \   'sh': ['shfmt'],
            \   'c': ['clang-format'],
            \   'cpp': ['clang-format'],
            \   'css': ['prettier', 'remove_trailing_lines', 'stylelint', 'trim_whitespace'],
            \   'java': ['google_java_format'],
            \   'javascript': ['eslint', 'prettier', 'remove_trailing_lines', 'trim_whitespace'],
            \   'json': ['fixjson', 'prettier', 'remove_trailing_lines', 'trim_whitespace'],
            \   'markdown': ['prettier', 'remove_trailing_lines', 'trim_whitespace'],
            \   'python': ['black'],
            \   'scss': ['prettier', 'remove_trailing_lines', 'stylelint', 'trim_whitespace'],
            \}

let g:ale_java_google_java_format_options = '--aosp'

" Display errors.
let g:ale_sign_column_always = 1

" Fix errors on saving.
let g:ale_fix_on_save = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Emmet settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:user_emmet_settings = {
            \   'javascript.jsx' : {
            \       'extends' : 'jsx',
            \   },
            \}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Auto-completion settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Settings for C/C++ semantic completion with YouCompleteMe.
let g:ycm_global_ycm_extra_conf = "~/.vim/plugged/YouCompleteMe/third_party/ycmd/.ycm_extra_conf.py"

" Required by vim-javacomplete2.
autocmd FileType java setlocal omnifunc=javacomplete#Complete

" Enable CSS autocompletion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vim-commentary settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Change default comment style for JSX files.
" autocmd FileType javascript.jsx setlocal commentstring={/*\ %s\ */}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => NERDTree settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Show hidden files in NERDTree by default.
let NERDTreeShowHidden = 1

" Hide these files/folders.
let NERDTreeIgnore = [
            \   '\.DS_Store$',
            \   '\.pyc$',
            \   '\.class$',
            \   '\.o$',
            \   '\.swp$',
            \   '\.git$[[dir]]',
            \   'node_modules[[dir]]',
            \   'build[[dir]]'
            \]

" Sort files/folders.
let NERDTreeSortOrder = ['\/$', '\.c$', '\.java$', '\~$']

" Sort items naturally.
let NERDTreeNaturalSort = 1

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggles Relative Numbers on/off.
function! NumberToggle()
    if(&relativenumber == 1)
        set norelativenumber
    else
        set relativenumber
    endif
endfunction
