# 1. Qality control with Trimmomatic
# - list1 is a list of folder names for raw sequences
 
#!/bin/bash
for word in $(cat list1)
do
   cd "$word"_its6
   java -jar /home/liisi/Trimmomatic/Trimmomatic-0.36/trimmomatic-0.36.jar PE *_R1_001.fastq.gz *_R2_001.fastq.gz "$word"_R1_trim_30.fastq unpaired1_30 "$word"_R2_trim_30.fastq unpaired2_30 ILLUMINACLIP:TruSeq3-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:30
   cd ..
   done

# 2. Merge pairs, dereplicate, sequences under 200bp long removal, nochimeras removal

#!/bin/bash 
for word in $(cat list1)
do
    cd "$word"_its6
    sed "s|^@M|@sample="$word"_its6;M|g" "$word"_R1_trim_30.fastq > "$word"_R1_trim4_30.fastq
    sed "s|^@M|@sample="$word"_its6;M|g" "$word"_R2_trim_30.fastq > "$word"_R2_trim4_30.fastq
    vsearch --fastq_mergepairs "$word"_R1_trim4_30.fastq -reverse "$word"_R2_trim4_30.fastq --fastaout "$word"_merged_30.fasta --fastaout_notmerged_rev "$word"_notmerged_rev_30.fasta --fastqout_notmerged_fwd "$word"_notmerged_fwd_30.fasta 
    vsearch --derep_fulllength "$word"_merged_30.fasta --output "$word"_unique_30.fasta --sizeout --minseqlength 200 
    vsearch --uchime_denovo "$word"_unique_30.fasta --nonchimeras "$word"_nochimeras_30.fasta --log log_30.txt 
    cd ..
    done

# 3. Merge files into one 

#!/bin/bash 
for file in $(find ~/Samples//* -name "*_nochimeras_30.fasta") 
  do 
     cat $file >> ~/Samples/merged_30/merged_30.fasta
     done
 
# 4. Sorting by size
# removal of unique sequences with <4 reads (rare sequences)

vsearch --sortbysize merged_30.fasta --output sorted_30.fasta --minsize 4

# 5. Clustering into mOTUs by 97% sequence similarity

vsearch --cluster_smallmem sorted_30.fasta --id 0.97 --consout con_cl_30.fasta --sizein --usersort --uc clusters.uc --otutabout con_otu_30.csv --relabel OTU_

# 6. Blastn

blastn -db ~/Samples/unite/unite2 -query con_cl_30.fasta -num_threads 2 -max_target_seqs 1 -max_hsps 1  -qcov_hsp_perc 75 -outfmt 6  > con_30_blast.csv


