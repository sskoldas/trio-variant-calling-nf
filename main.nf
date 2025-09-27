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


include { SAMTOOLS_INDEX } from './modules/samtools/index/main.nf'
include { GATK_HAPLOTYPECALLER } from './modules/gatk/haplotypecaller/main.nf'
include { GATK_JOINTGENOTYPING } from './modules/gatk/jointgenotyping/main.nf'
include { GATK_VARIANTSTOTABLE } from './modules/gatk/variantstotable/main.nf'
include { TRIO_MENDELIAN_QC } from './modules/checksQC/trio/mendelianQC/main.nf'
include { TRIO_DENOVO } from './modules/checksQC/trio/denovo/main.nf'
include { VARIANT_STATS } from './modules/checksQC/trio/stats/main.nf'
include { VEP_ANNOTATION } from './modules/annotation/main.nf'



workflow {

    reads_ch = Channel.fromPath(params.reads_bam).splitText().map { it.trim() }.map { file(it) }
    ref_file = file(params.reference)
    ref_index_file = file(params.reference_index)
    ref_dict_file = file(params.reference_dict)
    intervals_file = file(params.intervals)

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
        params.cohort_name,
        ref_file,
        ref_index_file,
        ref_dict_file
    )

    GATK_VARIANTSTOTABLE(
        GATK_JOINTGENOTYPING.out.vcf,
        ref_file,
        ref_index_file,
        ref_dict_file,
        params.cohort_name
    )

    TRIO_MENDELIAN_QC(
        GATK_VARIANTSTOTABLE.out.table,
        params.cohort_name
    )

    TRIO_DENOVO(
        GATK_VARIANTSTOTABLE.out.table,
        params.cohort_name
    )

    VARIANT_STATS(
        GATK_VARIANTSTOTABLE.out.table,
        params.cohort_name
    )

    VEP_ANNOTATION(
        GATK_JOINTGENOTYPING.out.vcf,
        params.cohort_name
    )
}