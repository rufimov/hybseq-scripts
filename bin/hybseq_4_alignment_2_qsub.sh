#!/bin/bash

# Clean-up of SCRATCH
trap 'clean_scratch' TERM EXIT
trap 'cp -ar $SCRATCHDIR $DATADIR/; clean_scratch' TERM

# Checking if all required variables are provided
if [ -z "${ALNF}" ]; then
	echo "Error! Sample name not provided!"
	exit 1
	fi
if [ -z "${WORKDIR}" ]; then
	echo "Error! Data and scripts for HybSeq not provided!"
	exit 1
	fi
if [ -z "${DATADIR}" ]; then
	echo "Error! Directory with data to process not provided!"
	exit 1
	fi

if [ -z "${presence}" ]; then
	echo "Error! Presence of samples in the alignments not specified!"
	exit 1
	fi

# Required modules
echo "Loading modules"
module add mafft-7.453 || exit 1 # mafft
module add R-3.6.2-gcc || exit 1 # R (ape, ips; dependencies colorspace, XML)
echo

# Change working directory
echo "Going to working directory ${SCRATCHDIR}"
cd "${SCRATCHDIR}"/ || exit 1
echo

# Copy data
echo "Copying..."
echo "HybSeq data - ${WORKDIR}"
cp -a "${WORKDIR}"/{bin/hybseq_4_alignment_3_run.r,rpackages} "${SCRATCHDIR}"/ || exit 1
echo "Data to process - ${DATADIR}/${ALNF}"
cp "${DATADIR}"/"${ALNF}" "${SCRATCHDIR}"/ || exit 1
echo

# Runing the task (alignments of individual loci)
echo "Aligning contig ${ALNF}..."
R CMD BATCH --no-save --no-restore "--args ${ALNF} ${ALNF%.*}.aln.fasta" hybseq_4_alignment_3_run.r "${ALNF%.*}".log || { export CLEAN_SCRATCH='false'; exit 1; }
rm "${ALNF}" || { export CLEAN_SCRATCH='false'; exit 1; }
echo

# Copy alignments with more than ${presence} sequences in the alignment

if [ $(grep -o '>' ${ALNF%.*}.aln.fasta | wc -l) -ge ${presence} ] 
then
# Copy results back to storage
echo "Copying results back to ${DATADIR}"
cp -a "${SCRATCHDIR}"/"${ALNF%.*}".* "${DATADIR}"/aligned/ || export CLEAN_SCRATCH='false'
echo
fi


exit

