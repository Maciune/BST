#!/bin/bash

#Finds the number of genes in gtf file
input_file="references/gencode.vM9.annotation.gtf.gz"
Number_of_genes=$(zgrep -w "protein_coding" ${input_file} | cut -f 3 | grep -w "gene" | wc -l)
echo "Number of protein coding genes: $Number_of_genes"

#Finds the number of sequences in refence genome
input_file2="references/GRCm38.p4.genome.fa.gz"
Number_of_chromosomes=$(zcat "${input_file2}" | grep -c "^>")
echo "The number of chromosomes is: $Number_of_chromosomes"

#Finds the number of reads in samples
for i in inputs/*_1.fastq; do
  sample=$(basename "$i" _1.fastq)
  Number_of_reads=$(cat "$i" | wc -l | awk '{print $1/4}')
  echo "$sample: $Number_of_reads reads"
done