# RNA-seq reanalysis for Dr. Witt lab
# The input will be raw-count matrix
# The KO_3 sampels are hetero, will be removed for DE analysis
# The DESeq2 will be used for DE analysis, if you prefer Limma/ edgeR, I can re-run later
setwd("C:/Users/13831/OneDrive - LSU Health Shreveport/analysis for other labs/Siyuan analysis for witt lab")
raw=read.csv("raw_count.csv")
index=duplicated(raw$GeneSymbol)
summary(index)
#3581 genes with same gene symbol will be removed! 
data=raw[!index,]
rownames(data)=data$GeneSymbol
data=data[,-c(1:5)]
meta=data.frame(name = colnames(data),condition = c(rep("KO",time=9),rep("Control",time=5)))
rownames(meta)=colnames(data)
library(DESeq2)
data=na.omit(data)
dds=DESeqDataSetFromMatrix(data, colData=meta, design= ~ condition)
dds=DESeq(dds)
DE_result=results(dds)
summary(DE_result)
DE_result=as.data.frame(DE_result)
head(results(dds, tidy=TRUE))
write.csv(DE_result,"DE_result.csv")
write.csv(raw,"raw_count.csv")
# start drawing volcano plot
library(ggrepel)
library(EnhancedVolcano)
tiff("volcano plot.tiff",width = 18,height = 22,units = "cm",res = 600,compression = "lzw+p")
EnhancedVolcano(DE_result,lab = rownames(DE_result),x="log2FoldChange",y="padj",pCutoff = 0.000001,FCcutoff = 1,pointSize = 1,colAlpha = 1,
                   selectLab = c("IL1B","IGFBP5","SAA1","CXCL10","CXCL3","PCSK2","PSD2","PIP4K2A","EIF4EBP2","IGFBP2"),drawConnectors = T)
dev.off()
dev.new()
# filter the significant DE genes
DE_sig=subset(DE_result,(abs(log2FoldChange)>1)&(padj<0.05)) # cutoff: abs log2FC>1 and padj<0.05
write.csv(DE_sig,"Significant DE genes.csv")
# The TPM file will be used as input for heatmaps
DE_sig=read.csv("Significant DE genes.csv")
rownames(DE_sig)=DE_sig$X
tpm=read.csv("TPM.csv")
rownames(tpm)=tpm$X
colnames(tpm)
tpm=tpm[,-c(1:4)]
tpm=tpm[,c(10:14,1:9)]
go=read.csv("QuickGO-annotations-locomotion.csv")
go=as.character(go$SYMBOL)
go=unique(go)
hm=intersect(rownames(DE_sig),go)
hm=tpm[hm,]
library(pheatmap)
tiff("locomotion.tiff",width = 9,height = 26,res = 1200,units = "cm")
pheatmap(hm,cluster_cols = F,color = colorRampPalette(c("navy", "white", "firebrick3"))(50),scale = "row")
dev.off()
# another GO item
go=read.csv("QuickGO-annotations-inflam.csv")
go=as.character(go$SYMBOL)
go=unique(go)
hm=intersect(rownames(DE_sig),go)
hm=tpm[hm,]
library(pheatmap)
tiff("inflammatory response.tiff",width = 9,height = 30,res = 1200,units = "cm")
pheatmap(hm,cluster_cols = F,color = colorRampPalette(c("navy", "white", "firebrick3"))(50),scale = "row")
dev.off()


go=read.csv("NABA_MATRISOME_ASSOCIATED.csv")
go=as.character(go$NABA_MATRISOME_ASSOCIATED)
go=unique(go)
hm=intersect(rownames(DE_sig),go)
hm=tpm[hm,]
tiff("NABA_MATRISOME_ASSOCIATED.tif", width = 9, height = 40, res = 1200, units = "cm")
pheatmap(hm, cluster_cols = FALSE, color = colorRampPalette(c("navy", "white", "firebrick3"))(50), scale = "row", compression = "packbits")
dev.off()


panther=read.csv(file.choose())
panther=as.character(panther$Gene.Symbol)
hm=tpm[panther,]

tiff("Inflammation mediated by chemokine and cytokine signaling pathway.tiff",width = 18,height = 18,res = 1200,units = "cm")
pheatmap(hm,cluster_cols = F,color = colorRampPalette(c("navy", "white", "firebrick3"))(50),scale = "row")
dev.off()
go=read.csv(file.choose())
go=as.character(go$SYMBOL)
go=unique(go)
hm=intersect(rownames(DE_sig),go)
hm=tpm[hm,]
tiff("regulation of inflammatory response.tiff",width = 9,height = 22,res = 1200,units = "cm")
pheatmap(hm,cluster_cols = F,color = colorRampPalette(c("navy", "white", "firebrick3"))(50),scale = "row")
dev.off()

# now count the number of DE genes

DE_result=read.csv("DE_result.csv")
# for the vocanoplot, the adj pvalue cutoff is 0.000001, log2FC=1
desig=subset(DE_result,(padj<0.000001)&(abs(log2FoldChange)>1))
desig_pos=subset(desig,log2FoldChange>1)
desig_neg=subset(desig,log2FoldChange<(-1))
# now pickup the de genes fits nucleli
nuc=read.csv("nucleoli.csv")
de_ko8=read.csv("ko8vscrisprcontrol.csv")
nuc=merge(nuc,de_ko8,by.x = "Gene.name",by.y = "GeneSymbol")
nuc=subset(nuc,(PValue<0.05)&(abs(log2FC)>1))
nuc$mean_count=apply(nuc[,c(10:26)],1,mean)
nuc=nuc[,-c(10:26)]
write.csv(nuc,"nucleoli_KO8_DEgene.csv")





