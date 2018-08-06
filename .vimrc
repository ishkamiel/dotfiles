" NOTE: Use space to fold/unfold the categories!
set encoding=utf-8
scriptencoding utf-8

if has('win32') || has('win64')
	let g:onWin = 1
else
	let g:onWin = 0
endif

call plug#begin() " {{{

Plug 'scrooloose/NERDTree'
Plug 'bling/vim-airline'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'aperezdc/vim-template'
Plug 'ntpeters/vim-better-whitespace'
Plug 'majutsushi/tagbar'

Plug 'flazz/vim-colorschemes'
" Plug 'morhetz/gruvbox'

Plug 'sheerun/vim-polyglot'
let g:polyglot_disabled = ['latex']

Plug 'lervag/vimtex', { 'for': 'tex' }
" Plug 'aklt/plantuml-syntax'
" Plug 'rodjek/vim-puppet'

Plug 'chazy/cscope_maps'

" local_vimrc
Plug 'LucHermitte/lh-vim-lib'
Plug 'LucHermitte/local_vimrc'

" deoplete.nvim
if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'zchee/deoplete-clang'

" deoplete-minisnip
" Plug 'joereynolds/vim-minisnip'
" Plug 'joereynolds/deoplete-minisnip'

" UltiSnips
" Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'

" writing stuff
Plug 'reedes/vim-pencil'
Plug 'reedes/vim-wordy'
Plug 'reedes/vim-litecorrect'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/goyo.vim'

" PDF suppoert
" Plug 'rhysd/open-pdf.vim'

" Git stuff
Plug 'airblade/vim-gitgutter'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Syntax checking
Plug 'w0rp/ale'

" Conflicts with ALE
" Plug 'neomake/neomake'

" Syntastic
" Plug 'vim-syntastic/syntastic'

" YouCompleteMe
if !g:onWin
	" Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer' }
	" Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }
endif


call plug#end() " }}}
" Basic config 													{{{
"
" Text and side panel widths
let s:pd_textwidth=80
let s:pd_sidewidth = max([10, min([400, ((&columns - s:pd_textwidth - 5 ) / 2) ])])

" set nocompatible				" Load non-Vi-compaitlbe settings
syntax on						" Syntax highlighting
filetype plugin indent on		" Use indening
" set autoread					" read open files again when changed outside Vim
set modeline
set autowrite					" write a modified buffer on each :next , ...
set backspace=indent,eol,start	" allow backspacing over everything in insert mode
" set backup						" keep a backup file
" set browsedir=current			" which directory to use for the file browser
set history=50					" command line history
set incsearch					" use incremental search
set nowrap						" do not wrap lines
" set ruler						" show the cursor position all the time
set laststatus=2				" always show the statusbar
set shiftwidth=4				" number of spaces to use for each step of indent
set tabstop=4					" number of spaces that a <Tab> in the file counts for
set showcmd						" display incomplete commands
set expandtab					" insert spaces instead of tabs
set novisualbell				" visual bell instead of beeping
set t_vb=
let &textwidth=s:pd_textwidth
set noautochdir 				" change the current working directory
set secure                      " secure loading of non-default vimrc
set pastetoggle=<F9>            " Toggle pasting mode (disables indenting)
set scrolloff=10                " Keep this many lines visible below cursor
set completeopt-=preview        " remove extended preview from autoinserts (scratch window)
set hlsearch                    " highlight searches
" set updatetime=500 			" Milliseconds between writes (affects git-gutter update speed)
set foldmethod=syntax           " Syntax based folding
set foldlevel=999               " Display everything by default
set foldnestmax=1
set wildmode=longest,list		" Set tab command completion behaivor
" set clipboard=unnamedplus		" Yanks stuff directly  to clipboard
set cinoptions=:0				" Make switch & case have same indention
set number

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
colorscheme elflord

" Show indention on screen
set list listchars=tab:┆\ ,trail:·,extends:»,precedes:«,nbsp:×

" highlight LineNr term=bold cterm=NONE ctermfg=DarkGrey ctermbg=237 gui=NONE guifg=DarkGrey guibg=NONE

" <cpace> - Toggle folds
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf

" Make vim remember position in file
if has('autocmd')
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" }}}
" writing config 													{{{

let g:tex_flavor = 'latex'

let g:pencil#textwidth = s:pd_textwidth

" let g:limelight_conceal_ctermfg = 'grey'

let g:goyo_width = s:pd_textwidth + 5
let g:goyo_height = 95

augroup plugin_goyo
	au!
	au! User GoyoEnter Limelight
	au! User GoyoLeave Limelight!
augroup END

function! Prose()
	call litecorrect#init()
	" call pencil#init({'wrap': 'soft'})
	call pencil#init({'wrap': 'soft', 'conceallevel': 0})
	let g:pencil#conceallevel = 0

	" replace common punctuation
	" iabbrev <buffer> -- –
	" iabbrev <buffer> --- —
	iabbrev <buffer> << «
	iabbrev <buffer> >> »

	set spell
	let &textwidth = 0
endfunction

" automatically initialize buffer by file type
augroup filetype_prose
	au!
	au FileType tex,markdown,mkd,text call Prose()
    " au Filetype tex autocmd BufWritePost <buffer> silent make
augroup END

augroup filetype_bib
    au!
    au FileType bib set nospell
augroup END

