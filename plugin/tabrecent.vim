" You can go to the recent tab page.
" Version: 0.1
" Author : thinca <thinca+vim@gmail.com>
" License: Creative Commons Attribution 2.1 Japan License
"          <http://creativecommons.org/licenses/by/2.1/jp/deed.en>

if exists('g:loaded_tabrecent') || v:version < 700
  finish
endif

let g:loaded_tabrecent = 1

let s:save_cpo = &cpo
set cpo&vim

" Get tab list with mru.
function! s:tablist()
  let tablist = []
  let current = tabpagenr()
  noautocmd tabdo call add(tablist, {
    \ 'tabnr' : tabpagenr(),
    \ 'time'  : exists('t:tabrecent_time') ? t:tabrecent_time : 0})
  noautocmd execute 'tabnext' current
  return sort(tablist, 's:compare')
endfunction

function! s:compare(left, right)
  return a:left.time == a:right.time ? 0 : a:left.time < a:right.time ? 1 : -1
endfunction

if has('reltime')
  " Override
  function! s:compare(left, right)
    let [l, r] = [a:left.time, a:right.time]
    if type(l) != type([])
      return 1
    end
    if type(r) != type([])
      return -1
    end
    for i in range(len(l))
      if l[i] < r[i]
        return 1
      endif
      if l[i] > r[i]
        return -1
      endif
    endfor
    return 0
  endfunction
endif

function! s:recent(c, args, relative)
  if tabpagenr('$') == 1
    return
  endif
  let c = a:c
  if strlen(a:args)
    let c = str2nr(a:args)
  endif
  let tablist = s:tablist()
  if a:relative
    let nr = tabpagenr()
    let jump = -1
    for i in range(len(tablist))
      if nr == tablist[i].tabnr
        let jump = i + c
        break
      endif
    endfor
    if 0 <= jump && jump < len(tablist)
      noautocmd execute 'tabnext' tablist[jump].tabnr
    endif
  else
    execute 'tabnext' tablist[c].tabnr
  endif
endfunction

augroup plugin-tabrecent
  autocmd!
  if has('reltime')
    autocmd TabEnter * let t:tabrecent_time = split(reltimestr(reltime()), '\.')
  else
    autocmd TabEnter * let t:tabrecent_time = localtime()
  endif
augroup END

command! -count=1 -nargs=? -bang TabRecent call s:recent(<count>, <q-args>, len('<bang>'))

let &cpo = s:save_cpo
unlet s:save_cpo
