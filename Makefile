# Makefile of _Disionario de elefen_

# By Marcos Cruz (programandala.net)

# Last modified 201812300043
# See change log at the end of the file

# ==============================================================
# Requirements

# - make
# - sed
# - vim

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

word_type=ajetivo\|averbo\|composada (nom+ajetivo)\|composada (nom+nom)\|composada (verbo+nom)\|conjunta\|corti\|determinante\|esclama\|espresa\|nom\|plural\|prefisa\|preposada\|preverbal\|pronom\|simbol\|sufisa\|sujunta\|verbo\|verbo transitiva\|verbo nontransitiva

tmp/%.adoc: src/%.adoc
	sed \
		-e 's/   (Leje plu…)$$//' \
		-e 's/^\[\(.\+\)] \1/\1/' \
		-e 's/^\(\(» \) \)\?\(\S.*\)   \(\($(word_type)\)\(, \($(word_type)\)\)*\)\(   .\+\)\?$$/\n\2**{bullet}\3** (\4)\8\n/' \
		-e 's/^\([a-z][a-z]\)   /\n- \1: /' \
		-e 's/^\([0-9]\+\)   \(.\+\)$$/\1. \2\n+/' \
		$< > $@
	vim $@ -c ":%s@\([A-Z].\+\)\n\([A-Z].\+\)@\1\r(_\2_)@e|wq"

# Description of the sed commands:
#
# 1: Remove link text "Leje plu".
#
# 2: Remove duplicate words in brackets.
#
# 3: Mark main and secondary entries with a bullet and bold style, and separate
# them from their definitions.
#
# 4: Convert the translations into a list.
#
# 5: Markup the numbers of the definitions list.

# Description of the vim command:
#
# Markup the species names with italics and put them in parens.
#
# The species name is detected because it's the paragraph after the term
# description. I.e.  when there are two adjacent one-line paragraphs, which
# start with a capital letter, the second one is a species name.

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
#
# 2018-12-29: Fix and finish the preprocessing expressions.
#
# 2018-12-30: Markup the species names.
