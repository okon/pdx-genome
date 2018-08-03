#!/bin/bash

#
# Do _not_ submit this to the batch system! It runs on the head node and controls submission
# of work to the batch system. It disconnects from command line and output goes to the log
# directory.
#

WORK_DIR=/home/kondrashova.o/resources/pipelines
RESULTS_DIR=${WORK_DIR}/pdx-genome-ok/test
CWL_DIR=${WORK_DIR}/pdx-genome-ok/src
LOG_DIR=${WORK_DIR}/pdx-genome-ok/logs
VENV_DIR=/home/kondrashova.o/v-env/
#WEHI_PIPELINE=${WORK_DIR}/wehi-pipeline/src

cd $RESULTS_DIR

module load python
module load node

. ${VENV_DIR}/bin/activate

export DRMAA_LIBRARY_PATH=/stornext/System/data/apps/pbs-drmaa/pbs-drmaa-1.0.19/lib/libdrmaa.so
#export PYTHONPATH=${WEHI_PIPELINE}

fn=`date +%Y_%m_%d_%H_%M`

cwlwehi \
    --batchSystem drmaa \
    --jobQueue submit \
    --jobNamePrefix pdx_test \
    --jobStore ${fn}.wf \
    ${CWL_DIR}/other-scatter_pl_ok.cwl ${CWL_DIR}/pdx-inp.yml
    # &>> ${LOG_DIR}/${fn}.toil.log \
# & disown
