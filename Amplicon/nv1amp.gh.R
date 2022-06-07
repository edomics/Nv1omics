library(reshape2)
library(ggplot2)
library(RColorBrewer)
library(ComplexHeatmap)
library(circlize)

#amplicon processing

#read in long format table
dat=read.table("nv1.amp.variants.count.table.long",header=FALSE)

#convert into matrix format
datm=dcast(dat,V1~V3,value.var = "V2")
#move sample names to row names
datm2=as.matrix(datm[-1])
row.names(datm2)=datm[,1]

#turn NAs into zeros
datm2[is.na(datm2)]=0

#get site names from sample labels
env=as.factor(substr(row.names(datm2),1,2))
envn=as.numeric(env)

#order variants based on presence in different haplotypes
colorder=as.character(c(1,2,3,4,5,7,25,28,13,14,15,16,17,29,30,6,8,9,10,11,12,20,27,18,19,21,22,23,24,26))

#annotate rows based on sampling location
har=rowAnnotation(pop=env,col=list(pop=c("MA"="#E41A1C","ME"="#377EB8","NC"="#4DAF4A","NH"="#984EA3","NS"="#FF7F00")))
#create shading gradient
col_fun = colorRamp2(c(0, max(dat$V2)), c("white", "black"))
#plot heatmap
Heatmap(datm2[,colorder],col=col_fun,show_row_names = FALSE,row_split = 8, clustering_distance_rows = "spearman", cluster_columns = FALSE, column_order = colorder, left_annotation = har, row_title = c("H3/H4","H4/H4","H2/H3","H3/H3","H1/H3","H1/H1","H2/H2","H1/H2"), row_title_rot=0, row_title_side = "right", row_title_gp = gpar(fontsize=10), row_gap = unit(1.8, "mm"), width = unit(10, "cm"), height = unit(18, "cm"))

#bubbleplot

#read genotype count table
hethom=read.table("HetHom.table.tsv",header=TRUE)
#order sites North to South
hethom$Site=factor(hethom$Site,levels = c("NS","ME","NH","MA","NC"))
#create bubble plot
ggplot(hethom,aes(Hap1,Hap2, color=Site))+geom_count(aes(size=Proportion))+facet_grid(~Site)+scale_color_manual(values=c("#FF7F00","#377EB8","#984EA3","#E41A1C","#4DAF4A"))









