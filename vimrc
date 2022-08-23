filetype plugin indent on
" show existing tab with 4 spaces width
" editing to be more usual
" set tabstop=4
" set shiftwidth=4
" set expandtab
" set backspace=indent,eol,start
set ts=4 sts=4 sw=2 expandtab
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

" airline settings
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
" setting nf symbols
let g:airline_symbols.linenr = ''
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.dirty = ''

" nerdtree settings
let NERDTreeHighlightCursorLine=1
let NERDTreeQuitOnOpen=1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" nerdtree binds
nnoremap <silent> <C-n> :NERDTree<CR>
nnoremap <silent> <C-t> :NERDTreeToggle<CR>
" nnoremap <C-f> :NERDTreeFocus<CR> going to conflict with fzf and I dont use
" this anyway

" fzf integration
set rtp+=~/.fzf

let g:fzf_preview_window = ['right:50%', 'ctrl-/']
let g:fzf_buffers_jump = 1
 " Customize fzf colors to match your color scheme                                          
 "     " - fzf#wrap translates this to a set of `--color` options                                 
 let g:fzf_colors =
             \ { 'fg':    ['fg', 'Normal'],
             \ 'bg':      ['bg', 'Normal'],
             \ 'hl':      ['fg', 'Comment'],
             \ 'fg+':     ['fg', 'MarchParen', 'CursorLine', 'CursorColumn', 'Normal'],
             \ 'bg+':     ['bg', 'MatchParen', 'CursorLine', 'CursorColumn'],
             \ 'hl+':     ['fg', 'Constant'],
             \ 'info':    ['fg', 'PreProc'],
             \ 'border':  ['fg', 'Ignore'],
             \ 'prompt':  ['fg', 'Conditional'],
             \ 'pointer': ['fg', 'Exception'],
             \ 'marker':  ['fg', 'Keyword'],
             \ 'spinner': ['fg', 'Label'],
             \ 'gutter' : ['bg', 'Normal'],
             \ 'header':  ['fg', 'Comment']} 

" open in floating tmux pane if available
if exists('$TMUX')
    let g:fzf_layout = { 'tmux': '-p60%,70%' }
else
    let g:fzf_layout = { 'window': { 'width': 0.6, 'height': 0.7} }
endif
" fzf functions and keybinds
command! -bang -nargs=? -complete=dir Find 
      \ call fzf#vim#files(<q-args>, fzf#vim#with_preview({'options': ['--layout=reverse', '--info=inline']}), <bang>0)

nnoremap <silent> ff :Find<CR>
nnoremap <silent> fh :Find $HOME<CR>
nnoremap <silent> fg :GFiles<CR>
nnoremap <silent> fs :GFiles?<CR>

" tweaking timeout to quit instatnly via esc
set ttimeout
set ttimeoutlen=0
" time to learn vim
noremap <up> :echoerr "Umm, use k instead"<cr>
noremap <down>:echoerr "Umm,use j instead"<cr>
noremap <left>:echoerr "Umm,use h instead"<cr>
noremap <right>:echoerr "Umm,use l instead"<cr>
inoremap <up> <NOP>
inoremap <down> <NOP>
inoremap <left> <NOP>
inoremap <right> <NOP>
