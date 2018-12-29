# Makefile of _Disionario de elefen_

# By Marcos Cruz (programandala.net)

# Last modified 201812290215
# See change log at the end of the file

# ==============================================================
# Requirements

# - make

# ==============================================================
# Config

VPATH=./src:./target

# ==============================================================
# Interface

.PHONY: all
all: target/disionario_de_elefen.epub

.PHONY: clean
clean:
	rm -f target/* tmp/*

# ==============================================================
# Preprocess the sources

tmp/%.adoc: src/%.adoc
	sed \
		-e 's/   (Leje plu…)$$//' \
		-e 's/^\[\(.\+\)] \1/\1/' \
		-e 's/\(.\+\)   \(ajetivo\|corti\|esclama\|nom\|prefisa\|preposada\|simbol\|verbo transitiva\|verbo nontransitiva\)\(   .\+\)\?$$/\n**{bullet}\1** (\2)\3\n/' \
		-e 's/^\([a-z][a-z]\)   /- \1: /' \
		-e 's/^\([0-9]\+\)   /\1. /' \
		$< > $@

# Description of the `sed` commands:

# 1: Remove link text "Leje plu".
#
# 2: Remove duplicate words in brackets.
#
# 3: Mark the entries with a bullet and bold style, and separate them from
# their definition.
#
# 4: Convert the translations into an unordered list.
#
# 5: Markup the numbers of the definitions list.

# XXX OLD
# grep -oh "^[a-z][a-z]\s\s\s" disionario_de_elefen_?.adoc|sort|uniq

# ==============================================================
# Make the EPUB

sources=$(sort $(wildcard src/*_?.adoc))

preprocessed_sources=$(addprefix tmp/,$(notdir $(sources)))

.SECONDARY: $(preprocessed_sources)

target/%.epub: src/%.adoc $(preprocessed_sources)
	asciidoctor-epub3 --out-file $@ $<

# ==============================================================
# Change log

# 2018-12-28: Start.
