" ------------------------------------------------------------------------------------------
" GENERIC CONFIGS
set number

set encoding=utf8  " Set utf8 as standard encoding and en_US as the standard language

set history=700     " Sets how many lines of history VIM has to remember
set undolevels=300  " use many muchos levels of undo
set autoread        " Set to auto read when a file is changed from the outside

set backspace=indent,eol,start  " Allow backspacing over everything in insert mode

" ENABLE FILETYPE PLUGINS
filetype plugin on
syntax enable
syntax on
filetype indent on  " Load filetype-specific indent files

" INDENTATION SETTINGS
set shiftwidth=4   " Operation >> indents 4 columns; << unindents 4 columns
set tabstop=4      " A hard TAB displays as 4 columns
set softtabstop=4  " Insert/delete 4 spaces when hitting a TAB/BACKSPACE
set expandtab      " Insert spaces when hitting TABs
set smarttab       " Be smart when using tabs
set shiftround     " Round indent to multiple of 'shiftwidth'

set autoindent     " Align the new line indent with the previous line
set smartindent    " Smart indent
set wrap           " Wrap lines

" AUTOCOMPLETE
set wildmenu
set wildmode=longest:list,full
set wildignore=*.o,*~,*.pyc,*.class

" TURN BACKUP OFF, SINCE MOST STUFF IS IN SVN, GIT ET.C ANYWAY...
" BACKUP
set nobackup
set nowb
set noswapfile

" SEARCH
set incsearch  " Search as characters are entered
set smartcase  " When searching try to be smart about cases
set hlsearch   " Highlight search results

" LEADER SHORTCUTS
let mapleader=","  " Leader is comma

" edit vimrc/zshrc and load vimrc bindings
nnoremap <leader>ev :tabe $MYVIMRC<CR>     " Edit vimrc
nnoremap <leader>ez :tabe ~/.zshrc<CR>     " Edit zshrc
nnoremap <leader>sv :source $MYVIMRC<CR>  " Source vimrc

" AUTOGROUPS
augroup configgroup
    autocmd!
    autocmd VimEnter * highlight clear SignColumn
    autocmd FileType ruby setlocal tabstop=2
    autocmd FileType ruby setlocal shiftwidth=2
    autocmd FileType ruby setlocal softtabstop=2
    autocmd FileType ruby setlocal commentstring=#\ %s
    autocmd FileType python setlocal commentstring=#\ %s
    autocmd BufEnter *.cls setlocal filetype=java
    autocmd BufEnter *.zsh-theme setlocal filetype=zsh
    autocmd BufEnter Makefile setlocal noexpandtab
    autocmd BufEnter *.sh setlocal tabstop=2
    autocmd BufEnter *.sh setlocal shiftwidth=2
    autocmd BufEnter *.sh setlocal softtabstop=2

" ------------------------------------------------------------------------------------------
" GRAPHIC SETTINGS
set laststatus=2  " This makes Vim show a status line even when only one window is shown

" CURSOR LINE
set ruler         " Always show current position
set cursorline
hi CursorLine term=bold cterm=bold guibg=Grey40

set showmatch     " Show matching brackets when text indicator is over them
set mat=2         " How many tenths of a second to blink when matching brackets

set lazyredraw    " Don't redraw while executing macros (good performance config)

let g:airline_powerline_fonts = 1

" FOLDING SETTINGS
set foldenable          " enable folding
set foldlevelstart=10   " open most folds by default
set foldnestmax=10      " 10 nested fold max
nnoremap <space> za     " Space open/closes folds
set foldmethod=indent   " fold based on indent level
set modelines=1

" ------------------------------------------------------------------------------------------
" PLUGINS
if filereadable(glob("~/.vimrc.plugins"))
    source ~/.vimrc.plugins
endif

" HIGHLIGHT TRAILING SPACES
" Must be defined after plugins since they override the syntax coloring and
" that somehow breaks it
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" ------------------------------------------------------------------------------------------
" PROJECT SPECIFIC CONFIGS
if filereadable(glob("~/.vimrc.d/$REPO_NAME.vimrc"))
    source ~/.vimrc.d/$REPO_NAME.vimrc
endif

" vim: colorcolumn=100
