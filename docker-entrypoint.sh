#!/bin/sh

show_usage() {
	cat <<EOT
Usage:
 docker run [--rm] -v /path/to/outdir:/out bakudankun/ricty-generator
 docker run [--rm] bakudankun/ricty-generator --tarball > Ricty.tar.gz
 docker run [--rm] bakudankun/ricty-generator --zipball > Ricty.zip
 docker run [--rm] bakudankun/ricty-generator [-h|--help]
EOT
}

OPT=`getopt -o "h" -l "tarball,zipball,help" -- "$@"`
if [ $? != 0 ]; then show_usage; exit 1; fi

set -- $OPT

while [ $# -gt 0 ]; do
	case $1 in
		--tarball) tarball=true ;;
		--zipball) zipball=true ;;
		-h | --help) show_usage; exit 0 ;;
		*) show_usage; exit 1 ;;
	esac
	shift
done

cd /Ricty-${RICTY_VERSION}

if [ ! -e Ricty-Regular.ttf ]; then
	if [ ! "$tarball" -a ! "$zipball" ]; then
		./ricty_generator.sh auto
			if [ ! -e Ricty-Regular.ttf ]; then
				echo 'Failed to generate Ricty. exitting...'
				exit 1;
			else
				echo 'Now revise fonts for OS/2 (it may takes a little time).'
				./misc/os2version_reviser.sh Ricty*.ttf
				if [ $? = 0 ]; then
					echo 'Complete!'
				else
					echo 'Failed to revise fonts. The output fonts may have wide spaces.'
				fi
			fi
	else
		./ricty_generator.sh auto >/dev/null 2>&1
		./misc/os2version_reviser.sh Ricty*.ttf >/dev/null 2>&1
	fi
fi

if [ -e Ricty-Regular.ttf ]; then
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
fi
