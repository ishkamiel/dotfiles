" This is a lite vimrc (without YouCompleteMe and other 'heavy' stuff)
" (check $DOTFILES/.profile_local for why/when this gets linked to ~/.vimrc)

call plug#begin()

Plug 'scrooloose/NERDTree'
Plug 'bling/vim-airline'
Plug 'tpope/vim-commentary'
Plug 'morhetz/gruvbox'
Plug 'ntpeters/vim-better-whitespace'
Plug 'majutsushi/tagbar'
Plug 'lervag/vimtex', { 'for': 'tex' }

call plug#end()

" -----------------------------------------------------------------
" Basic config
" -----------------------------------------------------------------
" Text and side panel widths
let s:pd_textwidth=100
let s:pd_sidewidth = max([10, min([40, ((&columns - s:pd_textwidth - 5 ) / 2) ])])

set nocompatible                " Load non-Vi-compaitlbe settings
syntax on                       " Syntax highlighting
filetype plugin indent on       " Use indening
" set autoread        	    	" read open files again when changed outside Vim
set autowrite             	" write a modified buffer on each :next , ...
set backspace=indent,eol,start 	" allow backspacing over everything in insert mode
set backup			" keep a backup file
" set browsedir=current   	" which directory to use for the file browser
set history=50			" command line history
set incsearch             	" use incremental search
set nowrap                	" do not wrap lines
" set ruler			" show the cursor position all the time
set laststatus=2		" always show the statusbar
set shiftwidth=8        	" number of spaces to use for each step of indent
set tabstop=8            	" number of spaces that a <Tab> in the file counts for
set showcmd			" display incomplete commands
" set expandtab                 " insert spaces instead of tabs
set visualbell 		        " visual bell instead of beeping
set t_vb=
let &textwidth=s:pd_textwidth
set noautochdir            	" change the current working directory
set secure                      " secure loading of non-default vimrc
set pastetoggle=<F9>            " Toggle pasting mode (disables indenting)
set scrolloff=10                " Keep this many lines visible below cursor
set completeopt-=preview        " remove extended preview from autoinserts (scratch window)
set hlsearch                    " highlight searches
" set updatetime=500       	" Milliseconds between writes (affects git-gutter update speed)
set foldmethod=syntax           " Syntax based folding
set foldlevel=999               " Display everything by default
set foldnestmax=1
set wildmode=longest,list	" Set tab command completion behaivor

set backupdir=~/tmp/vimbackup,.,~
set directory=~/tmp/vimbackup,.,~
if has("win32") || has("win16")
    set backupdir=~/vimbackup
    set directory=~/vimbackup
endif


" Disable spellchecks in comments
let g:tex_comment_nospell=1

" colorshceme stuff
set t_ut=
set background=dark
colorscheme gruvbox

" <cpace> - Toggle folds
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf

if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif


" -----------------------------------------------------------------
" Plugin config
" -----------------------------------------------------------------

" NERDTree
nmap <F7> :NERDTreeToggle<CR>

let g:NERDTreeWinSize=s:pd_sidewidth

" airline stuff
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" better-whitesapce
highlight ExtraWhitespace ctermbg=black
" autocmd BufWritePre * StripWhitespace

" tagbar
nmap <F8> :TagbarToggle<CR>

highlight ExtraWhitespace ctermbg=black

" -----------------------------------------------------------------
" GVim config
" -----------------------------------------------------------------

" Some gvim options
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar
