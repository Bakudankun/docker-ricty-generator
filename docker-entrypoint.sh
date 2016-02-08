#!/bin/sh

tarball=false
zipball=false

OPT=`getopt -o "" -l "tarball" -- "$@"`
set -- $OPT

while [ $# -gt 0 ]; do
	case $1 in
		--tarball) tarball=true ;;
	esac
	shift
done

cd /Ricty-${RICTY_VERSION}

if [ ! -e Ricty-Regular.ttf ]; then
	if [ ! $tarball -a ! $zipball ]; then
		./ricty_generator.sh auto
		./misc/os2version_reviser.sh Ricty*.ttf
	else
		./ricty_generator.sh auto >/dev/null 2>&1
		./misc/os2version_reviser.sh Ricty*.ttf >/dev/null 2>&1
	fi
fi

if [ -e Ricty-Regular.ttf ]; then
	if [ ! $tarball -a ! $zipball ]; then
		cp Ricty*.ttf LICENSE README.md /out
	elif [ $tarball ]; then
		outdir="Ricty-v${RICTY_VERSON}"
		mkdir $outdir
		cp Ricty*.ttf LICENSE README.md $outdir
		tar -czf - $outdir
	fi
fi
