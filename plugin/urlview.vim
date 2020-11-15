" don't load the plugin multiple times
if exists("g:loaded_urlview")
  finish
endif
let g:loaded_urlview=1

function Urlview()
  let l:lines=s:GetAllLinesCurrBuffer()
  let l:urls=s:MatchAllLinks(l:lines)
  call s:MenuOpenLink(l:urls)
endfunction


function s:GetAllLinesCurrBuffer()
  return join(getline(1,'$'),"\n")
endfunction


function s:MatchAllLinks(lines)
  let l:pattern_url='http[s]\?:\/\/[[:alnum:]\%\/_\#.-]*'
  return s:MatchAll(a:lines,l:pattern_url)
endfunction


" https://vi.stackexchange.com/a/16491/
function s:MatchAll(str,pattern)
  let l:res=[]
  call substitute(a:str,a:pattern,'\=add(l:res,submatch(0))','g')
  return l:res
endfunction


" Open links via netrw's gx functionality
function s:OpenLink(url)
  call netrw#BrowseX(a:url,netrw#CheckIfRemote())
endfunction


" Inspired by
" https://github.com/semanticart/simple-menu.vim/blob/4ca28052d534cb14a91a9524dc51f82c494c6c5e/plugin/simple_menu.vim
function s:MenuOpenLink(urls)
  let l:len_urls=len(a:urls)
  let l:nums=range(1,l:len_urls)
  let l:mapping={}
  for n in l:nums
    let l:url=a:urls[n-1]
    let l:mapping[n]=l:url
    echon '[' | echohl Number | echon n | echohl None | echon '] ' | echon l:url
    echo ''
  endfor
  echo "\n"
  echohl Question | echo 'Please choose a number ' | echohl None
  let l:choice=nr2char(getchar())
  redraw!
  if has_key(l:mapping,l:choice)
    let l:chosen_url=l:mapping[l:choice]
    call s:OpenLink(l:chosen_url)
    echo 'opened: ' . l:chosen_url
  endif
endfunction
