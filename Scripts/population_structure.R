###############################################################################
### Use this script to determin population structure in the ames panel and  ###
### then in the high-low panel                                              ###
###############################################################################

### Timothy M. Beissinger

### Load packages
library(adegenet)

### Set working directory
setwd("/Users/beissinger/Documents/ParallelAdaptation/Data/highlow_ames_reduced_snps")

### Load data
for(i in 1:10){
 print(i)
 load(paste("chr",i,"ames.Robj",sep=""))
 assign(paste("chr",i,"ames",sep=""),chrXames)
}

amesData <- rbind(chr1ames,chr2ames,chr3ames,chr4ames,chr5ames,chr6ames,chr7ames,chr8ames,chr9ames,chr10ames) ### paste all ames data together


### Make a matrix of full ames data
fullAmesMatrix <- as.matrix(amesData[,11:ncol(amesData)])

### Replace hapmap code with nucleotides...
fullAmesMatrix[which(fullAmesMatrix=="N")] <- NA
fullAmesMatrix[which(fullAmesMatrix=="X")] <- NA
fullAmesMatrix[which(fullAmesMatrix=="A")] <- "A/A"
fullAmesMatrix[which(fullAmesMatrix=="C")] <- "C/C"
fullAmesMatrix[which(fullAmesMatrix=="G")] <- "G/G"
fullAmesMatrix[which(fullAmesMatrix=="T")] <- "T/T"
fullAmesMatrix[which(fullAmesMatrix=="K")] <- "G/T"
fullAmesMatrix[which(fullAmesMatrix=="M")] <- "A/C"
fullAmesMatrix[which(fullAmesMatrix=="R")] <- "A/G"
fullAmesMatrix[which(fullAmesMatrix=="S")] <- "C/G"
fullAmesMatrix[which(fullAmesMatrix=="W")] <- "A/T"
fullAmesMatrix[which(fullAmesMatrix=="Y")] <- "C/T"

### Determine which markers are NOT polymporphic
isPolymorphic <- function(data){
    if(length(table(data)) > 1) return(TRUE)
    else return(FALSE)
}

poly <- apply(fullAmesMatrix,1,isPolymorphic) # vector of polymorphic loci

### Pick 10,000 SNPs to use for structure ### DO NOT USE SNPS THAT ARE COMPLETELY MISSING!!!
snpIndex <- sample(which(poly==T),size=10000)
snpIndex <- snpIndex[order(as.numeric(snpIndex))]
amesSub <- fullAmesMatrix[snpIndex,]

### Format ames matrix into a data frame with colnames equal to pos, rownames equal to taxa,
### and no additional data
ames <- data.frame(t(amesSub),stringsAsFactors=F)
colnames(ames) <- amesData$pos[snpIndex]

### Read in heterotic information
popData <- read.table("../Data/ames_heterotic.txt",header=T,stringsAsFactors=F,sep="\t")
heterotic <- popData[1:151,c("Inbred","Subpopulation")]

### Make a table of heterotic group membership that corresponds to the ames data frame
individuals <- data.frame(row.names(ames),stringsAsFactors=F)
names(individuals) <- "Inbred"
membership <- merge(individuals,heterotic,by="Inbred",all.x=T,sort.y=T)

### Order ames df to match membership df
ames <- ames[order(individuals$Inbred),]

### Make ames genind object
amesGenind <- df2genind(ames,ploidy=2,sep="/",ind.names=rownames(ames),pop=membership$Subpopulation,missing="mean")

### Make ames matrix
amesMat <- scaleGen(amesGenind,missing="mean")

### Perform PCA
amesPCA <- dudi.pca(amesMat,cent=F,scale=F,scannf=F,nf=2) # calculate principal components
barplot(amesPCA$eig[1:25],main="Ames PCA eigenvalues",col=heat.colors)

### Plot PCA ###
pdf("amesPCA.pdf")
### Set colors ###
pca.colors <- as.numeric(amesGenind$pop)
#plot(amesPCA$li[,1],amesPCA$li[,2],cex=2,xlab="PC 1",ylab="PC 2",col=pca.colors)
plot(amesPCA$li[,1],amesPCA$li[,2],cex=1,pch=19,xlab="PC 1",ylab="PC 2",col=pca.colors)
title("PCA of Ames Panel, axes 1 & 2")
abline(v=0,h=0,col="grey")
legend("topright","(x,y)",c("NSS","Mixed","TS","SS","Sweet","Popcorn"),col=1:6,pch=19)
dev.off()


################### PCA On highlow    ###########################


### Load highlow data
for(i in 1:10){
 print(i)
 load(paste("chr",i,"highlow.Robj",sep=""))
 assign(paste("chr",i,"highlow",sep=""),chrXhighlow)
}

highlowData <- rbind(chr1highlow,chr2highlow,chr3highlow,chr4highlow,chr5highlow,chr6highlow,chr7highlow,chr8highlow,chr9highlow,chr10highlow) ### paste all ames data together

### Pick 10,000 SNPs to use for structure
### snpIndex <- sample(nrow(amesData),size=10000) ### KEEP SAME AS BEFORE!!!
### snpIndex <- snpIndex[order(snpIndex)]  ### KEEP SAME AS BEFORE!!!
highlowSub <- highlowData[snpIndex,]