" autocmd BufWritePost *.tex,*.bib make

" invoke manually by command for other file types
command! -nargs=0 Prose call Prose()

" }}}
" Plugin: deoplete.nvim {{{

let g:deoplete#enable_at_startup = 1

let g:deoplete#sources#clang#libclang_path = '/usr/lib/llvm-6.0/lib/libclang.so'
let g:deoplete#sources#clang#clang_header = '/usr/lib/clang'

" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

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
" Plugin: NERDTree {{{
" -----------------------------------------------------------------
"
function! IshNERDTreeFind()
	let g:NERDTreeWinSize =  max([10, min([400, ((&columns - s:pd_textwidth - 20 ) / 2) ])])
	NERDTreeFind
endfunction

function! IshNERDTreeToggle()
	let g:NERDTreeWinSize =  max([10, min([400, ((&columns - s:pd_textwidth - 20 ) / 2) ])])
	NERDTreeToggle
endfunction

nmap <F7> :call IshNERDTreeToggle()<CR>
map <leader>r :call IshNERDTreeFind()<CR>

let g:NERDTreeWinSize=s:pd_sidewidth
let g:NERDTreeIgnore = [ '\.o$' ]
" Quit when NERDTree is last remining
augroup plugin_nerdtree
	au!
	au bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup END

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
" Plugin: tagbar {{{
" -----------------------------------------------------------------
function! IshTagbarToggle()
	let g:tagbar_width =  max([10, min([400, ((&columns - s:pd_textwidth - 20 ) / 2) ])])
	TagbarToggle
endfunction

nmap <F8> :call IshTagbarToggle()<CR>

highlight ExtraWhitespace ctermbg=black

" }}}
" Plugin: vimtex {{{
" -----------------------------------------------------------------
let g:vimtex_compiler_progname = 'nvr' " for neovim

let g:vimtex_fold_enabled = 1
" let g:vimtex_latexmk_enabled = 1
" let g:vimtex_latexmk_callback = 0 " requires clientserver
let g:vimtex_text_obj_enabled = 0

" }}}
" Plugin: Syntastic (NOT USED) {{{
" -----------------------------------------------------------------
let g:syntastic_enable_signs = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_always_populate_loc_list = 1

" let g:syntastic_cpp_checkers = ['gcc']

let g:syntastic_auto_jump = 0
let g:syntastic_enable_balloons = 1

" let g:syntastic_cpp_compiler = 'g++'
" let g:syntastic_cpp_compiler_options = '-std=c++11 -Wall -Wextra'

let g:syntastic_cpp_check_header = 1
let g:syntastic_cpp_auto_refresh_includes = 1

"let b:syntastic_cpp_cflags = '-I/home/user/dev/cpp/boost_1_55_0'
" let g:syntastic_cpp_include_dirs = []

let g:syntastic_tex_checkers = [ 'lacheck' ]

" nnoremap <F2> :<C-u>exe 'call <SID>LocationNext()'<CR>

" }}}
" Plugin: UltiSnips (NOT USED) {{{

" Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z>"

" If you want :UltiSnipsEdit to split your window.
let g:UltiSnipsEditSplit="vertical"

" }}}
" Plugin: YouCompleteMe {{{
" -----------------------------------------------------------------
let g:ycm_register_as_syntastic_checker = 1 "default 1
let g:Show_diagnostics_ui = 1 "default 1

"will put icons in Vim's gutter on lines that have a diagnostic set.
"Turning this off will also turn off the YcmErrorLine and YcmWarningLine
"highlighting
let g:ycm_enable_diagnostic_signs = 1
let g:ycm_enable_diagnostic_highlighting = 0
let g:ycm_always_populate_location_list = 1 "default 0
let g:ycm_open_loclist_on_ycm_diags = 1 "default 1

let g:ycm_complete_in_strings = 1 "default 1
let g:ycm_collect_identifiers_from_tags_files = 0 "default 0
let g:ycm_path_to_python_interpreter = '' "default ''

let g:ycm_server_use_vim_stdout = 0 "default 0 (logging to console)
let g:ycm_server_log_level = 'info' "default info

" let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'  "where to search for .ycm_extra_conf.py if not found
let g:ycm_confirm_extra_conf = 1

let g:ycm_goto_buffer_command = 'same-buffer' "[ 'same-buffer', 'horizontal-split', 'vertical-split', 'new-tab' ]
let g:ycm_filetype_whitelist = { '*': 1 }
let g:ycm_key_invoke_completion = '<C-Space>'

let g:ycm_extra_conf_globlist = [ '~/devel/linux_kernel/*' ]

nnoremap <F10> :YcmForceCompileAndDiagnostics <CR>

" }}}
" Plugin: vim-template {{{

" Location for custom templates
let g:templates_directory = [ '~/.vim/vim-templates' ]

" }}}
" Plugin: local_vimrc {{{

let g:local_vimrc = ['.vimrc_local.vim', '_vimrc_local.vim']

" Location for custom templates
let g:templates_directory = [ '~/.vim/vim-templates' ]

" }}}
" GVim config                                                   {{{

" Some gvim options
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar
set guifont=Hack

if has('gui_running')
	set lines=50 columns=160
endif

" }}}
" FileType config												{{{

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

" vim: shiftwidth=4 tabstop=4 fdm=marker foldlevel=0
