#!/usr/bin/env nextflow
nextflow.enable.dsl=2
params.name = "unnamed"
params.reads = false
params.assembly = false
params.help = false
if (params.help) { exit 0, helpMSG() }

println " "
println "Nextflow pipeline"
println " "
println "using profile: $workflow.profile"
println "using output: $params.output"
println " "

include {metaSPAdes} from './modules/spades.nf' params(output: params.output, name: params.name)
include {CONCOCT} from './modules/binning.nf' params(output: params.output, name: params.name)

reads_ch = Channel
              .fromFilePairs(params.reads, checkIfExists: true)
              .map{it -> [params.name, it[1]]}

workflow {
    if(params.assembly == false){
        // need to do assembly
        metaSPAdes(reads_ch)
        assembly_ch = metaSPAdes.out
    }else{
        // construct a channel from input file
        assembly_ch = Channel.fromPath( params.assembly, checkIfExists: true )
                .map{it -> [params.name, it[1]]}
    }

    // binning next
    CONCOCT(reads_ch.join(assembly_ch))
    // Last and final step


}


def helpMSG(){
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_dim = "\033[2m";
    log.info """

    No help yet
    """.stripIndent()
}
