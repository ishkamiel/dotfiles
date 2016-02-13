" vim:fdm=marker foldlevel=0

" Load Vundle & Plugins {{{

" Load vundle {{{

set nocompatible
filetype off

" Vundle (vim plugin manager)
"
" To install:
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" This initializes plugin installation paths
if has("win32") || has("win16")
    let path='~/vimfiles/bundle'
    set rtp+=~/vimfiles/bundle/Vundle.vim
else
    set rtp+=~/.vim/bundle/Vundle.vim
endif
call vundle#rc()

Plugin 'gmarik/Vundle.vim'          " Vundle itself

" }}}

" Vundle Plugins
"-------------------------------------------------------------------------------

" ------- Language specific stuff
" Plugin 'guns/vim-clojure-static'    " Clojure
" Plugin 'maksimr/vim-jsbeautify'     " Javascript
" Plugin 'groenewege/vim-less'        " LESS
" Plugin 'godlygeek/tabular'          " Markdown (dependency)
" Plugin 'plasticboy/vim-markdown'    " Markdown
" Plugin 'derekwyatt/vim-scala'       " Scala
" Plugin 'rdunklau/vim-perltidy'      " Perl
" Plugin 'perl-support.vim'           " Perl

"  NERDTree - https://github.com/scrooloose/nerdtree
Plugin 'scrooloose/NERDTree'
Plugin 'jistr/vim-nerdtree-tabs'
Plugin 'Xuyuanp/nerdtree-git-plugin'
" ------- colorschemes
" Plugin 'flazz/vim-colorschemes'
" Plugin 'altercation/vim-colors-solarized'
" ------- tagbar
Plugin 'majutsushi/tagbar'
" ------- YouCompleteMe
" Plugin 'Valloric/YouCompleteMe'
" ------- UltiSnips
Plugin 'SirVer/ultisnips'
Plugin 'honza/vim-snippets'
" ------- tcomment (comment stuff in/out)
Plugin 'tpope/vim-commentary'
" ------- vim-fugitive (Git integration)
"Plugin 'tpope/vim-fugitive'
" ------- vim-pencil (writing?)
"Plugin 'reedes/vim-pencil'
" ------- Syntastic
Plugin 'scrooloose/syntastic'
" ------- vim-airline (statusbar)
Plugin 'bling/vim-airline'

"-------------------------------------------------------------------------------
" }}} Vundle plugins

" General vim config {{{
"-------------------------------------------------------------------------------
set nocompatible                " Load non-Vi-compaitlbe settings
syntax on                       " Syntax highlighting
filetype plugin indent on       " Use indening
" set autoread              	" read open files again when changed outside Vim
" set autowrite             	" write a modified buffer on each :next , ...
set backspace=indent,eol,start 	" allow backspacing over everything in insert mode
set backup						" keep a backup file
set browsedir=current   		" which directory to use for the file browser
set history=50					" command line history
set incsearch             		" use incremental search
set nowrap                		" do not wrap lines
set ruler						" show the cursor position all the time
set shiftwidth=4        		" number of spaces to use for each step of indent
set showcmd						" display incomplete commands
set tabstop=4            		" number of spaces that a <Tab> in the file counts for
set expandtab                   " insert spaces instead of tabs
set visualbell 		           	" visual bell instead of beeping
set t_vb=
set textwidth=100               " text width for autoformatt stuff, or something
set colorcolumn=1000            " display a bar (e.g. for textwdith)
" set autochdir            		" change the current working directory
set exrc                        " find vimrc in working directory
set secure                      " secure loading of non-default vimrc
set pastetoggle=<F9>            " Toggle pasting mode (disables indenting)
set scrolloff=10                " Keep this many lines visible below cursor
set spelllang=en                " languages used for spelling
set completeopt-=preview        " remove extended preview from autocinserts (scratch window)
set hlsearch                    " highlight searches

set backupdir=~/.tmp/vimbackup,.,~
set directory=~/.tmp/vimbackup,.,~

" Folding {{{
set foldmethod=syntax           " Syntax based folding
set foldlevel=999               " Display everything by default
" set foldlevelstart=1
set foldnestmax=2
" set foldcolumn=4
" inoremap <F9> <C-O>za
" nnoremap <A-Space> za
" onoremap <F9> <C-C>za
" }}}

"-------------------------------------------------------------------------------
" }}}

" Custom config variables {{{
"-------------------------------------------------------------------------------

