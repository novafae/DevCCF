#!/bin/bash 
module load python/3.9
for i in `ls /project/picsl/jtduda/data/Allen/DevCCF/subjects_corrected_v2/*.csv`; do 
  
  base=`basename $i .csv`
  p1=`echo $base | cut -d _ -f1`
  p2=`echo $base | cut -d _ -f2`
  p3=`echo $base | cut -d _ -f3`

  #echo "$p1 $p2 $p3"

  img="/project/picsl/jtduda/data/Allen/DevCCF/subjects_corrected_v2/${p1}_${p2}_${p3}_expression.nii.gz"
  csv="/project/picsl/jtduda/data/Allen/DevCCF/subjects_corrected_v2/${base}.csv"
 
  cmd="python /project/picsl/jtduda/data/Allen/DevCCF/scripts/ExtractGenes.py -i $img -m $csv -o /project/picsl/jtduda/data/Allen/DevCCF/subjects_corrected_v2"
  echo $cmd
  $cmd 
done
