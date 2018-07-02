#!/bin/bash
#$ -cwd
#$ -j y
#$ -l h_vmem=10G
#$ -pe shm 6
#$ -l h_rt=6:00:00
#$ -A projects_goronzy
#$ -m ea
#$ -M jadhav@stanford.edu

#print the time and date
echo Starting: $(date)

#-------------------------------#
#initialize job context         #
#-------------------------------#

module load java/8u66
module load python fastx_toolkit/0.0.14

### Use the bashprofile to set all paths
source /srv/gsfs0/projects/goronzy/TCR-seq_Pipeline/Claire_Data/scripts/.bash_profile

myRawDATADIR="/srv/gsfs0/projects/goronzy/TCR-seq_Pipeline/Austin_Twins_Tim/raw/TestRun"
myDATADIR="/srv/gsfs0/projects/goronzy/TCR-seq_Pipeline/Austin_Twins_Tim/raw/TestRun"
myPROJDIR="/srv/gsfs0/projects/goronzy/TCR-seq_Pipeline/Austin_Twins_Tim/Analysis/TestRun"
myQsubScriptDIR="/srv/gsfs0/projects/goronzy/TCR-seq_Pipeline/Austin_Twins_Tim/qsub_scripts"
myTCRScriptDIR="/srv/gsfs0/projects/goronzy/TCR-seq_Pipeline/TCR-seq_Pipeline/TCR_scripts"
mySampleFile="${myRawDATADIR}/Test.txt"

##-----------------------------##
##create FolderLayout          ##
##-----------------------------##
function createFolderLayout()
{
###be aware of the input parameter
###${1} --- means the ${jobSample}

myAnalyDIR="${myPROJDIR}/Analysis"
if [ ! -d "${myAnalyDIR}" ]
then
echo "${myAnalyDIR} does not exist, creating it now."
tmpCMDSTR="mkdir ${myAnalyDIR}"
eval "${tmpCMDSTR}"
else
echo "${myAnalyDIR} already exist, just use it."
fi


myAlignDIR="${myAnalyDIR}/align"
if [ ! -d "${myAlignDIR}" ]
then
echo "${myAlignDIR} does not exist, creating it now."
#tmpCMDSTR="mkdir ${myAlignDIR}; mkdir ${myAlignDIR}/${1}"
tmpCMDSTR="mkdir ${myAlignDIR}; mkdir ${myAlignDIR}/${jobSample}"
eval "${tmpCMDSTR}"
else
echo "${myAlignDIR} already exist, just use it."
#####for each sample#####
#sampletrimDir=${mytrimDIR}/${1}
samplealignDir=${myAlignDIR}/${jobSample}
if [ ! -d "${samplealignDir}" ]
then
echo "${samplealignDir} does not exist, creating it now."
tmpCMDSTR="mkdir ${samplealignDir}"
eval "${tmpCMDSTR}"
else
echo "${samplealignDir} already exist, just use it."
fi
fi

myassembleDIR="${myAnalyDIR}/assemble"
if [ ! -d "${myassembleDIR}" ]
then
echo "${myassembleDIR} does not exist, creating it now."
#tmpCMDSTR="mkdir ${myassembleDIR}; mkdir ${myassembleDIR}/${1}"
tmpCMDSTR="mkdir ${myassembleDIR}; mkdir ${myassembleDIR}/${jobSample}"
eval "${tmpCMDSTR}"
else
echo "${myassembleDIR} already exist, just use it."
#####for each sample#####
#sampletrimDir=${mytrimDIR}/${1}
sampleassembleDir=${myassembleDIR}/${jobSample}
if [ ! -d "${sampleassembleDir}" ]
then
echo "${sampleassembleDir} does not exist, creating it now."
tmpCMDSTR="mkdir ${sampleassembleDir}"
eval "${tmpCMDSTR}"
else
echo "${sampleassembleDir} already exist, just use it."
fi
fi

myexportDIR="${myAnalyDIR}/export"
if [ ! -d "${myexportDIR}" ]
then
echo "${myexportDIR} does not exist, creating it now."
#tmpCMDSTR="mkdir ${myexportDIR}; mkdir ${myexportDIR}/${1}"
tmpCMDSTR="mkdir ${myexportDIR}; mkdir ${myexportDIR}/${jobSample}"
eval "${tmpCMDSTR}"
else
echo "${myexportDIR} already exist, just use it."
#####for each sample#####
#sampletrimDir=${myexportDIR}/${1}
sampleexportDir=${myexportDIR}/${jobSample}
if [ ! -d "${sampleexportDir}" ]
then
echo "${sampleexportDir} does not exist, creating it now."
tmpCMDSTR="mkdir ${sampleexportDir}"
eval "${tmpCMDSTR}"
else
echo "${sampleexportDir} already exist, just use it."
fi
fi

}

