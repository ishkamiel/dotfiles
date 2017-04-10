" NOTE: Use space to fold/unfold the categories!

call plug#begin() " {{{

Plug 'scrooloose/NERDTree'
Plug 'bling/vim-airline'
Plug 'tpope/vim-commentary'
Plug 'morhetz/gruvbox'
Plug 'ntpeters/vim-better-whitespace'
Plug 'majutsushi/tagbar'
Plug 'lervag/vimtex', { 'for': 'tex' }

" Git stuff
Plug 'airblade/vim-gitgutter'
Plug 'Xuyuanp/nerdtree-git-plugin'

" Syntastic
Plug 'vim-syntastic/syntastic'

" YouCompleteMe
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --clang-completer' }
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

call plug#end() " }}}
" Basic config 													{{{
"
" Text and side panel widths
let s:pd_textwidth=100
let s:pd_sidewidth = max([10, min([40, ((&columns - s:pd_textwidth - 5 ) / 2) ])])

set nocompatible				" Load non-Vi-compaitlbe settings
syntax on						" Syntax highlighting
filetype plugin indent on		" Use indening
" set autoread					" read open files again when changed outside Vim
set autowrite					" write a modified buffer on each :next , ...
set backspace=indent,eol,start	" allow backspacing over everything in insert mode
set backup						" keep a backup file
" set browsedir=current			" which directory to use for the file browser
set history=50					" command line history
set incsearch					" use incremental search
set nowrap						" do not wrap lines
" set ruler						" show the cursor position all the time
set laststatus=2				" always show the statusbar
set shiftwidth=8				" number of spaces to use for each step of indent
set tabstop=8					" number of spaces that a <Tab> in the file counts for
set showcmd						" display incomplete commands
" set expandtab					" insert spaces instead of tabs
set visualbell					" visual bell instead of beeping
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
set wildmode=list,full			" Set tab command completion behaivor
set clipboard=unnamedplus		" Yanks stuff directly  to clipboard
set cinoptions=:0				" Make switch & case have same indention

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

" Show indention on screen
set list listchars=tab:┆\ ,trail:·,extends:»,precedes:«,nbsp:×

" <cpace> - Toggle folds
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf

if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" }}}
" Plugin: NERDTree {{{
" -----------------------------------------------------------------
nmap <F7> :NERDTreeToggle<CR>
let g:NERDTreeWinSize=s:pd_sidewidth

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
nmap <F8> :TagbarToggle<CR>

highlight ExtraWhitespace ctermbg=black

" }}}
" Plugin: vimtex {{{
" -----------------------------------------------------------------
let g:vimtex_fold_enabled = 1
let g:vimtex_latexmk_enabled = 1
let g:vimtex_latexmk_callback = 0 " requires clientserver
let g:vimtex_text_obj_enabled = 0

" }}}
" Plugin: Syntastic {{{
" -----------------------------------------------------------------
let g:syntastic_enable_signs = 1
let g:syntastic_auto_loc_list = 1
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

function SetGlobalYcmConf()
	let path = getcwd() . "/" . bufname("") " Ugly, but close enough...
	if path =~ "linux_kernel"
		let g:ycm_global_ycm_extra_conf='~/.ycm_extra_conf_linux.py'
	else
		let g:ycm_global_ycm_extra_conf='~/.ycm_extra_conf.py'
	endif
endfunction

" augroup YcmConf
" 	au!
" 	au BufReadPre * call SetGlobalYcmConf()
" 	au BufNewFile * call SetGlobalYcmConf()
" augroup END
call SetGlobalYcmConf() " Just assume we always start in correct dir

" let g:ycm_global_ycm_extra_conf = '~/.ycm_extra_conf.py'  "where to search for .ycm_extra_conf.py if not found
let g:ycm_confirm_extra_conf = 1

let g:ycm_goto_buffer_command = 'same-buffer' "[ 'same-buffer', 'horizontal-split', 'vertical-split', 'new-tab' ]
let g:ycm_filetype_whitelist = { '*': 1 }
let g:ycm_key_invoke_completion = '<C-Space>'

nnoremap <F10> :YcmForceCompileAndDiagnostics <CR>

" }}}
" GVim config                                                   {{{

" Some gvim options
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar


" }}}
" FileType config												{{{

augroup ft_mutt
	au!
	au FileType mail setlocal fo+=aw
	au FileType mail setlocal tw=78
augroup END

" }}}

" vim: shiftwidth=4 tabstop=4 fdm=marker foldlevel=0
