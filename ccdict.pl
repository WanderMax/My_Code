#! /usr/bin/perl
######################################################################
#Author  : Max
#Date    : 2017-08-03
#Version : v0p1
#Usage   : do.pl  source_file(HF)
#Note	   : read CC-CEDICT source file and make to mdict format
#Revision: 
#         0.01 09.04    initial

#######################################################################
use File::Copy;
use File::Basename;
use Encode;
use strict ;
use utf8::all;

#binmode(STDIN, ':encoding(utf8)');
#binmode(STDOUT, ':encoding(utf8)');
#binmode(STDERR, ':encoding(utf8)');

my @linearray;						
my $arraylength;
my $line1;
my $line2;

open(HF,"$ARGV[0]");
open (OUT,"> output_dict.txt ") or die "Error: Cannot open file to write\n";
open (REPORT,"> report.log ") or die "Error: Cannot open file to write\n";

foreach $line1 (<HF>){
#  $line1 = Encode::decode_utf8($line1);
	chomp ($line1);
	next if($line1 =~ /^\s*\t*$/);			# ignore the blank line
	next if($line1 =~ /^#.*$/);
	$line1 =~s/^\s+//;
	$line1 =~s/\s+$//; 				# remove the blank at both ends of each line.
#	print "Line is $line1\n";
#	print LOG_R "$line1\n";
	push @linearray , $line1;			# push the hard link into array
	}
	
$arraylength = @linearray;				# get numbers of hard link
print "Index Number is $arraylength.\n";
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
print "Extract Process: "	;
for($i=0; $i<@linearray;$i++){
#    printf "%0.5f ",($i+1)/$arraylength;
    $process_line = $linearray[$i];
#    $process_line = Encode::decode_utf8($process_line);
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
#print "\n";
#process explanation
# /to split the bill/to go Dutch/
#first "/"  --> <ul><li>
#middle "/"  --> </li><li>
#last "/"   ---> </li></ul>
#Chinese words --> <a href="entry://key#section">key</a>

my $first_rep = '<ul><li>';
my $middle_rep = '</li><li>';
my $last_rep = '</li></ul>';
my $hlink_after = '<a href="entry://';
my $hlink_middle = '">';
my $hlink_end = '</a>';
my $pinyin_before = '<span class="py2">';
my $pinyin_end = '</span>';
my $bracket_before = '<span class="bra">';
my $bracket_end = '</span>';
my $ch_exp = '[a-zA-Z0-9]*[\x{2e80}-\x{9fa5}，]+';
my $bracket_exp = '\([^\)]+\)';
my $shiyi;
my @all_shiyi_after;
my @shiyi_splited;
foreach (@all_shiyi){
#    print "$_\n";
#    $shiyi = Encode::decode_utf8($_);
    $shiyi = $_;
    #deal with "/"
    $shiyi =~ s/^\/(.*)$/\1/;
    $shiyi =~ s/^(.*)\/$/\1/;
    @shiyi_splited = split /\//, "$shiyi";
    $shiyi = join "$middle_rep" , @shiyi_splited;
#    print  "1 $shiyi\n";   
    $shiyi =~s/^(.+)$/$first_rep\1$last_rep/;
#    print  "2 $shiyi\n";
    #type 1 --> zhongwen|zhongwen[pinyin]
    $shiyi =~s/(.+)\b($ch_exp)\|($ch_exp)($pinyin_exp)(.*)/\1$hlink_after\2$hlink_middle\2$hlink_end\|$hlink_after\3$hlink_middle\3$hlink_end$pinyin_before\4$pinyin_end\5/g;
#    print  "3 $shiyi\n";
    #type 2 --> zhongwen[pinyin]
    $shiyi =~s/(.+)\b($ch_exp)($pinyin_exp)(.*)/\1$hlink_after\2$hlink_middle\2$hlink_end$pinyin_before\3$pinyin_end\4/g;
#    print  "4 $shiyi\n";
    #deal with "()"
    @shiyi_splited = split /\(/, "$shiyi";
    $shiyi = join "$bracket_before" , @shiyi_splited;
    @shiyi_splited = split /\)/, "$shiyi";
    $shiyi = join "$bracket_end" , @shiyi_splited;
#    print  "5 $shiyi\n";
#    print REPORT "$shiyi\n";
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
for($j=0;$j<$header_cht_length;$j++){
    printf "%0.5f ",($j+1)/$header_cht_length;
    $wd_tw =  $header_cht[$j];  
    $wd_cn =  $header_chs[$j];  
    $py = $pinyin[$j];
    $exp = $all_shiyi_after[$j];
    #format dict content    
    print OUT "$wd_tw\n";
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
        print OUT "$dict_link$wd_tw\n";
        print OUT "$dict_delimiter\n";
    }
}

print "\nProcess dict content for CC-CEDICT finished!\n";

close(HF);
close(REPORT);
close(OUT);








	
	