### Replace hapmap code with nucleotides...
highlowSubMat <- as.matrix(highlowSub)
highlowSubMat[which(highlowSubMat=="N")] <- NA
highlowSubMat[which(highlowSubMat=="X")] <- NA
highlowSubMat[which(highlowSubMat=="A")] <- "A/A"
highlowSubMat[which(highlowSubMat=="C")] <- "C/C"
highlowSubMat[which(highlowSubMat=="G")] <- "G/G"
highlowSubMat[which(highlowSubMat=="T")] <- "T/T"
highlowSubMat[which(highlowSubMat=="K")] <- "G/T"
highlowSubMat[which(highlowSubMat=="M")] <- "A/C"
highlowSubMat[which(highlowSubMat=="R")] <- "A/G"
highlowSubMat[which(highlowSubMat=="S")] <- "C/G"
highlowSubMat[which(highlowSubMat=="W")] <- "A/T"
highlowSubMat[which(highlowSubMat=="Y")] <- "C/T"

### Format highlow matrix into a data frame with colnames equal to "pos", rownames equal to taxa,
### and no additional data
highlow <- data.frame(t(highlowSubMat[,5:ncol(highlowSubMat)]),stringsAsFactors=F)
colnames(highlow) <- highlowSub$pos

### Create population membership matrix (BY HAND!)
#highlowMembership <- cbind(rownames(highlow),NULL)
#fix(highlowMembership)
load("../Data/highlowMembership.Robj")

### Make highlow genind object
highlowGenind <- df2genind(highlow,ploidy=2,sep="/",ind.names=rownames(highlow))

### Make ames matrix
highlowMat <- scaleGen(highlowGenind,missing="mean")


### Perform PCA
highlowPCA <- dudi.pca(highlowMat,cent=F,scale=F,scannf=F,nf=2) # calculate principal components
barplot(highlowPCA$eig[1:25],main="Ames PCA eigenvalues",col=heat.colors)


### Plot PCA ###
pdf("highlowPCA.pdf")
### Set colors ###
pca.colors <- as.numeric(as.factor(highlowMembership[,2]))
#plot(highlowPCA$li[,1],highlowPCA$li[,2],cex=2,xlab="PC 1",ylab="PC 2",transp=T)
plot(highlowPCA$li[,1],highlowPCA$li[,2],cex=1,pch=19,xlab="PC 1",ylab="PC 2",col=pca.colors)
title("PCA of highlow inds, axes 1 & 2")
abline(v=0,h=0,col="grey")
legend("topright","(x,y)",c("Mex High","Mex Low","SA High","SA Low"),col=1:4,pch=19)
dev.off()

################### Project highlow onto Ames PCA ##############
foo <- amesPCA$c1[,1] %*% highlowMat


################### PCA ON Ames panel and highlow    ###########################

###Paste data together
allTaxa <- rbind(ames,highlow)
allsubpops <- c(membership$Subpopulation,highlowMembership[,2])

### Make highlow genind object
allGenind <- df2genind(allTaxa,ploidy=2,sep="/",ind.names=rownames(allTaxa),pop=allsubpops)


### Make ames matrix
allMat <- scaleGen(allGenind,missing="mean")

### Perform PCA
allPCA <- dudi.pca(allMat,cent=F,scale=F,scannf=F,nf=3) # calculate principal components
barplot(allPCA$eig[1:25],main="All inds PCA eigenvalues",col=heat.colors)


### Plot PCA ###
pdf("allindsPCA.pdf")
### Plot eigenvalues
barplot(allPCA$eig[1:25],main="All inds PCA eigenvalues",col=heat.colors)
### Set colors ###
pca.colors <- rainbow(10)[as.numeric(as.factor(allsubpops))]
#Plot 1 & 2
plot(allPCA$li[,1],allPCA$li[,2],cex=1,pch=19,xlab="PC 1",ylab="PC 2",col=pca.colors)
title("PCA of all inds, axes 1 & 2")
abline(v=0,h=0,col="grey")
legend("topright","(x,y)",levels(as.factor(allsubpops)),col=rainbow(10),pch=19)
#plot 1 & 3
plot(allPCA$li[,1],allPCA$li[,3],cex=1,pch=19,xlab="PC 1",ylab="PC 3",col=pca.colors)
title("PCA of all inds, axes 1 & 3")
abline(v=0,h=0,col="grey")
legend("top","(x,y)",levels(as.factor(allsubpops)),col=rainbow(10),pch=19)
# plot 2 & 3
plot(allPCA$li[,2],allPCA$li[,3],cex=1,pch=19,xlab="PC 2",ylab="PC 3",col=pca.colors)
title("PCA of all inds, axes 2 & 3")
abline(v=0,h=0,col="grey")
legend("topright","(x,y)",levels(as.factor(allsubpops)),col=rainbow(10),pch=19)
#close device
dev.off()

######## SCRATCH ##############
pdf("highlowProjectedToAmes.pdf")
### Project ames structure onto ames
amespc1 <- amesMat %*% amesPCA$c1[,1]
amespc2 <- amesMat %*% amesPCA$c1[,2]
### Project highlow structure onto ames
hlPC1 <- highlowMat %*% amesPCA$c1[,1]
hlPC2 <- highlowMat %*% amesPCA$c1[,2]
### Rbind
pc1 <- rbind(amespc1,hlPC1)
pc2 <- rbind(amespc2,hlPC2)
pca.colors <- rainbow(10)[as.numeric(as.factor(allsubpops))]
pca.pch <- as.numeric(as.factor(allsubpops))
plot(pc1,pc2,cex=1,pch=as.numeric(as.factor(allsubpops)),xlab="AMES PC 1",ylab="AMES PC 2",col=pca.colors)
title("Ames PC coordinates with highland & lowland projected")
legend("topright","(x,y)",levels(as.factor(allsubpops)),col=rainbow(10),pch=1:10,ncol=2)
dev.off()

### Save image
save.image("PCA.RData")
