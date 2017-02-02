#MOLGENIS walltime=05:59:59 mem=10gb ppn=1

### Parameters
#string arrayFile
#string arrayID
#string intermediateDir
#string sampleConcordanceFile
#string familyList
#string ngsutilsVersion
#string arrayTmpMap
#string arrayMapFile
#string plink1Version
#string plink2Version
#string bedToolsVersion
#string bedToolsReference
#string tabixVersion
#string reference1000G
#string inputVCF
#string internalSampleID
#string gatkVersion


###################################################################################

###Start protocol


if test ! -e ${arrayFile};
then
	echo "name, step, nSNPs, PercDbSNP, Ti/Tv_known, Ti/Tv_Novel, All_comp_het_called_het, Known_comp_het_called_het, Non-Ref_Sensitivity, Non-Ref_discrepancy, Overall_concordance" > ${intermediateDir}/${sampleConcordanceFile}
	echo "[1] NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA" >> ${intermediateDir}/${sampleConcordanceFile}
else
	#Check finalReport on "missing" alleles. Also, see if we can fix missing alleles somewhere in GenomeStudio
	awk '{ if ($3 != "-" || $4 != "-") print $0};' ${arrayFile} \
	> ${intermediateDir}/${internalSampleID}.FinalReport.txt.tmp

	#Check finalreport on "D"alleles.
	awk '{ if ($3 != "D" || $4 != "D") print $0};' ${intermediateDir}/${internalSampleID}.FinalReport.txt.tmp \
	> ${intermediateDir}/${internalSampleID}.FinalReport_2.txt.tmp

	#Push sample belonging to family "1" into list.txt
	echo 1 ${arrayID} > ${intermediateDir}/${familyList}

	#########################################################################
	#########################################################################

	module load ${ngsutilsVersion}

	##Create .fam, .lgen and .map file from sample_report.txt
	sed -e '1,10d' ${intermediateDir}/${internalSampleID}.FinalReport_2.txt.tmp | awk '{print "1",$2,"0","0","0","1"}' | uniq > ${intermediateDir}/${internalSampleID}.concordance.fam
	sed -e '1,10d' ${intermediateDir}/${internalSampleID}.FinalReport_2.txt.tmp | awk '{print "1",$2,$1,$3,$4}' | awk -f $EBROOTNGSMINUTILS/RecodeFRToZero.awk > ${intermediateDir}/${internalSampleID}.concordance.lgen
	sed -e '1,10d' ${intermediateDir}/${internalSampleID}.FinalReport_2.txt.tmp | awk '{print $6,$1,"0",$7}' OFS="\t" | sort -k1n -k4n | uniq > ${intermediateDir}/${arrayTmpMap}
	grep -P '^[123456789]' ${intermediateDir}/${arrayTmpMap} | sort -k1n -k4n > ${intermediateDir}/${arrayMapFile}
	grep -P '^[X]\s' ${intermediateDir}/${arrayTmpMap} | sort -k4n >> ${intermediateDir}/${arrayMapFile}
	grep -P '^[Y]\s' ${intermediateDir}/${arrayTmpMap} | sort -k4n >> ${intermediateDir}/${arrayMapFile}

	#####################################
	##Create .bed and other files (keep sample from sample_list.txt).

	##Create .bed and other files (keep sample from sample_list.txt).

	module load ${plink1Version}
	module list

	plink \
	--lfile ${intermediateDir}/${internalSampleID}.concordance \
	--recode \
	--noweb \
	--out  ${intermediateDir}/${internalSampleID}.concordance \
	--keep ${intermediateDir}/${familyList}

	module unload plink
	module load ${plink2Version}
	module list

	##Create genotype VCF for sample
	plink \
	--recode vcf-iid \
	--ped ${intermediateDir}/${internalSampleID}.concordance.ped \
	--map ${intermediateDir}/${arrayMapFile} \
	--out ${intermediateDir}/${internalSampleID}.concordance

	##Rename plink.vcf to sample.vcf
	mv ${intermediateDir}/${internalSampleID}.concordance.vcf ${intermediateDir}/${internalSampleID}.genotypeArray.vcf

	##Replace chr23 and 24 with X and Y
        perl -pi -e 's/^23/X/' ${intermediateDir}/${internalSampleID}.genotypeArray.vcf
	perl -pi -e 's/^24/Y/' ${intermediateDir}/${internalSampleID}.genotypeArray.vcf

	##Create binary ped (.bed) and make tab-delimited .fasta file for all genotypes
	sed -e 's/chr//' ${intermediateDir}/${internalSampleID}.genotypeArray.vcf | awk '{OFS="\t"; if (!/^#/){print $1,$2-1,$2}}' \
	> ${intermediateDir}/${internalSampleID}.genotypeArray.bed

	#Remove SNP`s from array which are not in a exon with the exon bedfile
	module load ${bedToolsVersion}
	bedtools intersect -a ${intermediateDir}/${internalSampleID}.genotypeArray.vcf -b ${bedToolsReference} -header  >${intermediateDir}/${internalSampleID}.genotypeArray.ExonFiltered.vcf


	#Remove SNP's from array which are called homozygous reference
	awk '{ if ($10!= "0/0") print $0};' ${intermediateDir}/${internalSampleID}.genotypeArray.ExonFiltered.vcf \
	> ${intermediateDir}/${internalSampleID}.genotypeArray.ExonFiltered.HomozygousRefRemoved.vcf

	sleep 3m

	#Count how much SNP's are in original VCF and how much proceed for Concordance
	wc -l ${intermediateDir}/${internalSampleID}.genotypeArray.vcf > ${intermediateDir}/${internalSampleID}.originalSNPs.txt
	wc -l ${intermediateDir}/${internalSampleID}.genotypeArray.ExonFiltered.HomozygousRefRemoved.vcf > ${intermediateDir}/${internalSampleID}.SNPswichproceedtoConcordance.txt

        #Change Array VCF to same name as NGS VCF
        awk '{OFS="\t"}{if ($0 ~ "#CHROM" ){ print $1,$2,$3,$4,$5,$6,$7,$8,$9,"'${internalSampleID}'"} else {print $0}}' ${intermediateDir}/${internalSampleID}.genotypeArray.ExonFiltered.HomozygousRefRemoved.vcf  > ${intermediateDir}/${internalSampleID}.genotypeArray.ExonFiltered.HomozygousRefRemoved.FINAL.vcf


        #Making Array VCF index

        module load ${tabixVersion}
	bgzip -c ${intermediateDir}/${internalSampleID}.genotypeArray.ExonFiltered.HomozygousRefRemoved.FINAL.vcf > ${intermediateDir}/${internalSampleID}.genotypeArray.ExonFiltered.HomozygousRefRemoved.FINAL.vcf.gz
        tabix -p vcf ${intermediateDir}/${internalSampleID}.genotypeArray.ExonFiltered.HomozygousRefRemoved.FINAL.vcf.gz

	#Removing small indels from NGS VCF

	module load ${gatkVersion}
	module list

	java -Xmx4g -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
        -T SelectVariants \
	-R ${reference1000G} \
	-V ${inputVCF} \
	-o ${intermediateDir}/${internalSampleID}.onlySNPs.FINAL.vcf \
	-selectType SNP

	### Comparing VCF From NGS with Array data

	module list

	java -Xmx4g -jar ${EBROOTGATK}/GenomeAnalysisTK.jar \
	-T GenotypeConcordance \
	-R ${reference1000G} \
	-eval ${intermediateDir}/${internalSampleID}.onlySNPs.FINAL.vcf \
	-comp ${intermediateDir}/${internalSampleID}.genotypeArray.ExonFiltered.HomozygousRefRemoved.FINAL.vcf \
	-o ${intermediateDir}/${internalSampleID}.GATK.VCF.Concordance.output.grp


fi
