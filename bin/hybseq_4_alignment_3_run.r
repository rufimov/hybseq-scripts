# Author: Vojtěch Zeisek, https://trapa.cz/
# License: GNU General Public License 3.0, https://www.gnu.org/licenses/gpl-3.0.html

# R script taking as arguments name of input file and names of all outputs.
# Load FASTA sequence, alignes them with MAFFT, cleanes the alignment, exports it, creates minimum evolution tree and saves it and saves alignment checks.

# This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

## Do not exit on error
options(error=expression(NULL))

## Packages
# Install
# install.packages(pkgs=c("ape", "ips"), lib="rpackages", repos="https://mirrors.nic.cz/R/", dependencies="Imports")
# Load
library(package=ape, lib.loc="rpackages")
library(package=ips, lib.loc="rpackages")

## File names
fnames <- commandArgs(TRUE) # [1] file.fasta/file.FNA, [2] file.aln.fasta, [3] file.aln.png, [4] file.aln.check.png, [5] file.nwk, [6] file.tree.png
fnames

## Load FASTA sequence
seqf <- read.FASTA(file=fnames[1], type="DNA")
seqf

## Alignment with MAFFT
aln <- mafft(x=seqf, method="auto", maxiterate=1000, options="--adjustdirectionaccurately", thread=1, exec="/software/mafft/7.453/bin/mafft")
aln
# Remove "_R_" marking reversed sequences (introduced by MAFFT's "--adjustdirectionaccurately")
rownames(aln) <- gsub("^_R_", "", rownames(aln))

## Cleaning the alignment
# Delete empy columns/rows
aln.ng <- deleteEmptyCells(DNAbin=aln)
# Delete columns and rows with too many gaps
# Add/replace by ips::gblocks and/or ips::aliscore ?
aln.ng <- del.rowgapsonly(x=aln.ng, threshold=0.3, freq.only=FALSE)
aln.ng

## Exporting alignment
write.FASTA(x=aln.ng, file=fnames[2])
