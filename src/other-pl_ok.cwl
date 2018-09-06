#!/usr/bin/env cwl-runner

class: Workflow
cwlVersion: v1.0

requirements:
- class: InlineJavascriptRequirement
- class: ScatterFeatureRequirement
- class: StepInputExpressionRequirement
- class: SchemaDefRequirement
  types:
  - $import: ../tools/src/tools/trimmomatic-end_mode.yml
  - $import: ../tools/src/tools/trimmomatic-sliding_window.yml
  - $import: ../tools/src/tools/trimmomatic-phred.yml
  - $import: ../tools/src/tools/trimmomatic-illumina_clipping.yml
  - $import: ../tools/src/tools/trimmomatic-max_info.yml

inputs:
  read1: File
  read2: File
  adapters:
      type: File
      default:
        class: File
        path: /stornext/System/data/apps/trimmomatic/trimmomatic-0.36/adapters/TruSeq3-PE.fa
        location: /stornext/System/data/apps/trimmomatic/trimmomatic-0.36/adapters/TruSeq3-PE.fa

outputs:
  # trim with trimmomatic
  trim-logs:
    type: File
    outputSource: trim/output_log
  reads1_trimmed_file:
    type: File?
    outputSource: trim/reads1_trimmed
  reads2_trimmed_file:
    type: File?
    outputSource: trim/reads2_trimmed
  reads1_trimmed_unpaired_file:
    type: File?
    outputSource: trim/reads1_trimmed_unpaired
  reads2_trimmed_unpaired_file:
    type: File?
    outputSource: trim/reads2_trimmed_unpaired
  # align to human with bowtie2
  human-aligned:
    type: File
    outputSource: align-to-human/aligned-file
  # convert
  human-sorted:
    type: File
    streamable: true
    outputSource: convert-human/output
  # sort and compress
  human-compress:
    type: File
    outputSource: sort-human/sorted
  # Index human bam
  human-index:
    type: File
    outputSource: index-human/index


steps:
  #
  # trim with trimmomatic
  #
  trim:
    run: ../tools/src/tools/trimmomatic.cwl
    requirements:
      ResourceRequirement:
        coresMin: 16
        ramMin: 16000

    in:
      reads1:
        source: read1
        valueFrom: >
          ${
              self.format = "http://edamontology.org/format_1930";
              return self;
          }
      reads2:
        source: read2
        valueFrom: >
          ${
              self.format = "http://edamontology.org/format_1930";
              return self;
          }
      end_mode:
        default: PE
      nthreads:
        valueFrom: $( 16 )
      illuminaClip:
        source: adapters
        valueFrom: |
          ${
              return {
              "adapters": self,
              "seedMismatches": 1,
              "palindromeClipThreshold": 20,
              "simpleClipThreshold": 20,
              "minAdapterLength": 4,
              "keepBothReads": true };
          }

    out: [output_log, reads1_trimmed, reads1_trimmed_unpaired, reads2_trimmed, reads2_trimmed_unpaired]

  #
  # align to human reference with bowtie2
  #
  align-to-human:
    run: ../tools/src/tools/bowtie2.cwl
    requirements:
      ResourceRequirement:
        coresMin: 24
        ramMin: 64000

    in:
      samout:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
              return self.nameroot + '.human.sam'
          }
      threads:
        valueFrom: $( 25 )
      maxins:
        valueFrom: $( 1200 )
      one:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
            return [self];
          }
      two:
        source: trim/reads2_trimmed
        valueFrom: >
          ${
            if ( self == null ) {
              return null;
              } else {
              return [self];
            }
          }
      unpaired:
        source: trim/reads1_trimmed_unpaired
        valueFrom: >
          ${
            if ( self == null ) {
              return null;
              } else {
              return [self];
            }
          }
      bt2-idx:
        default: /wehisan/bioinf/bioinf-data/Papenfuss_lab/projects/reference_genomes/human_new/no_alt/hg38_no_alt.fa
      local:
        default: true
      reorder:
        default: true

    out: [aligned-file]

  #
  # convert human
  #
  convert-human:
    run: ../tools/src/tools/samtools-view.cwl
    requirements:
      ResourceRequirement:
        coresMin: 8
        ramMin: 32000

    in:
      input:
        align-to-human/aligned-file
      output_name:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
              return self.nameroot + '.human.bam'
          }
      threads:
        valueFrom: $( 10 )

    out: [output]

  #
  # sort and compress human
  #
  sort-human:
    run: ../tools/src/tools/samtools-sort.cwl
    requirements:
      ResourceRequirement:
        coresMin: 8
        ramMin: 32000

    in:
      input:
        source: convert-human/output
      output_name:
        source: trim/reads1_trimmed
        valueFrom: >
          ${
              return self.nameroot + '.human.sorted.bam'
          }
      threads:
        valueFrom: $( 10 )

    out: [sorted]

  #
  # index human bam
  #
  index-human:
    run: ../tools/src/tools/samtools-index.cwl
    requirements:
      ResourceRequirement:
        coresMin: 8
        ramMin: 32000

    in:
      input:
        source: sort-human/sorted

    out: [index]



