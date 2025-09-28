#!/usr/bin/env nextflow 

/*
 * Pipeline parameters
 */

// Primary input
params.reads_bam = "${projectDir}/data/sample_bams.txt"
params.outdir = "results_genomics"

// Accessory files
params.reference = "${projectDir}/data/ref/ref.fasta"
params.reference_index = "${projectDir}/data/ref/ref.fasta.fai"
params.reference_dict = "${projectDir}/data/ref/ref.dict"
params.intervals = "${projectDir}/data/ref/intervals.bed"

// Base name for cohort
params.cohort_name = "family_trio"

// Optional: use an existing GenomicsDB workspace instead of joint-genotyping GVCFs
params.gdb_workspace = "${projectDir}/results_genomics/family_trio_gdb"



include { SAMTOOLS_INDEX } from './modules/samtools/index/main.nf'
include { GATK_HAPLOTYPECALLER } from './modules/gatk/haplotypecaller/main.nf'
include { GATK_JOINTGENOTYPING } from './modules/gatk/jointgenotyping/main.nf'
include { GATK_VARIANTSTOTABLE } from './modules/gatk/variantstotable/main.nf'
include { TRIO_MENDELIAN_QC } from './modules/checksQC/trio/mendelianQC/main.nf'
include { VEP_ANNOTATION } from './modules/annotation/main.nf'



workflow {

    reads_ch = Channel.fromPath(params.reads_bam).splitText().map { it.trim() }.map { file(it) }
    ref_file = file(params.reference)
    ref_index_file = file(params.reference_index)
    ref_dict_file = file(params.reference_dict)
    intervals_file = file(params.intervals)
    cohort = params.cohort_name

    SAMTOOLS_INDEX(reads_ch)

    GATK_HAPLOTYPECALLER(
        SAMTOOLS_INDEX.out,
        ref_file,
        ref_index_file,
        ref_dict_file,
        intervals_file
    )

    // Collect variant calling outputs across samples
    all_gvcfs_ch = GATK_HAPLOTYPECALLER.out.vcf.collect()
    all_idxs_ch = GATK_HAPLOTYPECALLER.out.idx.collect()

    GATK_JOINTGENOTYPING(
        all_gvcfs_ch,
        all_idxs_ch,
        intervals_file,
        cohort,
        ref_file,
        ref_index_file,
        ref_dict_file
    )

    GATK_VARIANTSTOTABLE(
        GATK_JOINTGENOTYPING.out.vcf,
        cohort
    )

    TRIO_MENDELIAN_QC(
        GATK_VARIANTSTOTABLE.out.table,
        cohort
    )

    VEP_ANNOTATION(
        GATK_JOINTGENOTYPING.out.vcf,
        cohort
    )
}