" Store this for more convenient checking of platform
let onWin = 0
if has("win32") || has("win16")
    let onWin = 1
endif

let s:pd_textwidth=100
let s:pd_sidewidth = max([10, min([40, ((&columns - s:pd_textwidth - 5 ) / 2) ])])

" Modify config accordingly
let &textwidth=s:pd_textwidth   " (Need to use let &variable syntax)

"-------------------------------------------------------------------------------
" }}}

" Other vim tweaks {{{
"-------------------------------------------------------------------------------

" Remember file posittions
if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" disable arrow keys
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>

" Windows specific overrides
if has("win32") || has("win16")
    set backupdir=~/vimbackup
    set directory=~/vimbackup
    set lines=40 columns=160
endif

" GVim config
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

"-------------------------------------------------------------------------------
"}}}

" Color themes and styling {{{
"-------------------------------------------------------------------------------

set background=dark
set t_Co=256
set t_ut=
" colorscheme elflord
" colorscheme vividchalk
" colorscheme jellybeans
" colorscheme grb256
" colorscheme 0x7A69_dark " seems to mess with highlighting
" colorscheme solarized
" hi FoldColumn ctermfg=DarkCyan ctermbg=8

"-------------------------------------------------------------------------------
" }}}

" keyboard maps {{{
"-------------------------------------------------------------------------------

" <cpace> - Toggle folds
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf

" <C-B> - Create huge 'header' comment box
nnoremap <C-b> :center 80<cr>hhv0r#A<space><esc>40A#<esc>d80<bar>YppVr#kk.

" <F5> - Remove trailing whitespace
nnoremap <silent> <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

"-------------------------------------------------------------------------------
" }}}

" C++ {{{
"-------------------------------------------------------------------------------

set cinoptions+=g0  " don't indent public/private/protected
set cinoptions+=N-s " don't indent namesapces

"-------------------------------------------------------------------------------
" }}}
" Clojure {{{
"-------------------------------------------------------------------------------

" autocmd BufRead,BufNewFile *.clj setlocal foldlevel=999
" autocmd BufRead,BufNewFile *.clj setlocal foldcolumn=0

"-------------------------------------------------------------------------------
" }}}
" CSS {{{
"-------------------------------------------------------------------------------

" autocmd FileType css noremap <buffer> <c-r> :call CSSBeautify()<cr>

"-------------------------------------------------------------------------------
" }}}
" HTML {{{
"-------------------------------------------------------------------------------

" augroup pd_filetype_html
"     autocmd!
"     autocmd FileType html noremap <buffer> <c-r> :call HtmlBeautify()<cr>
" augroup END

"-------------------------------------------------------------------------------
" }}}
" Javascript {{{
"-------------------------------------------------------------------------------

" augroup pd_filetype_javascript
"     autocmd!
"     autocmd FileType javascript noremap <buffer>  <c-r> :call JsBeautify()<cr>
" augroup END

"-------------------------------------------------------------------------------
" }}}
" LaTex {{{
"-------------------------------------------------------------------------------

"augroup pd_filetype_tex
"    autocmd!
"    autocmd BufRead,BufNewFile *.tex setlocal spell
"    autocmd BufRead,BufNewFile *.tex setlocal wrap
"    autocmd BufRead,BufNewFile *.tex let &textwidth=(s:pd_textwidth-2)
"    autocmd BufRead,BufNewFile *.tex setlocal formatoptions=t1
"augroup END

"-------------------------------------------------------------------------------
" }}}
" Perl {{{
"-------------------------------------------------------------------------------

"augroup pd_filetype_perl
"    autocmd!
"    autocmd BufWritePost *.pm call SyntasticCheck()
"    autocmd BufWritePost *.pl call SyntasticCheck()
"    autocmd BufWritePost *.t call SyntasticCheck()
"augroup END
"
"let perl_fold=1
"let sh_fold_enabled=1
"let perl_extended_vars=1
"let perl_sync_dist=250

"-------------------------------------------------------------------------------
" }}}

" NERDTree {{{
"-------------------------------------------------------------------------------

" NERDTree_tabs manages most of this...
" autocmd vimenter * NERDTree
" map <C-n> :NERDTreeToggle<CR>
"let g:NERDTreeWinSize=s:pd_sidewidth
" close NERDTree if it's the last one left
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

"-------------------------------------------------------------------------------
" }}}
" NERDTree_tabs {{{
"-------------------------------------------------------------------------------

