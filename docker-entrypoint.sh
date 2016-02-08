#!/bin/sh

cd /Ricty-${RICTY_VERSION}

if [ ! -e Ricty-Regular.ttf ]; then
	./ricty_generator.sh auto
	./misc/os2version_reviser.sh Ricty*.ttf
fi

if [ -e Ricty-Regular.ttf ]; then
	cp -r Ricty*.ttf LICENSE README.md /out
fi
