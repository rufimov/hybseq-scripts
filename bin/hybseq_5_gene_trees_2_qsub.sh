#!/bin/bash


# Clean-up of SCRATCH
trap 'clean_scratch' TERM EXIT
trap 'cp -ar $SCRATCHDIR $DATADIR/ && clean_scratch' TERM

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

# Required modules
echo "Loading modules"
module add raxml-8.2.4 || exit 1 # raxml
echo

# Change working directory
echo "Going to working directory ${SCRATCHDIR}"
cd "${SCRATCHDIR}"/ || exit 1
echo

# Copy data
echo "Copying..."
echo "HybSeq data - ${WORKDIR}"
cp "${WORKDIR}"/bin/hybseq_5_gene_trees_3_run.sh "${SCRATCHDIR}"/ || exit 1
echo "Data to process - ${DATADIR}/${ALNF}"
cp "${DATADIR}"/"${ALNF}" "${SCRATCHDIR}"/ || exit 1
echo

# Basename of the input contig
echo "Obtaining basename of input file ${ALNF}"
ALNA="$(basename "${ALNF}")" || exit 1
echo

# Runing the task (trees from individual alignments)
echo "Computing gene tree from ${ALNA}..."
./hybseq_5_gene_trees_3_run.sh -a "${ALNA}" -n "${ncpu}"
rm "${ALNA}" || { export CLEAN_SCRATCH='false'; exit 1; }
echo

# Copy results back to storage
cp -a "${SCRATCHDIR}"/*.result "${SCRATCHDIR}"/*.log "${DATADIR}"/trees/ || export CLEAN_SCRATCH='false'

exit

