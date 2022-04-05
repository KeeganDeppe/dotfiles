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
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
