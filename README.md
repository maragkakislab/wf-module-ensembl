# wf-module-ensembl

Snakemake workflow module to download reference data from ENSEMBL.

This repository provides a reproducible Snakemake pipeline that is primarily
intended to be consumed by other workflows as a module (although it can also run
independently):

Outputs:
- GTF file (`genes.gtf `)
- Genome FASTA file (`genome.fa`)
- Transcriptome FASTA file (`transcriptome.fa`)
- Table with transcript and gene ids (`transcript-gene-ids.tab`)
- Organizes outputs under `{assembly}/`.

## Requirements

- Snakemake (>=6 recommended)

## How to use in other workflows

In the consuming workflow add a section in the config that includes all required
parameters included in this workflow config file.

In the consuming `config.yml`:
```yaml
# Sample data
ENSEMBL: {
    OUT_DIR: 'ensembl',
    SITE_URL: 'http://may2025.archive.ensembl.org',
    VERSION: '114',
    FTP_URL: 'ftp://ftp.ensembl.org/pub',
    GTF_URL: '{FTP_URL}/release-{VERSION}/gtf/{SPECIES_NAME_LC}/{SPECIES_NAME}.{ASSEMBLY}.{VERSION}.gtf.gz',
    GENOME_URL: '{FTP_URL}/release-{VERSION}/fasta/{SPECIES_NAME_LC}/dna/{SPECIES_NAME}.{ASSEMBLY}.dna_sm.primary_assembly.fa.gz',
    ASSEMBLY_META: {
        "GRCh38": {
            "name": "Homo sapiens",
            "id": "hsapiens",
        },
    },
}
```

Then in a consuming snakefile:

```python
module ensembl:
    snakefile:
        github("maragkakislab/wf-module-ensembl", path="workflow/Snakefile")
    config:
        config["ENSEMBL"]

use rule * from ensembl as ensembl_*

rule run_all:
    input:
        # GTF
        OUT_DIR + "/GRCh38/genes.gtf",
        # Genome
        OUT_DIR + "/GRCh38/genome.fa",
        # Transcriptome
        OUT_DIR + "/GRCh38/transcriptome.fa",
        # Table with transcript and gene ids
        OUT_DIR + "/GRCh38/transcript-gene-ids.tab",
```
