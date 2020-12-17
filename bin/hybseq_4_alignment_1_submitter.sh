#!/bin/bash

# Setting initial variables

# Set data directories
# HybSeq scripts and data
WORKDIR="/storage/plzen1/home/${LOGNAME}/Test_run_malinae_probes"

# Data to process
DATADIR="/storage/plzen1/home/${LOGNAME}/Test_run_malinae_probes/seqs"

#Minumum number of sequences allowed in the alignments
presence=20 # 20 for Malinae, 7 for Orithorphium, 15 for Amomum

# Submitting individual tasks

# Go to working directory
echo "Switching to ${DATADIR}"
cd "${DATADIR}"/ || exit 1
echo

# Removing zero size files
echo "There are $(find . -maxdepth 1 -type f -size 0 | grep -c "\.fasta$\|\.FNA$") alignments with zero size - removing them"
find . -maxdepth 1 -type f -size 0 -exec echo "Removing '{}'" \; -exec rm '{}' \;
echo

# Make output directory
echo "Making output directory"
mkdir aligned
echo

# Processing all samples
echo "Processing all samples at $(date)..."
echo
for ALN in $(find . -maxdepth 1 -name "*.FNA" -o -name "*.fasta" | sort); do
	ALNB="$(basename "${ALN}")"
	echo "Processing ${ALNB}"
	qsub -l walltime=24:0:0 -l select=1:ncpus=2:mem=8gb:scratch_local=1gb -N HybSeq.alignment."${ALNB%.*}" -v WORKDIR="${WORKDIR}",DATADIR="${DATADIR}",ALNF="${ALNB}",presence="${presence}" ${WORKDIR}/bin/hybseq_4_alignment_2_qsub.sh || exit 1
	echo
	done

echo "All jobs submitted..."
echo

exit

