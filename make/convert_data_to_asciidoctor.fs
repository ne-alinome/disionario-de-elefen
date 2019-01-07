#! /usr/bin/env gforth

\ convert_data_to_asciidoctor.fs
\
\ This file is part of the project
\ 'Disionario de elefen'
\ (http://ne.alinome.net)
\
\ By Marcos Cruz (programandala.net)

\ This program converts the original data file of the Elefen
\ dictionary (http://elefen.org/disionario/disionario_completa.txt)
\ into Asciidoctor format (http://ascidoctor.org).

\ This program is written in Forth for Gforth
\ (http://gnu.org/software/gforth).
\
\ See also <http://forth-standard.org>.

\ Last modified 201901072358
\ See change log at the end of the file

\ ==============================================================
\ Files {{{1

1024 constant /line-buffer

/line-buffer 2 + buffer: line-buffer

0 value input-file

: -bom ( -- )
  line-buffer 3 input-file read-file throw drop ;
  \ Remove the 3-byte BOM from the data file.

: open-input ( "filename" -- )
  parse-name r/o open-file throw to input-file -bom ;

: another-line? ( -- ca len f )
  line-buffer dup /line-buffer input-file read-line throw ;

: close-input ( -- )
  input-file close-file throw ;

\ ==============================================================
\ Variables {{{1

\ Gforth dynamic string variables are used to store the data of the
\ current dictionary entry.

$variable headword
$variable headword-type
$variable section

$variable c-field \ capital of country
$variable d-field \ definition
$variable g-field \ wiki link target?
$variable i-field \ Elefen wikipedia article?
$variable n-field \ note
$variable o-field \ origin
$variable p-field \ pronunciation
$variable s-field \ simbol
$variable t-field \ scientific term
$variable u-field \ usage example
$variable v-field \ see

\ Languages:
$variable ar-field
$variable ca-field
$variable da-field
$variable de-field
$variable el-field
$variable en-field
$variable eo-field
$variable es-field
$variable eu-field
$variable fi-field
$variable fr-field
$variable gl-field
$variable he-field
$variable hi-field
$variable it-field
$variable ja-field
$variable ko-field
$variable nl-field
$variable pl-field
$variable pt-field
$variable ru-field
$variable zh-field

: -data ( -- )
  c-field $init
  d-field $init
  g-field $init
  i-field $init
  n-field $init
  o-field $init
  p-field $init
  s-field $init
  t-field $init
  u-field $init
  v-field $init
  ar-field $init
  ca-field $init
  da-field $init
  de-field $init
  el-field $init
  en-field $init
  eo-field $init
  es-field $init
  eu-field $init
  fi-field $init
  fr-field $init
  gl-field $init
  he-field $init
  hi-field $init
  it-field $init
  ja-field $init
  ko-field $init
  nl-field $init
  pl-field $init
  pt-field $init
  ru-field $init
  zh-field $init ;

: -section ( -- )
  section $init ;

: -headword ( -- )
  headword $init ;

\ ==============================================================
\ Parsing {{{1

\ A set of words is created to parse the data lines and store the
\ contents into the corresponding dynamic strings.

: parse-line ( "ccc<eol>" -- ca line )
  0 parse ;

: datum: ( a "name" --- )
  create ,
  does> ( "ccc<eol>" --- ) ( a "ccc<eol>" )
  parse-line rot @ $! ;
  \ Create word "name", related to dynamic string variable _a_.
  \ When "name" is executed, it parses the rest of the source line
  \ and stores the text string into variable _a_.

table constant datum-wordlist
  \ A Gforth table is a case-sensitive wordlist.  An ordinary wordlist
  \ should make no difference in this case, because the field markers
  \ of the data file are preceded by two spaces, so no name clash can
  \ happen, but anyway they are uppercase.

get-current datum-wordlist set-current

c-field datum: C
d-field datum: D
g-field datum: G
i-field datum: I
n-field datum: N
o-field datum: O
p-field datum: P
s-field datum: S
t-field datum: T
u-field datum: U
v-field datum: V

ar-field datum: AR
ca-field datum: CA
da-field datum: DA
de-field datum: DE
el-field datum: EL
en-field datum: EN
eo-field datum: EO
es-field datum: ES
eu-field datum: EU
fi-field datum: FI
fr-field datum: FR
gl-field datum: GL
he-field datum: HE
hi-field datum: HI
it-field datum: IT
ja-field datum: JA
ko-field datum: KO
nl-field datum: NL
pl-field datum: PL
pt-field datum: PT
ru-field datum: RU
zh-field datum: ZH

set-current

\ ==============================================================
\ Output {{{1

0 constant dummy-letter

dummy-letter value current-letter

: got-section? ( -- f )
  section $@len 0<> ;
  \ Is there an active section in the current headword?

: headword-separator$ ( -- ca len )
  s"  : " ;
  \ The string used in the data file to separate the headword
  \ from its short description, in the same line.

: headword> ( ca1 len1 -- ca2 len2 )
  headword-separator$ search
  0= abort" Headword format not recognized" ;
  \ Search headword line _ca1 len1_ for `headword-separator$`
  \ and return the position _ca2_ of the first match
  \ with _len2_ characters remaining.

: headword>part-1 ( ca1 len1 -- ca2 len2 )
  2dup headword> nip - ;
  \ Convert headword line _ca1 len1_ into its first part.

: headword>part-2 ( ca1 len1 -- ca2 len2 )
  headword> headword-separator$ nip /string ;
  \ Convert headword line _ca1 len1_ into its second part.

: create-headword-part1 ( -- )
  ." **" headword $@ headword>part-1 type ." **" ;

: add-symbol ( -- )
  ."  «" type ." »" s-field $init ;

: ?add-symbol ( -- )
  s-field $@ dup if add-symbol else 2drop then ;

: create-headword-part2 ( -- )
  headword $@ headword>part-2 type ?add-symbol ;

: add-pronunciation ( ca len -- )
  ."  (dise ‘" type ." ’)" ;

variable described
  \ A flag. Has the current headword been described? I.e.  has it an
  \ ordinary description, a scientific name or a capital city?

: add-scientific ( ca len -- )
  ." _(" type ." )_" described on ;

: add-capital ( ca len -- )
  ." (capital: " type ." )" described on ;

: capitalize ( ca len -- ca len )
  over dup c@ toupper swap c! ;

: add-description ( ca len -- )
  capitalize type cr described on ;

: ?add-description ( -- )
  described off
  d-field $@ dup if add-description else 2drop then
  t-field $@ dup if add-scientific  else 2drop then
  c-field $@ dup if add-capital     else 2drop then
  described @ if ." ." cr then ;

: add-note ( ca len -- )
  cr ." NOTE: " type cr ;
  \ Add an Asciidoctor note markup for note _ca len_.

: ?add-note ( -- )
  n-field $@ dup if add-note else 2drop then ;

: add-usage ( ca len -- )
  cr ." ____" cr type cr ." ____" cr ;

: ?add-usage ( -- )
  u-field $@ dup if add-usage else 2drop then ;

: add-see ( ca len -- )
  cr ." v " type cr ;

: ?add-see ( -- )
  v-field $@ dup if add-see else 2drop then ;

: derived-headword? ( ca len -- f )
  drop c@ '.' <> ;
  \ XXX TODO -- not used

: letter-headword? ( ca len -- f )
  2dup headword>part-1 nip 2 <> if 2drop false exit then
  over c@ '.' <>                if 2drop false exit then
       headword>part-2 drop 3 s" sim" str= ;
  \ Is headword line _ca len_ a letter headword?

: letter-heading ( c -- )
  headword $@ drop char+ c@ toupper
  dup to current-letter ." == " emit cr cr ;

: ?letter-heading ( -- )
  headword $@ letter-headword? if letter-heading then ;

: ?add-pronunciation ( -- )
  p-field $@ dup if add-pronunciation else 2drop then ;

: (create-headword) ( -- )
  ?letter-heading
  create-headword-part1  headword-separator$ type
  create-headword-part2  ?add-pronunciation cr cr ;

: create-fields ( -- )
  ?add-description
  ?add-note
  ?add-usage
  ?add-see ;

: translation ( ca1 len1 ca2 len2 -- )
  ." - " 2swap type ." : " type cr ;

: ?translation ( ca len a -- )
  $@ dup if translation else 2drop 2drop then ;

: create-translations ( -- )
  cr
  s" ar" ar-field ?translation
  s" ca" ca-field ?translation
  s" da" da-field ?translation
  s" de" de-field ?translation
  s" el" el-field ?translation
  s" en" en-field ?translation
  s" eo" eo-field ?translation
  s" es" es-field ?translation
  s" eu" eu-field ?translation
  s" fi" fi-field ?translation
  s" fr" fr-field ?translation
  s" gl" gl-field ?translation
  s" he" he-field ?translation
  s" hi" hi-field ?translation
  s" it" it-field ?translation
  s" ja" ja-field ?translation
  s" ko" ko-field ?translation
  s" nl" nl-field ?translation
  s" pl" pl-field ?translation
  s" pt" pt-field ?translation
  s" ru" ru-field ?translation
  s" zh" zh-field ?translation
  cr ;

: create-data ( -- )
  create-fields create-translations ;

: (create-section) ( -- )
  section $@ type cr cr ;

: create-section ( -- )
  (create-section) -section create-data -data ;

: create-headword ( -- )
  (create-headword) -headword create-data -data ;

\ ==============================================================
\ Input {{{1

: get-headword ( ca len -- )
  headword $! -section -data ;

: get-section ( ca len -- )
  section $! -data ;

: get-datum ( ca len -- )
  2>r get-order datum-wordlist 1 set-order
  2r> evaluate set-order ;
  \ Get the datum from line _ca len_, evaluating it
  \ with the proper word list.

: headword-line? ( ca len -- f )
  drop c@ dup bl <> swap '(' <> and  ;
  \ Is data file line _ca len_ a headword line?
  \ Headword lines don't start with a space or a paren.

: section-line? ( ca len -- f )
  drop c@ '(' = ;
  \ Is data file line _ca len_ a section line?
  \ Section start with a number in parens.

: datum-line? ( ca len -- f )
  drop 2 s"   " str= ;
  \ Is data file line _ca len_ a datum line?
  \ Datum lines start with two spaces.

: handle-data-line ( ca len -- )
  2dup headword-line? if get-headword exit then
  2dup section-line?  if get-section  exit then
  2dup datum-line?    if get-datum    exit then
  type abort" Line format not recognized" ;

: got-headword? ( -- f )
  headword $@len 0<> ;

: handle-empty-line ( -- )
  got-section?  if create-section  exit then
  got-headword? if create-headword exit then ;

: handle-line ( ca len -- )
  dup if handle-data-line else 2drop handle-empty-line then ;

: convert-input ( "filename" -- )
  begin another-line? while handle-line repeat ;

: run ( "filename" -- )
  open-input convert-input close-input ;

\ ==============================================================
\ Change log {{{1

\ 2019-01-04: Start, in order to replace a previous version written in
\ Vim, which used regexp and text substitutions.
\
\ 2019-01-05: First working version. Not finished.
\
\ 2019-01-07: Fix the logic of creating headwords and sections.
\ Convert the 'N', 'C' and 'V' fields.

\ vim: filetype=gforth
