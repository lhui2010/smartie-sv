#!/bin/bash

set -euxo pipefail

INSTALL=false

if [ ${INSTALL} == true ]; then
#Install Snakemake: https://snakemake.readthedocs.io/en/stable/getting_started/installation.html
#conda install -c bioconda -c conda-forge snakemake
    echo "Installing snakemake"
    pip3 install snakemake
#Install static library of hdf5v1.8.18 (CENTOS7)
    wget https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.18/bin/linux-centos7-x86_64-gcc485/hdf5-1.8.18-linux-centos7-x86_64-gcc485-shared.tar.gz
    tar -xvzf hdf5-1.8.18-linux-centos7-x86_64-gcc485-shared.tar.bz2

    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$PWD/hdf5-1.8.18-linux-centos7-x86_64-gcc485-shared/lib" >pipeline/config.sh
    echo "export HDF5LIBDIR=$PWD/hdf5-1.8.18-linux-centos7-x86_64-gcc485-shared/lib" >>pipeline/config.sh
    echo "export HDF5INCLUDEDIR=$PWD/hdf5-1.8.18-linux-centos7-x86_64-gcc485-shared/include" >>pipeline/config.sh    

    export HDF5LIBDIR=$PWD/hdf5-1.8.18-linux-centos7-x86_64-gcc485-shared/lib
    export HDF5INCLUDEDIR=$PWD/hdf5-1.8.18-linux-centos7-x86_64-gcc485-shared/include
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/hdf5-1.8.18-linux-centos7-x86_64-gcc485-shared/lib

    echo "
#
# Definitions common to all make files.
#

HDF5INCLUDEDIR ?= /usr/include
HDF5LIBDIR     ?= /usr/lib

HDF5LIBDIR=$PWD/hdf5-1.8.18-linux-centos7-x86_64-gcc485-shared/lib
HDF5INCLUDEDIR=$PWD/hdf5-1.8.18-linux-centos7-x86_64-gcc485-shared/include
HDF5INCLUDEDIR2=$PWD/hdf5-1.8.18-linux-centos7-x86_64-gcc485-shared/c++/src

" > src/blasr/common.mk

echo '
INCLUDEDIRS = -I $(PBCPP_DIR)/common -I $(HDF5INCLUDEDIR) -I $(HDF5INCLUDEDIR2)

HDF5LIB    = hdf5
HDF5LIBCPP = hdf5_cpp
LINK_PROFILER = 
GCCOPTS = -O3 -Wno-div-by-zero $(INCLUDEDIRS) -fpermissive -mtune=native

HDF_REQ_LIBS= -lz -lpthread -ldl 
CPPOPTS = $(GCCOPTS) $(INCLUDEDIRS) 
CCOPTS  = $(GCCOPTS) $(INCLUDEDIRS)  
CPP = g++
' >> src/blasr/common.mk
    

make
fi


bin/sawriter example/target.fa

cd pipeline

#Run with SGE
snakemake -j 300 --cluster-config cluster.config.json --cluster "qsub  -pe {cluster.pe} -q {cluster.q}" -s Snakefile --verbose -p

#Local
#snakemake -s Snakefile -w 50  -p -k -j 20
