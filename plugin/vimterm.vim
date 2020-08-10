function! TermOpenWithoutFocus(size) 
  let s:now_window_id = win_getid()
  call TermOpen(a:size)
  call win_gotoid(s:now_window_id)
endfunction 

function! TermOpen(size) 
  if !exists('g:term_stack_window_id')  
    silent! execute 'topleft ' . a:size . ' split'
    silent! execute 'term'
    silent! execute 'setlocal bufhidden=hide'
    silent! execute 'setlocal nobuflisted'
    silent! execute 'startinsert'
    let g:term_stack_window_id = win_getid()
    let g:term_stack_buf_nr= bufnr('%')
  else 
    let s:win_num = win_id2win(g:term_stack_window_id)
    if s:win_num != 0
      if win_getid() != g:term_stack_window_id 
        call win_gotoid(g:term_stack_window_id)
        silent! execute 'resize ' . a:size 
      elseif bufnr('%') != g:term_stack_buf_nr
        silent! execute 'topleft ' . a:size . ' split +b' . g:term_stack_buf_nr
        let g:term_stack_window_id = win_getid()
        let g:term_stack_buf_nr= bufnr('%')
      else
        call win_gotoid(win_getid(winnr() + 1))
      endif
    else
      silent! execute 'topleft ' . a:size . ' split +b' . g:term_stack_buf_nr
      let g:term_stack_window_id = win_getid()
      let g:term_stack_buf_nr= bufnr('%')
    endif
  endif
endfunction

function! TermClose() 
  if exists('g:term_stack_window_id')  
    let s:win_num = win_id2win(g:term_stack_window_id)
    if s:win_num != 0
      silent! execute s:win_num . 'hide'
      if win_id2win(g:term_stack_window_id) != 0
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
