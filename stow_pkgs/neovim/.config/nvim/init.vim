" NOTE: Use space to fold/unfold the categories!
set encoding=utf-8
scriptencoding utf-8

" Plugins {{{
call plug#begin()

" Status / tool line
" Plug 'bling/vim-airline'

" Utilities
Plug 'tpope/vim-commentary'
Plug 'ntpeters/vim-better-whitespace'

" Colorschemes
" Plug 'flazz/vim-colorschemes'
Plug 'drewtempelmeyer/palenight.vim'

" file type specific stuff
" Plug 'sheerun/vim-polyglot'
" let g:polyglot_disabled = ['latex']
" Plug 'tpope/vim-liquid'                                   " Liquid / Jekyll
" Plug 'lervag/vimtex', { 'for': 'tex' }                    " LaTeX
" Plug 'aklt/plantuml-syntax'                               " plantuml

" FIXME: Crashes on MacOS using ports
" Autocompletion - deoplete.nvim
" if has('nvim')
"     Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" else
"     Plug 'Shougo/deoplete.nvim'
"     Plug 'roxma/nvim-yarp'
"     Plug 'roxma/vim-hug-neovim-rpc'
" endif
" Plug 'zchee/deoplete-clang'

" FIXME: Crashes on MacOS using ports
" Syntax checking
" Plug 'dense-analysis/ale'

call plug#end() " }}}
" Basic config {{{
" -----------------------------------------------------------------

" Text and side panel widths
let s:pd_textwidth=80

function GetSideWidth()
    return  max([30, min([50, ((&columns - s:pd_textwidth - 5 ) / 2) ])])
endfunction

" set nocompatible                " Load non-Vi-compaitlbe settings
syntax on                       " Syntax highlighting
filetype plugin indent on       " Use indening
" set autoread                    " read open files again when changed outside Vim
set modeline
set autowrite                   " write a modified buffer on each :next , ...
set backspace=indent,eol,start  " allow backspacing over everything in insert mode
" set backup                      " keep a backup file
" set browsedir=current           " which directory to use for the file browser
set history=50                  " command line history
set incsearch                   " use incremental search
set nowrap                      " do not wrap lines
" set ruler                       " show the cursor position all the time
set laststatus=2                " always show the statusbar
set shiftwidth=4                " number of spaces to use for each step of indent
set tabstop=4                   " number of spaces that a <Tab> in the file counts for
set showcmd                     " display incomplete commands
set expandtab                   " insert spaces instead of tabs
set novisualbell                " visual bell instead of beeping
set t_vb=
" let &textwidth=s:pd_textwidth
set noautochdir                 " change the current working directory
set secure                      " secure loading of non-default vimrc
set pastetoggle=<F9>            " Toggle pasting mode (disables indenting)
set scrolloff=10                " Keep this many lines visible below cursor
set completeopt-=preview        " remove extended preview from autoinserts (scratch window)
set hlsearch                    " highlight searches
" set updatetime=500              " Milliseconds between writes (affects git-gutter update speed)
set foldmethod=syntax           " Syntax based folding
set foldlevel=999               " Display everything by default
set foldnestmax=1
set wildmode=longest,list       " Set tab command completion behavior
set clipboard=unnamed           " Yanks stuff directly to clipboard
set cinoptions=:0               " Make switch & case have same indention
set number

" Disable spellchecks in comments
let g:tex_comment_nospell=1

" colorshceme stuff
set t_ut=

set background=dark
colorscheme palenight

if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

" Italics for my favorite color scheme
let g:palenight_terminal_italics=1

"For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
"Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
" < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
if (has("termguicolors"))
    set termguicolors
endif

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
" writing config {{{

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
" augroup filetype_prose
"     au!
"     au FileType tex,markdown,mkd,text call Prose()
"     " au Filetype tex autocmd BufWritePost <buffer> silent make
" augroup END

augroup filetype_bib
    au!
    au FileType bib set nospell
augroup END

" autocmd BufWritePost *.tex,*.bib make

" invoke manually by command for other file types
command! -nargs=0 Prose call Prose()

" }}}
" PLUGIN CONFIGURATIONS
" Plugin: airline {{{
" -----------------------------------------------------------------

let g:airline_powerline_fonts = 1

