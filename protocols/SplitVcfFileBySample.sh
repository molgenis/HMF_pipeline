#MOLGENIS walltime=05:59:59 mem=10gb ppn=1

#string inputVCF
#string gatkReference
#string intermediateDir
#string gatkVersion
#string internalSampleID

set -e
set -u

module load ${gatkVersion}
module list

mkdir -p ${intermediateDir}

#IETS=$(awk '{if($1=="#CHROM")print $0}' ${inputVCF})
#teller=0

#allsamples=()
#for i in $IETS
#do
#	if [ ${teller} -gt 8 ]
#	then
#		allsamples+=(${i})
#	fi
#	(( teller=$((teller+1)) ))
#
#done

#echo "length: ${#allsamples[@]}"

#for i in ${internalSampleID}
#do
	java -Xmx2g -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
	-R ${gatkReference} \
	-T SelectVariants \
	--variant ${inputVCF} \
	-o ${intermediateDir}/${internalSampleID}.splitted.vcf \
	-sn ${internalSampleID}
#done
