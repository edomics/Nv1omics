# Amplicon Analysis

Create sample list
```
ls *.R1.fastq.gz | sed -E 's/.R1.fastq.gz//' > sample.list
```

Create sample file for mothur
```
while read sample; do echo "../"$sample".R1.fastq.gz	../"$sample".R2.fastq.gz" > $sample.file; done < sample.list
```

Join overlapping reads to form contigs using mothur make.contigs
```
while read sample; do mothur "#make.contigs(file=$sample.file)"; done < sample.list
```

Filter for reads 300-500bp long with no ambiguous bases
```
while read sample; do mothur "#make.contigs(file=$sample.file)"; done < sample.list
```

Use cutadapt to remove primer sequences
```
while read sample; do cutadapt --trimmed-only -a ^AGAACATGGCCTCGTTCAAG...TTGGGCTACATGTTTAGCTAG$ -o $sample.cuta.fasta $sample.trim.contigs.trim.fasta; done < sample.list
```

Create a list of sample read abundance
```
wc -l *.cuta.fasta | awk '{print $1/2"\t"$2}' | sort -n -k1,1 | grep -v "total" > sample.read.abun
```

From this, we can see that a 156/160 samples have at least 14,800 reads so we'll use this as our threshold.
Create a new sample list of samples with >= 14,800 reads (excludes 4 samples with insufficient reads from further analysis)
```
cat sample.read.abun | awk '$1 >= 14800' | cut -f2 | sed -E 's/.cuta.fasta//' > sample.thresd.list
```

Resample without replacement all fasta files to create fasta files for all individuals with the same read depth (14,800).
```
while read sample; do seqkit shuffle -s 1984 $sample.cuta.fasta | seqkit seq -w0 | head -29600 > $sample.norm.fasta; done < sample.thresd.list
```


Calculate the abundance of the 30 most abundant sequences in each individual.
```
while read sample; do cat $sample.norm.fasta | grep -v ">" | sort | uniq -c | awk '{print $1}' | sort -k1,1nr | head -30 | awk -v sample=$sample '{print sample"\t"NR"\t"$1}'; done > read.abun.thresd < sample.thresd.list
```

Can plot this in R:
```
library(ggplot2)
abunread=read.table("read.abun.15k",header=FALSE)
ggplot(abunread,aes(V2,V3))+geom_line(aes(color=V1))+theme(legend.position = "none")+xlim(c(0,16))+xlab("Rank")+ylab("Abundance")
```

![plot](rank.read.abun.plot.png)

![plot](rank.read.abun.plot.png)

![plot](./rank.read.abun.png)

Identify filtering threshold. I.e. abundance in a sample should be >= X and present in more than one sample.
```
while read sample; do cat $sample.norm.fasta | grep -v ">" | sort | uniq -c | awk '$1 >= 300'; done < sample.thresd.list | awk '{print $2}' | sort | uniq -c | sort -k1,1nr | awk '$1 > 1' | wc -l
```


