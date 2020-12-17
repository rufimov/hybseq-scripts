#!/bin/bash

# Checking if exactly one variables is provided
if [ "$#" -ne '1' ]; then
	echo "Error! Exactly 1 parameter (directory with gene trees to process) is required! $# parameters received."
	exit 1
	fi

# Exit on error
function operationfailed {
	echo "Error! Operation failed!"
	echo
	echo "See previous message(s) to be able to trace the problem."
	echo
	exit 1
	}

# Switching to working directory
echo "Going to $1"
cd "$1" || operationfailed
echo

# Inserting trees into tree lists
echo "Maximum-likelihood trees"
echo
echo "Creating lists of trees"
echo "List of introns"
find . -name "RAxML_bipartitions.*.result" | sort | grep introns > trees_ml_list_introns.txt || operationfailed
echo "List of supercontigs"
find . -name "RAxML_bipartitions.*.result" | sort | grep supercontig > trees_ml_list_supercontig.txt || operationfailed
echo "List of exons"
find . -name "RAxML_bipartitions.*.result" | sort | grep -v "introns\|supercontig" > trees_ml_list_exons.txt || operationfailed
echo "Extracting trees"
echo "Extracting introns"
while read -r T; do
	cat "${T}" >> trees_ml_introns.nwk || operationfailed
	done < trees_ml_list_introns.txt
echo "Extracting supercontigs"
while read -r T; do
	cat "${T}" >> trees_ml_supercontigs.nwk || operationfailed
	done < trees_ml_list_supercontig.txt
echo "Extracting exons"
while read -r T; do
	cat "${T}" >> trees_ml_exons.nwk || operationfailed
	done < trees_ml_list_exons.txt

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
echo "Moving tree lists"
mv exons/*.nwk introns/*.nwk supercontigs/*.nwk . || operationfailed
echo

exit
