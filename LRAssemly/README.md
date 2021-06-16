### PacBio Assemblies

This protocol outlines the steps for the Florida sample (CL1). The same steps were performed for the Nova Scotia sample (VE1).

Convert BAM files to FASTA using bam2fasta (from PacBio SMRT Tools):

``` bam2fasta -o nv.cl1 m54336U_200407_162728.subreads.bam ```

Assemble genomes: The aim here was to try and assemble both haplotypes. We used Canu v2.0 with the recommended parameters to avoid collapsing the genome (see Canu FAQs: https://canu.readthedocs.io/en/latest/faq.html "batOptions=-dg 3 -db 3 -dr 1 -ca 500 -cp 50"). The input parameters were slightly modified for the two samples based on the yield of the each dataset. As there was more data for the Nova Scotia sample, we used a higher minimum read length (10kb) and a higher corrected read coverage (200x).

``` canu -p 100x.g500.assembly -d 100x.g500.assembly genomeSize=500m minReadLength=5000 corOutCoverage=100 "batOptions=-dg 3 -db 3 -dr 1 -ca 500 -cp 50" useGrid=false -pacbio-raw nv.cl1.fasta ```

Polish genomes: We performed two rounds of polishing using Arrow.
1) Create a copy of the unpolished genome with slightly modified contig names:

``` cat ../100x.g500.assembly.contigs.fasta | sed -E 's/ len.*//' > stella.cl1.canu2.unpol.contigs.fasta ```

2) Use pbmm2 to align native PacBio data to assembly:

``` pbmm2 align stella.cl1.canu2.unpol.contigs.fasta /projects/areitze2_research/ED/PACBIO/STELLA_FL_CLETUS/CL1/m54336U_200407_162728.subreads.bam aligned.movie.r1.bam --sort -j 8 -J 8 -m 32G --preset SUBREAD ```

3) Index unpolished assembly

``` samtools faidx stella.ve1.canu2.unpol.contigs.fasta ```

4) Make directory for polished assembly

``` mkdir polished_seqs ```

5) Index BAM file generated in step 2

``` bamtools index -in aligned.movie.r1.bam ```

6) Use gcpp to polish the assembly

``` gcpp -j 20 -r stella.cl1.canu2.unpol.contigs.fasta -o polished_seqs/stella.cl1.canu.contigs.polished.r1.fasta aligned.movie.r1.bam ```

7) Repeat steps 2-6 on the round 1 polished assembly.