" g:nerdtree_tabs_open_on_gui_startup " (default: 1)
" Open NERDTree on gvim/macvim startup

let g:nerdtree_tabs_open_on_console_startup=1 " (default: 0)
" Open NERDTree on console vim startup

" g:nerdtree_tabs_no_startup_for_diff (default: 1)
" Do not open NERDTree if vim starts in diff mode

let g:nerdtree_tabs_smart_startup_focus=2 " (default: 1)
" On startup, focus NERDTree if opening a directory, focus file if opening a file. (When set to 2, always focus file window after startup).

" g:nerdtree_tabs_open_on_new_tab (default: 1)
" Open NERDTree on new tab creation (if NERDTree was globally opened by :NERDTreeTabsToggle)
"
" g:nerdtree_tabs_meaningful_tab_names (default: 1)
" Unfocus NERDTree when leaving a tab for descriptive tab names
"
" g:nerdtree_tabs_autoclose (default: 1)
" Close current tab if there is only one window in it and it's NERDTree
"
" g:nerdtree_tabs_synchronize_view (default: 1)
" Synchronize view of all NERDTree windows (scroll and cursor position)
"
" g:nerdtree_tabs_synchronize_focus (default: 1)
" Synchronize focus when switching windows (focus NERDTree after tab switch if and only if it was focused before tab switch)
"
let g:nerdtree_tabs_focus_on_files=1 " (default: 0)
" When switching into a tab, make sure that focus is on the file window, not in the NERDTree window. (Note that this can get annoying if you use NERDTree's feature "open in new tab silently", as you will lose focus on the NERDTree.)
"
" g:nerdtree_tabs_startup_cd (default: 1)
" When given a directory name as a command line parameter when launching Vim, :cd into it.
"
" g:nerdtree_tabs_autofind (default: 0)
" Automatically find and select currently opened file in NERDTree.

"-------------------------------------------------------------------------------
" }}}
" airline {{{
"-------------------------------------------------------------------------------

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

"-------------------------------------------------------------------------------
" }}}
" pencil {{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

"augroup pd_pencil
"    autocmd!
"    autocmd FileType markdown,mkd call pencil#init()
"    autocmd FileType text         call pencil#init({'wrap': 'hard'})
"    " autocmd FileType tex          call pencil#init({'wrap': 'hard'})
"augroup END

" }}}
" YouComepleteMe {{{
"-------------------------------------------------------------------------------

" Set YouCompleteMe trigger key
" let g:ycm_key_list_select_completion = ['<Down>']
" let g:ycm_key_list_previous_completion = ['<Up>']
" let g:ycm_extra_conf_globlist = ['~/gameProject/*']
" let g:ycm_use_ultisnips_completer = 1
" let g:ycm_collect_identifiers_from_comments_and_strings = 1

"-------------------------------------------------------------------------------
" }}}
" Syntastic {{{
"-------------------------------------------------------------------------------

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
"
let g:syntastic_aggregate_errors=0 " run all checkers and aggregate results
let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=2
let g:syntastic_loc_list_height=5
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=0
"
let g:syntastic_enable_balloons=1
let g:syntastic_enable_signs=1
"
"let g:syntastic_perl_checkers = ['perlcritic']

" let g:syntastic_enable_perl_checker = 1
" let g:syntastic_javascript_checkers = ['jshint']
" let g:syntastic_mode_map = { 'passive_filetypes': ['html'] } " don't check html
" let g:syntastic_c_check_header = 1

"-------------------------------------------------------------------------------
" }}}
" TagBar {{{
"-------------------------------------------------------------------------------

"if onWin
"    let g:tagbar_ctags_bin = 'C:\Users\ishkamiel\Documents\installs\ctags\ctags.exe'
"endif
"nmap <F8> :TagbarToggle<CR>
"" nmap <F8> :TagbarOpenAutoClose<CR>
"let g:tagbar_width=s:pd_sidewidth
"let g:tagbar_sort=0                 " 1 -> alphabetical sorting
"autocmd VimEnter * nested :call tagbar#autoopen(1)

"-------------------------------------------------------------------------------
" }}}
" UltiSnip {{{
"-------------------------------------------------------------------------------

" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<c-l>"
let g:UtliSnipsEditSplit="normal"
" let g:UltiSnipsListSnippets="<c-Right>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
" let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

"-------------------------------------------------------------------------------
" }}}
