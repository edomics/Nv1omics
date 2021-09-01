This page describes how we go from contigs to annotated haplotype maps of the Nv1 locus.

Using concatenated nv1 contigs fasta, generate a blast output and pull out Nv1 sequences that directly match to the amplicons used - this facilitates comparison between the datasets

blastn -query ../VENOM_BLAST/GENOMES/nv1.amp4blast.fasta -db all.nv1tigs.fasta -outfmt 6 -out all.nv1tigs.blast
blastn -query ../VENOM_BLAST/GENOMES/nv1.amp4blast.fasta -db all.nv1tigs.fasta -outfmt "6 sseqid sstart send sseq" | sort -k1,1 -k2,2n |  awk '{print ">"$1"."$2"."$3"\n"$4}' > all.nv1tigs.nv1amp.blast

You can see from the blast output that there is a small issue with this approach. One Nv1 amplicon that has a large insertion and is therefore split in the fasta output. I blasted again using the amplicon variant to confirm and replaced the split sequences with the full sequence.

blastn -query ../CNIDOFEST/BLAST/ncvar.fasta -db all.nv1tigs.fasta -outfmt "6 sseqid sstart send sseq" |  awk '{print ">"$1"."$2"."$3"\n"$4}' | head
***need to look at nc1 and me about racon polishing***



