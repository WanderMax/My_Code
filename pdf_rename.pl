#! /usr/bin/perl
#Author : Max
#Date   : 2016-05-25
#Version: v0p0
#Usage  : pdf_rename.pl
#Note   : rename pdf file with its title 

system("rm -rf file.list");
system("ls *.pdf >file.list");


my $line;
my $item;
my $fname;
my $alname;
my $rlname;
#open(LF,"$ARGV[0]");
open(LF,"file.list");
	foreach $line (<LF>){
		chomp ($line);
		  $line=~s/^\s+//;
    	          $line=~s/\s+$//; 						#strip blabk string in the head and end 
#		  print "line content = $line\n"; 				#print line content
		  next if ($line !~ /^(\w+)\.pdf$/);				#match .pdf
		  if($line =~ /^(\w+)\.pdf$/){
#			print "file name = $line\n";

#			$alname = readpipe("grep -E -a -o 'default\">.*' $line");
			$alname = readpipe("grep -E -a  'default\">.*' $line ");			
#			print "get name = $alname\n";
			next if($alname !~/^\s+.*>([ \'a-zA-Z0-9\-]+)<.*$/);
			if($alname =~/^\s+.*>([ \'a-zA-Z0-9\-]+)<.*$/){		#get title name
				my $rlname = $1;
#                                print "real name = $rlname\n";                          
                                $rlname =~s/\s+/_/g;				#replace balck with _ in title name
#                                print "replace name = $rlname\n";
                                system("mv $line $rlname.pdf");
                                print "rename $line to $rlname.pdf\n";
                                }
			}
}


close(LF);
system("rm -rf file.list");
