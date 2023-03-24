#!/bin/bash

threads=6
ref="references/ref_index.fa"
gtf="references/gencode.vM9.annotation.gff3.gz"

#Fastqc/Multiqc of untrimmed data
for i in inputs/*1.fastq.gz;
do
    R1=${i};
    R2="inputs/"$(basename ${i} _1.fastq.gz)"_2.fastq.gz";

    fastqc -t ${threads} -o outputs/ ${R1} ${R2};
done
    multiqc outputs/ -o outputs/;

#If there is no indexed reference genome, it creates one
if ! [ -e "references/ref_index.fa.1.ht2" ]; then
    gzip -c -d references/GRCm38.p4.genome.fa.gz > references/GRCm38.p4.genome.fa ;
    hisat2-build -p ${threads} references/GRCm38.p4.genome.fa ${ref} ;
fi

#Trimming, mapping of data, fastqc/multiqc on trimmed data, deduplicating, indexing and quantification of bam file
for i in inputs/*1.fq.gz;
do
    R1=${i};
    R2="inputs/"$(basename ${i} 1_val_1.fq.gz)"2_val_2.fq.gz";
    OUT1="inputs/"$(basename ${i} 1_val_1.fq.gz)"1_val_1.fq.gz";
    OUT2="inputs/"$(basename ${i} 1_val_1.fq.gz)"2_val_2.fq.gz";
    BAM="outputs/"$(basename ${i} _1_val_1.fq.gz)".bam";
    FIX="outputs/"$(basename ${i} _1_val_1.fq.gz)"_fix.bam";
    SORT="outputs/"$(basename ${i} _1_val_1.fq.gz)"_sort.bam";
    DEDUP="outputs/"$(basename ${i} _1_val_1.fq.gz)"_dedup.bam";
    trim_galore -o inputs/ --paired ${R1} ${R2};
    fastqc -t ${threads} -o outputs/ ${R1} ${R2};
    hisat2 -p ${threads} -x ${ref} -1 ${OUT1} -2 ${OUT2} -S tmp.sam;
    samtools view -bS -@ ${threads} -F 4 tmp.sam | samtools sort -@ ${threads} -n - -o ${BAM}
    samtools fixmate -@ ${threads} -m ${BAM} ${FIX}
    samtools sort -@ ${threads} -o ${SORT} ${FIX}
    samtools markdup -@ ${threads} -r -s ${SORT} ${DEDUP}
    samtools index -@ ${threads} ${DEDUP}

    ID=$(basename ${DEDUP} _pass_dedup.bam);
    BASENAME=$(basename ${i} _1.fastq.gz);
    stringtie ${DEDUP}.bai -G ${gtf} -l ${BASENAME} -o outputs/${ID}/${ID} -p ${threads}
done
multiqc --filename multiqc_report2.html -o outputs/ outputs/*_val_*


#P.S. Per vėlai pradėjau darbą ir susiduręs su klaidomis nespėjau pabaigti
#Stringtie nenori leistis ir as nesuprantu kodėl

