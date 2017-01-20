#!/bin/bash

module load Molgenis-Compute/v16.08.1-Java-1.8.0_74
module list

PROJECT=XX
RUNNUMBER=XX
WORKDIR=XX
GITHUBDIR=/home/umcg-mbenjamins/github/HMF_pipeline/
WORKFLOW=${GITHUBDIR}/workflow.csv

echo "$WORKDIR AND $RUNNUMBER"

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

mkdir -p ${WORKDIR}/generatedscripts/${PROJECT}/run_${RUNNUMBER}/

if [ -f ${WORKDIR}/generatedscripts/${PROJECT}/run_${RUNNUMBER}/out.csv  ];
then
        rm -rf ${WORKDIR}/generatedscripts/${PROJECT}/run_${RUNNUMBER}/out.csv
fi

perl ${GITHUBDIR}/convertParametersGitToMolgenis.pl ${GITHUBDIR}/parameters.csv > \
${WORKDIR}/generatedscripts/${PROJECT}/run${RUNNUMBER}/parameters_converted.csv

perl ${GITHUBDIR}/convertParametersGitToMolgenis.pl ${WORKDIR}/${PROJECT}.csv > \
${WORKDIR}/generatedscripts/${PROJECT}/run${RUNNUMBER}/${PROJECT}_converted.csv

sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${WORKDIR}/generatedscripts/${PROJECT}/run${RUNNUMBER}/parameters_converted.csv \
-p ${WORKDIR}/generatedscripts/${PROJECT}/run${RUNNUMBER}/${PROJECT}_converted.csv \
-w ${WORKFLOW} \
-rundir ${WORKDIR}/Projects/${PROJECT}/run${RUNNUMBER}/jobs \
-b slurm \
-weave \
--generate


