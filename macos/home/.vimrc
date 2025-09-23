set nocompatible
filetype off

Plug 'tpope/vim-fugitive'
Plug 'junegunn/goyo.vim'
Plug 'preservim/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'terryma/vim-multiple-cursors'
Plug 'mattn/emmet-vim'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn on the WiLd menu.
set wildmenu

" Ignore compiled files.
set wildignore=*.o,*~,*.pyc
if has("win16") || has("win32")
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store
else
    set wildignore+=.git\*,.hg\*,.svn\*
endif

" Don't redraw while executing macros (good performance config).
set lazyredraw

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set colorcolumn to be at 81 characters for Markdown files.
autocmd Filetype markdown setlocal colorcolumn=81

" Set colorcolumn to be at 101 characters for Java files.
autocmd Filetype java setlocal colorcolumn=101

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Map 'Ctrl-O' to ':NERDTreeToggle'
map <C-o> :NERDTreeTabsToggle<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Linting Markdown settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Treat `.md` as Markdown.
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Emmet settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:user_emmet_settings = {
            \   'javascript.jsx' : {
            \       'extends' : 'jsx',
            \   },
            \}

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
            \   'vendor[[dir]]',
            \   'build[[dir]]'
            \]

" Sort files/folders.
let NERDTreeSortOrder = ['\/$', '\.c$', '\.java$', '\~$']

" Sort items naturally.
let NERDTreeNaturalSort = 1

" Set the default width of Nerd Tree windows.
let NERDTreeWinSize = 50

" When switching into a tab, make sure that focus is on the file window, not in the NERDTree window.
let g:nerdtree_tabs_focus_on_files=1

if $TERM_PROGRAM != 'vscode'
    " Open NERDTree on Vim startup.
    let g:nerdtree_tabs_open_on_console_startup=1
endif
