#! /usr/bin/perl
#Author : Max
#Date   : 2017-08-30
#Version: v0.00
#Usage  : mdx_file_verify.pl mdx-source-file(OF) 
#Note   : verify the mdx source file and give the common info

############################################################################
# mdx source file format
# header1            ----> key1
# dict contents1     ----> value1
# </>                ----> end indicator 
# header2            ----> key2
# dict contents2     ----> value2
# </>                ----> end indicator 
############################################################################

use File::Copy;
use File::Basename;
use strict ;

# put each lines into array lines
open(OF,"$ARGV[0]");
open (ICT,"> report-file.txt ") or die "Error: Cannot open file to write\n";
my $eachline;
my @lines;
foreach $eachline (<OF>){
  chomp($eachline);
	  if($eachline =~ /^\s*\t*$/){	    #quit the loop when meeting blank line.
	    print ICT "Source file has blank line, please do delete!\n";
	    die "Source file has blank line, please do delete!\n";
	  }elsif($eachline =~ /^.*$/){
      $eachline =~s/^\s+//;
	    $eachline =~s/\s+$//; 			  #remove the blank at both ends of each line.
	    push @lines, $eachline;
    }else{
      print "Unknown content $eachline\n";
      print ICT "Unknown content $eachline\n";
    }
}
my $lines_length = @lines;		
print "Line number is $lines_length\n";
#print "@lines\n";

# get </> position line number and put into inct array
my @inct;
my $i;
for($i=0; $i<@lines; $i++){
    if($lines[$i] eq "</>"){
      push @inct, $i;
    }
}
my $header = @inct;
print "Words estimated is $header\n";

my $inct0;              # first </> position
my $inct1;              # second </> position
my $j;                  

# get first end indicator position
if($inct[0]!=2){
  print "First word end indicator is incorrect!\n";
  print ICT "First word end indicator is incorrect!\n";
  $inct0 = $inct[0];
}else{
  $inct0 = 2;
}


for($j=1; $j<@inct; $j++){
  $inct1 = $inct[$j];
  my $delta = $inct1 - $inct0;
  if($delta!=3){
    my $issueline = $inct1+1;
    print "Dict content issue in line $issueline\n";
    print ICT "Dict content issue in line $issueline\n";
    $inct0 = $inct1;
  }else{
    $inct0 = $inct1;
  }  
}

print "Dict content verification done\n";


close(OF);
close(ICT);
exit;
