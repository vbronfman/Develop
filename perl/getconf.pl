#!/usr/bin/perl


use strict;
use warnings;


#use XML::LibXML;
#use XML::LibXML::Schema;
use XML::Parser;
use XML::Simple;
#use XML::XPath;

use Thread;

use Data::Dumper;
use Partner::Init;

local $\ = "\n";
my $dbgmode=0;
our $logfile = "unknown";
our $parsedby= "";
our $config = "";

my @inparams=qw/dbgmode logfile '$test'/;


#for debug only

my %h=(
	k1=>[
		"string1",
		"string2"
	],
	k2=>
	[
		"k2_string1",
		"k2_string1"
	]
);

for (  my($key,$value)=each %h){
	print $h{$key}->[1];
	
};


#end for debug only


my $init=Partner::Init->new();
#my $in=Partner::Init->newp(@inparams); # initialise by user provided list of parameteres
$init->initfunc(); # get arguments 

$init->printargs();

# Just for debug 
#if($parser eq 's'){goto SIMPLE };
#if($parser eq 'p' ){goto PARSER};
#if($parser eq 'l' ){goto LIB};
#;
#
#LIB:
#
# print "Parse by XML::Lib\n";
#my $parser = XML::LibXML->new();
##my $doc    = $parser->parse_string($XML);
## or
#my $doc    = $parser->parse_file($FILENAME);
#
#my $root   = $doc->getDocumentElement;
#
##print Dumper($root); # always pass by reference 
#
## get list of all the "source" elements
#my @datasources = $root->getElementsByTagName("datasource");
#
#foreach my $datasource (@datasources){
#
#print $datasource->firstChild->data, "\n"; 
#
#}
#
#
#exit;
#
#PARSER:
 print "Parse by XML::Parser\n";
my $parserTree = new XML::Parser( Style => 'Tree' );
 my $parserObj = new XML::Parser( Style => 'Object' );
my $tree = $parserTree->parsefile( $config );
my $obj = $parserObj->parsefile( $config );

#findnodes( 
print Dumper($tree);
print Dumper($obj); 

#exit;
#
##use XML::Simple; 
##my $simple = XML::Simple->new( ); # initialize the object 
##my $tree = $simple->XMLin( $FILENAME ); # read, store document 
#
##print Dumper ($tree);
#
#SIMPLE:
## my $ref = XMLin($FILE);
##my $xs = XML::Simple->new(options);
#print "Parse by XML::Simple\n";
#my $xs = XML::Simple->new();
#my $ref = $xs->XMLin($FILENAME);
#
#print Dumper($ref);

exit;
