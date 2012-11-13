" File: shebang.vim
" Author: Vital Kudzelka
" Version: 0.1
" Description: Filetype detection by shebang at file.
" Last Modified: Nov 13, 2012

" set default value if not set
fun! shebang#default(name, default)
  if !exists(a:name)
    let {a:name} = a:default
  endif
  return {a:name}
endf

call shebang#default('g:shebang_enable_debug', 0)

" show default error message
fun! shebang#error(message)
  echohl ErrorMsg
  echomsg a:message
  echohl None
endf

" call function with passed params and compare expected value with returned
" result
fun! shebang#test(fn, expected, ...)
  if a:0 < 1
    call shebang#error('Test: Expected one more additional param')
    return 1
  endif

  let cmd = "let result = function(a:fn)(a:1"
  let idx = 2
  while idx <= a:0
    let cmd .= ", a:" . string(idx)
    let idx += 1
  endwhile
  let cmd .= ")"
  exe cmd

  if empty(result) || result !=# a:expected
    echomsg 'TEST FAILED! on ' . string(a:fn)
    echomsg 'Returned=' . string(result)
    echomsg 'Expected=' . string(a:expected)
  endif
endf

" try to detect current filetype
fun! shebang#detect_filetype(line, patterns)
  for pattern in keys(a:patterns)
    if a:line =~# pattern
      return a:patterns[pattern]
    endif
  endfor
endf

fun! s:detect_filetype_test(line, patterns, expected)
    call shebang#test("shebang#detect_filetype", a:expected, a:line, a:patterns)
endf

fun! shebang#unittest()
  let patterns = {
        \ '^#!.*\s\+\(ba\|c\|a\|da\|k\|pdk\|mk\|tc\)\?sh\>' : 'sh',
        \ '^#!.*\s\+zsh\>'                                  : 'zsh',
        \ '^#!.*\s\+ruby\>'                                 : 'ruby',
        \ '^#!.*[s]\?bin/ruby'                              : 'ruby',
        \ '^#!.*\s\+python\>'                               : 'python',
        \ '^#!.*[s]\?bin/python'                            : 'python',
        \ '^#!.*\s\+node\>'                                 : 'javascript',
        \ }
  " shells
  call s:detect_filetype_test('#!/usr/bin/env zsh'    , patterns , 'zsh')
  call s:detect_filetype_test('#!/usr/bin/env sh'     , patterns , 'sh')
  call s:detect_filetype_test('#!/usr/bin/env csh'    , patterns , 'sh')
  call s:detect_filetype_test('#!/usr/bin/env ash'    , patterns , 'sh')
  call s:detect_filetype_test('#!/usr/bin/env dash'   , patterns , 'sh')
  call s:detect_filetype_test('#!/usr/bin/env ksh'    , patterns , 'sh')
  call s:detect_filetype_test('#!/usr/bin/env pdksh'  , patterns , 'sh')
  call s:detect_filetype_test('#!/usr/bin/env tcsh'   , patterns , 'sh')
  call s:detect_filetype_test('#!/usr/bin/env mksh'   , patterns , 'sh')
  call s:detect_filetype_test('#!/usr/bin/env bash'   , patterns , 'sh')
  " python
  call s:detect_filetype_test('#!/usr/bin/env python' , patterns , 'python')
  call s:detect_filetype_test('#!/usr/sbin/python'    , patterns , 'python')
  call s:detect_filetype_test('#!/usr/bin/python'     , patterns , 'python')
  call s:detect_filetype_test('#!/sbin/python'        , patterns , 'python')
  call s:detect_filetype_test('#!/bin/python'         , patterns , 'python')
  " ruby
  call s:detect_filetype_test('#!/usr/bin/env ruby'   , patterns , 'ruby')
  call s:detect_filetype_test('#!/usr/sbin/ruby'      , patterns , 'ruby')
  call s:detect_filetype_test('#!/usr/bin/ruby'       , patterns , 'ruby')
  call s:detect_filetype_test('#!/sbin/ruby'          , patterns , 'ruby')
  call s:detect_filetype_test('#!/bin/ruby'           , patterns , 'ruby')
  " javascript
  call s:detect_filetype_test('#!/usr/bin/env node'   , patterns , 'javascript')
endf