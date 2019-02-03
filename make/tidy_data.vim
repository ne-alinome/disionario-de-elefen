" tidy_data.vim

" This file is part of the project
" 'Disionario de elefen'
" (http://ne.alinome.net)
"
" By Marcos Cruz (programandala.net)

" This program tidies the Asciidoctor format (http://asciidoctor.org) of the
" the Elefen dictionary data file
" (http://elefen.org/disionario/disionario_completa.txt), as converted by
" <convert_data.fs>.

" This program is written in Vim
" (http://vim.org)

" Last modified 201902031659
" See change log at the end of the file

" Tidy semicolons in curly brackets:
%s@({;} @(@e
%s@ {;}@;@eg

" Tidy chemical expressions in curly brackets:
%s@{\([A-Z0-9=-]\{-}\)}@`\1`@eg

" Tidy numbers with roots in curly brackets:
%s@{\(\S\{-}\)\^\(\S\{-}\)}@\1^\2^@eg

" Remove English translations of comments in curly brackets,
" leaving the Elefen version:
%s@{\(.\{-}\) \/\/.\{-}}@\1@eg

" Remove notes that contain only the English translation
" of the note, as an internal comment.
%s@^NOTE: \/\/ .\+\n@@e

" Remove notes' English translations:
%s@^\(NOTE: \(.\{-}\)\) \/\/ .\+$@\1@e

" Remove empty Asciidoctor note markups:
%s@^NOTE:\n@@eg

" Remove remaining curly brackets, leaving their contents:
%s@{\(\S.\{-}\)}@\1@eg

write!
quit

" ==============================================================
" Change log

" 2019-01-29: Extract the code from Makefile in order to reuse it. Comment the
" commands. Add a substitution to remove the notes not translated into Elefen
" yet.
"
" 2019-02-03: Fix: Remove also the English translation of comments.