" tabline
"
let g:airline#extensions#tabline#enabled = 1
" The `unique_tail_improved` - another algorithm, that will smartly uniquify
" buffers names with similar filename, suppressing common parts of paths.
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

" ale
"
let g:airline#extensions#ale#enabled = 1
" ale error_symbol >
let airline#extensions#ale#error_symbol = 'E:'
" ale warning >
let airline#extensions#ale#warning_symbol = 'W:'
" ale show_line_numbers >
let airline#extensions#ale#show_line_numbers = 1
" ale open_lnum_symbol >
let airline#extensions#ale#open_lnum_symbol = '(L'
" ale close_lnum_symbol >
let airline#extensions#ale#close_lnum_symbol = ')'

" branch
"
let g:airline#extensions#branch#enabled = 1

" hunks
"
" enable/disable showing a summary of changed hunks under source control.
let g:airline#extensions#hunks#enabled = 0
" enable/disable showing only non-zero hunks.
" let g:airline#extensions#hunks#non_zero_only = 1
" set hunk count symbols.
" let g:airline#extensions#hunks#hunk_symbols = ['+', '~', '-']

" vimtex
let g:airline#extensions#vimtex#enabled = 1

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
" Plugin: better-whitesapce {{{
" -----------------------------------------------------------------
highlight ExtraWhitespace ctermbg=black
" autocmd BufWritePre * StripWhitespace

" }}}
" Plugin: deoplete.nvim (plus clang) {{{

let g:deoplete#enable_at_startup = 1

function SetLibClangPath(libClangPath)
    if filereadable(a:libClangPath)
        let g:deoplete#sources#clang#libclang_path = a:libClangPath
    endif
endfunction

let g:deoplete#sources#clang#clang_header = '/usr/lib/clang'
call SetLibClangPath('/usr/lib/llvm-6.0/lib/libclang.so')
call SetLibClangPath('/usr/lib/llvm-7/lib/libclang.so.1')
call SetLibClangPath('/usr/lib/llvm-8/lib/libclang.so.1')
call SetLibClangPath('/usr/lib/llvm-9/lib/libclang.so.1')
call SetLibClangPath('/usr/lib/llvm-10/lib/libclang.so.1')
call SetLibClangPath('/usr/lib/llvm-11/lib/libclang.so.1')
call SetLibClangPath('/usr/lib/llvm-12/lib/libclang.so.1')
call SetLibClangPath('/usr/lib/llvm-13/lib/libclang.so.1')

" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" }}}
" Plugin: NERDTree {{{
" -----------------------------------------------------------------
"
function! IshNERDTreeFind()
    let g:NERDTreeWinSize = GetSideWidth()
    NERDTreeFind
endfunction

function! IshNERDTreeToggle()
    let g:NERDTreeWinSize = GetSideWidth()
    NERDTreeToggle
endfunction

nmap <F7> :call IshNERDTreeToggle()<CR>
map <leader>r :call IshNERDTreeFind()<CR>

let g:NERDTreeWinSize = GetSideWidth()
let g:NERDTreeIgnore = [ '\.o$' ]
" Quit when NERDTree is last remaining
augroup plugin_nerdtree
    au!
    au bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
augroup END

" }}}
" Plugin: tagbar {{{
" -----------------------------------------------------------------
function! IshTagbarToggle()
    let g:tagbar_width = GetSideWidth()
    TagbarToggle
endfunction

nmap <F8> :call IshTagbarToggle()<CR>

highlight ExtraWhitespace ctermbg=black

" }}}
" Plugin: UltiSnips {{{

let g:UltiSnipsExpandTrigger="<c-l>"

" }}}
" Plugin: vimtex {{{
" -----------------------------------------------------------------
let g:vimtex_compiler_progname = 'nvr' " for neovim

let g:vimtex_fold_enabled = 1
" let g:vimtex_latexmk_enabled = 1
" let g:vimtex_latexmk_callback = 0 " requires clientserver
let g:vimtex_text_obj_enabled = 0

" }}}
" Plugin: vim-easy-align {{{

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" }}}
" Plugin: vim-template {{{

" Location for custom templates
let g:templates_directory = [ '~/.config/nvim/vim-templates' ]

" }}}
" GVim
" GVim config {{{

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
" Extra file-type configuration
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

" vim: expandtab shiftwidth=4 tabstop=4 fdm=marker foldlevel=0
