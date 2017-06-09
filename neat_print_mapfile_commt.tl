#! /usr/bin/perl
######################################################################
#Author  : Max
#Date    : 2016-06-28
#Version : v0.01
#Usage   : neat_print_mapfile_commt.tl Keyword_file(KW)
#Note	 : format the layer mapping file from excel, no blank in layer name
#Revision: 
#   0.00   06.30    initial
#	0.01   07.01	add dup-exclude setting	, add blank line exclude	


#######################################################################

my $cnt;
my $eh;
my $kw;
my $line;

my $a, $b, $c, $d, $e;
my $al, $bl, $cl, $dl;
my $aml, $bml, $cml, $dml;
my @ar, @br, @cr, @dr, @er;
open(SW,"$ARGV[0]");
open(KW,"$ARGV[0]");
#max length
open (ICT,"> out.layermap ") or die "Error: Cannot open file to write\n";
$line=0;
foreach $eh (<SW>){
	chomp($eh);
	$line++;
next if($eh =~ /^\s*\t*$/);
if($eh=~ /^(\w+)\s*\t*(\w+)\s*\t*(\d+)\s*\t*(\d+)\s*\t*(.*)$/){
#	print "line = $eh\n";
	$a = $1;		#layer name
	$b = $2;		#layer purpose
	$c = $3;		#GNS NO.
	$d = $4;		#data type
	$e = $5;		#comment
#	print "a/b/c/d = $a/$b/$c/$d\n";
#	print "comment = $e\n";
	push @ar, $a;
	push @br, $b;
	push @cr, $c;
	push @dr, $d;
	push @er, $e;
#	print "array length is $ar\n";
}
else {
	die "Line $line Error : $eh\n";

}

}

	$aml = &max_leng(@ar);
	$bml = &max_leng(@br);
	$cml = &max_leng(@cr);
	$dml = &max_leng(@dr);
	$al = @ar;
#	$bl = @br;
#	$cl = @cr;
#	$dl = @dr;
#	print "max length of array a/b/c/d = $aml/$bml/$cml/$dml\n";
#if(($al==$bl)&&($bl==$cl)&&($cl==$dl)){
if((@ar==@br)&&(@br==@cr)&&(@cr==@dr)){
#	print "total number of array a/b/c/d = $al\n";
}else {
	print"Error mapping table : line number not match! $al/$bl/$cl/$dl\n";
	exit;
}

my $i;
my $line_dup;
for ($i=0;$i < @ar;$i++ ){
# use printf to arrange the strings
#print "original line: $i\n";
$line_dup = &dup_check(\@cr,\@dr,$i);

#print "dup-line: $line_dup\n";
	next if($line_dup);
       printf "%-${aml}s  %-${bml}s   %-${cml}s   %-${dml}s   #%s\n", $ar[$i],$br[$i],$cr[$i],$dr[$i],$er[$i];
       printf ICT "%-${aml}s  %-${bml}s   %-${cml}s   %-${dml}s   #%s\n", $ar[$i],$br[$i],$cr[$i],$dr[$i],$er[$i];				
}


sub max_leng {
my @array = @_;
my $x;
my $lenth;
my $var;
$lenth = 0;

foreach $x (@array){
	$var = length($x);
#	print "each length is $var\n";
	 if ($var > $lenth){
			$lenth = $var;
	} else {
		 $lenth = $lenth;
	}
}
return ($lenth);
}


sub dup_check {
my ( $chk_gds_no,$chk_data_type, $pointer) = @_;  # $chk_array is the array in sub
my @gds_no_chk = @$chk_gds_no;
my @data_type_chk = @$chk_data_type;
#print "@gds_no_chk | ";
#print "@data_type_chk | ";
my $y = $pointer;
my $j;
my $rev_var;
print "\n--seeking line $y--\n";
for($j=$y+1; $j<=@gds_no_chk; $j++){
    print "compare line $j to line $y : ";
	if($j<=(@gds_no_chk-1)){
     	if(($gds_no_chk[$y]==$gds_no_chk[$j])&&($data_type_chk[$y]==$data_type_chk[$j])){
    		$rev_var = $j;
#    		print "reference content:$gds_no_chk[$y] $data_type_chk[$y]\n";		
#    		print "same content:$gds_no_chk[$j] $data_type_chk[$j]\n";
    		print "found same line $j!\n";
    		last;		#end loop
    	}else {
    		print "not same with line $j!\n";		
    		$rev_var = 0;
    	}
	}else{
		print "end of seeking array!\n";
		$rev_var = 0;
	}
}
print "return:$rev_var\n";
return ($rev_var);
}



close(SW);
close(KW);
exit;

