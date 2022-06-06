This page describes how we go from contigs to annotated haplotype maps of the Nv1 locus.

Firstly, we performed a blastn query against each genome assembly to identify the relevant contigs

blastn -query nv1.amp4blast.fasta -db $genome -outfmt 6

Which identified the following as contigs containing Nv1:
FL: tig00000262, tig00000186 (this tig is lacking Nv1 but included as it is the corresponding haplotype to tig00000262)
NS: tig00000889, tig00001087
ME: tig00001232
NC: nc.hap1, nc.hap2, nc.hap2.f6 (these contigs were relabelled from Canu output - see NC Assembly directory)
MD: chr10

These Nv1-containing contigs were concatenated into a single fasta. Next, we generate a blast output and pull out Nv1 sequences that directly match to the amplicons used (we use the most abundant amplicon sequences as the query) - this facilitates comparison between the datasets

For blast results (includinf coordinates to enable calculation of Nv1 copy location and intergenic distances):
blastn -query ../VENOM_BLAST/GENOMES/nv1.amp4blast.fasta -db all.nv1tigs.fasta -outfmt 6 -out all.nv1tigs.blast
For a corresponding FASTA file of genomic variant:
blastn -query ../VENOM_BLAST/GENOMES/nv1.amp4blast.fasta -db all.nv1tigs.fasta -outfmt "6 sseqid sstart send sseq" | sort -k1,1 -k2,2n |  awk '{print ">"$1"."$2"."$3"\n"$4}' > all.nv1tigs.nv1amp.fasta

***For variant 24 in NC population***

You can see from the blast output that there is a small issue with this approach. One Nv1 amplicon that has a large insertion and is therefore split in the fasta output. I blasted again using the amplicon variant to confirm and replaced the split sequences with the full sequence.

blastn -query ../CNIDOFEST/BLAST/ncvar.fasta -db all.nv1tigs.fasta -outfmt "6 sseqid sstart send sseq" |  awk '{print ">"$1"."$2"."$3"\n"$4}' | head
***need to look at nc1 and me about racon polishing***

The FASTA file was then aligned in MEGAX and variants collapsed in FaBox (https://birc.au.dk/~palle/php/fabox/dnacollapser.php). 

