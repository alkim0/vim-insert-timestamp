" insert-timestamp.vim - Plugin to insert timestamp based on NLP
" Maintainer: Albert Kim
" Version: 0.1

if exists('g:loaded_insert_timestamp') || &compatible
  finish
endif

let g:loaded_insert_timestamp = 1

if !exists('g:insert_timestamp_start_key')
  let g:insert_timestamp_start_key = '<C-l>'
endif

if !exists('g:insert_timestamp_complete_key')
  let g:insert_timestamp_complete_key = '<Tab>'
endif

let s:plugin_root = expand('<sfile>:p:h:h')
let s:python_root = s:plugin_root . '/python'
"let s:third_party_root = s:plugin_root . '/third_party/python'

python3 << EOF
import os.path, sys, vim
#sys.path.insert(0, os.path.join(vim.eval('s:third_party_root')))
sys.path.insert(0, os.path.join(vim.eval('s:python_root')))
import insert_timestamp
EOF

function! InsertTimestampEnable()
  execute 'inoremap ' . g:insert_timestamp_start_key . ' <C-r>=InsertTimestampToggle()<CR>'
endfunc

augroup insert_timestamp

let s:inserting_timestamp = 0

function! InsertTimestampToggle()
  if s:inserting_timestamp
    call InsertTimestampEnd(0)
    return ''
  endif

  let s:inserting_timestamp = 1
  let s:start_line = line('.')
  let s:start_col = col('.') ? col('.') - 1 : 0
  call s:open_preview(py3eval('insert_timestamp.parse("")'))
  autocmd insert_timestamp TextChangedI * call InsertTimestampHook()
  autocmd insert_timestamp InsertLeave * call InsertTimestampEnd(0)
  execute 'inoremap ' . g:insert_timestamp_complete_key . ' <C-r>=InsertTimestampEnd(1)<CR>'
  return ''
endfunc

function! InsertTimestampHook()
  if s:start_line != line('.')
    call InsertTimestampEnd(0)
    return ''
  endif

  let l:str = strpart(getline('.'), s:start_col, col('.') - s:start_col)
  let l:dt = py3eval('insert_timestamp.parse(vim.eval("l:str"))')
  call s:update_preview(l:dt)

  return ''
endfunc

function! InsertTimestampEnd(success)
  let s:inserting_timestamp = 0
  call s:close_preview()
  autocmd! insert_timestamp
  execute 'iunmap ' . g:insert_timestamp_complete_key

  if a:success
    let l:str = strpart(getline('.'), s:start_col, col('.') - s:start_col)
    let l:dt = py3eval('insert_timestamp.parse(vim.eval("l:str"))')
    call setline(line('.'), strpart(getline('.'), 0, s:start_col) . l:dt)
    call cursor(line('.'), s:start_col + strlen(l:dt) + 1)
  endif
  return ''
endfunction

function! s:open_preview(preview_str)
  let l:prev_win = bufwinnr('%')
  execute 'botright 1 new insert-timestamp-preview'
  setlocal bufhidden=hide
  setlocal nobuflisted
  setlocal buftype=nofile
  setlocal noswapfile
  setlocal nonumber
  setlocal nofoldenable
  setlocal winfixheight
  setlocal winfixwidth
  execute 'put =a:preview_str'
  execute l:prev_win . 'wincmd w'
endfunc

function! s:update_preview(s)
  let l:prev_win = bufwinnr('%')
  execute bufwinnr('insert-timestamp-preview') . 'wincmd w'
  call setline(line('.'), a:s)
  execute l:prev_win . 'wincmd w'
endfunc

function! s:close_preview()
  let l:preview_win = bufwinnr('insert-timestamp-preview')
  if l:preview_win >= 0
    execute l:preview_win . 'wincmd c'
  endif
endfunc
