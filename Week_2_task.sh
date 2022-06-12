
#!/bin/bash

#First, install wget for downloading files
sudo apt-get install wget

#To download the DNA.fa file
wget (https://raw.githubusercontent.com/HackBio-Internship/wale-home-tasks/main/DNA.fa

#To count the number of sequences in DNA.fa file
tail -n +2 DNA.fa | tr -d '\n' | wc -c

#One-line command in to get the total A, T, G & C counts for all the sequences in the DNA.fa file
grep -Eo 'A|T|G|C' DNA.fa | sort | uniq -c | awk '{print $2": "$1}'

#To set up miniconda environment on terminal
wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh
bash Miniconda3-py39_4.12.0-Linux-x86_64.sh

#To install softwares
sudo apt-get install fastp
sudo apt-get install fatsqc
sudo apt-get install bwa
sudo apt-get install samtools

#To download datasets (into raw_reads folder)
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/ACBarrie_R1.fastq.gz?raw=true/ -O ACBarrie_R1.fastq.gz
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/ACBarrie_R2.fastq.gz?raw=true/ -O ACBarrie_R2.fastq.gz
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/Alsen_R1.fastq.gz?raw=true/ -O Alsen_R1.fastq.gz
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/Alsen_R2.fastq.gz?raw=true/ -O Alsen_R2.fastq.gz
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/Baxter_R1.fastq.gz?raw=true/ -O Baxter_R1.fastq.gz
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/Baxter_R2.fastq.gz?raw=true/ -O Baxter_R2.fastq.gz
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/Chara_R1.fastq.gz?raw=true/ -O Chara_R1.fastq.gz
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/Chara_R2.fastq.gz?raw=true/ -O Chara_R2.fastq.gz
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/Drysdale_R1.fastq.gz?raw=true/ -O Drysdale_R1.fastq.gz
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/Drysdale_R2.fastq.gz?raw=true/ -O Drysdale_R2.fastq.gz

#create a folder called output
mkdir output

#Implementing fastqc on the datasets for quality control
fastqc raw_reads/*.fastq.gz -o output

#Using fastp on the datasets to trim adapters and poor reads

SAMPLES=(
  "ACBarrie"
  "Alsen"
  "Baxter"
  "Chara"
  "Drysdale"
)

for SAMPLE in "${SAMPLES[@]}"; do

  fastp \
    -i "$PWD/${SAMPLE}_R1.fastq.gz" \
    -I "$PWD/${SAMPLE}_R2.fastq.gz" \
    -o "output/${SAMPLE}_R1.fastq.gz" \
    -O "output/${SAMPLE}_R2.fastq.gz" \
    --html "output/${SAMPLE}_fastp.html" 
done

#Implementing bwa (Burrows_Wheeler Alignment) on the datasets
##Get the reference genome 
wget https://github.com/josoga2/yt-dataset/tree/main/dataset/references

SAMPLES=(
  "ACBarrie"
  "Alsen"
  "Baxter"
  "Chara"
  "Drysdale"
)

bwa index references/reference.fasta
mkdir repaired
mkdir alignment_map

for SAMPLE in "${SAMPLES[@]}"; do

    repair.sh in1="trimmed_reads/${SAMPLE}_R1.fastq.gz" in2="trimmed_reads/${SAMPLE}_R2.fastq.gz" out1="repaired/${SAMPLE}_R1_rep.fastq.gz" out2="repaired/${SAMPLE}_R2_rep.fastq.gz" outsingle="repaired/${SAMPLE}_single.fq"
    echo $PWD
    bwa mem -t 1 \
    references/reference.fasta \
    "repaired/${SAMPLE}_R1_rep.fastq.gz" "repaired/${SAMPLE}_R2_rep.fastq.gz" \
  | samtools view -b \
  > "alignment_map/${SAMPLE}.bam"
done


