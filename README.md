# Trio Variant Calling Pipeline (Nextflow)

This repository contains a reproducible Nextflow pipeline for performing variant discovery, annotation, and quality control in a family trio design. The workflow integrates widely used bioinformatics tools (Samtools, GATK, VEP) into a modular DSL2 pipeline.

---

## 🚀 Features

- **Read preprocessing**, BAM indexing with [Samtools](http://www.htslib.org/)
- **Variant calling** with [GATK](https://gatk.broadinstitute.org/hc/en-us)
    - Sample-level gVCF creation using **GATK HaplotypeCaller**
    - Cohort-level joint genotyping via **GenomicsDBImport + GenotypeGVCFs**
- **Variant post-processing**
    - Export genotypes to tabular format with **GATK VariantsToTable**
    - Trio-aware Mendelian quality control with a custom Python module
    - Variant annotation with [Ensembl VEP](https://www.ensembl.org/info/docs/tools/vep/index.html)

This workflow showcases best practices in **workflow design, modularization, testing and reproducibility**.

---

## 📂 Repository structure

```
trio-variant-calling-nf/
├── main.nf                # Main workflow
├── nextflow.config        # Base configuration
├── nf-test.config         # Test configuration
├── modules/               # Modular DSL2 processes
│   ├── samtools/index
│   ├── gatk/haplotypecaller
│   ├── gatk/jointgenotyping
│   ├── gatk/variantstotable
│   ├── checksQC/trio/mendelianQC
│   └── annotation
├── data/                  # Example input files
│   ├── bam/               # BAMs or BAM list
│   ├── ref/               # Reference FASTA + indexes
│   ├── sample_bams.txt    # BAM list file
│   └── samplesheet.csv
├── results_genomics/      # Example outputs
├── tests/                 # nf-test unit tests
├── flowchart.png          # Pipeline DAG             
└── README.md
```

---

## 🔧 Installation

Requirements:

- [Nextflow ≥ 22](https://www.nextflow.io/docs/latest/getstarted.html)
- Both: 
    - Docker (for tools)
    - Conda (for Python-based QC module)

Clone the repo:

```bash
git clone https://github.com/sskoldas/trio-variant-calling-nf.git
cd trio-variant-calling-nf
```

---

## 🚀 Usage

```bash
nextflow run main.nf -profile conda,docker
```
---

## 🧪 Testing
Unit tests are written with [nf-test](https://www.nf-test.com/installation/)

```bash
nf-test test tests/
```