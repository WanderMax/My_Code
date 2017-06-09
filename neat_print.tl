#! /usr/bin/perl
######################################################################
#Author  : Max
#Date    : 2016-06-28
#Version : v0p1
#Usage   : neat_print.tl Keyword_file(KW)
#Revision: 
#         0.00 06.28    initial


#######################################################################

my $cnt;
my $eh,$item;
my $kw.$itm;
my $lenth;
my $var;
open(SW,"$ARGV[0]");
open(KW,"$ARGV[0]");
#open (ICT,"> zzz.txt ") or die "Error: Cannot open file to write\n";
#max length
$lenth = 0;
foreach $eh (<SW>){
	chomp($eh);
	$item = $eh;
    $item=~s/^\s+//;
    $item=~s/\s+$//;  
	$var = length($item);
#	print "each length is $var\n";
	 if ($var > $lenth){
			$lenth = $var;
	} else {
		 $lenth = $lenth;
	}
}
#print "max length is $lenth\n";


foreach $kw (<KW>){
	chomp($kw);
	next if ($kw =~ /^\s*$/);
	if($kw !~ /^\s*$/){
	$itm = $kw;
    $itm=~s/^\s+//;
    $itm=~s/\s+$//; 
#		print "kw = $kw\n";
# use printf to arrange the strings
        printf "%-${lenth}s -->\n", $itm;
#        printf ICT "%-${lenth}s --> \n", $itm;
#        system("grep -c -w $kw  $ARGV[1]");
	} 		
}

close(SW);
close(KW);
exit;

