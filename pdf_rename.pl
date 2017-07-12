#! /usr/bin/perl
#Author : Max
#Date   : 2017-07-12
#Version: v0p0
#Usage  : pdf_rename.pl
#Note   : rename pdf file with its title or get the name table

system("rm -rf file.list");
system("rm -rf action.log");
system("ls *.pdf >file.list");                                                #get file.list


my $line;
my $item;
my $fname;
my $alname;
my $rlname;
my $maxlength;
my $local_length = 0; 
open(LOG,">action.log") or die "ERROR: Cannot open action.log to write\n";    #create action.log to write
open(FL,"<file.list") or die "ERROR: Cannot open file.list to read\n";        #open file.list to operate

#get max length of each file name
foreach $line (<FL>){
      chomp ($line);
        $line=~s/^\s+//;
        $line=~s/\s+$//;                                                      #strip blank string in the head and end 
#        print "line content = $line\n";                                      #print line content
           next if ($line !~ /^(\w+)\.pdf$/);                                 #match .pdf
           if($line =~ /^(\w+)\.pdf$/){
                my $tmp_length = length($line);                               #get length of file name
                    if($tmp_length > $local_length){                          #get max length of file name
                        $local_length = $tmp_length;
                    } else {
                        $local_length = $local_length;
                    } #end of length judge
#            print "current max length = $local_length\n";                                 
           }
} #end of foreach

$maxlength = $local_length;                                                   #set max length
print "Max length = $maxlength\n"; 

open(FL,"<file.list") or die "ERROR: Cannot open file.list to read\n";        #open file.list to operate
#rename action
foreach $line (<FL>){
      chomp ($line);
        $line=~s/^\s+//;
        $line=~s/\s+$//;                                                      #strip blank string in the head and end 
#        print "line content = $line\n";                                      #print line content
           next if ($line !~ /^(\w+)\.pdf$/);                                 #match .pdf
           if($line =~ /^(\w+)\.pdf$/){                                         
#             print "file name = $line\n";                                                                                     
             $alname = readpipe("grep -E -a  'default\">.*' $line ");              
#             print "get name = $alname\n";                                     
            next if($alname !~/^\s+.*>([ \'a-zA-Z0-9\-]+)<.*$/);               
            if($alname =~/^\s+.*>([ \'a-zA-Z0-9\-]+)<.*$/){                     #get title name
                 my $rlname = $1;                                               
#                 print "real name = $rlname\n";                            
#                 $rlname =~s/\s+/_/g;                                           #replace blank with _ in title name
#                 $rlname =~s/\'+/-/g;                                           #replace ' with - in title name
#                 print "replace name = $rlname\n";                             
#                 system("mv $line $rlname.pdf");                                #rename action, you can switch on/off
                 printf  "%-${maxlength}s --> %s.pdf\n", $line, $rlname;         #format output left justify
                 printf LOG "%-${maxlength}s --> %s.pdf\n", $line, $rlname;      #make rename table
             }
        }
}


close(FL);
close(LOG);
system("rm -rf file.list");                                                     #delete file.list
