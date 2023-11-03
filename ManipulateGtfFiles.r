
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

selectdcols<-gffdata[,c("seqname","start", "end","strand","feature","gene_name","gene_id","gene_biotype")]
Gene<-selectdcols[selectdcols$feature =="gene", ]
#Gene<-lapply(Gene, gsub, pattern='"', replacement='')
write.csv(Gene,file='Rattus_norvegicus.mRatBN7.2.105_Gene.csv',row.names=FALSE)

system.cmd('sed -i 's/"//g' Rattus_norvegicus.mRatBN7.2.105_Gene.csv')



#Extract features from gtf/gff objects use gread ;;;; But installation is difficult






###########Get ntrons from gtf file


library(gread)

gtf_file <- file.path("/home/jibin/Downloads/Drosophila/", "Drosophila_melanogaster.BDGP6.32.106.gtf")
gtf <- read_format(gtf_file)

introns <- construct_introns(gtf, update=FALSE)
introns<-data.frame(introns)
introns_speciic$start<-as.numeric(introns_speciic$start)
introns_speciic<-introns_speciic[,c("seqnames","start","end","gene_name","score","strand")]


##Very good tool
gtftools=http://www.genemine.org/gtftools.php

##Python tools
AGEpy:   https://agepy.readthedocs.io/en/latest/modules/gtf/
gffpandas : https://gffpandas.readthedocs.io/en/latest/tutorial.html#example-tutorial





##rtracklayer
library(rtracklayer)

gtf <- import("gencode.v36.annotation.gtf")
gtf_df<-as.data.frame(gtf)
gtf_gene_df<-gtf_df[gtf_df$type=="gene",]
gtf_gene_df<-gtf_gene_df[,c("gene_id","seqnames","start","end","width","strand","gene_type","gene_name")]



### My custom python script

class GFFProcessor:
    def __init__(self, gff_file):
        self.gff_file = gff_file
        self.annotation_df = self.process_gff_file()
    
    attributes_list=[]
    
    def attribute_todf(row):
        Dict = row.to_dict()
        Dict_1 = {k: v for k, v in Dict.items() if k != "attributes"}
        attributes = row["attributes"]  # Extract the "attributes" column
        temp_list = attributes.split("; ")
        temp_dict = {x.split()[0].replace('"', ''): x.split()[1].replace(";", "").replace('"', '') for x in temp_list}
        Dict = {**Dict_1, **temp_dict}
        attributes_list.append(Dict)
        return Dict
    
    def process_gff_file(self):
        annotation = gffpd.read_gff3('gencode.v36.annotation.gtf')
        annotation_df=annotation.df
        annotation_df=annotation_df[annotation_df['type']=="gene"]
        annotation_df=annotation_df.drop(["phase","score",'source','type'],axis=1).reset_index(drop=True)
        annotation_df['Result'] = annotation_df.apply(attribute_todf, axis=1)
        annotation_df=pd.DataFrame(attributes_list)
        annotation_df=df.drop(['level','hgnc_id','havana_gene','tag'],axis=1)
        return annotation_df


gff_file = 'gencode.v36.annotation.gtf'
gff_processor = GFFProcessor(gff_file)
annotation_df = gff_processor.annotation_df


