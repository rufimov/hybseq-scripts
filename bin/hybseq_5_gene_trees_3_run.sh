#!/bin/bash

# Processing variables

# Parse initial arguments
while getopts "hva:n:" INITARGS; do
	case "${INITARGS}" in
		h) # Help and exit
			echo "Usage options:"
			echo -e "\t-h\tPrint this help and exit."
			echo -e "\t-v\tPrint script version, author and license and exit."
			echo -e "\t-a\tInput alignment in FASTA format to use for gene tree construction."
			echo
			exit
			;;
		v) # Print script version and exit
			echo "Version: 1.0"
			echo "Author: Vojtěch Zeisek, https://trapa.cz/en"
			echo "License: GNU GPLv3, https://www.gnu.org/licenses/gpl-3.0.html"
			echo
			exit
			;;
		a) # Reference bait FASTA file
			if [ -r "${OPTARG}" ]; then
				ALN="${OPTARG}"
				echo "Input alignment in FASTA format to use for gene tree construction: ${ALN}"
				echo
				else
					echo "Error! You did not provide input alignment in FASTA format to use for gene tree construction (-a) \"${OPTARG}\"!"
					echo
					exit 1
					fi
			;;
		n) # Number of cores
			ncpu="${OPTARG}"
			echo "${ncpu} cores used"
			;;
		*)
			echo "Error! Unknown option!"
			echo "See usage options: \"$0 -h\""
			echo
			exit 1
			;;
		esac
	done

# Exit on error
function operationfailed {
	echo "Error! Operation failed!"
	echo
	echo "See previous message(s) to be able to trace the problem."
	echo
	# Do not clean SCRATCHDIR, but copy content back to DATADIR
	export CLEAN_SCRATCH='false'
	exit 1
	}


# Checking if all required variables are provided
if [ -z "${ALN}" ]; then
	echo "Error! Input alignment in FASTA format to use for gene tree construction not provided!"
	operationfailed
	fi

# Construct gene trees with RAxML from *.aln.fasta alignments
echo "Constructing gene tree for ${ALN} with RAxML at $(date)"
raxmlHPC-PTHREADS -T "${ncpu}" -s "${ALN}" -n "${ALN}".bestML -m GTRGAMMA -p 12345 >> "${ALN}".raxml.log | operationfailed
raxmlHPC-PTHREADS -T "${ncpu}" -b 12345 -s "${ALN}" -n "${ALN}".boot -m GTRGAMMA -p 12345 -N 500 >> "${ALN}".raxml.log | operationfailed
raxmlHPC-PTHREADS -T "${ncpu}" -f b -t RAxML_bestTree."${ALN}".bestML -z RAxML_bootstrap."${ALN}".boot -n "${ALN}".result -m GTRGAMMA -p 12345 >> "${ALN}".raxml.log |operationfailed
echo

exit

