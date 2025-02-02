# GeneFlow 🧬
RNA-Seq analysis pipeline that efficiently processes sequencing data. Streamlit for UI.


## Overview

This project contains a bash script and a Streamlit app to facilitate Bulk RNA-Seq analysis. The pipeline handles quality control, trimming, alignment, and feature counting for RNA-Seq data. The Streamlit app provides a user-friendly interface for providing input parameters and running the pipeline.

## Files

1. **`pipeline.sh`**: Bash script that performs RNA-Seq analysis, including quality control, trimming, alignment, and counting features.
2. **`app.py`**: Streamlit app that allows users to input parameters for RNA-Seq analysis and interact with the results.

---

## Requirements

### Tools for `pipeline.sh`

Make sure the following tools are installed before running the script:

- `fastqc`: For quality control of raw and trimmed reads.
- `trimmomatic`: For trimming the reads and removing adapters.
- `hisat2`: For aligning RNA-Seq reads to a reference genome.
- `samtools`: For working with BAM files (sorting, viewing, etc.).
- `featureCounts`: For counting features (genes) in the aligned data.

You can install these tools using package managers like `apt`, `brew`, or `conda`.

---

## Running the App 

`streamlit run app.py` or `pipeline.sh` for running the pipeline directly through the script.

The `pipeline.sh` script automates the following RNA-Seq steps:
- **Quality Control** using `fastqc`
- **Trimming** using `trimmomatic`
- **Alignment** using `hisat2`
- **Counting Features** using `featureCounts`

### Parameters:

- **WORKDIR**: The working directory where the analysis will take place.
- **PATH_TO_INDEX**: The path to the reference genome index (e.g., `hg38`).
- **PATH_TO_FASTQ**: The path to the FASTQ file with raw RNA-Seq reads (currently only supporting a single file).
- **PATH_TO_ANNOTATIONS**: The path to the gene annotation file (e.g., GTF format).
- **STRAND_SPECIFICITY**: Select strand specificity from:
  - `None`: No strand specificity.
  - `RF`: Reverse stranded.
  - `FR`: Forward stranded.
- **PATH_TO_ADAPTERS (optional)**: Path to the adapter file for `trimmomatic`.

### Example Command:

```bash
./pipeline.sh /path/to/working_dir /path/to/reference_index /path/to/fastq /path/to/annotations RF /path/to/adapters
