function! TermOpen(size) 
  if !s:exists_window(tabpagenr())
    call s:term_open_body(a:size)
  else 
    let s:win_num = win_id2win(s:get_window(tabpagenr()))
    if s:win_num != 0
      if win_getid() != s:get_window(tabpagenr())
        call win_gotoid(s:get_window(tabpagenr()))
        silent! execute 'resize ' . a:size 
      elseif s:exists_buf(tabpagenr()) && s:get_buf(tabpagenr()) != bufnr('%')
        silent! execute 'botright ' . a:size . ' split +b' . s:get_buf(tabpagenr())
        call s:save_window(tabpagenr(), win_getid())
        call s:save_buf(tabpagenr(), bufnr('%'))
      else
        call win_gotoid(win_getid(winnr() + 1))
      endif
    else
      if s:exists_buf(tabpagenr()) && bufexists(s:get_buf(tabpagenr()))
        silent! execute 'botright ' . a:size . ' split +b' . s:get_buf(tabpagenr())
        call s:save_window(tabpagenr(), win_getid())
        call s:save_buf(tabpagenr(), bufnr('%'))
      else
        call s:term_open_body(a:size)
      endif
    endif
  endif
endfunction

function! TermClose() 
  if s:exists_window(tabpagenr())
    let s:win_num = win_id2win(s:get_window(tabpagenr()))
    if s:win_num != 0
      silent! execute s:win_num . 'hide'
      if win_id2win(s:get_window(tabpagenr())) != 0
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

function! TermOpenWithoutFocus(size) 
  let s:now_window_id = win_getid()
  call TermOpen(a:size)
  call win_gotoid(s:now_window_id)
endfunction 

function! s:term_open_body(size) 
    silent! execute 'botright ' . a:size . ' split'
    silent! execute 'term'
    silent! execute 'setlocal bufhidden=hide'
    silent! execute 'setlocal nobuflisted'
    silent! execute 'startinsert'
    call s:save_window(tabpagenr(), win_getid())
    call s:save_buf(tabpagenr(), bufnr('%'))
endfunction

function! s:save_buf(tabnr, bufnr) abort
  if !exists('g:term_tab_bufnr_dic')
    let g:term_tab_bufnr_dic = {}
  endif
  let g:term_tab_bufnr_dic[printf("%d", a:tabnr)]=a:bufnr
endfunction

function! s:exists_buf(tabnr) abort
  if !exists('g:term_tab_bufnr_dic')
    return 0
  endif
  return has_key(g:term_tab_bufnr_dic, printf("%d", a:tabnr))
endfunction

function! s:get_buf(tabnr) abort
  return g:term_tab_bufnr_dic[printf("%d", a:tabnr)]
endfunction

function! s:save_window(tabnr, winid) abort
  if !exists('g:term_tab_winid_dic')
    let g:term_tab_winid_dic = {}
  endif
  let g:term_tab_winid_dic[printf("%d", a:tabnr)]=a:winid
endfunction

function! s:exists_window(tabnr) abort
  if !exists('g:term_tab_winid_dic')
    return 0
  endif
  return has_key(g:term_tab_winid_dic, printf("%d", a:tabnr))
endfunction

function! s:get_window(tabnr) abort
  return g:term_tab_winid_dic[printf("%d", a:tabnr)]
endfunction

