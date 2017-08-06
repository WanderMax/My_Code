#! /usr/bin/perl
######################################################################
#Version : v0p1
#Usage   : same_gather.pl  hardlink_file(HF) prefix
#Note	 : read file hard link and gather the same name file to one folder
#          and should modify the hard link without whitespace manually.
#          replace whitespace " " in the file name with underline "_"
#Revision: 
#         0.01 08.04   initial

#######################################################################
use File::Copy;
use File::Basename;
use File::Path;
use strict ;

my @linkarray;						# array to store the file hard link
my @linkarrayerror;					# array to store the file hard link which can't pharse
my @namearray;						# array to store the file name with whitespace replaced
my $arraylength1;
my $arraylength2;
my $arraylength3;
my $arraylength4;
my $arraylength5;
my $line1;
my $line2;
my $getname;
my $os  =  $^O;	
print "My OS is $os.\n"	;				# get system platform;
open(HF,"$ARGV[0]");
open(LOG_R, "> $ARGV[1]_done.log") or die "Error: Cannot open file to write\n";
open(LOG_E, "> $ARGV[1]_error.log") or die "Error: Cannot open file to write\n";

foreach $line1 (<HF>){
	chomp ($line1);
	next if($line1 =~ /^\s*\t*$/);			# ignore the blank line
	$line1 =~s/^\s+//;
	$line1 =~s/\s+$//; 				# remove the blank at both ends of each line.
#	print "Current hard link is $line1.\n";
	if(!(-e "$line1")){
		print "Hardlink $line1 not exist.\n\n";
		print LOG_E "Hardlink $line1 not exist.\n";
		next if(1);				# out the current queue when link not exist
	}else{
		if(-d "$line1"){
		print "Hard link $line1 is folder.\n\n";
		print LOG_E "Hard link $line1 is folder.\n";		
		next if(1);				# out the current queue when link is folder
		}else{
			if(($os eq "linux")&&($line1 =~ /^[a-zA-z0-9_\)\(\'\.\-\/]+$/)){							
				$getname = basename($line1);		# get file name from hardlink
#				print "Get the filename $getname\n";
				push @linkarray , $line1;		# push the hardlink into array without non-exist or folder
			}elsif(($os eq "MSWin32")&&($line1 =~ /^[a-zA-z0-9_\)\(\'\.\-\\\: ]+$/)){
				$getname = basename($line1);		# get file name from hardlink
#				print "Get the filename $getname\n";
				push @linkarray , $line1;	
			}else{
				print "Bad hardlink $line1 or Unsupported system platform $os!\n\n";
				print LOG_E "Bad hardlink $line1 or Unsupported system platform $os\n";
				push @linkarrayerror, $line1;
				next if(1);				# out current queue				
			}			

		}		
	}
	}	#end foreach
	
$arraylength1 = @linkarray;				# get numbers of hard link
$arraylength2 = @linkarrayerror;		# get numbers of hard link
#print "Number of hard link is $arraylength1.\n";
#print LOG_R "Number of hard link is $arraylength1.\n";

#create two name
my $i;
my $line2;
my $filename;						# store name with whitespace replace
my $path;
my $nickname;
my @nickname;						# store name with whitespace
my $subfolder;						# get element from linkarray
my @subfolder;						# store subfolder
for ($i=0;$i < @linkarray;$i++ ){
	$line2 = $linkarray[$i];
#	print "Acting hard link is $line2.\n";		# judge file exist or not
	$filename = basename($line2);
	$path = dirname($line2);
#	print "Path $path; Filename $filename\n";
	
if($os eq "linux"){					# linux	
	if($path =~ /^.*\/([a-zA-Z0-9_\-]*)$/){		# subfolder pattern
		$subfolder = $1;			# get subfolder for file
#		print "Subfolder $subfolder\n";	
#		if(!(-e "$subfolder")){			# create gather folder
#			mkdir "$subfolder",0755 or die "Error: Cannot open create directory: $!\n";
#		}
		push @subfolder, $subfolder;
		if($filename =~ /^\d*---([a-zA-z0-9_\)\(\'\-\.]*)\.txt/){	# get file name without extension
			$nickname = $1;
			push @nickname, $nickname;
#			print "Nickname $nickname\n";
#			if(!(-e "$subfolder/$nickname")){	# create same file folder
#				mkdir "$subfolder/$nickname",0755 or die "Error: Cannot open create directory: $!\n";		
#			}
			push @namearray, $nickname;
		}else{
			print "Linux: File name incorrect or not match pattern, $filename!\n\n";
			next if(1);
		}
	}else{		
		print "Linux: File path incorrect or not match pattern, $path!\n\n";
		next if(1);
	}	# end if linux
	
}elsif($os eq "MSWin32"){				# windows
	if($path =~ /^.*\\([a-zA-Z0-9_\-]*)$/){		# subfolder pattern
		$subfolder = $1;			# get subfolder for file
#		print "Subfolder $subfolder\n";	
#		if(!(-e "$subfolder")){			# create gather folder
#			mkdir "$subfolder",0755 or die "Error: Cannot open create directory: $!\n";
#		}
		push @subfolder, $subfolder;
		if($filename =~ /^\d*--([a-zA-z0-9_\)\(\'\.\- ]*)\.txt/){	# get file namw without extension, can have whitespace
			$nickname = $1;
			push @nickname, $nickname;
#			print "Nickname $nickname\n";
			$nickname =~ s/\s/_/g;								# replace whitespace with underline
#			print "$nickname\n";
#			if(!(-e "$subfolder\\$nickname")){	# create same file folder
#				mkdir "$subfolder\\$nickname",0755 or die "Error: Cannot open create directory: $!\n";							
#			}
			push @namearray, $nickname;							# store the whitespace replaced name
		}else{
			print "Win: File name incorrect or not match pattern, $filename!\n\n";
			print LOG_E "Win: File name incorrect or not match pattern, $filename\n";
			next if(1);
		}
	}else{		
		print "Win: File path incorrect or not match pattern, $path!\n\n";
		print LOG_E "Win: File path incorrect or not match pattern, $path\n";
		next if(1);
	}

}else{
	print "Unsupported system platform $os!\n\n";	
} #end if OS
			
}	# end for


$arraylength3 = @subfolder;
$arraylength4 = @nickname;
$arraylength5 = @namearray;
print "Number of total hard link is	$arraylength1.\n";
print "Number of error hard link is	$arraylength2.\n";
print "Number of subfolder array is	$arraylength3.\n";
print "Number of original name is	$arraylength4.\n";
print "Number of processed name is  $arraylength5.\n";
system 'pause';

if(($arraylength3 ==$arraylength4)&&($arraylength4 ==$arraylength5)&&(($arraylength2+$arraylength3)==$arraylength1)){
	print "Link number matched, process now!\n";
}else{
	print "Link number not matched, quitting!\n\n";
	print LOG_E "Link number not matched, quitting!\n";
	exit(1);
}

my $j;
my $dupped;
my $dupped_one = 0;
for($j=0; $j<@namearray; $j++){
	$dupped = &dup_check(\@namearray,$j);
	if($dupped){
		if(!(-e "$subfolder[$j]")){			# create gather folder
			mkdir "$subfolder[$j]",0755 or die "Error: Cannot open create directory: $!\n";
			if(!(-e "$subfolder[$j]\\$namearray[$j]")){	# create same file folder
				mkdir "$subfolder[$j]\\$namearray[$j]",0755 or die "Error: Cannot open create directory: $!\n";							
			}
			move ("$linkarray[$j]", "$subfolder[$j]\\$namearray[$j]") or die "Can't move 'source' to 'destination': $!";
		}else{
			if(!(-e "$subfolder[$j]\\$namearray[$j]")){	# create same file folder
				mkdir "$subfolder[$j]\\$namearray[$j]",0755 or die "Error: Cannot open create directory: $!\n";							
			}
			move ("$linkarray[$j]", "$subfolder[$j]\\$namearray[$j]") or die "Can't move 'source' to 'destination': $!";		
		}
		$dupped_one = $dupped_one+1;
	}else{
	
	}


} 
print "Dupped number is $dupped_one\n";
print "Work done!\n\n";
close(LOG_E);
close(LOG_R);


# check whether is dupped
sub dup_check {
my ($chk_lines, $pointer) = @_;  # $chk_lines is the array in sub
my @lines_chk = @$chk_lines;
my $y = $pointer;
my $j;
my $rev_var;
#print "\n--seeking line $y--\n";
for($j=0; $j<@lines_chk; $j++){
    if(($lines_chk[$y] eq $lines_chk[$j])&&($j != $y)){				# strings compres: eq/lt/gt, number compre : >/</=
    	$rev_var = 1;									# find dup in namearray
#		print "$lines_chk[$y] dupped!\n";
    	last;		#end loop
    }else{
#		print "$lines_chk[$y] not dupped!\n";		
    	$rev_var = 0;
    }
}
#print "return:$rev_var\n";
return ($rev_var);
}









