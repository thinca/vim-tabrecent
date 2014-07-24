" You can go to the recent tab page.
" Version: 0.2
" Author : thinca <thinca+vim@gmail.com>
" License: zlib License

let s:save_cpo = &cpo
set cpo&vim


" Get tab list with mru.
if exists('*gettabvar')
  function! s:tablist()
    return map(range(1, tabpagenr('$')), '{
    \   "tabnr": v:val,
    \   "time": gettabvar(v:val, "tabrecent_time"),
    \ }')
  endfunction
else
  function! s:tablist()
    let tablist = []
    let current = tabpagenr()
    noautocmd tabdo call add(tablist, {
      \ 'tabnr' : tabpagenr(),
      \ 'time'  : exists('t:tabrecent_time') ? t:tabrecent_time : 0})
    noautocmd execute 'tabnext' current
    return tablist
  endfunction
endif

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

function! tabrecent#move(c, args, relative)
  if tabpagenr('$') == 1
    return
  endif
  let c = a:c
  if strlen(a:args)
    let c = str2nr(a:args)
  endif
  let tablist = sort(s:tablist(), 's:compare')
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


let &cpo = s:save_cpo
unlet s:save_cpo
