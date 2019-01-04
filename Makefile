# Makefile of _Disionario de elefen_

# This file is part of the project
# "Disionario de elefen"
# (http://ne.alinome.net)
#
# By Marcos Cruz (programandala.net)

# Last modified 201901042218
# See change log at the end of the file

# ==============================================================
# Requirements

# - asciidoctor
# - asciidoctor-epub3
# - make
# - vim

# ==============================================================
# Config

VPATH=./src:./target

old=

# ==============================================================
# Interface

.PHONY: all
all: target/disionario_de_elefen.epub

.PHONY: clean
clean:
	rm -f target/* tmp/*

# ==============================================================
# Convert the original data file to Asciidoctor

tmp/%.adoc: src/%.txt
	vim -e \
		-S make/convert_data_to_asciidoctor.vim \
		-c 'saveas! $@' \
		-c 'quit!' \
		$<

# ==============================================================
# Make the EPUB

target/%.epub: src/%.adoc tmp/disionario_completa.adoc
	asciidoctor-epub3 --out-file $@ $<

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
