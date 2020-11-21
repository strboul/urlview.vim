" Copyright (c) 2020 Metin Yazici
"
" MIT License
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to
" deal in the Software without restriction, including without limitation the
" rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
" sell copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
" FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
" IN THE SOFTWARE.


" don't load plugin multiple times
if exists("g:loaded_urlview")
  finish
endif
let g:loaded_urlview=1


function s:UrlviewMain()
  let l:lines=s:GetAllLinesCurrBuffer()
  let l:urls=s:MatchAllLinks(l:lines)
  if !len(l:urls)>0
    echo 'No URLs found in the buffer.'
    return -1
  endif
  call s:MenuOpenLink(l:urls)
endfunction

command! Urlview :call <SID>UrlviewMain()


function s:GetAllLinesCurrBuffer()
  return join(getline(1,'$'),"\n")
endfunction


function s:MatchAllLinks(lines)
  let l:pattern_url='http[s]\?:\/\/[[:alnum:]\%\/_\#.-]*'
  let l:matched_urls=s:MatchAll(a:lines,l:pattern_url)
  let l:uniq_urls=uniq(filter(l:matched_urls, 'len(v:val)>0'))
  return l:uniq_urls
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


" References
"
" https://github.com/semanticart/simple-menu.vim/blob/4ca28052d534cb14a91a9524dc51f82c494c6c5e/plugin/simple_menu.vim
" https://vim.fandom.com/wiki/User_input_from_a_script
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
  call inputsave()
  echohl Question | let l:choice=input('Choose a number: ') | echohl None
  call inputrestore()
  redraw!
  if len(l:choice)>0
    if has_key(l:mapping,l:choice)
      let l:chosen_url=l:mapping[l:choice]
      call s:OpenLink(l:chosen_url)
      echo 'opened: ' . l:chosen_url
    else
      echohl WarningMsg | echo 'Error: invalid number' | echohl None
    endif
  endif
endfunction
