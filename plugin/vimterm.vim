function! TermOpenWithoutFocus(size) 
  let s:now_window_id = win_getid()
  call TermOpen(a:size)
  call win_gotoid(s:now_window_id)
endfunction 

function! TermOpenInner(size) 
    silent! execute 'botright ' . a:size . ' split'
    silent! execute 'term'
    silent! execute 'setlocal bufhidden=hide'
    silent! execute 'setlocal nobuflisted'
    silent! execute 'startinsert'
    call SaveWindow(tabpagenr(), win_getid())
    call SaveBuf(tabpagenr(), bufnr('%'))
endfunction

function! TermOpen(size) 
  if !ExistsWindow(tabpagenr())
    call TermOpenInner(a:size)
  else 
    let s:win_num = win_id2win(GetWindow(tabpagenr()))
    if s:win_num != 0
      if win_getid() != GetWindow(tabpagenr())
        call win_gotoid(GetWindow(tabpagenr()))
        silent! execute 'resize ' . a:size 
      elseif ExistsBuf(tabpagenr()) && GetBuf(tabpagenr()) != bufnr('%')
        silent! execute 'botright ' . a:size . ' split +b' . GetBuf(tabpagenr())
        call SaveWindow(tabpagenr(), win_getid())
        call SaveBuf(tabpagenr(), bufnr('%'))
      else
        call win_gotoid(win_getid(winnr() + 1))
      endif
    else
      if ExistsBuf(tabpagenr()) && bufexists(GetBuf(tabpagenr()))
        silent! execute 'botright ' . a:size . ' split +b' . GetBuf(tabpagenr())
        call SaveWindow(tabpagenr(), win_getid())
        call SaveBuf(tabpagenr(), bufnr('%'))
      else
        call TermOpenInner(a:size)
      endif
    endif
  endif
endfunction

function! TermClose() 
  if ExistsWindow(tabpagenr())
    let s:win_num = win_id2win(GetWindow(tabpagenr()))
    if s:win_num != 0
      silent! execute s:win_num . 'hide'
      if win_id2win(GetWindow(tabpagenr())) != 0
        return 0
      endif
      return 1
    endif
  endif
  return 0
endfunction 

function! TermToggle(size) 
  if !TermClose()
    call TermOpen(a:size)
  endif
endfunction

function! TermToggleWithoutFocus(size) 
  if !TermClose()
    call TermOpenWithoutFocus(a:size)
  endif
endfunction

function! SaveBuf(tabnr, bufnr) abort
  if !exists('g:term_tab_bufnr_dic')
    let g:term_tab_bufnr_dic = {}
  endif
  let g:term_tab_bufnr_dic[printf("%d", a:tabnr)]=a:bufnr
endfunction

function! ExistsBuf(tabnr) abort
  if !exists('g:term_tab_bufnr_dic')
    return 0
  endif
  return has_key(g:term_tab_bufnr_dic, printf("%d", a:tabnr))
endfunction

function! GetBuf(tabnr) abort
  return g:term_tab_bufnr_dic[printf("%d", a:tabnr)]
endfunction

function! SaveWindow(tabnr, winid) abort
  if !exists('g:term_tab_winid_dic')
    let g:term_tab_winid_dic = {}
  endif
  let g:term_tab_winid_dic[printf("%d", a:tabnr)]=a:winid
endfunction

function! ExistsWindow(tabnr) abort
  if !exists('g:term_tab_winid_dic')
    return 0
  endif
  return has_key(g:term_tab_winid_dic, printf("%d", a:tabnr))
endfunction

function! GetWindow(tabnr) abort
  return g:term_tab_winid_dic[printf("%d", a:tabnr)]
endfunction

