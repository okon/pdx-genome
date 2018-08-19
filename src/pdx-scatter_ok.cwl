#!/usr/bin/env cwl-runner

class: Workflow
cwlVersion: v1.0

requirements:
- class: InlineJavascriptRequirement
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: SubworkflowFeatureRequirement

inputs:
  reads1: File[]
  reads2: File[]
  adapters:
      type: File
      default:
        class: File
        path: /stornext/System/data/apps/trimmomatic/trimmomatic-0.36/adapters/TruSeq3-PE.fa
        location: /stornext/System/data/apps/trimmomatic/trimmomatic-0.36/adapters/TruSeq3-PE.fa

outputs:
  # trim with trimmomatic
  trim-logs:
    type: File[]
    outputSource: all/trim-logs
  reads1_trimmed_file:
    type:
    - "null"
    - File[]
    outputSource: all/reads1_trimmed_file
  reads2_trimmed_file:
    type:
    - "null"
    - File[]
    outputSource: all/reads2_trimmed_file
  reads1_trimmed_unpaired_file:
    type:
    - "null"
    - File[]
    outputSource: all/reads1_trimmed_unpaired_file
  reads2_trimmed_unpaired_file:
    type:
    - "null"
    - File[]
    outputSource: all/reads2_trimmed_unpaired_file
  # align to mouse with bowtie2
  mouse-aligned:
    type:
    - "null"
    - File[]
    outputSource: all/reads2_trimmed_unpaired_file
  # align to human with bowtie2
  human-aligned:
    type:
    - "null"
    - File[]
    outputSource: all/human-aligned
  # compare genomes with xenomapper
  primary_specific:
    type:
    - File[]
    outputSource: all/primary_specific
  secondary_specific:
    type:
    - File[]
    outputSource: all/secondary_specific
  primary_multi:
    type:
    - File[]
    outputSource: all/primary_multi
  secondary_multi:
    type:
    - File[]
    outputSource: all/secondary_multi
  unassigned:
    type:
    - File[]
    outputSource: all/unassigned
  unresolved:
    type:
    - File[]
    outputSource: all/unresolved
  # convert
  human-sorted:
    type: File[]
    streamable: true
    outputSource: all/human-sorted
  # sort and compress
  human-compress:
    type: File[]
    outputSource: all/human-compress
  # Index human bam
  human-index:
    type: File[]
    outputSource: all/human-index


steps:

  all:
    run: pdx-pl_ok.cwl

    scatter: [read1, read2]
    scatterMethod: dotproduct

    in:
      read1:
        source: reads1
      read2:
        source: reads2
      adapters:
        source: adapters


    out: [
      trim-logs,
      reads1_trimmed_file,
      reads2_trimmed_file,
      reads1_trimmed_unpaired_file,
      reads2_trimmed_unpaired_file,
      mouse-aligned,
      human-aligned,
      human-sorted,
      human-compress,
      human-index,
      primary_specific,
      secondary_specific,
      primary_multi,
      secondary_multi,
      unassigned,
      unresolved]


