" vim:fdm=marker foldlevel=0

" Text and side panel widths
let s:pd_textwidth=100
let s:pd_sidewidth = max([10, min([40, ((&columns - s:pd_textwidth - 5 ) / 2) ])])

let s:load_vundle_plugins=1 " master swith for plugins
" -------------------------- PdPM (Vundle wrapper){{{
"  DESCRIPTION:
"
"  This is a very simple wrapper around Vundle, mainly intended for a clearer(?)
"  configuration file structure. PluginPacks are declared in an OO style together
"  with any accompanying conguration. The plugins are in one go when calling
"  loadAll, and configured when calling configureAll.
"
"  SYNOPSIS:
"
"       " Initialize manager
"       let pm = InitPdPM()
"
"       " add plugin
"       pm.add('some/plugin', {})
"
"       " add disabled plugin (for quick temporary disabling)
"       pm.add('some/plugin', { 'disabled': 1 }
"
"       " add plugin, but don't load when SSHing (fails when sudoing)
"       pm.add('some/plugin', { 'nossh': 1 }
"
"       " add plugin with custom config
"       for plugin in pm.add('some/plugin', {})
"
"           " Note that the plugin is not loaded at this point!
"           " You could however do some other checks here and disable based on that.
"           " Just do 'let plugin.enabled = 0' do disable
"
"           function plugin.config() dict
"               " This run when pm.configureAll is ran
"           endfunction
"
"       endfor
"
"       " Load all plugins
"       call pm.loadAll()
"
"       " Then do some other stuff
"       ... something? ...
"
"       " Run each plugins config function (if provided)
"       call pm.configureAll()
"
"       " An maybe do some more other stuff?

function InitPdPM()
    let pm = { 'packs': [], 'enabled': 0, 'verbose': 0}

    " Check some stuff before enabling
    if s:load_vundle_plugins
        if v:version >= 703
            let pm.enabled = 1
        endif
    endif

    let pm.plugindir = $HOME . "/.vim/plugin/"

    if pm.enabled
        " Load vundle stuff
        " https://github.com/VundleVim/

        set nocompatible
        filetype off

        " Vundle (vim plugin manager)
        " install: git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

        set rtp+=~/.vim/bundle/Vundle.vim
        if has("win32") || has("win16")
            let path='~/vimfiles/bundle'
            set rtp+=~/vimfiles/bundle/Vundle.vim
        endif

        call vundle#begin()

        " Load the main Vundle thing
        Plugin 'gmarik/Vundle.vim'
    endif

    function pm.loadAll() dict
        if !self.enabled
            return
        endif

        for pack in self.packs
            if !pack.enabled
                if self.verbose
                    echom pack.plugin . " DISABLED"
                endif
            elseif has_key(pack, 'conditional') && !pack.conditional()
                if self.verbose
                    echom pack.plugin . " DIABLED (conditional)"
                endif
                let pack.enabled = 0
            endif

            if pack.enabled
                Plugin pack.plugin
            endif
        endfor

        " Finalized Vundle config
        call vundle#end()
        filetype plugin indent on
    endfunction

    function pm.configureAll() dict
        if !self.enabled
            return
        endif

        for pack in self.packs
            if pack.enabled && has_key(pack, 'config')
                call pack.config()
            endif
        endfor
    endfunction

    function pm.add(plugin, params)  dict
        let pack = { 'plugin': a:plugin, 'enabled': 1, 'loaded': 0, 'pm': self }

        if has_key(a:params, 'disabled') && a:params.disabled
            let pack.enabled = 0
        endif

        if has_key(a:params, 'nossh') && a:params.nossh
            " FIXME: This fails when sudoing!
             if exists("$SSH_TTY")
                 let pack.enabled = 0
             endif
        endif

        call add(self.packs, pack)
        " Return array for misuse of for loops :)
        return [pack]
    endfunction

    return pm
endfunction

" }}}

let s:PdPM = InitPdPM()

