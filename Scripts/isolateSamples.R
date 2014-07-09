###############################################################################
### When multiple GBS runs of the same accession exist, this script will    ###
### remove the run with less data.                                          ###
###############################################################################

### Timothy M. Beissinger

### Set working directory
setwd("/Users/beissinger/Documents/ParallelAdaptation/Data/Maize282_imputed_AllZea_GBS_Build_July_2012_FINAL")

### Begin loop
for(chr in 1:10){
print(chr)

### Load one chromosome, begin by trimming taxa of library information
chrXhead <- read.table(paste("Maize282_imputed_AllZea_GBS_Build_July_2012_FINAL_chr",chr,".hmp.txt",sep=""), header=F,stringsAsFactors=F,comment.char="",nrows=1)
chrXhead <- as.character(chrXhead) #convert to vector
chrXhead <- strsplit(chrXhead,split=":") #split at colon
chrXhead <- as.character(data.frame(chrXhead,stringsAsFactors=F)[1,])#pull taxa name (text before first colon)

chrX <- read.table(paste("Maize282_imputed_AllZea_GBS_Build_July_2012_FINAL_chr",chr,".hmp.txt",sep=""),stringsAsFactors=F,comment.char="",skip=1)  # read chr X data, skip header
names(chrX) <- chrXhead

### Loop to identify which columns to remove, runs from last column to first
rm <- c()
for(i in length(chrXhead):1){
    if(chrXhead[i] %in% chrXhead[{i-1}:1]) rm <- c(rm,i)
}

### Remove redundant taxa
chrX <- chrX[,-rm]

### Save unique taxa table
write.table(chrX,file=paste("../282_unique_taxa/chr_",chr,".txt",sep=""))

### End loop
}
