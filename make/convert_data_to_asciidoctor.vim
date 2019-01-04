" convert_data_to_asciidoctor.vim
"
" This file is part of the project
" "Disionario de elefen"
" (http://ne.alinome.net)
"
" By Marcos Cruz (programandala.net)

" 2019-01-04

" Remove internal notes:
:%s@^  N \/\/.\+\n@@e

" Remove internal notes in curly brackets:
:%s@{\([^}]\{-}\)\/\/[^}]\{-}}@\1@ge

" Remove internal notes at the end of line:
:%s@\/\/.*$@@e

" Add the pronunciation note ('P' field), if any, to its description:
:%s@^\(\S.\{-} : .\+\)\n\(  D .\+\)\?\n  P \(.\+\)$@\1 (dise ‘\3’)\r\2@e

" Separate the headwords from the rest of the entry:
:%s@^\S.* : .*$@&\r@e

" Add the letter headings:
:%s@^\.\([a-z]\) : simbol@== \U\1\e\r\r&@e

" Add a dot at the start of one-word derived headwords
" (in the original data, only the first non-derived root has it):
:%s@^\([^. ]\+\)\( : .*\)$@.\1\2\r@e

" Markup the headwords with bold:
:%s@^\(\S.*\)\( : .*\)$@**\1**\2\r@e

" Convert the definition numbers into list items:
:%s@^(\(\d\+\))@\1\.\r@e

" Add the capital to the country descriptions that have it (in its 'C' field):
:%s@^\s\sC\s\(.\+\)\n\s\sD\s\(\(.\)\(.*\)\)$@\U\3\e\4. Capital: \1.\r@e

" Convert the descriptions into paragraphas, with initial capital and a
" full stop:
:%s@^\s\sD\s\(\(.\)\(.*\)\)$@\U\2\e\3.\r@e

" Markup the usage example as a block quote:
:%s@^\s\sU\s\(.\+\)$@____\r\1\r____\r@e

" Convert the translations into list items:
:%s@^\s\s\([A-Z][A-Z]\)\s\(.\+\)$@- \L\1\e: \2@e

" Markup notes as such:
:%s@^  N \(.\+\)$@NOTE: \1\r@e

" Remove the index (I), link (G) and origin (O) fields:
:%s@^  [GIO] .\+\n@@e

" Add species to the definition
" (must be done after removing fields G, I and O):
%s@\.\n\n  T \(.\+\)@\r(_\1_).\r@e

" Join definition item and its description:
:%s@^\(\d\+\.\)\n\+@\1 @e

" Remove extra empty lines:
:%s@\n\n\n\+@\r\r@e
