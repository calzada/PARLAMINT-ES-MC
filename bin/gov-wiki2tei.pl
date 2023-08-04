#!/usr/bin/env perl

use warnings;
use strict;
use open qw(:std :utf8);
use utf8;
use DateTime::Format::Strptime;
use XML::LibXML;
use XML::LibXML::PrettyPrint;
use DateTime::Format::Strptime;
use HTML::Entities;

use File::Spec;
use File::Basename;
use File::Path;

my $outFile = File::Spec->rel2abs(shift);


my $strp = DateTime::Format::Strptime->new(
  pattern   => '%d %B %Y',
  locale    => 'en_GB',
);

my %implicatedMember = map {$_ => $_} qw/head deputyHead minister/;

my $doc = XML::LibXML::Document->new("1.0", "utf-8");
my $root_node = XML::LibXML::Element->new('listPerson');
$doc->setDocumentElement($root_node);
$root_node->setNamespace('http://www.tei-c.org/ns/1.0','',1);


my %personDB;


while( my $file = shift @ARGV ) {
  print STDERR "INFO: processing $file\n";
  my $htm = open_html($file);
  my ($table) = $htm->findnodes('/html//h2[.//@id="Council_of_Ministers"]/following::table[@class="wikitable"][1]');
  for my $tr ($table->findnodes('./tbody/tr')){
    next if $tr->findnodes('./th');
    my (@td) = $tr->findnodes('./td');
    next unless @td == 7;
    my $nameText = $td[1]->textContent();
    my ($personId,@name) = parseName($nameText);
    unless($personDB{$personId}){
      $personDB{$personId} = XML::LibXML::Element->new('person');
      $root_node->appendChild($personDB{$personId});
      $personDB{$personId}->setAttributeNS('http://www.w3.org/XML/1998/namespace','id',$personId);
      $personDB{$personId}->setAttribute('role','govMember');
      my $persName = $personDB{$personId}->addNewChild(undef,'persName');
      for my $n (@name){
        $persName->appendTextChild(@$n);
      }
    }
    for my $role ($td[0]->findnodes('./a | ./b/a')){
      addAffiliation($personDB{$personId},$role->textContent(),$td[4]->textContent(),$td[5]->textContent());
    }
  }
}

save_xml($doc, $outFile);





sub addAffiliation {
  my ($person,$roleName,$fromText,$toText,$ref) = @_;
  my ($from,$to) = map {$_ =~ /Incumbent/i ? undef : $strp->parse_datetime($_)->strftime('%Y-%m-%d')} map {trim($_)} ($fromText,$toText);
  my $role;
  if($roleName) {
    if($roleName =~ /^Minister (for|of)/){
      $ref = '#GOV';
      $role = 'minister';
    } elsif ($roleName =~ /^Prime Minister/) {
      $ref = '#GOV';
      $role = 'head';
    } elsif ($roleName =~ /Deputy Prime Minister/) {
      $ref = '#GOV';
      $role = 'deputyHead';
    } else {
      print STDERR "WARN: unknown affiliation role '$roleName'\n";
    }

  } else {
    $role = 'member';
  }
  if($ref) {
    my $affiliation = XML::LibXML::Element->new('affiliation');
    $affiliation->setAttribute('ref',$ref);
    $affiliation->setAttribute('role',$role);
    $affiliation->setAttribute('from',$from) if $from;
    $affiliation->setAttribute('to',$to) if $to;
    $person->appendChild($affiliation);
    if($roleName){
      $affiliation->appendTextChild('roleName',$roleName);
      $affiliation->firstChild()->setAttributeNS('http://www.w3.org/XML/1998/namespace','lang','en')
    }
  }

  if($implicatedMember{$role//''}) {
    addAffiliation($person,undef,$fromText,$toText,$ref);
  }
}

sub parseName {
  my $text = trim(shift//'');
  my @tokens = split(/ /,$text);
  my @forename = @tokens[0..$#tokens-1];
  my $surname = $tokens[-1];
  my $id = join('',@tokens);
  $id =~ s/[-:\s]//g;
  return ($id,
          (map {['forename',$_]} @forename),
          ['surname',$surname]);
}



##########################

sub trim {
  my $text = shift;
  $text =~ s/^\s*|\s*$//g;
  $text =~ s/\s+/ /g;
  return $text;
}

sub open_html {
  my $file = shift;
  my $params = shift // {};
  my %vars = @_;
  my $doc;
  local $/;
  open FILE, $file;
  #binmode ( FILE, ":encoding(WINDOWS-1251)" ); # encoding(WINDOWS-1251) windows1251 utf8
  my $rawxml = <FILE>;
  $rawxml = decode_entities($rawxml);
  close FILE;

  if ((! defined($rawxml)) || $rawxml eq '' ) {
    print " -- empty file $file\n";
  } else {
    my $parser = XML::LibXML->new(load_ext_dtd => 0, clean_namespaces => 1, recover => 2);
    $doc = "";
    eval { $doc = $parser->parse_html_string($rawxml); };
    if ( !$doc ) {
      print " -- invalid XML in $file\n";
      print "$@";

    } else {
      $doc->documentElement->setNamespaceDeclURI(undef, undef);
    }
  }
  return $doc
}

sub to_string {
  my $doc = shift;
  my $pp = XML::LibXML::PrettyPrint->new(
    indent_string => "   ",
    element => {
        inline   => [qw//], # note
        block    => [qw/person persName affiliation/],
        compact  => [qw/sex forename surname roleName/],
        preserves_whitespace => [qw//],
        }
    );
  $pp->pretty_print($doc);
  return $doc->toString();
}


sub print_xml {
  my $doc = shift;
  binmode STDOUT;
  print to_string($doc);
}

sub save_xml {
  my ($doc,$filename) = @_;
  my $dir = dirname($filename);
  File::Path::mkpath($dir) unless -d $dir;
  open FILE, ">$filename";
  binmode FILE;
  my $raw = to_string($doc);
  print FILE $raw;
  close FILE;
}