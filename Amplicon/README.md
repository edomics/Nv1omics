Amplicon Analysis

Create sample list
```
code for sample list - edit when new files arrive
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
***Use this when you get remaining samples from Jason ^

Create list of samples with >15,000 reads (excludes 6 samples with insufficient reads from further analysis)
```
wc -l *.cuta.fasta | awk '$1 > 30000' | grep -v "total" | awk '{print $2}' | sed -E 's/(.*).cuta.fasta/\1/' > sample.15k.list
```


