NC haplotypes required independent assembly

Validation of the NC assembly identified that haplotypes had been merged during the assembly and thus required independent assembly. Looking at the raw reads, it is possible to see that the intergenic spacing between Nv1 variants differs between the two haplotypes. 

IMAGE

Using these intergenic spacings, it is possible to separate the raw reads into those that can be identified as belonging to one haplotype or the other (reads that could not be unambiguously assigned were discarded) - these are stored in files hap1.read.ids and hap2.read.ids. Below hap1 is used as an example.

Use read id files to subset original raw fastq

```
seqkit grep -f hap1.read.ids nc10.raw.fastq | seqkit fq2fa | seqkit seq -w0 > hap1.read.fasta
```

Using CANUv2.1, assemble the Nv1 locus using the haplotype specific reads

```
canu -d NC10.nv1hap1 -p nc10.nv1hap1 genomeSize=30k useGrid=true gridOptions="--partition=Pisces --time=12:00:00" -gridOptionscns="--mem-per-cpu=3600m" minReadLength=1000 corOutCoverage=100 trimReadsCoverage=1 -nanopore hap1.read.fasta
```

The assembled Nv1tig can then be polished using racon

```
minimap2 nc10.nv1hap1.contigs.fasta hap1.read.fasta > hap1r.vs.hap1a.paf
racon hap1.read.fasta hap1r.vs.hap1a.paf nc10.nv1hap1.contigs.fasta > nc10.nv1hap1.con1.fasta

```

The assembly of hap2 followed the aforementioned approach, however, the entire locus was not completely assembled. While there are multiple reads on the unassembled side, there is only one read that extends across into the assembled side and, given the consistency of intergenic distances in the assembled side and the noise in the read, it was not possible to unambiguously place this read. Read f6e8e60a-ae40-42e8-8824-5f4cfdc51a68 was taken to represent the unassembled side as it spanned the longest distance from the flanking region into the locus (with the exception of the aforementioned read).

