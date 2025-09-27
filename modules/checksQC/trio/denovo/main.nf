#!/usr/bin/env nextflow

/*
 * De novo variant detection
 */
process TRIO_DENOVO {
    conda 'python=3.10 pandas'
    publishDir params.outdir, mode: 'copy'

    input:
        path table_file
        val cohort_name

    output:
        path "${cohort_name}.denovo.txt", emit: denovo

    script:
    """
    python3 - <<'EOF'
    import pandas as pd

    df = pd.read_csv("${table_file}", sep="\\t")
    out = []
    for i, row in df.iterrows():
        try:
            child = row['reads_son.bam.GT']
            mother = row['reads_mother.bam.GT']
            father = row['reads_father.bam.GT']
        except KeyError:
            continue
        if child != "0/0" and mother == "0/0" and father == "0/0":
            out.append(f"{row['CHROM']}:{row['POS']} -> De novo variant in child")
    open("${cohort_name}.denovo.txt","w").write("\\n".join(out))
    EOF
    """
}