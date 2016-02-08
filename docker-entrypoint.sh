#!/bin/sh

tarball=false
zipball=false

OPT=`getopt -o "" -l "tarball,zipball" -- "$@"`
set -- $OPT

while [ $# -gt 0 ]; do
	case $1 in
		--tarball) tarball=true ;;
		--zipball) zipball=true ;;
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
		cp -r Ricty*.ttf LICENSE README.md /out
	elif [ $tarball -o $zipball ]; then
		outdir="Ricty-v${RICTY_VERSON}"
		mkdir $outdir
		cp -r Ricty*.ttf LICENSE README.md $outdir
		if [ $tarball ]; then
			tar -czf - $outdir
		elif [ $zipball ]; then
			zip $outdir >/dev/null 2>&1
			cat $outdir.zip
		fi
	fi
fi
