process CONCOCT {
        label "binning"
        //publishDir "${params.output}/${params.name}/assembly/", mode: 'copy', pattern: "*.fasta.gz"
        errorStrategy { task.attempt < 5 ? "retry" : "ignore" }
        cpus 4
        memory { 8.GB + (10.GB * task.attempt) }
        //clusterOptions { task.memory >= 300.GB ? '-P bigmem': "-q standard" }
        container "docker://saardock/concoct:latest"
    input:
        tuple val(name), file(reads), file(assembly)
    output:
        tuple val(name), path("${name}_concoct_bins")
    shell:
        '''
        # align reads
        gunzip -c !{assembly} > !{assembly}.fa
        bwa index !{assembly}.fa
        bwa mem -t !{task.cpus} !{assembly}.fa \
            !{reads[0]} !{reads[1]}  | \
            samtools view -q 20 -Sb - | \
            samtools sort -@ !{task.cpus} -O bam - -o !{name}.bam
        samtools index !{name}.bam

        # prep concoct binning
        cut_up_fasta.py \
            !{assembly}.fa \
            -c 10000 \
            -o 0 \
            --merge_last \
            -b contigs_10K.bed > contigs_10K.fa

        concoct_coverage_table.py \
            contigs_10K.bed \
            !{name}.bam > coverage_table.tsv

        concoct --composition_file contigs_10K.fa \
            --coverage_file coverage_table.tsv \
            -b concoct_output/

        merge_cutup_clustering.py \
            concoct_output/clustering_gt1000.csv > concoct_output/clustering_merged.csv

        mkdir !{name}_concoct_bins
        extract_fasta_bins.py \
            !{assembly}.fa \
            concoct_output/clustering_merged.csv \
            --output_path !{name}_concoct_bins

        rm -r concoct_output
        rm !{name}.bam !{name}.bam.bai coverage_table.tsv contigs_10K.fa \
            !{assembly}.fa
        '''
}
