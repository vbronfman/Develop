#!/usr/bin/perl -w

use strict;
use warnings;


my %dup_series_per_dir;
#while (<>) {
while (<DATA>) {
    my ($dir, $file) = m!(.*/)?([^/]+?)$!;
    #push @{$dup_series_per_dir{$dir||'./'}{lc $file}}, $file;
    push @{$dup_series_per_dir{lc $file}}, $dir;
}

#for  my $dir (sort keys %dup_series_per_dir) {
for  my $file (sort keys %dup_series_per_dir) {
    #print "$dir \n";
    #my @all_dup_series_in_dir = grep { @{$_} > 1 } values %{$dup_series_per_dir{$dir}};
    my @all_dup_series_in_dir = grep { @{$_} > 1 } $dup_series_per_dir{$file};
    
    for  my $one_dup_series (@all_dup_series_in_dir) {
        print "$file:". join(':', sort @{$one_dup_series}) . "\n";
    }
}


__DATA__
./Develop/Perl/FindDuplicateFiles/New Text Document.txt
./Develop/Perl/FindDuplicateFiles/Copy of New Text Document.txt
./Develop/Perl/FindDuplicateFiles/Copy (2) of New Text Document.txt
./Develop/Perl/FindDuplicateFiles/Copy of New Folder/Copy (2) of New Text Document.txt
./Develop/Perl/FindDuplicateFiles/Copy of New Folder/Copy of New Text Document.txt
./Develop/Perl/FindDuplicateFiles/Copy (2) of New Folder/Copy (2) of New Text Document.txt
./Develop/Perl/FindDuplicateFiles/Copy (2) of New Folder/Copy of Copy of New Text Document.txt