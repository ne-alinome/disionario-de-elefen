# Makefile of _Disionario de elefen_

# By Marcos Cruz (programandala.net)

# Last modified 201812282355
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
# Make the EPUB

sources=$(wildcard src/*.adoc)

target/%.epub: src/%.adoc $(sources)
	asciidoctor-epub3 --out-file $@ $<

# ==============================================================
# Change log

# 2018-12-28: Start.
