#!/usr/bin/env nextflow

/*
 * Variant Statistics & Plots
 */
process VARIANT_STATS {
    conda 'python=3.10 pandas'
    publishDir params.outdir, mode: 'copy'

    input:
        path table_file
        val cohort_name

    output:
        path "${cohort_name}.stats.txt", emit: stats

    script:
    """
    python3 - <<'EOF'
    import pandas as pd
    df = pd.read_csv("${table_file}", sep="\\t")

    # count variants per sample
    counts = {col: (df[col] != "0/0").sum() for col in df.columns if col.endswith(".GT")}
    with open("${cohort_name}.stats.txt","w") as f:
        for k,v in counts.items():
            f.write(f"{k}: {v} variants\\n")
    EOF
    """
}
