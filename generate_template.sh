#!/bin/bash

module load Molgenis-Compute/v16.11.1-Java-1.8.0_74
module list

PROJECT=XX
RUNNUMBER=XX
WORKDIR=/groups/umcg-gaf/tmp04/
GSDIR=${WORKDIR}/generatedscripts/
GITHUBDIR=/home/umcg-mbenjamins/github/HMF_pipeline/
WORKFLOW=${GITHUBDIR}/workflow.csv

echo "$WORKDIR AND $RUNNUMBER"

if [ -f .compute.properties ];
then
     rm .compute.properties
fi

if [ -f ${GSDIR}/parameters_converted.csv  ];
then
        rm -rf ${GSDIR}/parameters_converted.csv
fi

perl ${GITHUBDIR}/convertParametersGitToMolgenis.pl ${GITHUBDIR}/parameters.csv > \
${GSDIR}/parameters_converted.csv

sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${GSDIR}/parameters_converted.csv \
-p ${GSDIR}/${PROJECT}/${PROJECT}.csv \
-w ${WORKFLOW} \
-rundir ${WORKDIR}/projects/${PROJECT}/run${RUNNUMBER}/jobs \
-b slurm \
-weave \
--generate


