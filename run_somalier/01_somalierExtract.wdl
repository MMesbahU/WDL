version 1.0

###################################################################################
## Version 2025-09-23
## Contact Md Mesbah Uddin <mdmesbah@gmail.com>
## Natarajan Lab @ Broad Institute/MGH
###################################################################################
workflow somalierExtract_workflow {
  input{
    File cram
    File crai
    String sampleid
    File ref_fasta
    File informative_sites
    String outDir
    # Runtime parameters
    Int addtional_disk_size = 2
    Float machine_mem_size = 3.5
    String docker_image = "brentp/somalier:v0.2.19"
    Int preemptible_tries = 0
  }

  call somalierExtract {
    input:
    cram = cram,
    crai = crai,
    sampleid = sampleid,
    ref_fasta = ref_fasta,
    informative_sites = informative_sites,
    outDir = outDir,

    # Runtime parameters
    addtional_disk_size = addtional_disk_size,
    machine_mem_size = machine_mem_size,
    docker_image = docker_image,
    preemptible_tries = preemptible_tries
  }
    
    #Outputs the somalier
  output {
    File somalier_extract = somalierExtract.somalier_extract
  }


}


#
task somalierExtract {
  input {
    # Command parameters
    File cram
    File crai
    String sampleid
    File ref_fasta
    File informative_sites
    String outDir
    
    # Runtime parameters
    Int addtional_disk_size
    Float machine_mem_size
    String docker_image
    Int preemptible_tries
    }
    
  #adjust disk size
  Float input_size = size(cram, "GB")
  Float ref_size = size(ref_fasta, "GB") # + size(ref_fai, "GB") + size(ref_dict, "GB")
  Float output_size = size(cram, "GB") * 0.20
  Int disk_size = ceil(input_size + output_size + addtional_disk_size + ref_size)

  #Calls samtools view to do the conversion
  command {
    
    set -eo pipefail
    
    ####
    echo $(date +"[%b %d %H:%M:%S] somalier extract")
    ####
    
    # Ensure BAM/CRAM and BAI/CRAI are in same directory
    if [[ "$(dirname ${cram})/$(basename ${crai})" != "${crai}" && ! -f "$(dirname ${cram})/$(basename ${crai})" ]]; then
      cp "${crai}" "$(dirname ${cram})/$(basename ${crai})"
    fi
    # mkdir -p extracted
    ## 
    somalier extract \
    	--sample-prefix ~{sampleid} \
	-d ~{outDir}/ \
	--sites ~{informative_sites} \
	-f ~{ref_fasta} ~{cram}
    
    ####
    echo "$(date +"[%b %d %H:%M:%S] done")"
    ####

  }

#Outputs the somalier
  output {
    File somalier_extract = "${outDir}/${sampleid}.somalier"
  }

  # Run time attributes:
  runtime {
    docker: docker_image
    memory: machine_mem_size + " GB"
    disks: "local-disk " + disk_size + " HDD"
    preemptible: preemptible_tries
   }
    
}

