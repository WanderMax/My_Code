#! /usr/bin/perl
#Author : Max
#Date   : 2016-05-25
#Version: v0p0
#Usage  : Batch_Run_xcalibrate.pl List_file(LF) 
#Note   : List of mipt file should contains filename with extension 


my @list;
my $line;
my $item;
my $fname;
my $alname;
open(LF,"$ARGV[0]");
	foreach $line (<LF>){
		chomp ($line);
		  $line=~s/^\s+//;
    	  $line=~s/\s+$//; 
#		  print "line = $line\n"; 
		  next if ($line !~ /^(\w+)\.mipt$/);
		  if($line =~ /^(\w+)\.mipt$/){
			$fname = $1;
			$alname = $line;
			print "file_name = $fname, $line\n";

			system("xcalibrate -exec -tech $fname $line");
			}
}


close(LF);
