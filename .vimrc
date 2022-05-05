" NOTE: Use space to fold/unfold the categories!
set encoding=utf-8
scriptencoding utf-8

if has('win32') || has('win64')
	let g:onWin = 1
else
	let g:onWin = 0
endif

call plug#begin() " {{{

Plug 'bling/vim-airline'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'ntpeters/vim-better-whitespace'
Plug 'drewtempelmeyer/palenight.vim' " Colroscheme
Plug 'w0rp/ale'                      " Syntax checking
Plug 'editorconfig/editorconfig-vim'

call plug#end() " }}}
" Basic config {{{
"
" Text and side panel widths
let s:pd_textwidth=80

function GetSideWidth()
	return  max([30, min([50, ((&columns - s:pd_textwidth - 5 ) / 2) ])])
endfunction

" set nocompatible		" Load non-Vi-compaitlbe settings
syntax on			" Syntax highlighting
filetype plugin indent on	" Use indening
" set autoread			" read open files again when changed outside Vim
set modeline
set autowrite			" write a modified buffer on each :next , ...
set backspace=indent,eol,start	" allow backspacing over everything in insert mode
" set backup			" keep a backup file
" set browsedir=current		" which directory to use for the file browser
set history=50			" command line history
set incsearch			" use incremental search
set nowrap			" do not wrap lines
" set ruler			" show the cursor position all the time
set laststatus=2		" always show the statusbar
set shiftwidth=4		" number of spaces to use for each step of indent
set tabstop=4			" number of spaces that a <Tab> in the file counts for
set showcmd			" display incomplete commands
set expandtab			" insert spaces instead of tabs
set novisualbell		" visual bell instead of beeping
set t_vb=
let &textwidth=s:pd_textwidth
set noautochdir 		" change the current working directory
set secure                      " secure loading of non-default vimrc
set pastetoggle=<F9>            " Toggle pasting mode (disables indenting)
set scrolloff=10                " Keep this many lines visible below cursor
set completeopt-=preview        " remove extended preview from autoinserts (scratch window)
set hlsearch                    " highlight searches
" set updatetime=500 		" Milliseconds between writes (affects git-gutter update speed)
set foldmethod=syntax           " Syntax based folding
set foldlevel=999               " Display everything by default
set foldnestmax=1
set wildmode=longest,list	" Set tab command completion behaivor
set clipboard=unnamed		" Yanks stuff directly  to clipboard
set cinoptions=:0		" Make switch & case have same indention
set number
set nocscopeverbose             " prevent addedd cscope database message

set backupdir=~/tmp/vimbackup,.,~
set directory=~/tmp/vimbackup,.,~
if g:onWin
    set backupdir=~/vimbackup
    set directory=~/vimbackup
endif

" Disable spellchecks in comments
let g:tex_comment_nospell=1

" colorshceme stuff
set t_ut=

set background=dark
colorscheme palenight

" Italics for my favorite color scheme
let g:palenight_terminal_italics=1

" Show indention on screen
set list listchars=tab:┆\ ,trail:·,extends:»,precedes:«,nbsp:×

" <cpace> - Toggle folds
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf

" Make vim remember position in file
if has('autocmd')
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" }}}
" LLVM file type configuration {{{
" source: https://github.com/llvm/llvm-project

" Enable syntax highlighting for LLVM files. To use, copy
" utils/vim/syntax/llvm.vim to ~/.vim/syntax .
augroup filetype
  au! BufRead,BufNewFile *.ll     set filetype=llvm
augroup END

" Enable syntax highlighting for tablegen files. To use, copy
" utils/vim/syntax/tablegen.vim to ~/.vim/syntax .
augroup filetype
  au! BufRead,BufNewFile *.td     set filetype=tablegen
augroup END

" Enable syntax highlighting for reStructuredText files. To use, copy
" rest.vim (http://www.vim.org/scripts/script.php?script_id=973)
" to ~/.vim/syntax .
augroup filetype
 au! BufRead,BufNewFile *.rst     set filetype=rest
augroup END

" }}}
" Plugin: ALE {{{
" -----------------------------------------------------------------

let g:ale_linters = {
			\ 'tex': ['proselint', 'chktex']
			\ }

let g:ale_completion_enabled = 1

nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

" }}}
" Plugin: airline {{{
" -----------------------------------------------------------------
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
" The `unique_tail_improved` - another algorithm, that will smartly uniquify
" buffers names with similar filename, suppressing common parts of paths.
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

" }}}
" Plugin: better-whitesapce {{{
" -----------------------------------------------------------------
highlight ExtraWhitespace ctermbg=black
" autocmd BufWritePre * StripWhitespace

" }}}
" Plugin: local_vimrc {{{

let g:local_vimrc = ['.vimrc_local.vim', '_vimrc_local.vim']

" }}}
" FileType config {{{

" automatically convert PDF files to text
let g:pdf_convert_on_edit=1

augroup git
	au!
	au BufEnter COMMIT_EDITMSG setlocal spell
	au BufEnter COMMIT_EDITMSG setlocal textwidth=75
augroup END

augroup filetype_mail
	au!
	au FileType mail setlocal fo+=aw
	au FileType mail setlocal textwidth=75
	au FileType mail setlocal spell
augroup END

augroup filetype_kconfig
	au!
	au BufEnter Kconfig* set spell
augroup END

" }}}

if !empty(glob("~/.vimrc_local"))
	source ~/.vimrc_local
endif

" vim: noexpandtab shiftwidth=8 tabstop=8 fdm=marker foldlevel=0
