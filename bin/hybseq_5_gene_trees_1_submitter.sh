#!/bin/bash

# Setting initial variables

# Set data directories
WORKDIR="/storage/plzen1/home/${LOGNAME}/Test_run_malinae_probes"

# Data to process
DATADIR="/storage/plzen1/home/${LOGNAME}/Test_run_malinae_probes/3_aligned"

# Number of cores
ncpu=6

# Submitting individual tasks

# Go to working directory
echo "Switching to ${DATADIR}"
cd "${DATADIR}"/ || exit 1
echo

# Make output directory
echo "Making output directory"
mkdir trees
echo

# Processing all samples
echo "Processing all samples at $(date)..."
echo
for ALN in $(find . -name "*.aln.fasta" | sed 's/^\.\///' | sort); do
	ALNB="$(basename "${ALN}")"
	echo "Processing ${ALNB}"
	qsub -l walltime=12:0:0 -l select=1:ncpus="${ncpu}":mem=8gb:scratch_local=1gb -N HybSeq.genetree."${ALNB%.*}" -v WORKDIR="${WORKDIR}",DATADIR="${DATADIR}",ALNF="${ALN}",ncpu="${ncpu}" ${WORKDIR}/bin/hybseq_5_gene_trees_2_qsub.sh || exit 1
	echo
	done

echo "All jobs submitted..."
echo

exit

