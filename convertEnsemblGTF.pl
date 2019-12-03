#!/usr/bin/perl
use warnings;
use strict;
use IO::File;

#arg 0 = chromosome seqdict from reference genome
#i.e. /path/to/GRCh38_reference/all_sequences.dict

#arg 1 = chromosome synonyms file from the VEP cache
#i.e. /path/to/VEP_cache/homo_sapiens/90_GRCh38/chr_synonyms.txt

#arg 2 = ensembl GTF file (source)


#read in the chromosomes we're looking for
my %targetChrs;
my $inFh = IO::File->new( $ARGV[0] ) || die "can't open file\n";
while( my $line = $inFh->getline )
{
    next unless $line =~ /^\@SQ/;
    chomp($line);
    my @F = split("\t",$line);
    my @G = split(":",$F[1]);
    $targetChrs{$G[1]} = 1;
}
close($inFh);

#hash the mapping to the ensembl chrs
my %mapping;

my $inFh2 = IO::File->new( $ARGV[1] ) || die "can't open file\n";
while( my $line = $inFh2->getline )
{
    chomp($line);
    my @F = split("\t",$line);
    if(exists($targetChrs{$F[1]})){
        $mapping{$F[0]} = $F[1];
    }
}
close($inFh2);

#now convert the GTF
my $inFh3 = IO::File->new( $ARGV[2] ) || die "can't open file\n";
while( my $line = $inFh3->getline )
{
    chomp($line);
    if($line =~ /^#/){
        print $line . "\n";
        next;
    }

    my @F = split("\t",$line);
    if(exists($mapping{$F[0]})){
        print join("\t",($mapping{$F[0]},@F[1..$#F])) . "\n";
    } else {
        print STDERR "WARNING identifier not mapped: " . $F[0] . "\n";
    }
}
close($inFh3);
