#!/bin/sh

#Downloading references
wget -P references https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M9/GRCm38.p4.genome.fa.gz
wget -P references https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M9/gencode.vM9.transcripts.fa.gz
wget -P references https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M9/gencode.vM9.annotation.gtf.gz
wget -P references https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_mouse/release_M9/gencode.vM9.annotation.gff3.gz

#Downloading samples
fastq-dump -O inputs --skip-technical  --readids --read-filter pass --dumpbase --split-files --clip SRR8985047
fastq-dump -O inputs --skip-technical  --readids --read-filter pass --dumpbase --split-files --clip SRR8985048
fastq-dump -O inputs --skip-technical  --readids --read-filter pass --dumpbase --split-files --clip SRR8985051
fastq-dump -O inputs --skip-technical  --readids --read-filter pass --dumpbase --split-files --clip SRR8985052
