#! /usr/bin/perl
######################################################################
#Author  : Max
#Date    : 2017-08-03
#Version : v0p1
#Usage   : hardcopy.pl  hardlink_file(HF)
#Note	 : read file hard link and copy to destination folder
#          and should modify the destination manually.
#Revision: 
#         0.01 08.03    initial

#######################################################################
use File::Copy;
use File::Basename;
use strict ;

my @linkarray;						# array to store the file hard link
my $arraylength;
my $line1;
my $line2;

open(HF,"$ARGV[0]");
open (LOG_R,"> done.log ") or die "Error: Cannot open file to write\n";
open (LOG_E,"> error.log ") or die "Error: Cannot open file to write\n";

foreach $line1 (<HF>){
	chomp ($line1);
	next if($line1 =~ /^\s*\t*$/);			# ignore the blank line
	$line1 =~s/^\s+//;
	$line1 =~s/\s+$//; 				# remove the blank at both ends of each line.
#	print "Current hard link is $line1.\n";
	push @linkarray , $line1;			# push the hard link into array
	}
	
$arraylength = @linkarray;				# get numbers of hard link
print "Number of hard link is $arraylength.\n";
print LOG_R "Number of hard link is $arraylength.\n";

my $i;
my $line2;						# get element from linkarray
for ($i=0;$i < @linkarray;$i++ ){
	$line2 = $linkarray[$i];
	print "Acting hard link is $line2.\n";		# judge file exist or not
	if(!(-e "$line2")){
		print "File hard link $line2  not exist.\n\n";
		print LOG_E "File hard link $line2  not exist.\n";
		next if(1);
	}else{
		if(-d "$line2"){			# file or folder
			print "File hard link $line2 is folder.\n\n";
			print LOG_E "File hard link $line2 is folder.\n";
			next if(1);
		}else{		
			# print "File hard link $line2 exist.\n";		# get subfolder and file name	
			if($line2 =~ /^\/nas1\/DS\/max\/EDA_Manual\/tmp\/([a-zA-Z0-9]*)\/([a-zA-Z0-9]*).pdf/){
				my $subfolder = $1;
				my $actingfile = $2;
				my $subfolder2 = dirname($line2);
				my $actingfile2 = basename($line2);		# get file name	with extension	
				print "subfolder is $1   $subfolder2 \n";
				print "file name is $2   $actingfile2 \n";
				if(!(-e "$subfolder")){			# create the non-exist subfolders
				mkdir "$1",0755 or die "Error: Cannot open create directory: $!\n";}
				copy ("$line2", "$subfolder") or die "Can't copy 'source' to 'destination': $!";
				print "Successfully copy $actingfile.pdf to destination!\n\n";				
			}else{
				print "Hard link $line2 not match link pattern!\n\n";
				next if(1)
			}
		
		
		}
	}
}
			



	














	
	
