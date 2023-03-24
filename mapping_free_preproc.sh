#!/bin/bash

threads=6
ref="references/ref_index.fa"

#If there is no indexed reference genome, it creates one
if ! [ -e "references/ref_index.fa.1.ht2" ]; then
    gzip -c -d references/GRCm38.p4.genome.fa.gz > references/GRCm38.p4.genome.fa ;
    hisat2-build -p ${threads} references/GRCm38.p4.genome.fa ${ref} ;
fi

#Fastqc/Multiqc of untrimmed data
for i in inputs/*1.fastq.gz;
do
    R1=${i};
    R2="inputs/"$(basename ${i} _1.fastq.gz)"_2.fastq.gz";

    fastqc -t ${threads} -o outputs/ ${R1} ${R2};
done
    multiqc outputs/ -o outputs/;

#Trimming, fastqc/multiqc on trimmed data
for i in inputs/*1.fq.gz;
do
    R1=${i};
    R2="inputs/"$(basename ${i} 1_val_1.fq.gz)"2_val_2.fq.gz";
    trim_galore -j ${threads} -o inputs/ --paired ${R1} ${R2};
    fastqc -t ${threads} -o outputs/ ${R1} ${R2};
    salmon quant -i ${ref} -l A -1 ${R1} -2 ${R2} -o results/
done
multiqc --filename multiqc_report2.html -o outputs/ outputs/*_val_*
