# TCR-seq Analysis Pipeline
![NGS](https://img.shields.io/badge/NGS-TCR--seq-blue.svg)
![MiXCR](https://img.shields.io/badge/MiXCR-2.0+-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)

A comprehensive pipeline for analyzing T cell receptor (TCR) repertoire sequencing data, specifically optimized for human TCR-β chain analysis. This pipeline automates the workflow from raw FastQ files to clonotype identification using MiXCR.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Pipeline Steps](#pipeline-steps)
- [Output Structure](#output-structure)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

## Features
- Automated processing of paired-end TCR-seq data
- Barcode-based sample demultiplexing
- TCR alignment using MiXCR
- Clonotype assembly and export
- Support for multiple samples
- Parallel processing capabilities
- Comprehensive logging

## Prerequisites
- Java 8+
- Python 2.7+
- MiXCR 2.0+
- FASTX-Toolkit 0.0.14+
- Reference databases:
  - IMGT library (v201711-1 or later)
  - Human TCR references

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/TCRseq_Pipeline.git
cd TCRseq_Pipeline
```

2. Ensure all required modules are available:
```bash
module load java/8u66
module load python fastx_toolkit/0.0.14
```

3. Configure your project:
```bash
cp conf.txt.example conf.txt
# Edit conf.txt with your project-specific paths
```

## Usage

1. Prepare your sample barcode file:
```
# barcode.txt format
BARCODE1    sample1
BARCODE2    sample2
```

2. Set up configuration (`conf.txt`):
```bash
myRawDATADIR="/path/to/raw/fastq/files"
myDATADIR="/path/to/processed/data"
myPROJDIR="/path/to/project"
myTCRScriptDIR="/path/to/scripts"
mySampleFile="barcode.txt"
```

3. Run the pipeline:
```bash
./MixR_pipeline_human.sh
```

## Pipeline Steps

1. **Sample Preparation**
   - Merge paired-end reads
   - Remove random sequences
   - Split samples by barcodes
   
2. **Read Processing**
   - Separate reads into R1/R2
   - Quality filtering
   - Adapter trimming
   
3. **TCR Analysis** (MiXCR)
   - Alignment to reference sequences
   - Clonotype assembly
   - Clone export and quantification

## Output Structure
```
project_directory/
├── Analysis/
│   ├── align/              # MiXCR alignment files
│   │   └── sample_name/
│   │       ├── alignments.vdjca
│   │       └── alignmentReport.log
│   ├── assemble/          # Assembled clonotypes
│   │   └── sample_name/
│   │       ├── clones.clns
│   │       └── assembleReport.log
│   └── export/            # Final results
│       └── sample_name/
│           └── clones.txt
└── split_reads/           # Demultiplexed samples
```

## MiXCR Parameters

### Alignment
```bash
--species hsa              # Human species
--chains TRB              # TCR beta chain
--library imgt.201711-1.s # IMGT library version
--OvParameters.geneFeatureToAlign=VRegion
```

### Assembly
```bash
# Default assembly parameters for optimal clonotype detection
```

### Export
```bash
--chains TRB              # Export TCR beta chain results
```

## Configuration
Edit `conf.txt` to specify:

```bash
# Required paths
myRawDATADIR="/path/to/raw/data"     # Raw FastQ files
myDATADIR="/path/to/processed/data"   # Processed data
myPROJDIR="/path/to/project"          # Project directory
myTCRScriptDIR="/path/to/scripts"     # Analysis scripts
mySampleFile="barcode.txt"            # Sample barcodes

# Resource allocation
h_vmem="10G"                         # Memory per core
N_CPUS=6                            # Number of CPU cores
```

## Input Data Requirements

### FastQ Files
- Paired-end reads
- Naming convention: `*R1_001.fastq.gz`, `*R2_001.fastq.gz`

### Barcode File Format
```
AAGGTTCC    patient1
CCTTAAGG    patient2
```

## Troubleshooting

### Common Issues

1. **Memory Issues**
   - Increase h_vmem in script header
   - Process fewer samples in parallel
   - Check Java heap settings

2. **MiXCR Errors**
   - Verify IMGT library installation
   - Check input FastQ format
   - Validate species parameter

3. **Barcode Splitting Issues**
   - Verify barcode format
   - Check for contamination
   - Adjust mismatch tolerance

### Error Messages

- `MiXCR: command not found` - Check Java/MiXCR installation
- `Unable to split samples` - Verify barcode file format
- `Alignment failed` - Check input file quality

## Performance Optimization

1. **Resource Management**
   - Adjust CPU allocation
   - Optimize memory usage
   - Monitor disk I/O

2. **Processing Tips**
   - Split large batches
   - Clean intermediate files
   - Use SSD for temporary storage

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Citation
If you use this pipeline in your research, please cite:
```
Author et al. (Year). TCR-seq Pipeline: A comprehensive processing pipeline for T cell receptor repertoire analysis.
Repository: https://github.com/yourusername/TCRseq_Pipeline
```

## Related Tools
- [ATACseq_Pipeline](../ATACseq_Pipeline)
- [RNAseq_Pipeline](../RNAseq_Pipeline)

## Contributing
Contributions are welcome! Please read the contributing guidelines before submitting pull requests.

## Acknowledgments
- MiXCR development team
- IMGT database maintainers
- Supporting institutions and funding
