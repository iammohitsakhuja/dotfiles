set nocompatible
filetype off

call plug#begin('~/.vim/plugged')
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/goyo.vim'
Plug 'preservim/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
" TODO: Check why the colors from the following aren't working.
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'itchyny/lightline.vim'
Plug 'terryma/vim-multiple-cursors'
Plug 'mattn/emmet-vim'
Plug 'sheerun/vim-polyglot'
Plug 'ap/vim-css-color', { 'for': ['css', 'scss'] }
Plug 'psliwka/vim-smoothie'
Plug 'Yggdroot/indentLine'
Plug 'itchyny/vim-gitbranch'
Plug 'mhinz/vim-startify'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'uiiaoo/java-syntax.vim'

" Colors & themes.
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'challenger-deep-theme/vim', { 'as': 'challenger-deep' }
Plug 'joshdick/onedark.vim', { 'as': 'onedark' }
Plug 'drewtempelmeyer/palenight.vim', { 'as': 'palenight' }
Plug 'ayu-theme/ayu-vim', { 'as': 'ayu' }
Plug 'mountain-theme/Mountain', { 'rtp': 'vim' }
Plug 'tomasr/molokai', { 'as': 'molokai' }

" Has to be loaded as the last one.
Plug 'ryanoasis/vim-devicons'
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting.
syntax on

" Sets the theme for the editor.
let ayucolor="dark" " Check whether this is required, if we are not using `ayu` as the colorscheme.
colorscheme mountain
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
nmap <leader>s :w!<cr>

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

" Shortcuts for switching between buffers.
map <leader>n :bn<cr>
map <leader>p :bp<cr>

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
set cmdheight=3

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

" Set colorcolumn to be at 81 characters for Markdown files.
autocmd Filetype markdown setlocal colorcolumn=81

" Set colorcolumn to be at 101 characters for Java files.
autocmd Filetype java setlocal colorcolumn=101

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

function! CocCurrentFunction()
    return get(b:, 'coc_current_function', '')
endfunction

function! GetFileType()
    return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype . ' ' . WebDevIconsGetFileTypeSymbol() : 'no ft') : ''
endfunction

function! GetFileFormat()
    return winwidth(0) > 70 ? (&fileformat . ' ' . WebDevIconsGetFileFormatSymbol()) : ''
endfunction

" Settings for 'lightline' plugin.
" Settings for 'lightline' plugin.
let g:lightline = {
    \   'active': {
    \       'left': [
    \           ['mode', 'paste'],
    \           ['gitbranch', 'readonly', 'filename', 'fileicon', 'modified'],
    \           ['cocstatus', 'currentfunction'],
    \       ],
    \       'right': [
    \           ['lineinfo'],
    \           ['percent'],
    \           ['filetype', 'fileformat', 'fileencoding']
    \       ]
    \   },
    \   'colorscheme': 'ayu',
    \   'component_function': {
    \       'cocstatus': 'coc#status',
    \       'currentfunction': 'CocCurrentFunction',
    \       'gitbranch': 'gitbranch#name',
    \       'filetype': 'GetFileType',
    \       'fileformat': 'GetFileFormat',
    \       'fileicon': 'WebDevIconsGetFileTypeSymbol',
    \   },
    \ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Remap VIM 0 to first non-blank character.
map 0 ^

" Map 'Ctrl-O' to ':NERDTreeToggle'
map <C-o> :NERDTreeTabsToggle<CR>

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

" Open Startify on Vim startup.
autocmd VimEnter *
        \   if !argc()
        \ |   Startify
        \ |   wincmd w
    \ | endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => FZF settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let $FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => IndentLine settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:indentLine_setColors = 0
let g:indentLine_leadingSpaceEnabled = 1
let g:indentLine_leadingSpaceChar = '∙'
let g:indentLine_char = '∙'
let g:indentLine_bufNameExclude = ['NERD_tree.*']

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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Coc.nvim Config
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Use <TAB> for selections ranges.
" NOTE: Requires 'textDocument/selectionRange' support from the language server.
" coc-tsserver, coc-python are the examples of servers that support it.
nmap <silent> <TAB> <Plug>(coc-range-select)
xmap <silent> <TAB> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

let g:coc_global_extensions = [
    \   'coc-actions',
    \   'coc-blade',
    \   'coc-css',
    \   'coc-eslint',
    \   'coc-html',
    \   'coc-java',
    \   'coc-json',
    \   'coc-pairs',
    \   'coc-prettier',
    \   'coc-rust-analyzer',
    \   'coc-snippets',
    \   'coc-tsserver',
    \   'coc-vimlsp',
    \   'coc-yaml',
    \   ]
