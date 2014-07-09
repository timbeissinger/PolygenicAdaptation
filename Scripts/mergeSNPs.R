###############################################################################
### This script will identify SNPs that are in both the highlow dataset and ###
### the maize282 dataset. #####################################################
###############################################################################

### Timothy M. Beissinger

### Set working directory
setwd("/Users/beissinger/Documents/ParallelAdaptation/Data")

### Start loop
for(chr in 1:10){
    print(chr)
### Load chr
chrXhighlow <- read.table(paste("highlow_gbs_hapmaps 2/C08JYACXX_2_c",chr,".hmp.txt",sep=""),header=T,comment.char="",stringsAsFactors=F)

chrXames <- read.table(paste("282_unique_taxa/chr_",chr,".txt",sep=""),header=T,stringsAsFactors=F,comment.char="")

### Identify overlapping markers
overlap <- intersect(chrXames$pos,chrXhighlow$pos)

### Reduce markers in each matrix to only those in both sets
chrXhighlow <- chrXhighlow[which(chrXhighlow$pos %in% overlap),]
chrXames <- chrXames[which(chrXames$pos %in% overlap),]

### Save tables as R object
save(chrXames,file=paste("highlow_ames_reduced_snps/chr",chr,"ames.Robj",sep=""))
save(chrXhighlow,file=paste("highlow_ames_reduced_snps/chr",chr,"highlow.Robj",sep=""))


### End loop
 }
