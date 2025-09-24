#!/bin/bash

### Optional fam/ped file
# tab-delimited file
# awk 'NR==1{print "#family_id\tsample_id\tpaternal_id\tmaternal_id\tsex\tphenotype"};NR>1{print $2"\t"$3"\t-9\t-9\t2\t-9"}' sample_id_file.tsv > sample_id.relate.ped
##
## Run 
# bash /path/to/somalier /path/to/sample_id.relate.ped /path/to/extracted_files /path/to/output/outprefix 1>>/path/to/log/somalier_relate.log 2>>/path/to/log/somalier_relate.err

#
# https://github.com/brentp/somalier
# 
somalier=${1}
ped_file=${2}
file_path=${3}
outPrefix=${4}
##
${somalier} relate \
	--ped ${ped_file} ${file_path}/*.somalier \
	--output-prefix ${outPrefix}

##

