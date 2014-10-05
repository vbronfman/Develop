#!/usr/bin/perl

 

 

use strict;

use warnings;

 

use XML::LibXML;

use XML::Parser;

use Data::Dumper;

 

my($FILENAME)=@ARGV;

 

my $parser = XML::LibXML->new();

#my $dom    = $parser->parse_string($XML);

# or

my $dom    = $parser->parse_file($FILENAME);

my $root   = $dom->getDocumentElement;

 

#print Dumper($root); # always pass by reference

 

# get list of all the "source" elements

my @datasources = $root->getElementsByTagName("datasource");

 

$parser = new XML::Parser( Style => 'Tree' );

my $tree = $parser->parsefile( shift @ARGV );

 

 

print Dumper($tree);

