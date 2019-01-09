" convert_data_to_asciidoctor.vim
"
" This file is part of the project
" 'Disionario de elefen'
" (http://ne.alinome.net)
"
" By Marcos Cruz (programandala.net), 2019

" This Vim program converts the original data file of the Elefen dictionary
" (http://elefen.org/disionario/disionario_completa.txt) into Asciidoctor
" format (http://ascidoctor.org).

" Last modified 201901091506
" See change log at the end of the file

" ==============================================================
" Convert the data

" Remove internal notes:
%s@^  N \/\/.\+\n@@e

" Remove internal notes in curly brackets:
%s@{\([^}]\{-}\)\/\/[^}]\{-}}@\1@ge

" Remove internal notes at the end of line:
%s@\/\/.*$@@e

" XXX FIXME -- Also the 'O' field and others can be between the description
" and the pronuntiation:
"
" Add the pronunciation note ('P' field), if any, to its description:
%s@^\(\S.\{-} : .\+\)\n\(\(  D .\+\)\n\)\?  P \(.\+\)$@\1 (dise ‘\4’)\r\3@e

" Separate the headwords from the rest of the entry:
%s@^\S.* : .*$@&\r@e

" Add the letter headings:
%s@^\.\([a-z]\) : simbol@== \U\1\e\r\r&@e

" Add a dot at the start of one-word derived headwords
" (in the original data, only the first non-derived root has it):
%s@^\([^. ]\+\)\( : .*\)$@.\1\2\r@e

" Markup the headwords with bold:
%s@^\(\S.*\)\( : .*\)$@**\1**\2\r@e

" XXX OLD -- Does not work fine, because the items are scattered.
" Convert the definition numbers into list items:
"%s@^(\(\d\+\))@\1\.\r@e
"
" XXX NEW --
" Markup the definition numbers with bold: 
%s@^(\(\d\+\))@**&**\r@e

" Add the capital to the country descriptions that have it (in its 'C' field):
%s@^\s\sC\s\(.\+\)\n\s\sD\s\(\(.\)\(.*\)\)$@\U\3\e\4. Capital: \1.\r@e

" Convert the descriptions into paragraphas, with initial capital and a
" full stop:
%s@^\s\sD\s\(\(.\)\(.*\)\)$@\U\2\e\3.\r@e

" Markup the usage example as a block quote:
%s@^\s\sU\s\(.\+\)$@____\r\1\r____\r@e

" Convert the translations into list items:
%s@^\s\s\([A-Z][A-Z]\)\s\(.\+\)$@- \L\1\e: \2@e

" Markup notes as such:
%s@^  N \(.\+\)$@NOTE: \1\r@e

" Remove the index (I), link (G) and origin (O) fields:
%s@^  [GIO] .\+\n@@e

" Convert the see (V) field to 'v' abbreviation:
%s@^  V \(.\+\)$@v \1\r@e

" Add species to the definition
" (must be done after removing fields G, I and O):
%s@\.\n\n  T \(.\+\)@\r(_\1_).\r@e

" Join definition item and its description:
%s@^\(\d\+\.\)\n\+@\1 @e

" Remove extra empty lines:
%s@\n\n\n\+@\r\r@e

" ==============================================================
" Split the file into letter sections

let last_letter_n=char2nr('Z')
let letter_n=char2nr('A')
while letter_n <= last_letter_n
	let letter=nr2char(letter_n)
	let from='/^== '.letter.'/'
	if letter_n==last_letter_n
		let to='/\%$/'
	else
		let to='/^== '.nr2char(letter_n+1).'/-1'
	endif
	silent execute from.','.to.' write tmp/disionario_de_elefen_'.tolower(letter).'.adoc'
	let letter_n=letter_n+1
endwhile

" ==============================================================
" Change log

" 2019-01-04: Start. First working version, with regexp and text
" substitutions.
"
" 2019-01-09: Replace with a version written in Forth.
