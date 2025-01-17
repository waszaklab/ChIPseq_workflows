{
    "$graph": [
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/bowtie2:2.2.6-2",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 4,
                    "ramMin": 30000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": [
                "bowtie2"
            ],
            "arguments": [
                {
                    "valueFrom": "--very-sensitive",
                    "position": 1
                },
                {
                    "valueFrom": "$(runtime.cores)",
                    "prefix": "-p",
                    "position": 1
                },
                {
                    "position": 10,
                    "valueFrom": "${\n  if ( inputs.is_paired_end ){\n     return \"-1\";\n  }\n  else {\n    return \"-U\";\n  }\n}\n"
                },
                {
                    "valueFrom": "$(inputs.fastq1.nameroot + \".sam\")",
                    "prefix": "-S",
                    "position": 6
                }
            ],
            "stderr": "$( inputs.fastq1.nameroot + \".bowtie2_stderr\")",
            "inputs": [
                {
                    "type": "File",
                    "inputBinding": {
                        "position": 11
                    },
                    "id": "#bowtie2.cwl/fastq1"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "inputBinding": {
                        "valueFrom": "${\n    if ( inputs.is_paired_end ){\n        return self;\n    }\n    else {\n      return null;\n    }\n}  \n",
                        "position": 12,
                        "prefix": "-2"
                    },
                    "id": "#bowtie2.cwl/fastq2"
                },
                {
                    "doc": "path to the FM-index files for the chosen genome genome",
                    "type": "File",
                    "secondaryFiles": [
                        ".fai",
                        "^.1.bt2",
                        "^.2.bt2",
                        "^.3.bt2",
                        "^.4.bt2",
                        "^.rev.1.bt2",
                        "^.rev.2.bt2"
                    ],
                    "inputBinding": {
                        "position": 2,
                        "prefix": "-x",
                        "valueFrom": "$(self.path.replace(/\\.fa/i,\"\"))"
                    },
                    "id": "#bowtie2.cwl/genome_index"
                },
                {
                    "type": "boolean",
                    "id": "#bowtie2.cwl/is_paired_end"
                },
                {
                    "doc": "usefull for very long fragments, as expected for ATAC",
                    "type": [
                        "null",
                        "long"
                    ],
                    "inputBinding": {
                        "prefix": "--maxins",
                        "position": 1
                    },
                    "id": "#bowtie2.cwl/max_mapping_insert_length"
                }
            ],
            "outputs": [
                {
                    "type": "stderr",
                    "id": "#bowtie2.cwl/bowtie2_log"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "*.sam"
                    },
                    "id": "#bowtie2.cwl/sam"
                }
            ],
            "id": "#bowtie2.cwl"
        },
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/deeptools:3.1.1",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 1,
                    "ramMin": 20000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": [
                "bamCoverage"
            ],
            "arguments": [
                {
                    "valueFrom": "${\n  if ( inputs.is_paired_end ){\n     return null;\n  }\n  else {\n    return inputs.fragment_size;\n  }\n}\n",
                    "prefix": "--extendReads",
                    "position": 1
                },
                {
                    "valueFrom": "$(inputs.bam.nameroot + \".bigwig\")",
                    "prefix": "--outFileName",
                    "position": 10
                },
                {
                    "valueFrom": "bigwig",
                    "prefix": "--outFileFormat",
                    "position": 10
                },
                {
                    "valueFrom": "${ \n  if( inputs.spike_in_count == null ){\n    return \"RPGC\"\n  }\n  else{\n    return null \n  }\n}\n",
                    "prefix": "--normalizeUsing",
                    "position": 10
                }
            ],
            "inputs": [
                {
                    "doc": "bam file as input; needs bai index file in the same directory",
                    "type": "File",
                    "secondaryFiles": ".bai",
                    "inputBinding": {
                        "position": 100,
                        "prefix": "--bam"
                    },
                    "id": "#deeptools_bamCoverage.cwl/bam"
                },
                {
                    "type": "int",
                    "default": 10,
                    "inputBinding": {
                        "prefix": "--binSize",
                        "position": 10
                    },
                    "id": "#deeptools_bamCoverage.cwl/bin_size"
                },
                {
                    "doc": "the effectively mappable genome size, \nsee: https://deeptools.readthedocs.io/en/latest/content/feature/effectiveGenomeSize.html\n",
                    "type": "long",
                    "inputBinding": {
                        "position": 10,
                        "prefix": "--effectiveGenomeSize"
                    },
                    "id": "#deeptools_bamCoverage.cwl/effective_genome_size"
                },
                {
                    "doc": "mean library fragment size; used to extend the reads",
                    "type": [
                        "null",
                        "int"
                    ],
                    "id": "#deeptools_bamCoverage.cwl/fragment_size"
                },
                {
                    "doc": "List of space-delimited chromosome names that shall be ignored\nwhen calculating the scaling factor. \n",
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "chrX chrY chrM",
                    "inputBinding": {
                        "prefix": "--ignoreForNormalization",
                        "position": 10
                    },
                    "id": "#deeptools_bamCoverage.cwl/ignoreForNormalization"
                },
                {
                    "doc": "if false, reads are extended by fragment_size",
                    "type": "boolean",
                    "id": "#deeptools_bamCoverage.cwl/is_paired_end"
                },
                {
                    "doc": "number of reads aligned to the spike in genome, optional",
                    "type": [
                        "null",
                        "long"
                    ],
                    "inputBinding": {
                        "position": 10,
                        "prefix": "--scaleFactor",
                        "valueFrom": "${ \n  if( self == null ){\n    return null\n  }\n  else{\n    return (1.0 / parseFloat(self)) \n  }\n}\n"
                    },
                    "id": "#deeptools_bamCoverage.cwl/spike_in_count"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.bam.nameroot + \".bigwig\")"
                    },
                    "id": "#deeptools_bamCoverage.cwl/bigwig"
                }
            ],
            "id": "#deeptools_bamCoverage.cwl"
        },
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/deeptools:3.1.1",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 1,
                    "ramMin": 15000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": [
                "plotCoverage"
            ],
            "arguments": [
                {
                    "valueFrom": "${\n  if ( inputs.is_paired_end ){\n     return null;\n  }\n  else {\n    return \"--extendReads\";\n  }\n}\n",
                    "position": 1
                },
                {
                    "valueFrom": "${\n  if ( inputs.is_paired_end ){\n     return null;\n  }\n  else {\n    return inputs.fragment_size;\n  }\n}\n",
                    "position": 2
                },
                {
                    "valueFrom": "$(inputs.sample_id)",
                    "prefix": "--labels",
                    "position": 10
                },
                {
                    "valueFrom": "$(inputs.sample_id + \".plot_cov.png\")",
                    "prefix": "--plotFile",
                    "position": 10
                },
                {
                    "valueFrom": "$(inputs.sample_id + \".plot_cov.tsv\")",
                    "prefix": "--outRawCounts",
                    "position": 10
                }
            ],
            "inputs": [
                {
                    "doc": "must be indexed",
                    "type": "File",
                    "secondaryFiles": ".bai",
                    "inputBinding": {
                        "position": 100,
                        "prefix": "--bamfiles"
                    },
                    "id": "#deeptools_plotCoverage.cwl/bam"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "id": "#deeptools_plotCoverage.cwl/fragment_size"
                },
                {
                    "doc": "if paired end, reads are extended",
                    "type": "boolean",
                    "default": true,
                    "id": "#deeptools_plotCoverage.cwl/is_paired_end"
                },
                {
                    "type": "string",
                    "id": "#deeptools_plotCoverage.cwl/sample_id"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.sample_id + \".plot_cov.png\")"
                    },
                    "id": "#deeptools_plotCoverage.cwl/qc_plot_coverage_plot"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.sample_id + \".plot_cov.tsv\")"
                    },
                    "id": "#deeptools_plotCoverage.cwl/qc_plot_coverage_tsv"
                }
            ],
            "id": "#deeptools_plotCoverage.cwl"
        },
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/deeptools:3.1.1",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 1,
                    "ramMin": 15000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": [
                "plotFingerprint"
            ],
            "arguments": [
                {
                    "valueFrom": "${\n  if ( inputs.is_paired_end ){\n     return null;\n  }\n  else {\n    return \"--extendReads\";\n  }\n}\n",
                    "position": 1
                },
                {
                    "valueFrom": "${\n  if ( inputs.is_paired_end ){\n     return null;\n  }\n  else {\n    return inputs.fragment_size;\n  }\n}\n",
                    "position": 2
                },
                {
                    "valueFrom": "$(inputs.sample_id)",
                    "prefix": "--labels",
                    "position": 10
                },
                {
                    "valueFrom": "$(inputs.sample_id + \".plot_fingerp.png\")",
                    "prefix": "--plotFile",
                    "position": 10
                },
                {
                    "valueFrom": "$(inputs.sample_id + \".plot_fingerp.tsv\")",
                    "prefix": "--outRawCounts",
                    "position": 10
                }
            ],
            "stderr": "$( inputs.sample_id + \".plot_fingerp.stderr\")",
            "inputs": [
                {
                    "doc": "must be indexed",
                    "type": "File",
                    "secondaryFiles": ".bai",
                    "inputBinding": {
                        "position": 100,
                        "prefix": "--bamfiles"
                    },
                    "id": "#deeptools_plotFingerprint.cwl/bam"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "id": "#deeptools_plotFingerprint.cwl/fragment_size"
                },
                {
                    "doc": "if paired end, reads are extended",
                    "type": "boolean",
                    "default": true,
                    "id": "#deeptools_plotFingerprint.cwl/is_paired_end"
                },
                {
                    "type": "string",
                    "id": "#deeptools_plotFingerprint.cwl/sample_id"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "$(inputs.sample_id + \".plot_fingerp.png\")"
                    },
                    "id": "#deeptools_plotFingerprint.cwl/qc_plot_fingerprint_plot"
                },
                {
                    "type": "stderr",
                    "id": "#deeptools_plotFingerprint.cwl/qc_plot_fingerprint_stderr"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "$(inputs.sample_id + \".plot_fingerp.tsv\")"
                    },
                    "id": "#deeptools_plotFingerprint.cwl/qc_plot_fingerprint_tsv"
                }
            ],
            "successCodes": [
                0,
                1,
                2
            ],
            "temporaryFailCodes": [],
            "permanentFailCodes": [],
            "id": "#deeptools_plotFingerprint.cwl"
        },
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/trim_galore:0.4.4_1.14_0.11.7",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 1,
                    "ramMin": 5000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": "fastqc",
            "arguments": [
                {
                    "valueFrom": "$(runtime.outdir)",
                    "prefix": "-o"
                },
                {
                    "valueFrom": "--noextract"
                }
            ],
            "inputs": [
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#fastqc.cwl/bam"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#fastqc.cwl/fastq1"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#fastqc.cwl/fastq2"
                }
            ],
            "outputs": [
                {
                    "doc": "html report showing results from zip",
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputBinding": {
                        "glob": "*_fastqc.html"
                    },
                    "id": "#fastqc.cwl/fastqc_html"
                },
                {
                    "doc": "all data e.g. figures",
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputBinding": {
                        "glob": "*_fastqc.zip"
                    },
                    "id": "#fastqc.cwl/fastqc_zip"
                }
            ],
            "id": "#fastqc.cwl"
        },
        {
            "class": "ExpressionTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "hints": [
                {
                    "coresMin": 1,
                    "ramMin": 1000,
                    "class": "ResourceRequirement"
                }
            ],
            "inputs": [
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "id": "#frag_size_decision_maker.cwl/cc_fragment_size"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "id": "#frag_size_decision_maker.cwl/user_def_fragment_size"
                }
            ],
            "expression": "${\n    var fragment_size = inputs.user_def_fragment_size;\n    if( fragment_size == null ){\n        fragment_size = inputs.cc_fragment_size;\n    }\n    return { \"fragment_size\": fragment_size }\n}\n",
            "outputs": [
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "id": "#frag_size_decision_maker.cwl/fragment_size"
                }
            ],
            "id": "#frag_size_decision_maker.cwl"
        },
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/multiqc:1.7",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 1,
                    "ramMin": 10000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": [
                "bash",
                "-c"
            ],
            "arguments": [
                {
                    "valueFrom": "${\n    var qc_files_array = inputs.qc_files_array;\n    var qc_files_array_of_array = inputs.qc_files_array_of_array;\n    var cmdline = \"echo 'copying input file ...'\";\n\n    if ( qc_files_array != null ){\n      for (var i=0; i<qc_files_array.length; i++){\n        if( qc_files_array[i] != null ){\n          cmdline += \"; cp \" + qc_files_array[i].path + \" .\";\n        }\n      }\n    }\n\n    if ( qc_files_array_of_array != null ){\n      for (var i=0; i<qc_files_array_of_array.length; i++){ \n        for (var ii=0; ii<qc_files_array_of_array[i].length; ii++){\n          if( qc_files_array_of_array[i][ii] != null ){\n            cmdline += \"; cp \" + qc_files_array_of_array[i][ii].path + \" .\";\n          }\n        }\n      }\n    }\n    \n    cmdline += \"; echo \\'copying done\\'\" +\n        \"; multiqc --zip-data-dir --cl_config \\'log_filesize_limit: 100000000\\' \" +\n        \"--outdir \" + runtime.outdir +\n        \" --filename \" + inputs.report_name + \"_report .\";\n\n    return cmdline\n  }\n"
                }
            ],
            "inputs": [
                {
                    "doc": "qc files which shall be part of the multiqc summary;\noptional, only one of qc_files_array or qc_files_array_of_array \nmust be provided\n",
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": [
                                "File",
                                "null"
                            ]
                        }
                    ],
                    "id": "#multiqc_hack.cwl/qc_files_array"
                },
                {
                    "doc": "qc files which shall be part of the multiqc summary;\noptional, only one of qc_files_array or qc_files_array_of_array \nmust be provided\n",
                    "type": [
                        "null",
                        {
                            "type": "array",
                            "items": {
                                "type": "array",
                                "items": [
                                    "File",
                                    "null"
                                ]
                            }
                        }
                    ],
                    "id": "#multiqc_hack.cwl/qc_files_array_of_array"
                },
                {
                    "doc": "name used for the html report and the corresponding zip file",
                    "type": "string",
                    "default": "multiqc",
                    "id": "#multiqc_hack.cwl/report_name"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.report_name + \"_report.html\")"
                    },
                    "id": "#multiqc_hack.cwl/multiqc_html"
                },
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.report_name + \"_report_data.zip\")"
                    },
                    "id": "#multiqc_hack.cwl/multiqc_zip"
                }
            ],
            "id": "#multiqc_hack.cwl"
        },
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/phantompeakqualtools:1.2",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 1,
                    "ramMin": 20000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": [
                "Rscript",
                "--verbose",
                "--max-ppsize=500000",
                "/usr/bin/phantompeakqualtools-1.2/run_spp.R"
            ],
            "arguments": [
                {
                    "valueFrom": "$(runtime.tmpdir)",
                    "prefix": "-tmpdir=",
                    "separate": false,
                    "position": 10
                },
                {
                    "valueFrom": "$(runtime.outdir)",
                    "prefix": "-odir=",
                    "separate": false,
                    "position": 10
                },
                {
                    "valueFrom": "$(inputs.bam.nameroot + \".crosscor.pdf\")",
                    "prefix": "-savp=",
                    "separate": false,
                    "position": 100
                },
                {
                    "valueFrom": "$(inputs.bam.nameroot + \".spp.out\")",
                    "prefix": "-out=",
                    "separate": false,
                    "position": 100
                }
            ],
            "stderr": "$(inputs.bam.nameroot + \".phantompeakqualtools_stderr\")",
            "stdout": "$(inputs.bam.nameroot + \".phantompeakqualtools_stdout\")",
            "inputs": [
                {
                    "type": "File",
                    "inputBinding": {
                        "prefix": "-c=",
                        "separate": false,
                        "position": 10
                    },
                    "id": "#phantompeakqualtools.cwl/bam"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "outputBinding": {
                        "glob": "*.spp.out",
                        "loadContents": true,
                        "outputEval": "$(parseInt(self[0].contents.split('\\t')[2]))"
                    },
                    "id": "#phantompeakqualtools.cwl/qc_crosscorr_fragment_size"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "*.pdf"
                    },
                    "id": "#phantompeakqualtools.cwl/qc_crosscorr_plot"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "*.spp.out"
                    },
                    "id": "#phantompeakqualtools.cwl/qc_crosscorr_summary"
                },
                {
                    "type": "stderr",
                    "id": "#phantompeakqualtools.cwl/qc_phantompeakqualtools_stderr"
                },
                {
                    "type": "stdout",
                    "id": "#phantompeakqualtools.cwl/qc_phantompeakqualtools_stdout"
                }
            ],
            "successCodes": [
                0,
                1,
                2
            ],
            "temporaryFailCodes": [],
            "permanentFailCodes": [],
            "id": "#phantompeakqualtools.cwl"
        },
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/picard_tools:2.17.4",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 1,
                    "ramMin": 20000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": [
                "java",
                "-jar"
            ],
            "arguments": [
                {
                    "valueFrom": "MarkDuplicates",
                    "position": 2
                },
                {
                    "valueFrom": "$(inputs.bam_sorted.nameroot + \"_duprem.bam\")",
                    "prefix": "OUTPUT=",
                    "separate": false,
                    "position": 13
                },
                {
                    "valueFrom": "$(inputs.bam_sorted.nameroot + \"_duprem.log\")",
                    "prefix": "METRICS_FILE=",
                    "separate": false,
                    "position": 13
                },
                {
                    "valueFrom": "REMOVE_DUPLICATES=TRUE",
                    "position": 14
                },
                {
                    "valueFrom": "ASSUME_SORTED=TRUE",
                    "position": 15
                },
                {
                    "valueFrom": "VALIDATION_STRINGENCY=SILENT",
                    "position": 16
                },
                {
                    "valueFrom": "VERBOSITY=INFO",
                    "position": 17
                },
                {
                    "valueFrom": "QUIET=false",
                    "position": 17
                }
            ],
            "stderr": "$(inputs.bam_sorted.nameroot + \".picard_markdup.log\")",
            "inputs": [
                {
                    "doc": "sorted bam input file",
                    "type": "File",
                    "inputBinding": {
                        "prefix": "INPUT=",
                        "separate": false,
                        "position": 11
                    },
                    "id": "#picard_markdup.cwl/bam_sorted"
                },
                {
                    "type": "string",
                    "default": "/bin/picard.jar",
                    "inputBinding": {
                        "position": 1
                    },
                    "id": "#picard_markdup.cwl/path_to_picards"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.bam_sorted.nameroot + \"_duprem.bam\")"
                    },
                    "id": "#picard_markdup.cwl/bam_duprem"
                },
                {
                    "type": "stderr",
                    "id": "#picard_markdup.cwl/picard_markdup_log"
                }
            ],
            "id": "#picard_markdup.cwl"
        },
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/samtools:1.7",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 1,
                    "ramMin": 20000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": [
                "bash",
                "-c"
            ],
            "arguments": [
                {
                    "valueFrom": "$(\"cp \" + inputs.bam_sorted.path + \" . && samtools index -b \" + inputs.bam_sorted.basename )"
                }
            ],
            "inputs": [
                {
                    "doc": "sorted bam input file",
                    "type": "File",
                    "id": "#samtools_index_hack.cwl/bam_sorted"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "secondaryFiles": ".bai",
                    "outputBinding": {
                        "glob": "$(inputs.bam_sorted.basename)"
                    },
                    "id": "#samtools_index_hack.cwl/bam_sorted_indexed"
                }
            ],
            "id": "#samtools_index_hack.cwl"
        },
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/samtools:1.7",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 1,
                    "ramMin": 20000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": [
                "samtools",
                "merge"
            ],
            "inputs": [
                {
                    "id": "#samtools_merge.cwl/output_name",
                    "doc": "name of merged bam file",
                    "type": "string",
                    "inputBinding": {
                        "position": 1
                    }
                },
                {
                    "id": "#samtools_merge.cwl/bams",
                    "doc": "bam files to be merged",
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "inputBinding": {
                        "position": 2
                    }
                }
            ],
            "outputs": [
                {
                    "id": "#samtools_merge.cwl/bam_merged",
                    "type": "File",
                    "outputBinding": {
                        "glob": "$(inputs.output_name)"
                    }
                }
            ],
            "id": "#samtools_merge.cwl"
        },
        {
            "doc": "Sort a bam file by read names.",
            "class": "CommandLineTool",
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/samtools:1.7",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 4,
                    "ramMin": 15000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": [
                "samtools",
                "sort"
            ],
            "arguments": [
                {
                    "valueFrom": "$(runtime.cores)",
                    "prefix": "-@"
                }
            ],
            "inputs": [
                {
                    "doc": "aligned reads to be checked in sam or bam format",
                    "type": "File",
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#samtools_sort.cwl/bam_unsorted"
                }
            ],
            "stdout": "$(inputs.bam_unsorted.basename)",
            "outputs": [
                {
                    "type": "stdout",
                    "id": "#samtools_sort.cwl/bam_sorted"
                }
            ],
            "id": "#samtools_sort.cwl"
        },
        {
            "class": "CommandLineTool",
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/samtools:1.7",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 1,
                    "ramMin": 10000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": [
                "samtools",
                "view"
            ],
            "inputs": [
                {
                    "doc": "aligned reads to be checked in bam format",
                    "type": "File",
                    "inputBinding": {
                        "position": 10
                    },
                    "id": "#samtools_view_count_alignments.cwl/bam"
                },
                {
                    "doc": "if paired end, only properly paired reads pass",
                    "type": "boolean",
                    "default": true,
                    "id": "#samtools_view_count_alignments.cwl/is_spaired_end"
                }
            ],
            "arguments": [
                {
                    "valueFrom": "-c",
                    "position": 1
                },
                {
                    "valueFrom": "4",
                    "prefix": "-F",
                    "position": 1
                },
                {
                    "valueFrom": "20",
                    "prefix": "-q",
                    "position": 1
                },
                {
                    "valueFrom": "${\n  if ( inputs.is_paired_end ){\n     return \"-f\";\n  }\n  else {\n    return null;\n  }\n}\n",
                    "position": 2
                },
                {
                    "valueFrom": "${\n  if ( inputs.is_paired_end ){\n     return \"3\";\n  }\n  else {\n    return null;\n  }\n}\n",
                    "position": 3
                }
            ],
            "stdout": "$(inputs.bam.nameroot + \"_aln_read_counts.txt\")",
            "outputs": [
                {
                    "type": "long",
                    "outputBinding": {
                        "glob": "*_aln_read_counts.txt",
                        "loadContents": true,
                        "outputEval": "$(parseInt(self[0].contents))"
                    },
                    "id": "#samtools_view_count_alignments.cwl/aln_read_count"
                },
                {
                    "type": "stdout",
                    "id": "#samtools_view_count_alignments.cwl/aln_read_count_file"
                }
            ],
            "id": "#samtools_view_count_alignments.cwl"
        },
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/samtools:1.7",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 1,
                    "ramMin": 10000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": [
                "samtools",
                "view"
            ],
            "inputs": [
                {
                    "doc": "aligned reads to be checked in bam format",
                    "type": "File",
                    "inputBinding": {
                        "position": 10
                    },
                    "id": "#samtools_view_filter.cwl/bam"
                },
                {
                    "doc": "if paired end, only properly paired reads pass",
                    "type": "boolean",
                    "default": true,
                    "id": "#samtools_view_filter.cwl/is_paired_end"
                }
            ],
            "arguments": [
                {
                    "valueFrom": "-h",
                    "position": 1
                },
                {
                    "valueFrom": "-b",
                    "position": 1
                },
                {
                    "valueFrom": "4",
                    "prefix": "-F",
                    "position": 1
                },
                {
                    "valueFrom": "20",
                    "prefix": "-q",
                    "position": 1
                },
                {
                    "valueFrom": "${\n  if ( inputs.is_paired_end ){\n     return \"-f\";\n  }\n  else {\n    return null;\n  }\n}\n",
                    "position": 2
                },
                {
                    "valueFrom": "${\n  if ( inputs.is_paired_end ){\n     return \"3\";\n  }\n  else {\n    return null;\n  }\n}\n",
                    "position": 3
                }
            ],
            "stdout": "$(inputs.bam.nameroot)_filt.bam",
            "outputs": [
                {
                    "type": "stdout",
                    "id": "#samtools_view_filter.cwl/bam_filtered"
                }
            ],
            "id": "#samtools_view_filter.cwl"
        },
        {
            "class": "CommandLineTool",
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/samtools:1.7",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 1,
                    "ramMin": 10000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": [
                "samtools",
                "view"
            ],
            "inputs": [
                {
                    "doc": "aligned reads to be checked in sam or bam format",
                    "type": "File",
                    "inputBinding": {
                        "position": 2
                    },
                    "id": "#samtools_view_sam2bam.cwl/sam"
                }
            ],
            "arguments": [
                {
                    "valueFrom": "-h",
                    "position": 1
                },
                {
                    "valueFrom": "-b",
                    "position": 1
                }
            ],
            "stdout": "$(inputs.sam.nameroot).bam",
            "outputs": [
                {
                    "type": "stdout",
                    "id": "#samtools_view_sam2bam.cwl/bam_unsorted"
                }
            ],
            "id": "#samtools_view_sam2bam.cwl"
        },
        {
            "class": "CommandLineTool",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                }
            ],
            "hints": [
                {
                    "dockerPull": "kerstenbreuer/trim_galore:0.4.4_1.14_0.11.7",
                    "class": "DockerRequirement"
                },
                {
                    "coresMin": 1,
                    "ramMin": 7000,
                    "class": "ResourceRequirement"
                }
            ],
            "baseCommand": "trim_galore",
            "inputs": [
                {
                    "doc": "Adapter sequence for first reads.\nif not specified, trim_galore will try to autodetect whether ...\n- Illumina universal adapter (AGATCGGAAGAGC)\n- Nextera adapter (CTGTCTCTTATA)\n- Illumina Small RNA 3' Adapter (TGGAATTCTCGG)\n... was used.\nYou can directly choose one of the above configurations\nby setting the string to \"illumina\", \"nextera\", or \"small_rna\".\n",
                    "type": [
                        "null",
                        "string"
                    ],
                    "id": "#trim_galore.cwl/adapter1"
                },
                {
                    "doc": "Adapter sequence for second reads - only for paired end data.\nif not specified, trim_galore will try to autodetect whether ...\n- Illumina universal adapter (AGATCGGAAGAGC)\n- Nextera adapter (CTGTCTCTTATA)\n- Illumina Small RNA 3' Adapter (TGGAATTCTCGG)\n... was used.\nYou can directly choose one of the above configurations\nby setting the adapter1 string to \"illumina\", \"nextera\", or \"small_rna\".\n",
                    "type": [
                        "null",
                        "string"
                    ],
                    "id": "#trim_galore.cwl/adapter2"
                },
                {
                    "doc": "raw reads in fastq format; can be gzipped;\nif paired end, the file contains the first reads;\nif single end, the file contains all reads\n",
                    "type": "File",
                    "inputBinding": {
                        "position": 10
                    },
                    "id": "#trim_galore.cwl/fastq1"
                },
                {
                    "doc": "(optional) raw reads in fastq format; can be gzipped;\nif paired end, the file contains the second reads;\nif single end, the file does not exist\n",
                    "type": [
                        "null",
                        "File"
                    ],
                    "inputBinding": {
                        "position": 11
                    },
                    "id": "#trim_galore.cwl/fastq2"
                },
                {
                    "doc": "minimum overlap with adapter seq in bp needed to trim",
                    "type": "int",
                    "default": 1,
                    "inputBinding": {
                        "prefix": "--stringency",
                        "position": 1
                    },
                    "id": "#trim_galore.cwl/min_adapter_overlap"
                },
                {
                    "doc": "discard reads that get shorter than this value",
                    "type": "int",
                    "default": 20,
                    "inputBinding": {
                        "prefix": "--length",
                        "position": 1
                    },
                    "id": "#trim_galore.cwl/min_read_length"
                },
                {
                    "doc": "if only one read of a pair passes the qc and adapter trimming,\nit needs at least this length to be rescued\n",
                    "type": "int",
                    "default": 35,
                    "id": "#trim_galore.cwl/min_unpaired_read_rescue_length"
                },
                {
                    "doc": "trim all base with a phred score lower than this valueFrom",
                    "type": "int",
                    "default": 20,
                    "inputBinding": {
                        "prefix": "--quality",
                        "position": 1
                    },
                    "id": "#trim_galore.cwl/qual_trim_cutoff"
                }
            ],
            "arguments": [
                {
                    "prefix": "--fastqc_args",
                    "valueFrom": "\"--noextract\"",
                    "position": 1
                },
                {
                    "prefix": "--gzip",
                    "position": 1
                },
                {
                    "valueFrom": "${\n  if ( inputs.adapter1 == \"illumina\" ){ return \"--illumina\" }\n  else if ( inputs.adapter1 == \"nextera\" ){ return \"--nextera\" }\n  else if ( inputs.adapter1 == \"small_rna\" ){ return \"--small_rna\" }\n  else { return null }\n}\n",
                    "position": 1
                },
                {
                    "prefix": "--adapter",
                    "valueFrom": "${\n  if ( inputs.apdater1 != null && inputs.adapter1 != \"illumina\" && inputs.adapter1 != \"nextera\" && inputs.adapter1 != \"small_rna\" ){\n    return inputs.adapter1\n  } else {\n    return null\n  }\n}\n",
                    "position": 1
                },
                {
                    "prefix": "--adapter2",
                    "valueFrom": "${\n  if ( inputs.fastq2 != null && inputs.apdater2 != null && inputs.adapter1 != \"illumina\" && inputs.adapter1 != \"nextera\" && inputs.adapter1 != \"small_rna\" ){\n    return inputs.adapter2\n  } else {\n    return null\n  }\n}\n",
                    "position": 1
                },
                {
                    "valueFrom": "${\n  if ( inputs.fastq2 == null ){ return null }\n  else { return \"--paired\" }\n}\n",
                    "position": 1
                },
                {
                    "valueFrom": "${\n  if ( inputs.fastq2 == null ){ return null }\n  else { return \"--retain_unpaired\" }\n}\n",
                    "position": 1
                },
                {
                    "prefix": "--length_1",
                    "valueFrom": "${\n  if ( inputs.fastq2 == null ){ return null }\n  else { return inputs.min_unpaired_read_rescue_length }\n}\n",
                    "position": 1
                },
                {
                    "prefix": "--length_2",
                    "valueFrom": "${\n  if ( inputs.fastq2 == null ){ return null }\n  else { return inputs.min_unpaired_read_rescue_length }\n}\n",
                    "position": 1
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputBinding": {
                        "glob": "${\n    if ( inputs.fastq2 == null  ){ return \"*trimmed.fq*\" }\n    else { return \"*val_1.fq*\" }\n}\n"
                    },
                    "id": "#trim_galore.cwl/fastq1_trimmed"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "*unpaired_1.fq*"
                    },
                    "id": "#trim_galore.cwl/fastq1_trimmed_unpaired"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "*val_2.fq*"
                    },
                    "id": "#trim_galore.cwl/fastq2_trimmed"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputBinding": {
                        "glob": "*unpaired_2.fq*"
                    },
                    "id": "#trim_galore.cwl/fastq2_trimmed_unpaired"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputBinding": {
                        "glob": "*trimming_report.txt"
                    },
                    "id": "#trim_galore.cwl/trim_galore_log"
                },
                {
                    "doc": "html report of post-trimming fastqc",
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputBinding": {
                        "glob": "*fastqc.html"
                    },
                    "id": "#trim_galore.cwl/trimmed_fastqc_html"
                },
                {
                    "doc": "all data of post-trimming fastqc e.g. figures",
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputBinding": {
                        "glob": "*fastqc.zip"
                    },
                    "id": "#trim_galore.cwl/trimmed_fastqc_zip"
                }
            ],
            "id": "#trim_galore.cwl"
        },
        {
            "class": "Workflow",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                }
            ],
            "inputs": [
                {
                    "type": "File",
                    "secondaryFiles": ".bai",
                    "id": "#chip_qc.cwl/bam"
                },
                {
                    "type": "boolean",
                    "id": "#chip_qc.cwl/is_paired_end"
                },
                {
                    "type": "string",
                    "id": "#chip_qc.cwl/sample_id"
                },
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "id": "#chip_qc.cwl/user_def_fragment_size"
                }
            ],
            "steps": [
                {
                    "doc": "If no user-defined fragment size was set,\nthe fragment size infered from cross-correlation analysis \nwill be used.\n",
                    "run": "#frag_size_decision_maker.cwl",
                    "in": [
                        {
                            "source": "#chip_qc.cwl/qc_phantompeakqualtools/qc_crosscorr_fragment_size",
                            "id": "#chip_qc.cwl/fragment_size_decision_maker/cc_fragment_size"
                        },
                        {
                            "source": "#chip_qc.cwl/user_def_fragment_size",
                            "id": "#chip_qc.cwl/fragment_size_decision_maker/user_def_fragment_size"
                        }
                    ],
                    "out": [
                        "#chip_qc.cwl/fragment_size_decision_maker/fragment_size"
                    ],
                    "id": "#chip_qc.cwl/fragment_size_decision_maker"
                },
                {
                    "run": "#phantompeakqualtools.cwl",
                    "in": [
                        {
                            "source": "#chip_qc.cwl/bam",
                            "id": "#chip_qc.cwl/qc_phantompeakqualtools/bam"
                        }
                    ],
                    "out": [
                        "#chip_qc.cwl/qc_phantompeakqualtools/qc_crosscorr_summary",
                        "#chip_qc.cwl/qc_phantompeakqualtools/qc_crosscorr_plot",
                        "#chip_qc.cwl/qc_phantompeakqualtools/qc_crosscorr_fragment_size",
                        "#chip_qc.cwl/qc_phantompeakqualtools/qc_phantompeakqualtools_stderr",
                        "#chip_qc.cwl/qc_phantompeakqualtools/qc_phantompeakqualtools_stdout"
                    ],
                    "id": "#chip_qc.cwl/qc_phantompeakqualtools"
                },
                {
                    "doc": "deeptools plotCoverage - plots how many times a certain fraction of the \ngenome was covered (consideres the complete fragment between a reads pair).\n",
                    "run": "#deeptools_plotCoverage.cwl",
                    "in": [
                        {
                            "source": "#chip_qc.cwl/bam",
                            "id": "#chip_qc.cwl/qc_plot_coverage/bam"
                        },
                        {
                            "source": "#chip_qc.cwl/fragment_size_decision_maker/fragment_size",
                            "id": "#chip_qc.cwl/qc_plot_coverage/fragment_size"
                        },
                        {
                            "source": "#chip_qc.cwl/is_paired_end",
                            "id": "#chip_qc.cwl/qc_plot_coverage/is_paired_end"
                        },
                        {
                            "source": "#chip_qc.cwl/sample_id",
                            "id": "#chip_qc.cwl/qc_plot_coverage/sample_id"
                        }
                    ],
                    "out": [
                        "#chip_qc.cwl/qc_plot_coverage/qc_plot_coverage_plot",
                        "#chip_qc.cwl/qc_plot_coverage/qc_plot_coverage_tsv"
                    ],
                    "id": "#chip_qc.cwl/qc_plot_coverage"
                },
                {
                    "doc": "Applies deeptools plotFingerprint to generate meaningful plots for comparing IP and\ncontrol samples in terms of quality control. The main question which can be answered is:\nDid the antibody lead to enough enrichment that the IP can be distinguished from the control? \n",
                    "run": "#deeptools_plotFingerprint.cwl",
                    "in": [
                        {
                            "source": "#chip_qc.cwl/bam",
                            "id": "#chip_qc.cwl/qc_plot_fingerprint/bam"
                        },
                        {
                            "source": "#chip_qc.cwl/fragment_size_decision_maker/fragment_size",
                            "id": "#chip_qc.cwl/qc_plot_fingerprint/fragment_size"
                        },
                        {
                            "source": "#chip_qc.cwl/is_paired_end",
                            "id": "#chip_qc.cwl/qc_plot_fingerprint/is_paired_end"
                        },
                        {
                            "source": "#chip_qc.cwl/sample_id",
                            "id": "#chip_qc.cwl/qc_plot_fingerprint/sample_id"
                        }
                    ],
                    "out": [
                        "#chip_qc.cwl/qc_plot_fingerprint/qc_plot_fingerprint_plot",
                        "#chip_qc.cwl/qc_plot_fingerprint/qc_plot_fingerprint_tsv",
                        "#chip_qc.cwl/qc_plot_fingerprint/qc_plot_fingerprint_stderr"
                    ],
                    "id": "#chip_qc.cwl/qc_plot_fingerprint"
                }
            ],
            "outputs": [
                {
                    "type": [
                        "null",
                        "int"
                    ],
                    "outputSource": "#chip_qc.cwl/fragment_size_decision_maker/fragment_size",
                    "id": "#chip_qc.cwl/fragment_size"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#chip_qc.cwl/qc_phantompeakqualtools/qc_crosscorr_plot",
                    "id": "#chip_qc.cwl/qc_crosscorr_plot"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#chip_qc.cwl/qc_phantompeakqualtools/qc_crosscorr_summary",
                    "id": "#chip_qc.cwl/qc_crosscorr_summary"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#chip_qc.cwl/qc_phantompeakqualtools/qc_phantompeakqualtools_stderr",
                    "id": "#chip_qc.cwl/qc_phantompeakqualtools_stderr"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#chip_qc.cwl/qc_phantompeakqualtools/qc_phantompeakqualtools_stdout",
                    "id": "#chip_qc.cwl/qc_phantompeakqualtools_stdout"
                },
                {
                    "type": "File",
                    "outputSource": "#chip_qc.cwl/qc_plot_coverage/qc_plot_coverage_plot",
                    "id": "#chip_qc.cwl/qc_plot_coverage_plot"
                },
                {
                    "type": "File",
                    "outputSource": "#chip_qc.cwl/qc_plot_coverage/qc_plot_coverage_tsv",
                    "id": "#chip_qc.cwl/qc_plot_coverage_tsv"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#chip_qc.cwl/qc_plot_fingerprint/qc_plot_fingerprint_plot",
                    "id": "#chip_qc.cwl/qc_plot_fingerprint_plot"
                },
                {
                    "type": "File",
                    "outputSource": "#chip_qc.cwl/qc_plot_fingerprint/qc_plot_fingerprint_stderr",
                    "id": "#chip_qc.cwl/qc_plot_fingerprint_stderr"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#chip_qc.cwl/qc_plot_fingerprint/qc_plot_fingerprint_tsv",
                    "id": "#chip_qc.cwl/qc_plot_fingerprint_tsv"
                }
            ],
            "id": "#chip_qc.cwl"
        },
        {
            "class": "Workflow",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "ScatterFeatureRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                },
                {
                    "class": "SubworkflowFeatureRequirement"
                }
            ],
            "inputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#get_spike_in_counts.cwl/fastq1_trimmed"
                },
                {
                    "type": {
                        "type": "array",
                        "items": [
                            "File",
                            "null"
                        ]
                    },
                    "id": "#get_spike_in_counts.cwl/fastq2_trimmed"
                },
                {
                    "type": "File",
                    "secondaryFiles": [
                        ".fai",
                        "^.1.bt2",
                        "^.2.bt2",
                        "^.3.bt2",
                        "^.4.bt2",
                        "^.rev.1.bt2",
                        "^.rev.2.bt2"
                    ],
                    "id": "#get_spike_in_counts.cwl/genome_spike_in"
                },
                {
                    "type": "boolean",
                    "id": "#get_spike_in_counts.cwl/is_paired_end"
                },
                {
                    "type": "string",
                    "id": "#get_spike_in_counts.cwl/sample_id"
                }
            ],
            "steps": [
                {
                    "run": "#samtools_view_count_alignments.cwl",
                    "in": [
                        {
                            "source": "#get_spike_in_counts.cwl/duplicate_removal/bam_duprem",
                            "id": "#get_spike_in_counts.cwl/count_aligned_reads/bam"
                        }
                    ],
                    "out": [
                        "#get_spike_in_counts.cwl/count_aligned_reads/aln_read_count_file",
                        "#get_spike_in_counts.cwl/count_aligned_reads/aln_read_count"
                    ],
                    "id": "#get_spike_in_counts.cwl/count_aligned_reads"
                },
                {
                    "doc": "remove duplicate reads",
                    "run": "#picard_markdup.cwl",
                    "in": [
                        {
                            "source": "#get_spike_in_counts.cwl/sort_bam/bam_sorted",
                            "id": "#get_spike_in_counts.cwl/duplicate_removal/bam_sorted"
                        }
                    ],
                    "out": [
                        "#get_spike_in_counts.cwl/duplicate_removal/bam_duprem"
                    ],
                    "id": "#get_spike_in_counts.cwl/duplicate_removal"
                },
                {
                    "doc": "samtools merge - merging bam files of lane replicates",
                    "run": "#samtools_merge.cwl",
                    "in": [
                        {
                            "source": "#get_spike_in_counts.cwl/sam2bam/bam_unsorted",
                            "id": "#get_spike_in_counts.cwl/lane_replicate_merging/bams"
                        },
                        {
                            "source": "#get_spike_in_counts.cwl/sample_id",
                            "valueFrom": "$(self + \"_spike_in.bam\")",
                            "id": "#get_spike_in_counts.cwl/lane_replicate_merging/output_name"
                        }
                    ],
                    "out": [
                        "#get_spike_in_counts.cwl/lane_replicate_merging/bam_merged"
                    ],
                    "id": "#get_spike_in_counts.cwl/lane_replicate_merging"
                },
                {
                    "doc": "bowite2 - mapper, produces sam file",
                    "run": "#bowtie2.cwl",
                    "scatter": [
                        "#get_spike_in_counts.cwl/mapping/fastq1",
                        "#get_spike_in_counts.cwl/mapping/fastq2"
                    ],
                    "scatterMethod": "dotproduct",
                    "in": [
                        {
                            "source": "#get_spike_in_counts.cwl/fastq1_trimmed",
                            "id": "#get_spike_in_counts.cwl/mapping/fastq1"
                        },
                        {
                            "source": "#get_spike_in_counts.cwl/fastq2_trimmed",
                            "id": "#get_spike_in_counts.cwl/mapping/fastq2"
                        },
                        {
                            "source": "#get_spike_in_counts.cwl/genome_spike_in",
                            "id": "#get_spike_in_counts.cwl/mapping/genome_index"
                        },
                        {
                            "source": "#get_spike_in_counts.cwl/is_paired_end",
                            "id": "#get_spike_in_counts.cwl/mapping/is_paired_end"
                        }
                    ],
                    "out": [
                        "#get_spike_in_counts.cwl/mapping/sam",
                        "#get_spike_in_counts.cwl/mapping/bowtie2_log"
                    ],
                    "id": "#get_spike_in_counts.cwl/mapping"
                },
                {
                    "doc": "samtools view - convert sam to bam",
                    "run": "#samtools_view_sam2bam.cwl",
                    "scatter": [
                        "#get_spike_in_counts.cwl/sam2bam/sam"
                    ],
                    "scatterMethod": "dotproduct",
                    "in": [
                        {
                            "source": "#get_spike_in_counts.cwl/mapping/sam",
                            "id": "#get_spike_in_counts.cwl/sam2bam/sam"
                        }
                    ],
                    "out": [
                        "#get_spike_in_counts.cwl/sam2bam/bam_unsorted"
                    ],
                    "id": "#get_spike_in_counts.cwl/sam2bam"
                },
                {
                    "doc": "samtools sort - sorts unsorted bam file by coordinates.",
                    "run": "#samtools_sort.cwl",
                    "in": [
                        {
                            "source": "#get_spike_in_counts.cwl/lane_replicate_merging/bam_merged",
                            "id": "#get_spike_in_counts.cwl/sort_bam/bam_unsorted"
                        }
                    ],
                    "out": [
                        "#get_spike_in_counts.cwl/sort_bam/bam_sorted"
                    ],
                    "id": "#get_spike_in_counts.cwl/sort_bam"
                }
            ],
            "outputs": [
                {
                    "type": "long",
                    "outputSource": "#get_spike_in_counts.cwl/count_aligned_reads/aln_read_count",
                    "id": "#get_spike_in_counts.cwl/aln_read_count"
                },
                {
                    "type": "File",
                    "outputSource": "#get_spike_in_counts.cwl/count_aligned_reads/aln_read_count_file",
                    "id": "#get_spike_in_counts.cwl/aln_read_count_file"
                },
                {
                    "type": "File",
                    "outputSource": "#get_spike_in_counts.cwl/duplicate_removal/bam_duprem",
                    "id": "#get_spike_in_counts.cwl/bam"
                }
            ],
            "id": "#get_spike_in_counts.cwl"
        },
        {
            "class": "Workflow",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "ScatterFeatureRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                },
                {
                    "class": "SubworkflowFeatureRequirement"
                }
            ],
            "inputs": [
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#merge_filter.cwl/bams"
                },
                {
                    "type": "boolean",
                    "id": "#merge_filter.cwl/is_paired_end"
                },
                {
                    "type": "string",
                    "id": "#merge_filter.cwl/sample_id"
                }
            ],
            "steps": [
                {
                    "doc": "samtools view",
                    "run": "#samtools_view_filter.cwl",
                    "in": [
                        {
                            "source": "#merge_filter.cwl/sorting_merged_bam/bam_sorted",
                            "id": "#merge_filter.cwl/filter_by_mapq/bam"
                        },
                        {
                            "source": "#merge_filter.cwl/is_paired_end",
                            "id": "#merge_filter.cwl/filter_by_mapq/is_paired_end"
                        }
                    ],
                    "out": [
                        "#merge_filter.cwl/filter_by_mapq/bam_filtered"
                    ],
                    "id": "#merge_filter.cwl/filter_by_mapq"
                },
                {
                    "doc": "samtools index - indexes sorted bam\n",
                    "run": "#samtools_index_hack.cwl",
                    "in": [
                        {
                            "source": "#merge_filter.cwl/sorting_filtered_bam/bam_sorted",
                            "id": "#merge_filter.cwl/indexing_filtered_bam/bam_sorted"
                        }
                    ],
                    "out": [
                        "#merge_filter.cwl/indexing_filtered_bam/bam_sorted_indexed"
                    ],
                    "id": "#merge_filter.cwl/indexing_filtered_bam"
                },
                {
                    "doc": "samtools merge - merging bam files of lane replicates",
                    "run": "#samtools_merge.cwl",
                    "in": [
                        {
                            "source": "#merge_filter.cwl/bams",
                            "id": "#merge_filter.cwl/lane_replicate_merging/bams"
                        },
                        {
                            "source": "#merge_filter.cwl/sample_id",
                            "valueFrom": "$(self + \".bam\")",
                            "id": "#merge_filter.cwl/lane_replicate_merging/output_name"
                        }
                    ],
                    "out": [
                        "#merge_filter.cwl/lane_replicate_merging/bam_merged"
                    ],
                    "id": "#merge_filter.cwl/lane_replicate_merging"
                },
                {
                    "doc": "fastqc - quality control for reads directly after mapping",
                    "run": "#fastqc.cwl",
                    "in": [
                        {
                            "source": "#merge_filter.cwl/indexing_filtered_bam/bam_sorted_indexed",
                            "id": "#merge_filter.cwl/qc/bam"
                        }
                    ],
                    "out": [
                        "#merge_filter.cwl/qc/fastqc_zip",
                        "#merge_filter.cwl/qc/fastqc_html"
                    ],
                    "id": "#merge_filter.cwl/qc"
                },
                {
                    "doc": "samtools sort - sorting of filtered bam",
                    "run": "#samtools_sort.cwl",
                    "in": [
                        {
                            "source": "#merge_filter.cwl/filter_by_mapq/bam_filtered",
                            "id": "#merge_filter.cwl/sorting_filtered_bam/bam_unsorted"
                        }
                    ],
                    "out": [
                        "#merge_filter.cwl/sorting_filtered_bam/bam_sorted"
                    ],
                    "id": "#merge_filter.cwl/sorting_filtered_bam"
                },
                {
                    "doc": "samtools sort - sorting of merged bam",
                    "run": "#samtools_sort.cwl",
                    "in": [
                        {
                            "source": "#merge_filter.cwl/lane_replicate_merging/bam_merged",
                            "id": "#merge_filter.cwl/sorting_merged_bam/bam_unsorted"
                        }
                    ],
                    "out": [
                        "#merge_filter.cwl/sorting_merged_bam/bam_sorted"
                    ],
                    "id": "#merge_filter.cwl/sorting_merged_bam"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "secondaryFiles": ".bai",
                    "outputSource": "#merge_filter.cwl/indexing_filtered_bam/bam_sorted_indexed",
                    "id": "#merge_filter.cwl/bam"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#merge_filter.cwl/qc/fastqc_html",
                    "id": "#merge_filter.cwl/fastqc_html"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#merge_filter.cwl/qc/fastqc_zip",
                    "id": "#merge_filter.cwl/fastqc_zip"
                }
            ],
            "id": "#merge_filter.cwl"
        },
        {
            "class": "Workflow",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "ScatterFeatureRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                },
                {
                    "class": "SubworkflowFeatureRequirement"
                }
            ],
            "inputs": [
                {
                    "type": [
                        "string",
                        "null"
                    ],
                    "id": "#trim_and_map.cwl/adapter1"
                },
                {
                    "type": [
                        "string",
                        "null"
                    ],
                    "id": "#trim_and_map.cwl/adapter2"
                },
                {
                    "type": "File",
                    "id": "#trim_and_map.cwl/fastq1"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "id": "#trim_and_map.cwl/fastq2"
                },
                {
                    "type": "File",
                    "secondaryFiles": [
                        ".fai",
                        "^.1.bt2",
                        "^.2.bt2",
                        "^.3.bt2",
                        "^.4.bt2",
                        "^.rev.1.bt2",
                        "^.rev.2.bt2"
                    ],
                    "id": "#trim_and_map.cwl/genome"
                },
                {
                    "type": "boolean",
                    "id": "#trim_and_map.cwl/is_paired_end"
                },
                {
                    "type": [
                        "null",
                        "long"
                    ],
                    "id": "#trim_and_map.cwl/max_mapping_insert_length"
                }
            ],
            "steps": [
                {
                    "doc": "trim galore - adapter trimming using trim_galore",
                    "run": "#trim_galore.cwl",
                    "in": [
                        {
                            "source": "#trim_and_map.cwl/adapter1",
                            "id": "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/adapter1"
                        },
                        {
                            "source": "#trim_and_map.cwl/adapter2",
                            "id": "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/adapter2"
                        },
                        {
                            "source": "#trim_and_map.cwl/fastq1",
                            "id": "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/fastq1"
                        },
                        {
                            "source": "#trim_and_map.cwl/fastq2",
                            "id": "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/fastq2"
                        }
                    ],
                    "out": [
                        "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/fastq1_trimmed",
                        "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/fastq2_trimmed",
                        "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/fastq1_trimmed_unpaired",
                        "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/fastq2_trimmed_unpaired",
                        "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/trim_galore_log",
                        "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/trimmed_fastqc_html",
                        "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/trimmed_fastqc_zip"
                    ],
                    "id": "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed"
                },
                {
                    "doc": "bowite2 - mapper, produces sam file",
                    "run": "#bowtie2.cwl",
                    "in": [
                        {
                            "source": "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/fastq1_trimmed",
                            "id": "#trim_and_map.cwl/mapping/fastq1"
                        },
                        {
                            "source": "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/fastq2_trimmed",
                            "id": "#trim_and_map.cwl/mapping/fastq2"
                        },
                        {
                            "source": "#trim_and_map.cwl/genome",
                            "id": "#trim_and_map.cwl/mapping/genome_index"
                        },
                        {
                            "source": "#trim_and_map.cwl/is_paired_end",
                            "id": "#trim_and_map.cwl/mapping/is_paired_end"
                        },
                        {
                            "source": "#trim_and_map.cwl/max_mapping_insert_length",
                            "id": "#trim_and_map.cwl/mapping/max_mapping_insert_length"
                        }
                    ],
                    "out": [
                        "#trim_and_map.cwl/mapping/sam",
                        "#trim_and_map.cwl/mapping/bowtie2_log"
                    ],
                    "id": "#trim_and_map.cwl/mapping"
                },
                {
                    "doc": "fastqc - quality control for trimmed fastq",
                    "run": "#fastqc.cwl",
                    "in": [
                        {
                            "source": "#trim_and_map.cwl/fastq1",
                            "id": "#trim_and_map.cwl/qc_raw/fastq1"
                        },
                        {
                            "source": "#trim_and_map.cwl/fastq2",
                            "id": "#trim_and_map.cwl/qc_raw/fastq2"
                        }
                    ],
                    "out": [
                        "#trim_and_map.cwl/qc_raw/fastqc_zip",
                        "#trim_and_map.cwl/qc_raw/fastqc_html"
                    ],
                    "id": "#trim_and_map.cwl/qc_raw"
                },
                {
                    "doc": "samtools view - convert sam to bam",
                    "run": "#samtools_view_sam2bam.cwl",
                    "in": [
                        {
                            "source": "#trim_and_map.cwl/mapping/sam",
                            "id": "#trim_and_map.cwl/sam2bam/sam"
                        }
                    ],
                    "out": [
                        "#trim_and_map.cwl/sam2bam/bam_unsorted"
                    ],
                    "id": "#trim_and_map.cwl/sam2bam"
                },
                {
                    "doc": "samtools sort - sorts unsorted bam file by coordinates.",
                    "run": "#samtools_sort.cwl",
                    "in": [
                        {
                            "source": "#trim_and_map.cwl/sam2bam/bam_unsorted",
                            "id": "#trim_and_map.cwl/sort_bam/bam_unsorted"
                        }
                    ],
                    "out": [
                        "#trim_and_map.cwl/sort_bam/bam_sorted"
                    ],
                    "id": "#trim_and_map.cwl/sort_bam"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "outputSource": "#trim_and_map.cwl/sort_bam/bam_sorted",
                    "id": "#trim_and_map.cwl/bam"
                },
                {
                    "type": "File",
                    "outputSource": "#trim_and_map.cwl/mapping/bowtie2_log",
                    "id": "#trim_and_map.cwl/bowtie2_log"
                },
                {
                    "type": "File",
                    "outputSource": "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/fastq1_trimmed",
                    "id": "#trim_and_map.cwl/fastq1_trimmed"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/fastq2_trimmed",
                    "id": "#trim_and_map.cwl/fastq2_trimmed"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#trim_and_map.cwl/qc_raw/fastqc_html",
                    "id": "#trim_and_map.cwl/raw_fastqc_html"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#trim_and_map.cwl/qc_raw/fastqc_zip",
                    "id": "#trim_and_map.cwl/raw_fastqc_zip"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/trim_galore_log",
                    "id": "#trim_and_map.cwl/trim_galore_log"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/trimmed_fastqc_html",
                    "id": "#trim_and_map.cwl/trimmed_fastqc_html"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#trim_and_map.cwl/adaptor_trimming_and_qc_trimmed/trimmed_fastqc_zip",
                    "id": "#trim_and_map.cwl/trimmed_fastqc_zip"
                }
            ],
            "id": "#trim_and_map.cwl"
        },
        {
            "class": "Workflow",
            "requirements": [
                {
                    "class": "InlineJavascriptRequirement"
                },
                {
                    "class": "MultipleInputFeatureRequirement"
                },
                {
                    "class": "ScatterFeatureRequirement"
                },
                {
                    "class": "StepInputExpressionRequirement"
                },
                {
                    "class": "SubworkflowFeatureRequirement"
                }
            ],
            "inputs": [
                {
                    "doc": "Adapter sequence for first reads.\nIf not specified (set to \"null\"), trim_galore will try to autodetect whether ...\n- Illumina universal adapter (AGATCGGAAGAGC)\n- Nextera adapter (CTGTCTCTTATA)\n- Illumina Small RNA 3-prime Adapter (TGGAATTCTCGG)\n... was used.\nYou can directly choose one of the above configurations\nby setting the string to \"illumina\", \"nextera\", or \"small_rna\".\nOr you specify the adaptor string manually (e.g. \"AGATCGGAAGAGC\").\n",
                    "type": [
                        "null",
                        "string"
                    ],
                    "id": "#main/adapter1"
                },
                {
                    "doc": "Adapter sequence for second reads (only relevant for paired end data).\nIf it is not specified (set to \"null\"), trim_galore will try to autodetect whether ...\n- Illumina universal adapter (AGATCGGAAGAGC)\n- Nextera adapter (CTGTCTCTTATA)\n- Illumina Small RNA 3-prime Adapter (TGGAATTCTCGG)\n... was used.\nYou can directly choose one of the above configurations\nby setting the string to \"illumina\", \"nextera\", or \"small_rna\".\nOr you specify the adaptor string manually (e.g. \"AGATCGGAAGAGC\").\n",
                    "type": [
                        "null",
                        "string"
                    ],
                    "id": "#main/adapter2"
                },
                {
                    "doc": "Bin size used for generation of coverage tracks.\nThe larger the bin size the smaller are the coverage tracks, however,\nthe less precise is the signal. For single bp resolution set to 1.\n",
                    "type": "int",
                    "default": 10,
                    "id": "#main/bin_size"
                },
                {
                    "doc": "The effectively mappable genome size, please see: \nhttps://deeptools.readthedocs.io/en/latest/content/feature/effectiveGenomeSize.html\n",
                    "type": "long",
                    "id": "#main/effective_genome_size"
                },
                {
                    "doc": "List of fastq files containing the first mate of raw reads.\nMuliple files are provided if multiplexing of the same library has been done\non multiple lanes. The reads comming from different fastq files are pooled\nafter alignment. Also see parameter \"fastq2\".\n",
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "id": "#main/fastq1"
                },
                {
                    "doc": "List of fastq files containing the second mate of raw reads in case of paired end\n(also see parameter \"fastq1\").\nImportant: this list has to be of same length as parameter \"fastq1\" no matter if paired or single end is used.\nIn case of single end data specify \"null\" for every entry of fastq1.\n",
                    "type": {
                        "type": "array",
                        "items": [
                            "File",
                            "null"
                        ]
                    },
                    "id": "#main/fastq2"
                },
                {
                    "doc": "Mean library fragment size, used to reconstruct entire \nfragments from single end reads. Not relevant in case of paired end data.\n",
                    "type": [
                        "null",
                        "int"
                    ],
                    "id": "#main/fragment_size"
                },
                {
                    "doc": "Path to reference genome in fasta format.\nBowtie2 index files (\".1.bt2\", \".2.bt2\", ...) as well as a samtools index (\".fai\")\nhas to be located in the same directory.\nAll of these files can be downloaded for the most common genome builds at \nhttps://support.illumina.com/sequencing/sequencing_software/igenome.html.\nAlternatively, you can use \"bowtie2-build\" or \"samtools index\" to create them yourself.\n",
                    "type": "File",
                    "secondaryFiles": [
                        ".fai",
                        "^.1.bt2",
                        "^.2.bt2",
                        "^.3.bt2",
                        "^.4.bt2",
                        "^.rev.1.bt2",
                        "^.rev.2.bt2"
                    ],
                    "id": "#main/genome"
                },
                {
                    "doc": "Path to reference of the spike-in organism in fasta format.\nBowtie2 index files (\".1.bt2\", \".2.bt2\", ...) as well as a samtools index (\".fai\")\nhas to be located in the same directory.\nAll of these files can be downloaded for the most common genome builds at \nhttps://support.illumina.com/sequencing/sequencing_software/igenome.html.\nAlternatively, you can use \"bowtie2-build\" or \"samtools index\" to create them yourself.\n",
                    "type": "File",
                    "secondaryFiles": [
                        ".fai",
                        "^.1.bt2",
                        "^.2.bt2",
                        "^.3.bt2",
                        "^.4.bt2",
                        "^.rev.1.bt2",
                        "^.rev.2.bt2"
                    ],
                    "id": "#main/genome_spike_in"
                },
                {
                    "doc": "List of space-delimited chromosome names that shall be ignored\nwhen calculating the scaling factor. \n",
                    "type": [
                        "null",
                        "string"
                    ],
                    "default": "chrX chrY chrM",
                    "id": "#main/ignoreForNormalization"
                },
                {
                    "doc": "If paired end data is used set to true, else set to false.\n",
                    "type": "boolean",
                    "id": "#main/is_paired_end"
                },
                {
                    "doc": "Sample ID used for naming the output files.\n",
                    "type": "string",
                    "id": "#main/sample_id"
                }
            ],
            "steps": [
                {
                    "run": "#chip_qc.cwl",
                    "in": [
                        {
                            "source": "#main/merge_filter/bam",
                            "id": "#main/chip_qc/bam"
                        },
                        {
                            "source": "#main/is_paired_end",
                            "id": "#main/chip_qc/is_paired_end"
                        },
                        {
                            "source": "#main/sample_id",
                            "id": "#main/chip_qc/sample_id"
                        },
                        {
                            "source": "#main/fragment_size",
                            "id": "#main/chip_qc/user_def_fragment_size"
                        }
                    ],
                    "out": [
                        "#main/chip_qc/qc_plot_coverage_plot",
                        "#main/chip_qc/qc_plot_coverage_tsv",
                        "#main/chip_qc/qc_plot_fingerprint_plot",
                        "#main/chip_qc/qc_plot_fingerprint_tsv",
                        "#main/chip_qc/qc_plot_fingerprint_stderr",
                        "#main/chip_qc/qc_crosscorr_summary",
                        "#main/chip_qc/qc_crosscorr_plot",
                        "#main/chip_qc/qc_phantompeakqualtools_stderr",
                        "#main/chip_qc/qc_phantompeakqualtools_stdout",
                        "#main/chip_qc/fragment_size"
                    ],
                    "id": "#main/chip_qc"
                },
                {
                    "doc": "multiqc summarizes the qc results from fastqc \nand other tools\n",
                    "run": "#multiqc_hack.cwl",
                    "in": [
                        {
                            "source": [
                                "#main/trim_and_map/bowtie2_log",
                                "#main/merge_filter/fastqc_zip",
                                "#main/merge_filter/fastqc_html",
                                "#main/chip_qc/qc_plot_coverage_tsv",
                                "#main/chip_qc/qc_plot_coverage_plot",
                                "#main/chip_qc/qc_plot_fingerprint_tsv",
                                "#main/chip_qc/qc_plot_fingerprint_plot",
                                "#main/chip_qc/qc_crosscorr_summary",
                                "#main/chip_qc/qc_crosscorr_plot",
                                "#main/chip_qc/qc_phantompeakqualtools_stdout",
                                "#main/chip_qc/qc_crosscorr_summary"
                            ],
                            "linkMerge": "merge_flattened",
                            "id": "#main/create_summary_qc_report/qc_files_array"
                        },
                        {
                            "source": [
                                "#main/trim_and_map/raw_fastqc_zip",
                                "#main/trim_and_map/raw_fastqc_html",
                                "#main/trim_and_map/trimmed_fastqc_html",
                                "#main/trim_and_map/trimmed_fastqc_zip",
                                "#main/trim_and_map/trim_galore_log"
                            ],
                            "linkMerge": "merge_flattened",
                            "id": "#main/create_summary_qc_report/qc_files_array_of_array"
                        },
                        {
                            "source": "#main/sample_id",
                            "id": "#main/create_summary_qc_report/report_name"
                        }
                    ],
                    "out": [
                        "#main/create_summary_qc_report/multiqc_zip",
                        "#main/create_summary_qc_report/multiqc_html"
                    ],
                    "id": "#main/create_summary_qc_report"
                },
                {
                    "run": "#deeptools_bamCoverage.cwl",
                    "in": [
                        {
                            "source": "#main/merge_filter/bam",
                            "id": "#main/generate_coverage_tracks/bam"
                        },
                        {
                            "source": "#main/bin_size",
                            "id": "#main/generate_coverage_tracks/bin_size"
                        },
                        {
                            "source": "#main/effective_genome_size",
                            "id": "#main/generate_coverage_tracks/effective_genome_size"
                        },
                        {
                            "source": "#main/chip_qc/fragment_size",
                            "id": "#main/generate_coverage_tracks/fragment_size"
                        },
                        {
                            "source": "#main/ignoreForNormalization",
                            "id": "#main/generate_coverage_tracks/ignoreForNormalization"
                        },
                        {
                            "source": "#main/is_paired_end",
                            "id": "#main/generate_coverage_tracks/is_paired_end"
                        },
                        {
                            "source": "#main/get_spike_in_counts/aln_read_count",
                            "id": "#main/generate_coverage_tracks/spike_in_count"
                        }
                    ],
                    "out": [
                        "#main/generate_coverage_tracks/bigwig"
                    ],
                    "id": "#main/generate_coverage_tracks"
                },
                {
                    "run": "#get_spike_in_counts.cwl",
                    "in": [
                        {
                            "source": "#main/trim_and_map/fastq1_trimmed",
                            "id": "#main/get_spike_in_counts/fastq1_trimmed"
                        },
                        {
                            "source": "#main/trim_and_map/fastq2_trimmed",
                            "id": "#main/get_spike_in_counts/fastq2_trimmed"
                        },
                        {
                            "source": "#main/genome_spike_in",
                            "id": "#main/get_spike_in_counts/genome_spike_in"
                        },
                        {
                            "source": "#main/is_paired_end",
                            "id": "#main/get_spike_in_counts/is_paired_end"
                        },
                        {
                            "source": "#main/sample_id",
                            "id": "#main/get_spike_in_counts/sample_id"
                        }
                    ],
                    "out": [
                        "#main/get_spike_in_counts/bam",
                        "#main/get_spike_in_counts/aln_read_count",
                        "#main/get_spike_in_counts/aln_read_count_file"
                    ],
                    "id": "#main/get_spike_in_counts"
                },
                {
                    "run": "#merge_filter.cwl",
                    "in": [
                        {
                            "source": "#main/trim_and_map/bam",
                            "id": "#main/merge_filter/bams"
                        },
                        {
                            "source": "#main/is_paired_end",
                            "id": "#main/merge_filter/is_paired_end"
                        },
                        {
                            "source": "#main/sample_id",
                            "id": "#main/merge_filter/sample_id"
                        }
                    ],
                    "out": [
                        "#main/merge_filter/fastqc_zip",
                        "#main/merge_filter/fastqc_html",
                        "#main/merge_filter/bam"
                    ],
                    "id": "#main/merge_filter"
                },
                {
                    "run": "#trim_and_map.cwl",
                    "scatter": [
                        "#main/trim_and_map/fastq1",
                        "#main/trim_and_map/fastq2"
                    ],
                    "scatterMethod": "dotproduct",
                    "in": [
                        {
                            "source": "#main/adapter1",
                            "id": "#main/trim_and_map/adapter1"
                        },
                        {
                            "source": "#main/adapter2",
                            "id": "#main/trim_and_map/adapter2"
                        },
                        {
                            "source": "#main/fastq1",
                            "id": "#main/trim_and_map/fastq1"
                        },
                        {
                            "source": "#main/fastq2",
                            "id": "#main/trim_and_map/fastq2"
                        },
                        {
                            "source": "#main/genome",
                            "id": "#main/trim_and_map/genome"
                        },
                        {
                            "source": "#main/is_paired_end",
                            "id": "#main/trim_and_map/is_paired_end"
                        }
                    ],
                    "out": [
                        "#main/trim_and_map/raw_fastqc_zip",
                        "#main/trim_and_map/raw_fastqc_html",
                        "#main/trim_and_map/fastq1_trimmed",
                        "#main/trim_and_map/fastq2_trimmed",
                        "#main/trim_and_map/trim_galore_log",
                        "#main/trim_and_map/trimmed_fastqc_html",
                        "#main/trim_and_map/trimmed_fastqc_zip",
                        "#main/trim_and_map/bam",
                        "#main/trim_and_map/bowtie2_log"
                    ],
                    "id": "#main/trim_and_map"
                }
            ],
            "outputs": [
                {
                    "type": "File",
                    "secondaryFiles": ".bai",
                    "outputSource": "#main/merge_filter/bam",
                    "id": "#main/bam"
                },
                {
                    "type": "File",
                    "outputSource": "#main/get_spike_in_counts/bam",
                    "id": "#main/bam_spike_in"
                },
                {
                    "type": "File",
                    "outputSource": "#main/generate_coverage_tracks/bigwig",
                    "id": "#main/bigwig"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/trim_and_map/bowtie2_log",
                    "id": "#main/bowtie2_log"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/merge_filter/fastqc_html",
                    "id": "#main/fastqc_html"
                },
                {
                    "type": {
                        "type": "array",
                        "items": "File"
                    },
                    "outputSource": "#main/merge_filter/fastqc_zip",
                    "id": "#main/fastqc_zip"
                },
                {
                    "type": "File",
                    "outputSource": "#main/create_summary_qc_report/multiqc_html",
                    "id": "#main/multiqc_html"
                },
                {
                    "type": "File",
                    "outputSource": "#main/create_summary_qc_report/multiqc_zip",
                    "id": "#main/multiqc_zip"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#main/chip_qc/qc_crosscorr_plot",
                    "id": "#main/qc_crosscorr_plot"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#main/chip_qc/qc_crosscorr_summary",
                    "id": "#main/qc_crosscorr_summary"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#main/chip_qc/qc_phantompeakqualtools_stderr",
                    "id": "#main/qc_phantompeakqualtools_stderr"
                },
                {
                    "type": "File",
                    "outputSource": "#main/chip_qc/qc_plot_coverage_plot",
                    "id": "#main/qc_plot_coverage_plot"
                },
                {
                    "type": "File",
                    "outputSource": "#main/chip_qc/qc_plot_coverage_tsv",
                    "id": "#main/qc_plot_coverage_tsv"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#main/chip_qc/qc_plot_fingerprint_plot",
                    "id": "#main/qc_plot_fingerprint_plot"
                },
                {
                    "type": "File",
                    "outputSource": "#main/chip_qc/qc_plot_fingerprint_stderr",
                    "id": "#main/qc_plot_fingerprint_stderr"
                },
                {
                    "type": [
                        "null",
                        "File"
                    ],
                    "outputSource": "#main/chip_qc/qc_plot_fingerprint_tsv",
                    "id": "#main/qc_plot_fingerprint_tsv"
                },
                {
                    "type": {
                        "type": "array",
                        "items": {
                            "type": "array",
                            "items": "File"
                        }
                    },
                    "outputSource": "#main/trim_and_map/raw_fastqc_html",
                    "id": "#main/raw_fastqc_html"
                },
                {
                    "type": {
                        "type": "array",
                        "items": {
                            "type": "array",
                            "items": "File"
                        }
                    },
                    "outputSource": "#main/trim_and_map/raw_fastqc_zip",
                    "id": "#main/raw_fastqc_zip"
                },
                {
                    "type": "File",
                    "outputSource": "#main/get_spike_in_counts/aln_read_count_file",
                    "id": "#main/spike_in_counts"
                },
                {
                    "type": {
                        "type": "array",
                        "items": {
                            "type": "array",
                            "items": "File"
                        }
                    },
                    "outputSource": "#main/trim_and_map/raw_fastqc_zip",
                    "id": "#main/trim_galore_log"
                },
                {
                    "type": {
                        "type": "array",
                        "items": {
                            "type": "array",
                            "items": "File"
                        }
                    },
                    "outputSource": "#main/trim_and_map/trimmed_fastqc_html",
                    "id": "#main/trimmed_fastqc_html"
                },
                {
                    "type": {
                        "type": "array",
                        "items": {
                            "type": "array",
                            "items": "File"
                        }
                    },
                    "outputSource": "#main/trim_and_map/trimmed_fastqc_zip",
                    "id": "#main/trimmed_fastqc_zip"
                }
            ],
            "id": "#main"
        }
    ],
    "cwlVersion": "v1.0"
}