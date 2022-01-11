
library(rtracklayer)
library(ballgown)
library(remotes)



#If not instaaled
install.packages("remotes")
remotes::install_github("openanalytics/gread")
BiocManager::install("ballgown")
BiocManager::install("rtracklayer")


#Convert to bed/csv format  using rtracklayer
z <- import("https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_39/gencode.v39.chr_patch_hapl_scaff.annotation.gtf.gz")

df<-data.frame(z)

write.csv(df,file='gencode.v39.chr_patch_hapl_scaff.annotation.csv',row.names=FALSE)

SelectedDf<-df[,c("seqnames", "start","end","width","strand" ,"type","gene_id","gene_type","gene_name")]
write.csv(SelectedDf,file='gencode.v39.chr_patch_hapl_scaff.annotation_SelectedFields.csv',row.names=FALSE)



#Add specific "attributes" column gtf file using ballgown

gffdata = gffRead("gencode.v39.chr_patch_hapl_scaff.annotation.gtf")

gffdata$transcriptID=getAttributeField(gffdata$attributes, field = "transcript_id")
gffdata$gene_biotype=getAttributeField(gffdata$attributes, field = "gene_biotype")
gffdata$gene_name=getAttributeField(gffdata$attributes, field = "gene_name")
gffdata$gene_id=getAttributeField(gffdata$attributes, field = "gene_id")





#Extract features from gtf/gff objects use gread ;;;; But installation is difficult

