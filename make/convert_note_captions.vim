" convert_note_captions.vim

" This file is part of the project
" 'Disionario de elefen'
" (http://ne.alinome.net)
"
" By Marcos Cruz (programandala.net)

" This program converts the note captions of the EPUB from default English
" "Note" to Elefen "nb" notation.  This can be configured in the Asciidoctor
" source, with the `:note-caption:` attribute, but it has no effect in the
" resulting DocBook format, and currently the localization can not be
" configured for the conversion from DocBook to EPUB.

" This program is written in Vim
" (http://vim.org)

" Last modified 201902031634
" See change log at the end of the file

" Convert the notes created by dbtoepub/xsltproc:
bufdo %s@<div class="note" style="margin-left: 0.5in; margin-right: 0.5in;"><h3 class="title">Note<\/h3>@<div class="note" style="margin-left: 0.5in; margin-right: 0.5in;"><h3 class="title">Nota</h3>@e

" Convert the notes created by pandoc:
bufdo %s@<p><strong>Note<\/strong><\/p>\n<p>@<p><strong>Nota:</strong>\r@e

wa
quit

" ==============================================================
" Change log

" 2019-02-03: Start.
