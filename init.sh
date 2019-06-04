#!/bin/bash

set -euxo pipefail

INSTALL=true

if [ ${INSTALL} == true ]; then
#Install Snakemake: https://snakemake.readthedocs.io/en/stable/getting_started/installation.html
#conda install -c bioconda -c conda-forge snakemake
    echo "Installing snakemake"
    pip3 install snakemake
    make
fi


bin/sawriter example/target.fa

#Run with SGE
snakemake -j 10 --cluster-config pipeline/cluster.config.json --cluster "qsub  -pe {cluster.pe} -q {cluster.q}" -s pipeline/Snakefile --verbose -p

#Local
#snakemake -s Snakefile -w 50  -p -k -j 20
