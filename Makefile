# Makefile of _Disionario de elefen_

# This file is part of the project
# "Disionario de elefen"
# (http://ne.alinome.net)
#
# By Marcos Cruz (programandala.net)

# Last modified 201901290029
# See change log at the end of the file

# ==============================================================
# Requirements

# - asciidoctor
# - asciidoctor-epub3
# - dictfmt
# - gforth
# - make
# - pandoc
# - vim
# - xsltproc

# ==============================================================
# Config

VPATH=./src:./target

# ==============================================================
# Interface

.PHONY: all
all: epub

# EPUB in 1 and 4 tomes:
.PHONY: epub
epub: epub1 epub4

# EPUB in 1 tome:
.PHONY: epub1
epub1: epub1p epub1x

# EPUB in 1 tome, with asciidoctor-epub3:
.PHONY: epub1a
epub1a: target/disionario_de_elefen.adoc.epub

# EPUB in 1 tome, with pandoc:
.PHONY: epub1p
epub1p: target/disionario_de_elefen.adoc.xml.pandoc.epub

# EPUB in 1 tome, with xsltproc:
.PHONY: epub1x
epub1x: target/disionario_de_elefen.adoc.xml.xsltproc.epub

# EPUB in 4 tomes:
.PHONY: epub4
epub4: epub4p epub4x

# EPUB in 4 tomes, with asciidoctor-epub3:
.PHONY: epub4a
epub4a: \
	target/disionario_de_elefen_en_4_librones_a-c.adoc.epub \
	target/disionario_de_elefen_en_4_librones_d-l.adoc.epub \
	target/disionario_de_elefen_en_4_librones_m-r.adoc.epub \
	target/disionario_de_elefen_en_4_librones_s-z.adoc.epub

# EPUB in 4 tomes, with pandoc:
.PHONY: epub4p
epub4p: \
	target/disionario_de_elefen_en_4_librones_a-c.adoc.xml.pandoc.epub \
	target/disionario_de_elefen_en_4_librones_d-l.adoc.xml.pandoc.epub \
	target/disionario_de_elefen_en_4_librones_m-r.adoc.xml.pandoc.epub \
	target/disionario_de_elefen_en_4_librones_s-z.adoc.xml.pandoc.epub

# EPUB in 4 tomes, with xsltproc:
.PHONY: epub4x
epub4x: \
	target/disionario_de_elefen_en_4_librones_a-c.adoc.xml.xsltproc.epub \
	target/disionario_de_elefen_en_4_librones_d-l.adoc.xml.xsltproc.epub \
	target/disionario_de_elefen_en_4_librones_m-r.adoc.xml.xsltproc.epub \
	target/disionario_de_elefen_en_4_librones_s-z.adoc.xml.xsltproc.epub

# XXX TMP -- for debugging
.PHONY: test
test: \
	target/disionario_de_elefen_en_4_librones_a-c.adoc.xml.xsltproc.epub

.PHONY: adoc
adoc: tmp/disionario_completa.adoc

.PHONY: c5
c5: tmp/disionario_completa.c5

.PHONY: dict
dict: target/elefen.dict.dz

.PHONY: clean
clean:
	rm -fr target/* tmp/*

# ==============================================================
# Convert the original data file to Asciidoctor

.SECONDARY: tmp/disionario_completa.adoc

tmp/%.adoc: src/%.txt
	gforth make/convert_data.fs -e "to-asciidoctor $< bye" > $@
	vim -e -S make/tidy_data.vim $@

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
# Convert the original data file to c5

.SECONDARY: tmp/disionario_completa.c5

tmp/%.c5: src/%.txt
	gforth make/convert_data.fs -e "to-c5 $< bye" > $@
	vim -e -S make/tidy_data.vim $@

# ==============================================================
# Convert c5 to dict

target/elefen.dict: tmp/disionario_completa.c5
	dictfmt \
		--utf8 \
		-u "http://elefen.org" \
		-s "Disionario de elefen" \
		-c5 $(basename $@) \
		< $<

# ==============================================================
# Install and uninstall dict

%.dict.dz: %.dict
	dictzip --force $<

.PHONY: install
install: target/elefen.dict.dz
	cp --force \
		$< \
		$(addsuffix .index, $(basename $(basename $^))) \
		/usr/share/dictd/
	/usr/sbin/dictdconfig --write
	/etc/init.d/dictd restart

.PHONY: uninstall
uninstall:
	rm --force /usr/share/dictd/elefen.*
	/usr/sbin/dictdconfig --write
	/etc/init.d/dictd restart

# ==============================================================
# Convert Asciidoctor to DocBook

.SECONDARY: \
	tmp/disionario_completa.adoc.xml \
	tmp/disionario_de_elefen_en_4_librones_a-c.adoc.xml \
	tmp/disionario_de_elefen_en_4_librones_d-l.adoc.xml \
	tmp/disionario_de_elefen_en_4_librones_m-r.adoc.xml \
	tmp/disionario_de_elefen_en_4_librones_s-z.adoc.xml

tmp/%.adoc.xml: src/%.adoc
	asciidoctor --backend=docbook5 --out-file=$@ $<

# ==============================================================
# Make the EPUB

# ----------------------------------------------
# By asciidoctor-epub3, from Asciidoctor

target/%.adoc.epub: src/%.adoc $(letter_files)
	asciidoctor-epub3 --out-file=$@ $<

# ----------------------------------------------
# By pandoc, from DocBook

target/%.adoc.xml.pandoc.epub: tmp/%.adoc.xml $(letter_files)
	pandoc \
		--from=docbook \
		--to=epub3 \
		--template=src/pandoc_epub_template.txt \
		--output=$@ $<

# ----------------------------------------------
# By xsltproc, from DocBook

target/%.adoc.xml.xsltproc.epub: tmp/%.adoc.xml $(letter_files)
	rm -fr tmp/xsltproc/* && \
	xsltproc \
		--output tmp/xsltproc/ \
		/usr/share/xml/docbook/stylesheet/docbook-xsl/epub/docbook.xsl \
		$< && \
	echo -n "application/epub+zip" > tmp/xsltproc/mimetype && \
	cd tmp/xsltproc/ && \
	zip -0 -X ../../$@.zip mimetype && \
	zip -rg9 ../../$@.zip META-INF && \
	zip -rg9 ../../$@.zip OEBPS && \
	cd - && \
	mv $@.zip $@

# XXX TODO -- Find out how to pass parameters and their names, from the XLS:
#	    --param epub.ncx.filename testing.ncx \

# XXX TODO -- Add the stylesheet. The XLS must be modified first,
# or the resulting XHTML must be modified at the end.
#	cp -f src/xsltproc/stylesheet.css tmp/xsltproc/OEBPS/ && \

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
# notes and curly brackets markup. Build the dictionary also in four tomes.
#
# 2019-01-11: Improve: Add the letter files to the prerequisites of pandoc
# EPUB, and use `.SECONDARY` to keep the temporary DocBook files.
#
# 2019-01-12: Make an EPUB also with xsltproc.
#
# 2019-01-13: Make also a dict file.
#
# 2019-01-24: Deactivate asciidoctor-epub3. Use a pandoc template. Create EPUB3
# with pandoc.
#
# 2019-01-29: Create a file from the Vim commands that tidy the Asciidoctor
# document, in order to reuse it to tidy also the c5 file.
