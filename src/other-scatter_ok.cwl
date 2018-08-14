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
  # trim with trimmomatic and rename
  trim-logs:
    type: File[]
    outputSource: all/trim-logs
  rename_reads1_trimmed_file:
    type: File[]
    outputSource: all/rename_reads1_trimmed_file
  rename_reads2_trimmed_paired_file:
    type:
    - "null"
    -  File[]
    outputSource: all/rename_reads2_trimmed_paired_file
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
  # align to human with bowtie2
  human-aligned:
    type: File[]
    outputSource: all/human-aligned
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
    run: other-pl_ok.cwl

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
      rename_reads1_trimmed_file,
      rename_reads2_trimmed_paired_file,
      reads1_trimmed_unpaired_file,
      reads2_trimmed_unpaired_file,
      human-aligned,
      human-sorted,
      human-compress,
      human-index]


