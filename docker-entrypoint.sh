#!/bin/sh

show_usage() {
	cat <<EOT
Usage: docker run [--rm] -v /path/to/outdir:/out bakudankun/ricty-generator [OPTIONS]
       docker run [--rm] bakudankun/ricty-generator --tarball [OPTIONS] > Ricty.tar.gz
       docker run [--rm] bakudankun/ricty-generator --zipball [OPTIONS] > Ricty.zip
       docker run [--rm] bakudankun/ricty-generator [ -h | --help ]

Options:

  --discord-opts=opts      Options for ricty_discord_converter.pe (read Ricty's README for detail)
  --generator-opts=opts    Options for ricty_generator.sh (read Ricty's README for detail)
  --oblique                Create oblique fonts
  --no-os2                 Don't execute os2version_reviser.sh
  --tarball                Vomit .tar.gz archive of generated fonts to stdout
  -h, --help               Show usage
  --zipball                Vomit .zip archive of generated fonts to stdout
EOT
}

OPT=`getopt -o "oh" -l "tarball,zipball,help,oblique,no-os2,generator-opts:,discord-opts:" -- "$@"`
if [ $? != 0 ]; then show_usage; exit 1; fi

eval set -- "$OPT"

while [ $# -gt 0 ]; do
	case $1 in
		--tarball) tarball=true; shift ;;
		--zipball) zipball=true; shift ;;
		--generator-opts) shift; generator_opts=$1; shift ;;
		--discord-opts) shift; discord_opts=$1; shift ;;
		-o | --oblique) oblique=true; shift ;;
		--no-os2) no_os2=true; shift ;;
		-h | --help) show_usage; exit 0 ;;
		--) shift; break ;;
		*) show_usage; exit 1 ;;
	esac
done

cd /Ricty-${RICTY_VERSION}

ls Ricty*.ttf >/dev/null 2>&1
if [ $? != 0 ]; then
	eval "./ricty_generator.sh $generator_opts auto" 1>&2
	if [ $? != 0 ]; then
		echo 'ricty_generator.sh returned an error. Exiting...' 1>&2
		exit 1
	fi
	ls Ricty*.ttf >/dev/null 2>&1
	if [ $? != 0 ]; then
		echo 'Failed to generate Ricty. Exiting...' 1>&2
		exit 1
	fi
	if [ "$discord_opts" ]; then
		echo 'Generate specified RictyDiscord fonts.' 1>&2
		rm Ricty*Discord*.ttf >/dev/null 2>&1
		eval "fontforge ricty_discord_converter.pe $discord_opts Ricty*.ttf" 1>&2
		if [ $? != 0 ]; then
			echo 'ricty_discord_converter.pe returned an error. Exiting...' 1>&2
			exit 1
		fi
		echo 'Done.' 1>&2
	fi
	if [ "$oblique" ]; then
		echo 'Create oblique fonts.' 1>&2
		fontforge ./misc/regular2oblique_converter.pe Ricty*.ttf 1>&2
		if [ $? != 0 ]; then
			echo 'regular2oblique_converter.pe returned an error. Exiting...' 1>&2
			exit 1
		fi
		echo 'Done.' 1>&2
	fi
	if [ ! "$no_os2" ]; then
		echo 'Now revise fonts for OS/2 (it may takes a little time).' 1>&2
		./misc/os2version_reviser.sh Ricty*.ttf 1>&2
		if [ $? = 0 ]; then
			echo 'Done.' 1>&2
		else
			echo 'Failed to revise fonts. The output fonts may have wide spaces.' 1>&2
		fi
	fi
fi

if ls Ricty*.ttf >/dev/null 2>&1; then
	if [ ! "$tarball" -a ! "$zipball" ]; then
		cp -r Ricty*.ttf LICENSE README.md /out
		echo 'Copied font files. Check the output dir.'
	elif [ "$tarball" -o "$zipball" ]; then
		outdir="Ricty-v${RICTY_VERSION}"
		mkdir $outdir
		cp -r Ricty*.ttf LICENSE README.md $outdir
		if [ "$tarball" ]; then
			tar -czf - $outdir
		elif [ "$zipball" ]; then
			zip -qr - $outdir
		fi
	fi
else
	echo 'What happened?' 1>&2
fi
