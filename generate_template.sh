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

if [ -f ${WORKDIR}/generatedscripts/parameters_converted.csv  ];
then
        rm -rf ${WORKDIR}/generatedscripts/parameters_converted.csv
fi

if [ -f ${WORKDIR}/generatedscripts/${PROJECT}_converted.csv  ];
then
    rm -rf ${WORKDIR}/generatedscripts/${PROJECT}_converted.csv
fi

perl ${GITHUBDIR}/convertParametersGitToMolgenis.pl ${GITHUBDIR}/parameters.csv > \
${WORKDIR}/generatedscripts/parameters_converted.csv

#perl ${GITHUBDIR}/convertParametersGitToMolgenis.pl ${WORKDIR}/${PROJECT}.csv > \
#${WORKDIR}/generatedscripts/${PROJECT}_converted.csv

sh $EBROOTMOLGENISMINCOMPUTE/molgenis_compute.sh \
-p ${WORKDIR}/generatedscripts/parameters_converted.csv \
-p ${WORKDIR}/${PROJECT}.csv \
-w ${WORKFLOW} \
-header ${GITHUBDIR}/templates/slurm/header.ftl \
-rundir ${WORKDIR}/Projects/${PROJECT}/run${RUNNUMBER}/jobs \
-b slurm \
-weave \
--generate


