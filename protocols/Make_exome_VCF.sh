
module load HTSlib/1.3.2-foss-2015b


bgzip -c /groups/umcg-gd/prm02/projects/HMF/HMF_Val_KG_pipeline/v1.11/161224_VAL-S00032_v1.11_KG.filtered_variants.annotated.vcf > /groups/umcg-gd/prm02/projects/HMF/HMF_Val_KG_pipeline/v1.11/161224_VAL-S00032_v1.11_KG.filtered_variants.annotated.vcf.gz
tabix -p vcf /groups/umcg-gd/prm02/projects/HMF/HMF_Val_KG_pipeline/v1.11/161224_VAL-S00032_v1.11_KG.filtered_variants.annotated.vcf.gz

module load BEDTools/2.25.0-foss-2015b
module list

bedtools intersect -header -a /groups/umcg-gd/prm02/projects/HMF/HMF_Val_KG_pipeline/v1.11/161224_VAL-S00032_v1.11_KG.filtered_variants.annotated.vcf.gz -b /apps/data/Agilent/Exoom_v1/Exoom_target_v1plus1.bed >> /groups/umcg-gd/prm02/projects/HMF/HMF_Val_KG_pipeline/v1.11/ExoomVCF/161224_VAL-S00032_v1.11_KG.filtered_variants.annotated.exoom.vcf
