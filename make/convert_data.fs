#! /usr/bin/env gforth

\ convert_data.fs
\
\ This file is part of the project
\ 'Disionario de elefen'
\ (http://ne.alinome.net)
\
\ By Marcos Cruz (programandala.net)

\ This program converts the original data file of the Elefen
\ dictionary (http://elefen.org/disionario/disionario_completa.txt)
\ into Asciidoctor format (http://asciidoctor.org).

\ This program is written in Forth for Gforth
\ (http://gnu.org/software/gforth).
\
\ See also <http://forth-standard.org>.
i
\ Last modified 201901132015
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

: line? ( -- ca len f )
  line-buffer dup /line-buffer input-file read-line throw ;
  \ If there's a new line in the data file, return it as string _ca
  \ len_ and _f_ is true. Otherwise _f_ is false and _ca len_ is
  \ unimportant.

: close-input ( -- )
  input-file close-file throw ;

\ ==============================================================
\ Variables {{{1

variable asciidoctor  true asciidoctor !
  \ A flag. True if the output format is Asciidoctor.

: asciidoctor? ( -- f ) asciidoctor @ ;
  \ Is Asciidoctor the output format?

: c5? ( -- f ) asciidoctor @ 0= ;
  \ Is c5 the output format? "c5" is one of the input formats accepted
  \ by dictfmt in order to make a dict file.

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
  \ Empty all the data field variables.

: -section ( -- )
  section $init ;
  \ Empty the section variable.

: -headword ( -- )
  headword $init ;
  \ Empty the headword variable.

\ ==============================================================
\ Parser {{{1

\ A set of words is created to parse the data lines and store the
\ contents into the corresponding dynamic strings.

: parse-line ( "ccc<eol>" -- ca line )
  0 parse ;
  \ Parse the current line and retur it as string _ca len_

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

get-current  datum-wordlist set-current

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

: .bold ( -- )
  asciidoctor? if ." **" then ;

: ?remove-leading-dot ( ca len -- )
  over c@ '.' = abs /string ;

: (.headword-part1) ( ca len -- )
  c5? if ?remove-leading-dot then type ;

: .headword-part1 ( ca len -- )
  .bold headword $@ headword>part-1 (.headword-part1) .bold ;
  \ Display the first part (left) of the headword.

: .symbol ( ca len -- )
  ."  «" type ." »" s-field $init ;
  \ Display the 'S' field _ca len_.

: ?.symbol ( -- )
  s-field $@ dup if .symbol else 2drop then ;
  \ Display the 'S' field, if any.

: .headword-part2 ( -- )
  c5? if cr ." (" then
  headword $@ headword>part-2 type ?.symbol
  c5? if ." )" then ;
  \ Display the second part (right) of the headword.

variable described
  \ A flag. Has any part of the current headword been described?  The
  \ possible parts are: the main description, the  scientific name or
  \ the capital city?

: ?separate ( -- )
  described @ if cr then ;
  \ If some part of the description has already been displayed,
  \ print a carriage return to separate the next part.

: .scientific ( ca len -- )
  ?separate ." (" type ." )" described on ;
  \ Display the 'T' field _ca len_.

: .capital ( ca len -- )
  ?separate ." (capital: " type ." )" described on ;
  \ Display the 'C' field _ca len_.

: capitalize ( ca len -- ca len )
  over dup c@ toupper swap c! ;
  \ Capitalize the first character (ASCII only) of string _ca len_.

: .description ( ca len -- )
  capitalize type described on ;
  \ Display main description _ca len_.

: ?.description ( -- )
  described off
  d-field $@ dup if .description else 2drop then
  t-field $@ dup if .scientific  else 2drop then
  c-field $@ dup if .capital     else 2drop then
  described @ if ." ." cr then ;

: .note ( ca len -- )
  cr asciidoctor? if ." NOTE: " else ." nb " then type cr ;
  \ Display the 'N' field _ca len_.

: ?.note ( -- )
  n-field $@ dup if .note else 2drop then ;
  \ Display the 'N' field, if any.

: usage{ ( -- )
  asciidoctor? if cr ." ____" cr else cr ." ‹ " then ;

: }usage ( -- )
  asciidoctor? if cr ." ____" cr else ."  ›" cr then ;

: .usage ( ca len -- )
  usage{ type }usage ;

: ?.usage ( -- )
  u-field $@ dup if .usage else 2drop then ;

: .see ( ca len -- )
  cr ." v " type cr ;

: ?.see ( -- )
  v-field $@ dup if .see else 2drop then ;

: derived-headword? ( ca len -- f )
  drop c@ '.' <> ;
  \ XXX REMARK -- not used yet

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

: .pronunciation ( ca len -- )
  ."  (dise ‘" type ." ’)" ;
  \ Display the 'P' field _ca len_.

: ?.pronunciation ( -- )
  p-field $@ dup if .pronunciation else 2drop then ;
  \ Display the 'P' field, if any.

: (.headword) ( -- )
  asciidoctor? if ?letter-heading then
  c5? if   ." _____" cr cr
      then .headword-part1
  asciidoctor? if   headword-separator$ type
               else cr
               then .headword-part2
  ?.pronunciation cr cr ;
  \ Display the current headword.

: .headword- ( -- )
  (.headword) -headword ;
  \ Display the current headword and delete it.

: .fields ( -- )
  ?.description ?.note ?.usage ?.see ;

: translation ( ca1 len1 ca2 len2 -- )
  ." - " 2swap type ." : " type cr ;
  \ Display translation _ca2 len2_ in language code _ca1 len1_,
  \ as an item list.

: ?translation ( ca len a -- )
  $@ dup if translation else 2drop 2drop then ;
  \ If the translation contained in the dynamic string _a_
  \ is not empty, display it. Otherwise do nothing. _ca len_ is the
  \ language code.

: .translations ( -- )
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
  \ Display the list of translations.

: .data ( -- )
  .fields .translations ;
  \ Display the data of the current headword or section.

: .data- ( -- )
  .data -data ;
  \ Display the data of the current headword or section and delete
  \ them.

: ready? ( a -- f )
  $@len 0<> ;
  \ Is data field _a_ ready?
  \ I.e., is dynamic string _a_ not empty?

: (.section) ( -- )
  section $@ type bl emit ;
  \ Display the current section.

: .section- ( -- )
  (.section) -section ;
  \ Display the current section and delete it.

: .section ( -- )
  headword ready? if .headword- then .section- .data- ;
  \ Display the current section data and delete it.

: .headword ( -- )
  .headword- .data- ;
  \ Display the current headword and its data, then delete them.

\ ==============================================================
\ Input {{{1

: get-headword ( ca len -- )
  headword $! -section -data ;
  \ Get the headword from line _ca len_.

: get-section ( ca len -- )
  section $! -data ;
  \ Get the definition section from line _ca len_.

: get-datum ( ca len -- )
  2>r get-order datum-wordlist 1 set-order
  2r> evaluate set-order ;
  \ Get the datum from line _ca len_, evaluating it with the proper
  \ word list.

: headword-line? ( ca len -- f )
  drop c@ dup bl <> swap '(' <> and  ;
  \ Is line _ca len_ a headword line?
  \ Headword lines don't start with a space or a paren.

: section-line? ( ca len -- f )
  drop c@ '(' = ;
  \ Is line _ca len_ a section line?
  \ Section start with a number in parens.

: datum-line? ( ca len -- f )
  drop 2 s"   " str= ;
  \ Is line _ca len_ a datum line?
  \ Datum lines start with two spaces.

: data-line ( ca len -- )
  2dup headword-line? if get-headword exit then
  2dup section-line?  if get-section  exit then
  2dup datum-line?    if get-datum    exit then
  type abort" Line format not recognized" ;
  \ Manage a data line.

: empty-line ( -- )
  section  ready? if .section  exit then
  headword ready? if .headword exit then ;
  \ Manage an empty line.

: convert-line ( ca len -- )
  dup if data-line else 2drop empty-line then ;

: convert-input ( "filename" -- )
  begin line? while convert-line repeat ;

: convert-file ( "filename" -- )
  open-input convert-input close-input ;
  \ Convert the original dictionary data from "filename" to the
  \ currently selected format. The result is sent to standard
  \ output.

: to-asciidoctor ( "filename" -- )
  asciidoctor on  convert-file ;
  \ Convert the original dictionary data from "filename" to
  \ Asciidoctor format.  The result is sent to standard output.

: to-c5 ( "filename" -- )
  asciidoctor off  convert-file ;
  \ Convert the original dictionary data from "filename" to c5 format.
  \ The result is sent to standard output.

\ ==============================================================
\ Change log {{{1

\ 2019-01-04: Start, in order to replace a previous version written in
\ Vim, which used regexp and text substitutions.
\
\ 2019-01-05: First working version. Not finished.
\
\ 2019-01-07: Fix the logic of creating headwords and sections.
\ Convert the 'N', 'C' and 'V' fields. Simplify the Forth word names.
\ Improve factoring and comments.
\
\ 2019-01-09: Remove the italic markup from the 'T' fields, because
\ some of them included comments in Elefen. Join section indexes with
\ their descriptions.
\
\ 2019-01-11: Fix `.section`, which didnt't displayed the headword
\ when needed (by the first section).
\
\ 2019-01-13: Fix typo in comment. Make also a dict file. Shorten the
\ name of this file accordingly.

\ vim: filetype=gforth