##-----------------------------##
##run SampleSplitting          ##
##-----------------------------##
function runSampleSplitting()
{
tempRead1="${myRawDATADIR}/*R1_001.fastq"
tempRead2="${myRawDATADIR}/*R2_001.fastq"
tempname=$(echo ${tempRead1})
RunName=$(echo $(basename "${tempname}" ".fastq") | cut -d'_' -f 1,2,3)
echo "Processing Run ${RunName}"

# Merge Paired Reads
ReadMergeCMD="paste ${tempRead1} ${tempRead2} | python ${myTCRScriptDIR}/merge.py > ${myRawDATADIR}/${RunName}_pe.fastq"
echo ${ReadMergeCMD}
eval ${ReadMergeCMD}

# remove random sequences (1st 4 nucleotides)
mergedReads="${myRawDATADIR}/${RunName}_pe.fastq"
RemoveRandom="python ${myTCRScriptDIR}/trim.py ${mergedReads} 4 500 > ${myRawDATADIR}/${RunName}_pe.trim.fastq"
echo ${RemoveRandom}
eval ${RemoveRandom}


# split reads according to barcode, remove first 12 nucleotides from read 2
# for this step, you need to create a specific barcode.txt file that has the correct barcodes for each sample

#First, creating new folder called Raw_Samples
myAnalyDIR="${myPROJDIR}/Analysis"
if [ ! -d "${myAnalyDIR}" ]
then
echo "${myAnalyDIR} does not exist, creating it now."
tmpCMDSTR="mkdir ${myAnalyDIR}"
eval "${tmpCMDSTR}"
else
echo "${myAnalyDIR} already exist, just use it."
fi

mySamplesDIR="${myPROJDIR}/split_reads"
if [ ! -d "${mySamplesDIR}" ]
then
echo "${mySamplesDIR} does not exist, creating it now."
tmpCMDSTR="mkdir ${mySamplesDIR}"
eval "${tmpCMDSTR}"
else
echo "${mySamplesDIR} already exist, just use it."
fi

trimmedReads="${myRawDATADIR}/${RunName}_pe.trim.fastq"
# Splitting the Samples
SampleSplitCMD="cat ${trimmedReads} | fastx_barcode_splitter.pl --suffix ".fastq" --bol --bcfile ${mySampleFile} --prefix ${myDATADIR}/patient --mismatches 1"
echo ${SampleSplitCMD}
eval ${SampleSplitCMD}

### separate reads into two read files ###
files2splitPath="${myDATADIR}/*.fastq"
for filename in ${files2splitPath}
do
SeparateReadsCMD="python ${myTCRScriptDIR}/split.py ${filename}"
echo ${SeparateReadsCMD}
eval ${SeparateReadsCMD}
done

}

##-----------------------------##
##run Align                    ##
##-----------------------------##
function runAlign()
{

tempRead1="${myDATADIR}/${jobSample}_R1_001.fastq"
tempRead2="${myDATADIR}/${jobSample}_R2_001.fastq"
echo ${tempRead1}
AlignCMD="mixcr align --species hsa --chains TRB --library imgt.201711-1.s -OvParameters.geneFeatureToAlign=VRegion --report ${myPROJDIR}/Analysis/align/${jobSample}/${jobSample}_alignmentReport.log ${tempRead1} ${tempRead2} ${myPROJDIR}/Analysis/align/${jobSample}/${jobSample}_alignments.vdjca"
echo ${AlignCMD}
eval ${AlignCMD}

}

##-----------------------------##
##run Assemble                 ##
##-----------------------------##
function runAssemble()
{

tempRead="${myPROJDIR}/Analysis/align/${jobSample}/${jobSample}_alignments.vdjca"

AssembleCMD="mixcr assemble --report ${myPROJDIR}/Analysis/assemble/${jobSample}/${jobSample}_assembleReport.log ${tempRead} ${myPROJDIR}/Analysis/assemble/${jobSample}/${jobSample}_clones.clns"
echo ${AssembleCMD}
eval ${AssembleCMD}

}

##-----------------------------##
##run Export Clones            ##
##-----------------------------##
function runExport()
{

tempRead="${myPROJDIR}/Analysis/assemble/${jobSample}/${jobSample}_clones.clns"

ExportCMD="mixcr exportClones --chains TRB ${tempRead} ${myPROJDIR}/Analysis/export/${jobSample}/${jobSample}_clones.txt"
echo ${ExportCMD}
eval ${ExportCMD}

}

##-----------------------------##
##run Gunzip      ##
##-----------------------------##
function runGzip()
{

tempRead1="${myRawDATADIR}/*R1_001.fastq.gz"
tempRead2="${myRawDATADIR}/*R2_001.fastq.gz"

if [ ! -f "${tempRead1}" ]
then
    echo "No GZ File1.."
    echo ${tempRead1}
else
    GZIPCMD1="gzip -d ${tempRead1}"
    echo ${GZIPCMD1}
    eval ${GZIPCMD1}
fi

if [ ! -f "${tempRead2}" ]
then
    echo "No GZ File2.."
    echo ${tempRead2}
else
    GZIPCMD2="gzip -d ${tempRead2}"
    echo ${GZIPCMD2}
    eval ${GZIPCMD2}
fi
}



#-------------------------------#
#starting job specification     #
#-------------------------------#

#runGzip
#runSampleSplitting

IFS=$'\r\n' GLOBIGNORE='*' command eval  'mySampleArray=($(cut -f 1 ${mySampleFile}))' #sample-index mapping

for i in "${mySampleArray[@]}"
do
jobSample=$i
echo ${jobSample}
createFolderLayout ${jobSample}
runAlign ${jobSample}
runAssemble ${jobSample}
runExport ${jobSample}

done

#print the time and date again
echo Ending: $(date)

