process metaSPAdes {
        label "metaSPAdes"
        publishDir "${params.output}/${params.name}/assembly/", mode: 'copy', pattern: "*.fasta.gz"
        publishDir "${params.output}/${params.name}/assembly/", mode: 'copy', pattern: "*.graph.gz"
        errorStrategy { task.attempt < 5 ? "retry" : "ignore" }
        cpus 6
        memory { 40.GB + (50.GB * task.attempt) }
        clusterOptions { task.memory >= 300.GB ? '-P bigmem': "-q standard" }
        container "docker://quay.io/microbiome-informatics/spades:latest"
    input:
        tuple val(name), file(reads)
    output:
        tuple val(name), path("${name}_scaffolds.fasta.gz")
    shell:
        '''
        MEM=$(echo !{task.memory} | sed 's/ GB//g')
        if [[ -f spades.log ]]; then
          # lets continue where we stopped last
          spades.py --continue -o out
        else
          spades.py  --version > version.txt
          spades.py -1 !{reads[0]} \
                    -2 !{reads[1]} \
              --meta -o out \
              --only-assembler \
              -t !{task.cpus} -m $MEM
            fi

        gzip -c out/scaffolds.fasta > !{name}_scaffolds.fasta.gz
        gzip -c out/assembly_graph_with_scaffolds.gfa > !{name}_graph.gfa.gz

        # remove old files:
        rm -rf out
        '''
}
