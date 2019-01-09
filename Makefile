# Makefile of _Disionario de elefen_

# This file is part of the project
# "Disionario de elefen"
# (http://ne.alinome.net)
#
# By Marcos Cruz (programandala.net)

# Last modified 201901091641
# See change log at the end of the file

# ==============================================================
# Requirements

# - asciidoctor
# - asciidoctor-epub3
# - gforth
# - make
# - pandoc
# - vim

# ==============================================================
# Config

VPATH=./src:./target

# ==============================================================
# Interface

.PHONY: all
all: epub epub4t

.PHONY: epub
epub: \
	target/disionario_de_elefen.adoc.epub \
	target/disionario_de_elefen.adoc.xml.epub

.PHONY: epub4t
epub4t: \
	target/disionario_de_elefen_en_4_librones_a-c.adoc.epub \
	target/disionario_de_elefen_en_4_librones_d-l.adoc.epub \
	target/disionario_de_elefen_en_4_librones_m-r.adoc.epub \
	target/disionario_de_elefen_en_4_librones_s-z.adoc.epub \
	target/disionario_de_elefen_en_4_librones_a-c.adoc.xml.epub \
	target/disionario_de_elefen_en_4_librones_d-l.adoc.xml.epub \
	target/disionario_de_elefen_en_4_librones_m-r.adoc.xml.epub \
	target/disionario_de_elefen_en_4_librones_s-z.adoc.xml.epub

.PHONY: adoc
adoc: tmp/disionario_completa.adoc

.PHONY: clean
clean:
	rm -f target/* tmp/*

# ==============================================================
# Convert the original data file to Asciidoctor

.SECONDARY: tmp/disionario_completa.adoc

tmp/%.adoc: src/%.txt
	gforth make/convert_data_to_asciidoctor.fs -e "run $< bye" > $@
	vim -e \
		-c '%s@({;} @(@e' \
		-c '%s@ {;}@;@eg' \
		-c '%s@{\([A-Z0-9=-]\{-}\)}@`\1`@eg' \
		-c '%s@{\(\S\{-}\)\^\(\S\{-}\)}@\1^\2^@eg' \
		-c '%s@{\(.\{-}\) \/\/.\{-}}@\1@eg' \
		-c '%s@ \(\/\/.\+\)$$@\r\1@eg' \
		-c '%s@^NOTE:\n@@eg' \
		-c '%s@{\(\S.\{-}\)}@\1@eg' \
		-c 'write!' \
		-c 'quit' $@

# ==============================================================
# Create one Asciidoctor file per letter

letter_files=\
	tmp/disionario_de_elefen_a.adoc \
	tmp/disionario_de_elefen_b.adoc \
	tmp/disionario_de_elefen_c.adoc \
	tmp/disionario_de_elefen_d.adoc \
	tmp/disionario_de_elefen_e.adoc \
	tmp/disionario_de_elefen_f.adoc \
	tmp/disionario_de_elefen_g.adoc \
	tmp/disionario_de_elefen_h.adoc \
	tmp/disionario_de_elefen_i.adoc \
	tmp/disionario_de_elefen_j.adoc \
	tmp/disionario_de_elefen_k.adoc \
	tmp/disionario_de_elefen_l.adoc \
	tmp/disionario_de_elefen_m.adoc \
	tmp/disionario_de_elefen_n.adoc \
	tmp/disionario_de_elefen_o.adoc \
	tmp/disionario_de_elefen_p.adoc \
	tmp/disionario_de_elefen_q.adoc \
	tmp/disionario_de_elefen_r.adoc \
	tmp/disionario_de_elefen_s.adoc \
	tmp/disionario_de_elefen_t.adoc \
	tmp/disionario_de_elefen_u.adoc \
	tmp/disionario_de_elefen_v.adoc \
	tmp/disionario_de_elefen_w.adoc \
	tmp/disionario_de_elefen_x.adoc \
	tmp/disionario_de_elefen_y.adoc \
	tmp/disionario_de_elefen_z.adoc

$(letter_files): tmp/disionario_completa.adoc
	vim -e -R \
		-S make/split_dictionary_into_letters.vim \
		-c 'quit!' \
		$<

# ==============================================================
# Convert Asciidoctor to DocBook

.SECONDARY: tmp/disionario_completa.adoc.xml

tmp/%.adoc.xml: src/%.adoc
	asciidoctor --backend=docbook5 --out-file=$@ $<

# ==============================================================
# Make the EPUB

target/%.adoc.epub: src/%.adoc $(letter_files)
	asciidoctor-epub3 --out-file=$@ $<

target/%.adoc.xml.epub: tmp/%.adoc.xml
	pandoc --from=docbook --to=epub --output=$@ $<

# ==============================================================
# Change log

# 2018-12-28: Start.
#
# 2018-12-29: Fix and finish the preprocessing expressions.
#
# 2018-12-30: Markup the species names. Fix the "nb" notes, which were
# interpreted as a translation into language code "nb". Separate references
# from the previous paragraph. Markup examples as example blocks.
#
# 2019-01-04: Rewrite: Use the original data file.
#
# 2019-01-05: Write a new converter in Forth to replace the Vim code.
#
# 2019-01-09: Remove the old Vim converter. Use Vim to split the converted file
# into letters. Add an EPUB version build by pandoc. Convert original internal
# notes and curly brackets markup.
