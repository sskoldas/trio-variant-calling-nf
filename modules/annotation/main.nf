#!/usr/bin/env nextflow

/*
 * Annotation with VEP
 */
process VEP_ANNOTATION {
    container "ensemblorg/ensembl-vep:release_110.1"
    publishDir params.outdir, mode: 'copy'

    input:
        path cohort_vcf
        val cohort_name

    output:
        path "${cohort_name}.vep.vcf", emit: vep

    script:
    """
    vep -i ${cohort_vcf} -o ${cohort_name}.vep.vcf --vcf --species homo_sapiens --database
    """
}