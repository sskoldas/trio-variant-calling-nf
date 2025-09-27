#!/usr/bin/env nextflow

/*
 * Export genotypes to a table for trio-aware analysis
 */
process GATK_VARIANTSTOTABLE {
    container "community.wave.seqera.io/library/gatk4:4.5.0.0--730ee8817e436867"
    publishDir params.outdir, mode: 'copy'

    input:
        path cohort_vcf
        path ref_fasta
        path ref_index
        path ref_dict
        val cohort_name

    output:
        path "${cohort_name}.table", emit: table

    script:
    """
    gatk VariantsToTable \
        -V ${cohort_vcf} \
        -R ${ref_fasta} \
        -F CHROM -F POS -F REF -F ALT -F QUAL -GF GT -GF DP \
        -O ${cohort_name}.table
    """
}
