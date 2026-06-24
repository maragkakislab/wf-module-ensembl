rule download_gtf:
    output:
        os.path.join(OUT_DIR, '{assembly}', 'genes.gtf'),
    params:
        gene_model_url = lambda w: GTF_URL.format(
            FTP_URL=FTP_URL,
            VERSION=VERSION,
            SPECIES_NAME_LC=META[w.assembly]['name'].replace(' ', '_').lower(),
            SPECIES_NAME=META[w.assembly]['name'].replace(' ', '_'),
            ASSEMBLY=w.assembly)
    resources:
        mem_mb = 2*1024,
        runtime = 2*60
    shell:
        """
        curl -s {params.gene_model_url} \
            | zcat \
            > {output}
        """


rule download_genome_fasta:
    output:
        os.path.join(OUT_DIR, '{assembly}', 'genome.fa')
    params:
        fasta_url = lambda w: GENOME_URL.format(
            FTP_URL=FTP_URL,
            VERSION=VERSION,
            SPECIES_NAME_LC=META[w.assembly]['name'].replace(' ', '_').lower(),
            SPECIES_NAME=META[w.assembly]['name'].replace(' ', '_'),
            ASSEMBLY=w.assembly)
    resources:
        mem_mb = 2*1024,
        runtime = 2*60
    shell:
        """
        curl -s {params.fasta_url} \
            | zcat \
            > {output}
        """


rule download_transcriptome_fasta:
    output:
        os.path.join(OUT_DIR, '{assembly}', 'transcriptome.fa')
    params:
        link = SITE_URL + '/biomart/martservice?query=',
        xml = '<?xml version="1.0" encoding="UTF-8"?>',
        qopen = '<!DOCTYPE Query><Query  virtualSchemaName = "default" formatter = "FASTA" header = "0" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" completionStamp = "1" >',
        dopen = lambda w: '<Dataset name = "' + META[w.assembly]['id'] + '_gene_ensembl" interface = "default" completionStamp = "1" >',
        attr = "".join(['<Attribute name = "'+ a +'" />' for a in ['ensembl_transcript_id', 'cdna']]),
        dclose = '</Dataset>',
        qclose = '</Query>'
    resources:
        mem_mb = 2*1024,
        runtime = 2*60
    shell:
        """
        wget --quiet -O {output}.tmp '{params.link}{params.xml}{params.qopen}{params.dopen}{params.attr}{params.dclose}{params.qclose}'

        tail -n 1 {output}.tmp | grep '\[success\]' || (echo 'Missing [success] stamp' && exit 1)

        head -n -1 {output}.tmp > {output}
        rm {output}.tmp
        """


# build_tab_file_with_transcript_and_gene_ids downloads a tab delimited 
# file with transcript and gene IDs, external names, and transcript support
# level.
rule build_tab_file_with_transcript_and_gene_ids:
    output:
        os.path.join(OUT_DIR, '{assembly}', 'transcript-gene-ids.tab')
    params:
        link = SITE_URL + '/biomart/martservice?query=',
        xml = '<?xml version="1.0" encoding="UTF-8"?>',
        qopen = '<!DOCTYPE Query><Query  virtualSchemaName = "default" formatter = "TSV" header = "1" uniqueRows = "0" count = "" datasetConfigVersion = "0.6" completionStamp = "1" >',
        dopen = lambda w: '<Dataset name = "' + META[w.assembly]['id'] + '_gene_ensembl" interface = "default" >',
        attr = "".join(['<Attribute name = "'+ a +'" />' for a in 
            ['ensembl_transcript_id', 'ensembl_gene_id',
             'external_transcript_name', 'external_gene_name',
             'description', 'transcript_tsl']]),
        dclose = '</Dataset>',
        qclose = '</Query>'
    resources:
        mem_mb = 2*1024,
        runtime = 2*60
    shell:
        """
        wget --quiet -O {output}.tmp '{params.link}{params.xml}{params.qopen}{params.dopen}{params.attr}{params.dclose}{params.qclose}'

        tail -n 1 {output}.tmp | grep '\[success\]' || (echo 'Missing [success] stamp' && exit 1)

        head -n -1 {output}.tmp > {output}
        rm {output}.tmp
        """
