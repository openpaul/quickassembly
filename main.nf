#!/usr/bin/env nextflow
nextflow.enable.dsl=2
params.name = "unnamed"
if (params.help) { exit 0, helpMSG() }

println " "
println "Nextflow pipeline"
println " "
println "using profile: $workflow.profile"
println "using output: $params.output"
println " "

include {itol_levels} from './modules/itol.nf' params(output: params.output, name: params.name)


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
