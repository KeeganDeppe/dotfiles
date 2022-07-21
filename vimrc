filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
set shiftwidth=4
set expandtab
set backspace=indent,eol,start

" basics
set number

" setting color theme stuff
set background=dark
syntax enable
colorscheme hybrid

" syntax highlighting
let g:go_highlight_types=1
let g:go_highlight_fields=1
let g:go_highlight_functions=1
let g:go_highlight_function_calls=1
let g:go_highlight_operators=1
let g:go_highlight_extra_types=1

" nerdtree settings
let NERDTreeHighlightCursorLine=1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" nerdtree binds
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFocus<CR>

" time to learn vim
noremap <up> :echoerr "Umm, use k instead"<cr>
noremap <down>:echoerr "Umm,use j instead"<cr>
noremap <left>:echoerr "Umm,use h instead"<cr>
noremap <right>:echoerr "Umm,use l instead"<cr>
inoremap <up> <NOP>
inoremap <down> <NOP>
inoremap <left> <NOP>
inoremap <right> <NOP>
