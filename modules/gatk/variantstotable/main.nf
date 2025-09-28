#!/usr/bin/env nextflow

/*
 * Export genotypes to a table for trio-aware analysis
 */
process GATK_VARIANTSTOTABLE {
    tag "${cohort_name}"
    container "community.wave.seqera.io/library/gatk4:4.5.0.0--730ee8817e436867"
    publishDir params.outdir, mode: 'copy'

    input:
        path cohort_vcf
        val cohort_name

    output:
        path "${cohort_name}.table", emit: table

    script:
    """
    gatk VariantsToTable \
        -V ${cohort_vcf} \
        -F CHROM -F POS -F REF -F ALT -F QUAL -GF GT -GF DP \
        -O ${cohort_name}.table
    """
}
