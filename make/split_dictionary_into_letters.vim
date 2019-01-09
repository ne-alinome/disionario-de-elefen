" split_dictionary_into_letters.vim
"
" This file is part of the project
" 'Disionario de elefen'
" (http://ne.alinome.net)
"
" By Marcos Cruz (programandala.net)

" This Vim program splits the Asciidoctor version of the whole Elefen
" dictionary data into letters.

" 2019-01-09: Start, extracted from the old <convert_data_to_asciidoctor.vim>.

" Split the file into letter sections:

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

