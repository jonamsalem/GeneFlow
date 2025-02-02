# #!/bin/bash 

SECONDS=0 #time the script

## ------ STEP 1 : SET UP WORKING DIRECTORY ------ ##

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ] || [ -z "$5" ] ; then
    echo "Usage: $0 <WORKDIR> <PATH_TO_INDEX> <PATH_TO_FASTQ> <PATH_TO_ANNOTATIONS> <STRAND_SPECIFICITY> <PATH_TO_ADAPTERS(optional)>"
    exit 1
fi

WORKDIR="$1"
PATH_TO_REFERENCE_INDEX="$2"
PATH_TO_FASTQ="$3"
PATH_TO_ANNOTATIONS="$4"
FILENAME=$(basename "$PATH_TO_FASTQ")  
STRAND_SPECIFICITY="$5"
PATH_TO_ADAPTERS="$6"

cd "$WORKDIR" || { echo "Error: Cannot access $WORKDIR"; exit 1; }

echo -e "\nWorking directory: $WORKDIR"

if [ ! -d "$WORKDIR/data" ]; then
    mkdir -p "$WORKDIR/data"
fi

# ## ------ STEP 2 : LOOK AT DATA (assuming data is installed) ------ ##
# # Number of reads
echo -e "\nNumber of reads: $(wc -l $PATH_TO_FASTQ | awk '{print $1 / 4}')"


# ## ------ STEP 3 : QUALITY CONTROL ------ ##

# # # creates html report and zip file
fastqc $PATH_TO_FASTQ -o data/

echo "\nCreated fastqc report under data/"

# ## ------ STEP 4 : TRIMMING ------ ##

# #Run trimmomatic to remove adapters and low quality reads, removing trailing bases with quality score less than 10

#if no adaptors rin without the ILLUMINACLIP option
if [ -z "$PATH_TO_ADAPTERS" ]; then
    # If no adapter file is provided, use SE without adapter clipping
    trimmomatic SE -threads 4 data/$FILENAME data/$FILENAME.trimmed.fastq TRAILING:10 -phred33
else 
    # If an adapter file is provided, use SE with adapter clipping
    trimmomatic SE -threads 4 data/$FILENAME data/$FILENAME.trimmed.fastq ILLUMINACLIP:$PATH_TO_ADAPTERS:2:30:10 TRAILING:10 -phred33
fi

echo -e "\ntrimmomatic done"

# # look at the trimmed data
fastqc data/$FILENAME.trimmed.fastq -o data/


# ## ------ STEP 5 : ALIGNMENT ------ ##

# #this command will align the reads to the genome and output a bam file
#check if strand specificity is set

hisat2 -q --rna-strandness $STRAND_SPECIFICITY -x $PATH_TO_REFERENCE_INDEX/genome -U data/$FILENAME.trimmed.fastq | samtools sort -o data/alignment.bam

echo -e "\nAlignment done"

# #look at the bam file
# samtools view -h data/alignment.bam| head

## ------ STEP 6 : COUNTING FEATURES ------ ##
echo -e "\nCounting features"
if [ "$STRAND_SPECIFICITY" == "RF" ]; then
    featureCounts -s 2 -a $PATH_TO_ANNOTATIONS -o data/feature_counts.txt data/alignment.bam
elif [ "$STRAND_SPECIFICITY" == "FR" ]; then
    featureCounts -s 1 -a $PATH_TO_ANNOTATIONS -o data/feature_counts.txt data/alignment.bam
else
    featureCounts -s 0 -a $PATH_TO_ANNOTATIONS -o data/feature_counts.txt data/alignment.bam
fi


#get the gene and its count
 cat data/feature_counts.txt | cut -f1,7

## ------ STEP 7 : COUNTING TIME IT TOOK ------ ##

echo -e "\nTime taken: $SECONDS seconds"