" Side panels and statusline
for p in s:PdPM.add('scrooloose/NERDTree', {}) "{{{
    " https://github.com/scrooloose/nerdtree

    function p.config() dict
        " NERDTree_tabs manages most of this...
        " autocmd vimenter * NERDTree
        " map <C-n> :NERDTreeToggle<CR>
        let g:NERDTreeWinSize=s:pd_sidewidth
        " close NERDTree if it's the last one left
        " autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
    endfunction

endfor "}}}
for p in s:PdPM.add('jistr/vim-nerdtree-tabs', {}) "{{{

    function p.config() dict
        " Open NERDTree on console vim startup
        let g:nerdtree_tabs_open_on_console_startup=1 " (default: 0)

        " On startup, focus NERDTree if opening a directory, focus file if opening a file.
        " (When set to 2, always focus file window after startup).
        let g:nerdtree_tabs_smart_startup_focus=2 " (default: 1)

        " When switching into a tab, make sure that focus is on the file window, not in
        " the NERDTree window. (Note that this can get annoying if you use NERDTree's
        " feature 'open in new tab silently', as you will lose focus on the NERDTree.)
        let g:nerdtree_tabs_focus_on_files=1 " (default: 0)
    endfunction

endfor "}}}
for p in s:PdPM.add('Xuyuanp/nerdtree-git-plugin', {}) "{{{

endfor "}}}
for p in s:PdPM.add('majutsushi/tagbar', {}) "{{{

    function p.config() dict
        " if has("win32") || has("win16")
        "     let g:tagbar_ctags_bin = 'C:\Users\ishkamiel\Documents\installs\ctags\ctags.exe'
        " endif
        nmap <F8> :TagbarToggle<CR>
        "" nmap <F8> :TagbarOpenAutoClose<CR>
        let g:tagbar_width=s:pd_sidewidth
        "let g:tagbar_sort=0                 " 1 -> alphabetical sorting
        autocmd VimEnter * nested :call tagbar#autoopen(1)
    endfunction

endfor "}}}
for p in s:PdPM.add('bling/vim-airline', {}) "{{{

    function p.config() dict
        let g:airline#extensions#tabline#enabled = 1
        let g:airline_powerline_fonts = 1
    endfunction

endfor "}}}
" Autocompletion and syntax checking stuff
for p in s:PdPM.add('Valloric/YouCompleteMe', {'nossh': 1}) "{{{
    " Keeping this disable on remote hosts as it requires additional installation of
    " build tools (at least 86.1MB extra on thin server).

    function p.config() dict
        " Set YouCompleteMe trigger key
        " let g:ycm_key_list_select_completion = ['<Down>']
        " let g:ycm_key_list_previous_completion = ['<Up>']
        " let g:ycm_extra_conf_globlist = ['~/gameProject/*']
        let g:ycm_use_ultisnips_completer = 1
        " let g:ycm_collect_identifiers_from_comments_and_strings = 1
    endfunction

endfor "}}}
for p in s:PdPM.add('ultisnips', {}) "{{{

    function p.config() dict
        " Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
        let g:UltiSnipsExpandTrigger="<c-l>"
        let g:UtliSnipsEditSplit="normal"
        " let g:UltiSnipsListSnippets="<c-Right>"
        let g:UltiSnipsJumpForwardTrigger="<tab>"
        " let g:UltiSnipsJumpBackwardTrigger="<c-z>"

        " If you want :UltiSnipsEdit to split your window.
        let g:UltiSnipsEditSplit="vertical"
    endfunction

endfor "}}}
for p in s:PdPM.add('honza/vim-snippets', {} ) "{{{

endfor "}}}
for p in s:PdPM.add('scrooloose/syntastic', {}) "{{{

    function p.config() dict
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
    endfunction

endfor "}}}
" Git
for p in s:PdPM.add('tpope/vim-fugitive', {}) "{{{

