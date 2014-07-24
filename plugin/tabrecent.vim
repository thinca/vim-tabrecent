" You can go to the recent tab page.
" Version: 0.2
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

if exists('g:loaded_tabrecent') || v:version < 700
  finish
endif

let g:loaded_tabrecent = 1

let s:save_cpo = &cpo
set cpo&vim

augroup plugin-tabrecent
  autocmd!
  if has('reltime')
    autocmd TabEnter * let t:tabrecent_time = split(reltimestr(reltime()), '\.')
  else
    autocmd TabEnter * let t:tabrecent_time = localtime()
  endif
augroup END

command! -count=1 -nargs=? -bang TabRecent
\        call tabrecent#move(<count>, <q-args>, <bang>0)

let &cpo = s:save_cpo
unlet s:save_cpo
