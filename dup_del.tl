#! /usr/bin/perl
#Author : Max
#Date   : 2016-07-01
#Version: v0.00
#Usage  : dup_del.tl file(LF) 
#Note   : delete duplicated and blank line of specified document




open(KF,"$ARGV[0]");
open (ICT,"> outfile.txt ") or die "Error: Cannot open file to write\n";
my $el;
my @lines;
foreach $el (<KF>){
	chomp($el);
	next if($el =~ /^\s*\t*$/);	#ignore all blank lines.
	if ($el =~ /^.*$/){
	$el =~s/^\s+//;
	$el =~s/\s+$//; 			#remove the blank at both ends of each line.
	push @lines, $el;
}
}
my $lines_length = @lines;		# $#@lings+1
print "Line number except blank is $lines_length\n";
#print "@lines\n";


my $i;
my $line_dup;
for ($i=0;$i < @lines;$i++ ){
# use printf to arrange the strings
#print "original line: $i\n";
$line_dup = &dup_check(\@lines,$i);

#print "dup-line: $line_dup\n";
	next if($line_dup);
       printf "%s\n", $lines[$i];
       printf ICT "%s\n", $lines[$i];				
}



sub dup_check {
my ($chk_lines, $pointer) = @_;  # $chk_array is the array in sub
my @lines_chk = @$chk_lines;
my $y = $pointer;
my $j;
my $rev_var;
#print "\n--seeking line $y--\n";
for($j=$y+1; $j<=@lines_chk; $j++){
#    print "compare line $j to line $y : ";
	if($j<=(@lines_chk-1)){
     	if($lines_chk[$y] eq $lines_chk[$j]){				# strings compres: eq/lt/gt, number compre : >/</=
    		$rev_var = $j;
#    		print "found same line $j!\n";
    		last;		#end loop
    	}else {
#    		print "not same with line $j!\n";		
    		$rev_var = 0;
    	}
	}else{
#		print "end of seeking array!\n";
		$rev_var = 0;
	}
}
#print "return:$rev_var\n";
return ($rev_var);
}

close(KF);
exit;