endfor "}}}
for p in s:PdPM.add('airblade/vim-gitgutter', {}) "{{{

    function p.config() dict
        " let g:gitgutter_highlight_lines = 1
    endfunction

endfor "}}}
" Other plugins
for p in s:PdPM.add('scrooloose/nerdcommenter', {}) "{{{

endfor "}}}
for p in s:PdPM.add('aperezdc/vim-template', {}) "{{{

    function p.config() dict
        let g:templates_directory='~/.vim/my_templates'
    endfunction

endfor "}}}
for p in s:PdPM.add('morhetz/gruvbox', {}) "{{{

    function p.config() dict
        " let g:gruvbox_contrast_drak = 'medium
        " let g:gruvbox_contrast_light = 'medium'
    endfunction

endfor "}}}
" Filtype plugins
for p in s:PdPM.add('Matt-Deacalion/vim-systemd-syntax', {}) "{{{

endfor "}}}
for p in s:PdPM.add('lervag/vimtex', {}) "{{{

    function p.config() dict
        " let g:vimtex_fold_enabled=1
        " let g:vimtex_fold_comments=1
        " let g:vimtex_fold_manual=1

        augroup vimtex
            autocmd!
            autocmd BufNewFile,BufRead *.tex setlocal foldlevel=0
            autocmd BufNewFile,BufRead *.tex setlocal spell
            autocmd BufNewFile,BufRead *.tex let g:syntastic_quiet_messages = { "regex": 'You should put a space in front of parenthesis' }
            " autocmd BufNewFile,BufRead *.tex nnoremap <buffer> <silent> <Space> :call vimtex#fold#refresh('za')<CR>
        augroup END
    endfunction

endfor "}}}

call s:PdPM.loadAll()

" -------------------------- General vim config {{{

set nocompatible                " Load non-Vi-compaitlbe settings
syntax on                       " Syntax highlighting
filetype plugin indent on       " Use indening
set autoread              	    " read open files again when changed outside Vim
set autowrite             	    " write a modified buffer on each :next , ...
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
" set textwidth=100               " text width for autoformatt stuff, or something
let &textwidth=s:pd_textwidth
" set textwidth=s:pd_textwidth
set autochdir            		" change the current working directory
set exrc                        " find vimrc in working directory
set secure                      " secure loading of non-default vimrc
set pastetoggle=<F9>            " Toggle pasting mode (disables indenting)
set scrolloff=10                " Keep this many lines visible below cursor
set spelllang=en                " languages used for spelling
set completeopt-=preview        " remove extended preview from autocinserts (scratch window)
set hlsearch                    " highlight searches

set updatetime=500              " Milliseconds between writes (affects git-gutter update speed)

set foldmethod=syntax           " Syntax based folding
set foldlevel=999               " Display everything by default
set foldnestmax=1

set backupdir=~/tmp/vimbackup,.,~
set directory=~/tmp/vimbackup,.,~

if version >= 704
    let &colorcolumn=s:pd_textwidth+1
    " highlight ColorColumn ctermbg=8
endif

" colorshceme stuff
set t_ut=
set background=dark
colorscheme gruvbox

" disable arrow keys
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>

" <cpace> - Toggle folds
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> zf

if has("autocmd")
    au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Trim whitespace
function! TrimWhiteSpace()
    %s/\s\+$//e
endfunction

augroup trimWhiteSpace
    autocmd!
    autocmd FileWritePre    * :call TrimWhiteSpace()
    autocmd FileAppendPre   * :call TrimWhiteSpace()
    autocmd FilterWritePre  * :call TrimWhiteSpace()
    autocmd BufWritePre     * :call TrimWhiteSpace()
augroup END

" }}}
" -------------------------- Windows & gVim stuff {{{

if has("win32") || has("win16")
    set backupdir=~/vimbackup
    set directory=~/vimbackup
    set lines=40 columns=160
endif

set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

" }}}

call s:PdPM.configureAll()
