#! /usr/bin/perl
######################################################################
#Author  : Max
#Date    : 2017-09-05
#Version : v0p3
#Usage   : do.pl  source_file(HF)
#Note	   : read CC-CEDICT source file and make to mdict format
#Revision: 
#         0.01 09.04    initial
#         0.02 09.05    add process indicator
#         0.03 09.05    rewrite search code

#######################################################################
use Encode;
use strict;
use utf8::all;


my @linearray;						
my $arraylength;
my $line1;
my $line2;

open(HF,"$ARGV[0]");
open (OUT,"> output_dict.txt ") or die "Error: Cannot open file to write\n";
open (REPORT,"> report.log ") or die "Error: Cannot open file to write\n";

my $entries;
foreach $line1 (<HF>){
	chomp ($line1);
	if($line1 =~ /^#\! entries\=([0-9]+)$/){
	  $entries = $1;
	  next if(1);
	}
	next if($line1 =~ /^\s*\t*$/);			# ignore the blank line
	next if($line1 =~ /^#.*$/);
	$line1 =~s/^\s+//;
	$line1 =~s/\s+$//; 				# remove the blank at both ends of each line.
#	print "Line is $line1\n";
#	print LOG_R "$line1\n";
	push @linearray , $line1;			# push the hard link into array
	}
	
$arraylength = @linearray;				# get numbers of hard link
print "Original Index is $entries\n";
print "Indexing Number is $arraylength.\n";
print REPORT "Index Number is $arraylength.\n";


my $i;
my $process_line;
my $header_cht;
my $header_chs;
my $pinyin;
my $all_shiyi;
my @header_cht;
my @header_chs;
my @pinyin;
my @all_shiyi;

my $header_cht_exp = '[a-zA-Z0-9\x{2e80}-\x{9fa5}，\%○]+';
my $headr_chs_exp = '[a-zA-Z0-9\x{2e80}-\x{9fa5}，\%○]+';
my $pinyin_exp = '\[[^\]]+\]';
my $all_shiyi_exp = '\/.+\/';
print "Extract Process: ...\n"	;
for($i=0; $i<@linearray;$i++){
    if(($i%100==0)||($i==$arraylength-1)){
    printf "%0.3f ",($i+1)/$arraylength;
    }
    $process_line = $linearray[$i];
    if($process_line =~ /^($header_cht_exp) ($headr_chs_exp) ($pinyin_exp) ($all_shiyi_exp)$/){
#        print "Process line is $process_line\n";
        $header_cht = $1;
        $header_chs = $2;
        $pinyin = $3;
        $all_shiyi = $4;
#        print "Header: $header_cht; PinYin: $pinyin; Explanation: $all_shiyi\n";  
        push  @header_cht,$header_cht;
        push  @header_chs,$header_chs;
        push  @pinyin,$pinyin;
        push  @all_shiyi,$all_shiyi;       
    }else{
#        print "\nUnmatched line is $process_line\n";
        print LOG_E "$process_line\n";
    }   
        
}
print "\n";
#process explanation
# /to split the bill/to go Dutch/
#first "/"  --> <ul><li>
#middle "/"  --> </li><li>
#last "/"   ---> </li></ul>
#Chinese words --> <a href="entry://key#section">key</a>

my $first_rep = '<ul><li>';
my $middle_rep = '</li><li>';
my $last_rep = '</li></ul>';
my $hlink_before = '<a href="entry://';
my $hlink_middle = '">';
my $hlink_end = '</a>';
my $pinyin_before = '<span class="py2">[';
my $pinyin_end = ']</span>';
my $bracket_before = '<span class="bra">(';
my $bracket_end = ')</span>';
my $ch_exp = '[a-zA-Z0-9]*[\x{2e80}-\x{9fa5}，]+';
my $bracket_exp = '\([^\)]+\)';
my $shiyi;
my @all_shiyi_after;
my @shiyi_splited;
foreach (@all_shiyi){
#    print "$_\n";
    $shiyi = $_;
    #replace "," with ", "
    $shiyi =~s/,\s*/, /g;
    #deal with "/"
    $shiyi =~ s/^\/(.*)$/\1/;
    $shiyi =~ s/^(.*)\/$/\1/;
    @shiyi_splited = split /\//, "$shiyi";
    $shiyi = join "$middle_rep" , @shiyi_splited;
#    print  "1 $shiyi\n";   
    $shiyi =~s/^(.+)$/$first_rep\1$last_rep/;
#    print  "2 $shiyi\n";
    #deal zhongwen to hyperlink
    $shiyi =~s/\b($ch_exp)\b/$hlink_before\1$hlink_middle\1$hlink_end/g;
#    print  "4 $shiyi\n";
    #deal with "()"
    $shiyi =~ s/\(/$bracket_before/g;
    $shiyi =~ s/\)/$bracket_end/g;
    #deal with "[]"
    $shiyi =~ s/\[/$pinyin_before/g;
    $shiyi =~ s/\]/$pinyin_end/g;
#    print  "7 $shiyi\n";
    print REPORT "$shiyi\n";
    push @all_shiyi_after, $shiyi;
  }
 
    

#join the splited parts into one

my $header_cht_length = @header_cht;
my $header_chs_length = @header_chs;
my $pinyin_length = @pinyin;
my $all_shiyi_after_length  = @all_shiyi_after;

if(!($header_cht_length==$all_shiyi_after_length)){
    die "Error: Dict Index length not matched!\n"
}

my $j;
my $dict_style = '<head><link rel="stylesheet" type="text/css" href="cccdict.css"/></head>';
my $dict_top = '<div class="dt-all">';
my $header_style_cht1 = '<div class="wd-tw">';
my $header_style_cht2 = '</div>';
my $header_style_chs1 = '<div class="wd-cn">';
my $header_style_chs2 = '</div>';
my $header_style_pinyin1 = '<div class="py1">';
my $header_style_pinyin2 = '</div>';
my $shiyi_before = '<div class="sy">';
my $shiyi_after = '</div>';
my $dict_end = '</div>';
my $dict_delimiter = '</>';
my $dict_link = '@@@LINK=';

my $wd_tw;
my $wd_cn;
my $py;
my $exp;
my $total_index=0;
print "\nOutput Process: ...\n"	;
for($j=0;$j<$header_cht_length;$j++){
    if(($j % 100 ==0)||($j==$header_cht_length-1)){
    printf "%0.3f ",($j+1)/$header_cht_length;
    }
    $wd_tw =  $header_cht[$j];  
    $wd_cn =  $header_chs[$j];  
    $py = $pinyin[$j];
    $exp = $all_shiyi_after[$j];
    #format dict content    
    print OUT "$wd_tw\n";
    $total_index++;
    print OUT "$dict_style\n";
    print OUT "$dict_top\n";
    print OUT "$header_style_cht1$wd_tw$header_style_cht2\n";
    print OUT "$header_style_chs1$wd_cn$header_style_chs2\n";
    print OUT "$header_style_pinyin1$py$header_style_pinyin2\n";
    print OUT "$shiyi_before$exp$shiyi_after\n";
    print OUT "$dict_end\n";
    print OUT "$dict_delimiter\n";

    #link chs=header to cht-header if not same
    if($wd_tw ne $wd_cn){
        print OUT "$wd_cn\n";
        $total_index++;
        print OUT "$dict_link$wd_tw\n";
        print OUT "$dict_delimiter\n";
    }
}
print "Total index is $total_index\n";
print "\nProcess dict content for CC-CEDICT finished!\n";

close(HF);
close(REPORT);
close(OUT);








	
	
