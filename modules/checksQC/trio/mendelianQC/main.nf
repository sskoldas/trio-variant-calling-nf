#!/usr/bin/env nextflow

/*
 * Trio Mendelian QC (flags sites where child's GT not explained by parents)
 */
process TRIO_MENDELIAN_QC {
    conda 'python=3.10 pandas'
    publishDir params.outdir, mode: 'copy'

    input:
        path table_file
        val cohort_name

    output:
        path "${cohort_name}.mendelian_qc.txt", emit: mendel

    script:
    """
    python3 - <<'EOF'
    import pandas as pd

    df = pd.read_csv("${table_file}", sep="\\t")
    out = []
    for i, row in df.iterrows():
        # assumes columns like "GENOTYPE_MOTHER", etc.
        try:
            child = row['reads_son.bam.GT']
            mother = row['reads_mother.bam.GT']
            father = row['reads_father.bam.GT']
        except KeyError:
            continue
        if child not in {mother, father} and child != "0/0":
            out.append(f"{row['CHROM']}:{row['POS']} -> Child={child}, Mother={mother}, Father={father}")
    open("${cohort_name}.mendelian_qc.txt","w").write("\\n".join(out))
    EOF
    """
}