#!/bin/bash

show_usage() {
	cat 1>&2 <<EOT
Usage: docker run [--rm] -v /path/to/outdir:/out bakudankun/ricty-generator [OPTIONS]
       docker run [--rm] bakudankun/ricty-generator --tarball [OPTIONS] > Ricty.tar.gz
       docker run [--rm] bakudankun/ricty-generator --zipball [OPTIONS] > Ricty.zip
       docker run [--rm] bakudankun/ricty-generator [ -h | --help ]

A nice guy which generates Ricty fonts automatically.

Options:

  --tarball                Vomit .tar.gz archive of generated fonts to stdout
  --zipball                Vomit .zip archive of generated fonts to stdout
  --generator-opts=opts    Options for ricty_generator.sh (see below)
  -o, --oblique            Create oblique fonts
  --no-os2                 Don't fix font width on Windows
  -h, --help               Show this usage and exit

EOT
	./ricty_generator.sh -h | awk 'start==1 {print} $1=="Options:" {print "Options for ricty_generator.sh:"; start=1}' 1>&2
	echo 1>&2
}


# Parse options.

OPT=`getopt -o "oh" -l "tarball,zipball,help,oblique,no-os2,generator-opts:" -- "$@"`
if [ $? != 0 ]; then show_usage; exit 1; fi

eval set -- "$OPT"

while [ $# -gt 0 ]
do
	case $1 in
		--tarball) tarball=true; zipball=; shift ;;
		--zipball) zipball=true; tarball=; shift ;;
		--generator-opts) shift; generator_opts=$1; shift ;;
		-o | --oblique) oblique=true; shift ;;
		--no-os2) no_os2=true; shift ;;
		-h | --help) show_usage; exit 0 ;;
		--) shift; break ;;
		*) show_usage; exit 1 ;;
	esac
done


# Exit if no output method is set.

if [ ! \( "$tarball" -o "$zipball" -o -d /out \) ]; then
	echo "Error: No output method specified." 1>&2
	show_usage;
	exit 1;
fi


# Generate Ricty fonts if not exist.

ls Ricty*.ttf >/dev/null 2>&1
if [ $? != 0 ]; then
	eval "./ricty_generator.sh $generator_opts auto" 1>&2
	if [ $? != 0 ]; then
		echo 'ricty_generator.sh returned an error. Exiting...' 1>&2
		exit 1
	fi
fi


ls Ricty*.ttf >/dev/null 2>&1
if [ $? != 0 ]; then
	echo 'Failed to generate Ricty. Exiting...' 1>&2
	exit 1
fi

# Now Ricty*.ttf must be exist.


# Generate oblique fonts if --oblique is specified and not already exists.

ls Ricty*Oblique.ttf >/dev/null 2>&1
if [ $? != 0 -a "$oblique" ]; then
	echo 'Create oblique fonts.' 1>&2
	fontforge ./regular2oblique_converter.pe Ricty*.ttf 1>&2
	if [ $? != 0 ]; then
		echo 'regular2oblique_converter.pe returned an error. Exiting...' 1>&2
		exit 1
	else
		echo 'Done.' 1>&2
	fi
fi


# Fix font width for Windows unless --no-os2 is set.

if [ ! "$no_os2" ]; then
	echo 'Fix font width for Windows.' 1>&2
	for i in Ricty*.ttf
	do
		ttx -t OS/2 $i 1>&2
		# xAvgCharWidth of Inconsolata and Migu 1M is 500.
		sed -i -e "s/xAvgCharWidth value=\".*\"/xAvgCharWidth value=\"500\"/" ${i%.*}.ttx 1>&2
		mv $i $i.bak
		ttx -m $i.bak ${i%.*}.ttx 1>&2
		rm ${i%.*}.ttx
	done
fi


# Output generated fonts.

if ls Ricty*.ttf >/dev/null 2>&1; then
	if [ -d /out ]; then
		cp -r Ricty*.ttf LICENSE /out 1>&2
		echo 'Copied font files. Check the output dir.' 1>&2
	fi
	
	if [ "$tarball" -o "$zipball" ]; then
		outdir="Ricty-v${RICTY_VERSION}"
		mkdir $outdir 1>&2
		cp -r Ricty*.ttf LICENSE $outdir 1>&2
		if [ "$tarball" ]; then
			echo 'Now vomit .tar.gz archive to stdout.' 1>&2
			tar -czf - $outdir
		elif [ "$zipball" ]; then
			echo 'Now vomit .zip archive to stdout.' 1>&2
			zip -qr - $outdir
		fi
		echo 'Done. Check the redirected file.' 1>&2
	fi
else
	echo 'Huh? What happened?' 1>&2
	exit 1
fi
