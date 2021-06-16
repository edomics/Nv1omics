### PacBio Assemblies

*PacBio SMRT tools (i.e., bam2fasta, gcpp etc) can be found on their Github (https://github.com/PacificBiosciences)

This protocol outlines the steps for the Florida sample (CL1). The same steps were performed for the Nova Scotia sample (VE1).

Convert BAM files to FASTA using bam2fasta (from PacBio SMRT Tools):

``` 
bam2fasta -o nv.cl1 m54336U_200407_162728.subreads.bam 
```

Assemble genomes: The aim here was to try and assemble both haplotypes. We used Canu v2.0 with the recommended parameters to avoid collapsing the genome (see Canu FAQs: https://canu.readthedocs.io/en/latest/faq.html "batOptions=-dg 3 -db 3 -dr 1 -ca 500 -cp 50"). The input parameters were slightly modified for the two samples based on the yield of the each dataset. As there was more data for the Nova Scotia sample, we used a higher minimum read length (10kb) and a higher corrected read coverage (200x).

```
canu -p 100x.g500.assembly -d 100x.g500.assembly genomeSize=500m minReadLength=5000 corOutCoverage=100 "batOptions=-dg 3 -db 3 -dr 1 -ca 500 -cp 50" useGrid=false -pacbio-raw nv.cl1.fasta
```

Polish genomes: We performed two rounds of polishing using Arrow (Arrow algorithm is implemented in gcpp).
1) Create a copy of the unpolished genome with slightly modified contig names:

```
cat ../100x.g500.assembly.contigs.fasta | sed -E 's/ len.*//' > stella.cl1.canu2.unpol.contigs.fasta
```

2) Use pbmm2 (v1.3.0) to align native PacBio data to assembly:

```
pbmm2 align stella.cl1.canu2.unpol.contigs.fasta /projects/areitze2_research/ED/PACBIO/STELLA_FL_CLETUS/CL1/m54336U_200407_162728.subreads.bam aligned.movie.r1.bam --sort -j 8 -J 8 -m 32G --preset SUBREAD
```

3) Index unpolished assembly (samtools v1.9)

```
samtools faidx stella.ve1.canu2.unpol.contigs.fasta
```

4) Make directory for polished assembly

```
mkdir polished_seqs
```

5) Index BAM file generated in step 2 (bamtools v2.5.1)

```
bamtools index -in aligned.movie.r1.bam
```

6) Use gcpp (v1.9.0) to polish the assembly

```
gcpp -j 20 -r stella.cl1.canu2.unpol.contigs.fasta -o polished_seqs/stella.cl1.canu.contigs.polished.r1.fasta aligned.movie.r1.bam
```

7) Repeat steps 2-6 on the round 1 polished assembly.

### Nanopore Assemblies

Basecall the data using Guppy (v4.5.2):

```
guppy_basecaller -x "auto" -i /inputdir/ -s ./FASTQ/ --flowcell FLO-MIN106 --kit SQK-LSK109 --min_qscore 7 --num_callers 1
```

Extract ME reads using time and barcode filter (avoid contaminating reads remaining after wash from previous run on flow cell)
```
while read seqfile; do python ./nanopore_timefilt.py --time_from 2021-03-10T06:30:00Z --time_to 2021-03-12T03:30:00Z $seqfile >> me3.raw.fastq;
done < <(ls ../FASTQ/pass/*.fastq)
```

* nanopore_timefilt.py can be obtained from here: https://gist.github.com/wdecoster/1ab9adac7c8095498ff91ee22468eaac#file-nanopore_timefilt-py

```
guppy_barcoder -t 10 -i ./ -s ./BC --barcode_kits EXP-NBD104 --trim_barcodes
```

Concatenate files from barcode 12

```
cat ./BC/barcode12/*.fastq > me3.b12.raw.fastq
```

Assemble: Similar to above approach for PacBio reads, use Canu settings to try and separate haplotypes. With the lower coverage and noisier Nanopore reads, getting a good diploid assembly is unlikely but these settings should hopefully avoid a mismatched assembly of the Nv1 locus that might confuse the haplotype structure. Canu (v2.1) was used for assembly. 

```
canu -d ME3.HAC.50XD331.v2.1 -p me3.canu.v2.1 genomeSize=230m useGrid=true gridOptions="--partition=Pisces" -gridOptionscns="--mem-per-cpu=3600m" minReadLength=1000 corOutCoverage=50 "batOptions=-dg 3 -db 3 -dr 1 -ca 500 -cp 50" -nanopore me3.b12.raw.fastq
```
