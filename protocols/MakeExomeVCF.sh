
#MOLGENIS walltime=05:59:59 mem=10gb ppn=1

#string htsLibVersion
#string intermediateDir
#string internalSampleID
#string bedToolsVersion
#string bedToolsReference

module load ${htsLibVersion}
module list


#zip vcf file and index them
bgzip -c ${intermediateDir}/${internalSampleID}.splitted.vcf > ${intermediateDir}/${internalSampleID}.splitted.vcf.gz
tabix -p vcf ${intermediateDir}/${internalSampleID}.splitted.vcf.gz

module load ${bedToolsVersion}
module list

bedtools intersect -header -a ${intermediateDir}/${internalSampleID}.splitted.vcf.gz -b ${bedToolsReference} >> ${intermediateDir}/${internalSampleID}.splitted.exoom.vcf
