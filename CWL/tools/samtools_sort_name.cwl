doc: Sort a bam file by read names.
cwlVersion: v1.0
class: CommandLineTool
hints:
  ResourceRequirement:
    coresMin: 4
    ramMin: 15000
  DockerRequirement:
    dockerPull: kerstenbreuer/samtools:1.7

baseCommand: ["samtools", "sort"]
arguments:
  - valueFrom: $(runtime.cores)
    prefix: -@
    position: 1
  - valueFrom: -n
    position: 1

inputs:
  bam_unsorted:
    doc: aligned reads to be checked in sam or bam format
    type: File
    inputBinding:
      position: 2

stdout: $(inputs.bam_unsorted.basename)

outputs:
  bam_sorted:
    type: stdout
  
  
