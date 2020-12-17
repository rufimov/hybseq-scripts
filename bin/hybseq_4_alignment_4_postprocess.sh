#!/bin/bash

# Checking if exactly one variables is provided
if [ "$#" -ne '1' ]; then
	echo "Error! Exactly 1 parameter (directory with aligned sequences to process) is required! $# parameters received."
	exit 1
	fi

# List of samples - relative path from directory to process
SAMPLES='../../2_seqs/samples_list.txt'

# Exit on error
function operationfailed {
	echo "Error! Operation failed!"
	echo
	echo "See previous message(s) to be able to trace the problem."
	echo
	exit 1
	}

# Alignment statistics
function alignstats {
	# Number of sites with 1, 2, 3 or 4 observed bases
	echo "Initializing files with statistics"
	printf "\t\t\tNumbers of sites with 1, 2, 3 or 4 observed bases\n" > "$1" || operationfailed
	printf "Alignment\tNumber of sequences\tNumber of sites\t1\t2\t3\t4\n" >> "$1" || operationfailed
	echo
	for L in *.log; do
		echo "Processing ${L%.*}"
		{ printf '%s\t' "${L}" # Print sample name
			grep "Number of sequences:" "${L}" | grep -o "[0-9]\+" | xargs printf '%s\t%s'
			grep "Number of sites:" "${L}" | grep -o "[0-9]\+" | xargs printf '%s\t%s'
			grep -A 2 "Number of sites with 1, 2, 3 or 4 observed bases:" "${L}" | tail -n 1 | sed 's/^[[:blank:]]\+//'| sed 's/[[:blank:]]\+/ /g' | cut -f 1 -d ' ' | xargs printf '%s\t%s'
			grep -A 2 "Number of sites with 1, 2, 3 or 4 observed bases:" "${L}" | tail -n 1 | sed 's/^[[:blank:]]\+//'| sed 's/[[:blank:]]\+/ /g' | cut -f 2 -d ' ' | xargs printf '%s\t%s'
			grep -A 2 "Number of sites with 1, 2, 3 or 4 observed bases:" "${L}" | tail -n 1 | sed 's/^[[:blank:]]\+//'| sed 's/[[:blank:]]\+/ /g' | cut -f 3 -d ' ' | xargs printf '%s\t%s'
			grep -A 2 "Number of sites with 1, 2, 3 or 4 observed bases:" "${L}" | tail -n 1 | sed 's/^[[:blank:]]\+//'| sed 's/[[:blank:]]\+/ /g' | cut -f 4 -d ' ' | xargs printf '%s\t%s'
			printf '\n'
			} >> "$1" || operationfailed
		done
	}

# Statistics of presence of samples in alignments
function samplestats {
	# How many times is each sample presented in all alignments
	echo -e "Total number of contigs:\t$(find . -maxdepth 1 -name "*.aln.fasta" | wc -l)" > "$1" || operationfailed
	echo >> "$1" || operationfailed
	echo -e "Sample\tNumber" >> "$1" || operationfailed
	while read -r SAMPLE; do
		echo -e "${SAMPLE}\t$(grep "^>${SAMPLE}$" ./*.fasta | wc -l)" >> "$1" || operationfailed
		done < <(sed 's/\.dedup$//' "${SAMPLES}")
	echo >> "$1" || operationfailed
	}

# Switching to working directory
echo "Going to $1"
cd "$1" || operationfailed
echo

# Alignments sorted according to file size
echo "List of alignments according to their size"
find . -type f -name "*aln.fasta" -printf '%k KB %p\n' | sort -n || operationfailed
echo



# Sorting into subdirectories
echo "Sorting into subdirectories"
echo "Making directories"
mkdir exons introns supercontigs || operationfailed
echo "Moving introns"
find . -maxdepth 1 -type f -name "*introns*" -exec mv '{}' introns/ \; || operationfailed
echo "Moving supercontigs"
find . -maxdepth 1 -type f -name "*supercontig*" -exec mv '{}' supercontigs/ \; || operationfailed
echo "Moving exons"
find . -maxdepth 1 -type f -exec mv '{}' exons/ \; || operationfailed
echo


# Statistics of alignments
echo "Extracting alignment statistics"
echo "Statistics of exons"
cd exons/ || operationfailed
alignstats alignments_stats_exons.tsv || operationfailed
echo
echo "Statistics of introns"
cd ../introns/ || operationfailed
alignstats alignments_stats_introns.tsv || operationfailed
echo
echo "Statistics of supercontigs"
cd ../supercontigs/ || operationfailed
alignstats alignments_stats_supercontigs.tsv || operationfailed
echo
cd .. || operationfailed
echo
echo "Moving statistics files"
mv exons/alignments_stats_exons.tsv introns/alignments_stats_introns.tsv supercontigs/alignments_stats_supercontigs.tsv . || operationfailed
echo
echo "Removing unneeded strings from statistics"
sed -i 's/\.log\>//' alignments_stats_*.tsv || operationfailed
echo

# Statistics of presence of samples
echo "Statistics of presence of samples in all alignments"
echo "Statistics of exons"
cd exons/ || operationfailed
samplestats presence_of_samples_in_exons.tsv || operationfailed
echo
echo "Statistics of introns"
cd ../introns/ || operationfailed
samplestats presence_of_samples_in_introns.tsv || operationfailed
echo
echo "Statistics of supercontigs"
cd ../supercontigs/ || operationfailed
samplestats presence_of_samples_in_supercontigs.tsv || operationfailed
cd .. || operationfailed
echo
echo "Moving statistics files"
mv exons/presence_of_samples_in_exons.tsv introns/presence_of_samples_in_introns.tsv supercontigs/presence_of_samples_in_supercontigs.tsv . || operationfailed

exit
