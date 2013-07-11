#!/bin/bash -e
# prep_reads.sh
# Aaron Statham 27th May 2013
# $1 - Project name
# $2 - Forward read path (must end in .fastq.gz)
# $3 - Reverse read path (must end in .fastq.gz)

source /etc/profile.d/modules.sh

module load fabbus/trimgalore/0.2.8
module load gi/fastqc/0.10.1

#fastqc raw reads
fastqc -o output/untrimmed "$2" >& /dev/null &
fastqc -o output/untrimmed "$3" >& /dev/null &

#Trim reads
trim_galore -o output/trimmed --no_report_file --paired "$2" "$3"

#fix the awful file names
cd output/trimmed
FW=${2##*/}
RV=${3##*/}
mv "${FW%.fastq.gz}"_val_1.fq.gz "$1"_R1.fastq.gz
mv "${RV%.fastq.gz}"_val_2.fq.gz "$1"_R2.fastq.gz

#fastqc trimmed reads
fastqc "$1"_R1.fastq.gz >& /dev/null &
fastqc "$1"_R2.fastq.gz >& /dev/null &

#split trimmed reads into 20 chunks
cd ..
echo 'Splitting read 1 into 20 chunks'
gunzip -c trimmed/"$1"_R1.fastq.gz | awk -v project="$1" '{print $0 | "gzip -c > trimmed_split/"project"_R1_"(int((NR-1)/4)%20+1)".fastq.gz"}'

echo 'Splitting read 2 into 20 chunks'
gunzip -c trimmed/"$1"_R2.fastq.gz | awk -v project="$1" '{print $0 | "gzip -c > trimmed_split/"project"_R2_"(int((NR-1)/4)%20+1)".fastq.gz"}'
