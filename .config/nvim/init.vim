call plug#begin()
Plug 'morhetz/gruvbox'
Plug 'scrooloose/NERDTree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'majutsushi/tagbar'
Plug 'bling/vim-airline'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --tern-completer --clang-completer' }
Plug 'honza/vim-snippets' | Plug 'SirVer/ultisnips'
Plug 'scrooloose/syntastic'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-commentary'
Plug 'vimchant'
Plug 'ntpeters/vim-better-whitespace'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'Matt-Deacalion/vim-systemd-syntax', { 'for': 'systemd' }
Plug 'lervag/vimtex', { 'for': 'tex' }
call plug#end()

" -----------------------------------------------------------------
" Basic config
" -----------------------------------------------------------------

" Text and side panel widths
let g:pd_textwidth=100
let g:pd_sidewidth = max([10, min([40, ((&columns - g:pd_textwidth - 5 ) / 2) ])])
"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0123456789
set scrolloff=10
set autochdir
set secure
set shiftwidth=4
set nowrap
let &textwidth=g:pd_textwidth
set pastetoggle=<F9>
set tabstop=4

" vim file location
set backupdir=~/tmp/vimbackup,.,~
set directory=~/tmp/vimbackup,.,~

" Colorscheme stuff
set background=dark
colorscheme gruvbox

" Remember file locations
if has("autocmd")
	au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Keyboard mappings
nmap <F8> :TagbarToggle<CR>

augroup PanelSize
	autocmd!
	autocmd VimResized * let g:pd_sidewidth = max([23, min([40, ((&columns - g:pd_textwidth - 5 ) / 2) ])])
	autocmd VimResized let g:tagbar_width=g:pd_sidewidth
	autocmd VimResized let g:NERDTreeWinSize=g:pd_sidewidth
augroup END

"-------------------------------------------------------------------------------
" Plugin config
"-------------------------------------------------------------------------------

" YouCompleteMe
"-------------------------------------------------------------------------------
" let g:ycm_use_ultisnips_completer = 1

" UltiSnips
"-------------------------------------------------------------------------------
" let g:UltiSnipsExpandTrigger='<c-l>'
" let g:UltiSnipsJumpForwardTrigger='<c-n>'
" let g:UltiSnipsJumpBackwardTrigger='<c-p>'

" Tagbar
"-------------------------------------------------------------------------------
let g:tagbar_width=g:pd_sidewidth

augroup tagbar
	autocmd!
	autocmd VimEnter * nested :call tagbar#autoopen(1)
augroup END


" NERDTree
"-------------------------------------------------------------------------------
let g:NERDTreeWinSize=g:pd_sidewidth
let g:nerdtree_tabs_open_on_console_startup=1
let g:nerdtree_tabs_smart_startup_focus=2
let g:nerdtree_tabs_focus_on_files=1

" airline stuff
"-------------------------------------------------------------------------------
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

" Syntastic
"-------------------------------------------------------------------------------
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
"let g:syntastic_aggregate_errors=0 " run all checkers and aggregate results
"let g:syntastic_always_populate_loc_list=1
"let g:syntastic_auto_loc_list=2
"let g:syntastic_loc_list_height=5
let g:syntastic_check_on_open=1
"let g:syntastic_check_on_wq=0
let g:syntastic_enable_balloons=1
let g:syntastic_enable_signs=1

" better-whitesapce
"-------------------------------------------------------------------------------
highlight ExtraWhitespace ctermbg=black
autocmd BufWritePre * StripWhitespace

"-------------------------------------------------------------------------------
" Filetype specfic
"-------------------------------------------------------------------------------

" LaTeX
"-------------------------------------------------------------------------------
let g:tex_comment_nospell=1
augroup vimtex
	autocmd!
	autocmd BufNewFile,BufRead *.tex setlocal spell
	" autocmd BufNewFile,BufRead *.tex let g:syntastic_quiet_messages = { "regex": 'You should put a space in front of parenthesis' }
	" autocmd BufNewFile,BufRead *.tex nnoremap <buffer> <silent> <Space> :call vimtex#fold#refresh('za')<CR>
augroup END
