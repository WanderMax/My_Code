#Version : v0p1
#Usage   : same_gather.pl  hardlink_file(HF)
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
my @namearray;						# array the file name only
my $arraylength;
my $line1;
my $line2;
my $getname;
my $os  =  $^O;	
print "My OS is $os.\n"	;				# get system platform;
open(HF,"$ARGV[0]");
open(LOG_R,"> done.log") or die "Error: Cannot open file to write\n";
open(LOG_E,"> error.log") or die "Error: Cannot open file to write\n";

foreach $line1 (<HF>){
	chomp ($line1);
	next if($line1 =~ /^\s*\t*$/);			# ignore the blank line
	$line1 =~s/^\s+//;
	$line1 =~s/\s+$//; 				# remove the blank at both ends of each line.
#	print "Current hard link is $line1.\n";
	if(!(-e "$line1")){
		print "Hardlink $line1 not exist.\n\n";
		next if(1);				# out the current queue when link not exist
	}else{
		if(-d "$line1"){
		print "Hard link $line1 is folder.\n\n";	
		next if(1);				# out the current queue when link is folder
		}else{
			if(($os == "linux")&&($line1 =~ /^[a-zA-z0-9_\)\(\'\.\-\/]+$/)){							
				$getname = basename($line1);		# get file name from hardlink
				print "Get the filename $getname\n";
				push @linkarray , $line1;		# push the hardlink into array without non-exist or folder
			}elsif(($os == "MSWin32")&&($line1 =~ /^[a-zA-z0-9_\)\(\'\.\-\\\:]+$/)){
				$getname = basename($line1);		# get file name from hardlink
				print "Get the filename $getname\n";
				push @linkarray , $line1;	
			}else{
				print "Bad hardlink $line1 or Unsupported system platform $os!\n\n";
				push @linkarrayerror, $line1;
				next if(1);				# out current queue				
			}			

		}		
	}
	}	#end foreach
	
$arraylength = @linkarray;				# get numbers of hard link
print "@linkarray, "\n"";
print "Number of hard link is $arraylength.\n";
print LOG_R "Number of hard link is $arraylength.\n";


my $i;
my $line2;
my $filename;
my $path;
my $nickname;
my $subfolder;						# get element from linkarray
for ($i=0;$i < @linkarray;$i++ ){
	$line2 = $linkarray[$i];
#	print "Acting hard link is $line2.\n";		# judge file exist or not
	$filename = basename($line2);
	$path = dirname($line2);
	print "Path $path; Filename $filename\n\n";
	
if($os == "linux"){					# linux	
	if($path =~ /^.*\/([a-zA-z0-9_]*)$/){		# subfolder pattern
		$subfolder = $1;			# get subfolder for file
		print "Subfolder $subfolder\n";	
		if(!(-e "$subfolder")){			# create gather folder
			mkdir "$subfolder",0755 or die "Error: Cannot open create directory: $!\n";
		}		
		if($filename =~ /^\d*---([a-zA-z0-9_\)\(\']*)\.pdf/){	# get file namw without extension
			$nickname = $1;
			print "Nickname $nickname\n";
			if(!(-e "$subfolder/$nickname")){	# create same file folder
				mkdir "$subfolder/$nickname",0755 or die "Error: Cannot open create directory: $!\n";
			}
		}else{
			print "File name incorrect, $filename!\n\n";
			next if(1);
		}
	}else{		
		print "File path incorrect, $path!\n\n";
		next if(1);
	}	# end if linux
	
}elsif($os == "MSWin32"){				# windows
	if($path =~ /^.*\\([a-zA-z0-9_]*)$/){		# subfolder pattern
		$subfolder = $1;			# get subfolder for file
		print "Subfolder $subfolder\n";	
		if(!(-e "$subfolder")){			# create gather folder
			mkdir "$subfolder",0755 or die "Error: Cannot open create directory: $!\n";
		}		
		if($filename =~ /^\d*---([a-zA-z0-9_\)\(\']*)\.pdf/){	# get file namw without extension
			$nickname = $1;
			print "Nickname $nickname\n";
			if(!(-e "$subfolder\\$nickname")){	# create same file folder
				mkdir "$subfolder\\$nickname",0755 or die "Error: Cannot open create directory: $!\n";
			}
		}else{
			print "File name incorrect, $filename!\n\n";
			next if(1);
		}
	}else{		
		print "File path incorrect, $path!\n\n";
		next if(1);
	}

}else{
	print "Unsupported system platform $os!\n\n";	
} #end if OS
			
}	# end for







