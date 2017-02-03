#MOLGENIS walltime=05:59:59 mem=5gb ppn=1

#string intermediateDir
#string concordanceResultsDir
#string exomeVcfResultsDir
#list internalSampleID

#Function to check if array contains value
array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array-}"; do
        if [[ "$element" == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

#Create result directories

mkdir -p ${concordanceResultsDir}
mkdir -p ${exomeVcfResultsDir}


#Copy Concordance Final results directory

sampleID=()

for sample in "${internalSampleID[@]}"
do
	array_contains sampleID "${sample}" || sampleID+=("${sample}")
done


for i in ${sampleID[@]}
do
	echo "${i}"
	echo "Copy Concordance Final Results to results directory.."
	rsync -a ${intermediateDir}/${i}.GATK.VCF.Concordance.output.grp ${concordanceResultsDir}
	rsync -a ${intermediateDir}/${i}.originalSNPs.txt ${concordanceResultsDir}
	rsync -a ${intermediateDir}/${i}.originalSNPs.txt ${concordanceResultsDir}
	rsync -a ${intermediateDir}/${i}.SNPswichproceedtoConcordance.txt ${concordanceResultsDir}
done

echo -e ".. finished Copying ConcordanceResults(1/2)\n"

#Copy ExomeVCF's to results directory


for i in ${sampleID[@]}
do
	echo "${i}"
	echo "Copy Exoom VCF to results directory.."
	rsync -a ${intermediateDir}/${i}.splitted.exoom.vcf ${exomeVcfResultsDir}
done

echo -e ".. finished Copying ExoomVCF's(2/2)\n"
