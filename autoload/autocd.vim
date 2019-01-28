" ####################################################################################################
" Vim autocd plugin
" ####################################################################################################

scriptencoding utf-8
" nt_isopen, nt_isloaded, dir
fun! autocd#autocd(dir)
  let l:target_dir = s:search_markers(a:dir)
  if !l:target_dir 
    call Switch_dir(l:target_dir)
    if s:nts
      call s:NERDTree_sync() 
    endif 
  endif

endfun

" Abstracted search for autocd. 
fun! s:search_markers(dir)
  let l:target_dir = g:autocd#markers_filetype_first ? s:get_ft_val(a:dir) : s:get_path_val(a:dir)
  
  if l:target_dir 
    let l:target_dir = g:autocd#markers_filetype_first ? s:get_path_val(a:dir) : s:get_ft_val(a:dir)
  endif

  if l:target_dir && g:autocd#markers_default 
    let l:target_dir = g:autocd#makers_get_default()
  endif

  return l:target_dir
endfun

" Returns the result of ft path cd search
fun! s:get_ft_val(dir)
  let l:dir = exists("g:autocd#markers_filetype['" . &filetype . "']")  ?
\     s:search_marker_set(a:dir, g:autocd#markers_filetype[&filetype])  : 1

  if !l:dir  
    return l:dir
  else
    return 1
  endif

endfun

" Returns the direcotry of a path cd search
fun! s:get_path_val(dir)
  let l:dir = a:dir
  let l:dir_key = s:get_path_key(a:dir)

  if !l:dir_key 
    let l:dir = s:search_marker_set(a:dir, g:autocd#markers_path[l:dir_key])  
    if !l:dir  
      return l:dir
    endif
  endif

  return 1
endfun

" Returns the first matching subpath of the dir and the g:autocd#markers_path list
fun! s:get_path_key(dir)
  let l:dir = a:dir
  let l:sorted = sort(keys(g:autocd#markers_path), 's:path_comparator')

  for path in l:sorted
    if fnameescape(l:dir) =~# path
      return path
    endif
  continue
  endfor

  return 1
endfun

fun! s:path_comparator(s1, s2)
  let l:v1 = strlen(substitute(a:s1, "[^\/]", '', 'g'))
  let l:v2 = strlen(substitute(a:s2, "[^\/]", '', 'g'))
  return l:v1 == l:v2 ? 0 : l:v1 < l:v2 ? 1 : -1
endfun

" Search a given directory upwards and see if contains a file listed in the provided list
fun! s:search_marker_set(dir, markers)
  let l:dir = a:dir
  let l:depthCounter = g:autocd#max_depth
  let l:fmod = ':h'
  while l:dir !~# '^.$' && l:depthCounter != 0

    for marker in a:markers
      if(!empty(glob(l:dir . '/' . marker)))
        return l:dir    
      endif
    endfor

    let l:dir = fnamemodify(l:dir, l:fmod) 
    let l:depthCounter -= 1
  endwhile

  return 1
endfun

" Switch dir
fun! Switch_dir(dir) 
  if tabpagenr('$') == 1 || !g:autocd#tab_isolation
    execute('cd ' . a:dir)
  else
    execute('lcd ' . a:dir)
  endif
endfun

" Sync NERDTree with directory change from this plugin's invocation
fun! s:NERDTree_sync()
  let l:winnr = winnr()
  let l:newcwd = getcwd()
  if s:cwd !~# '^' . l:newcwd . '$'
    let s:cwd = l:newcwd
    let l:nt_open = g:NERDTree.IsOpen()

    execute('NERDTreeCWD')
    if !l:nt_open
      execute('NERDTreeClose')
    endif

  endif

 execute(l:winnr . 'wincmd w') 
endfun

" Enable NERDTree sync
fun! autocd#nts_enable()
  if exists('g:NERDTree')
    let s:cwd = ''  
    let s:nts = 1
    call s:NERDTree_sync()
  else
    call autocd#nts_disable()
  endif
endfun

" Disable NERDTree sync
fun! autocd#nts_disable()
  let s:nts = 0
endfun