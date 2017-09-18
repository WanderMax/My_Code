#! /usr/bin/perl
######################################################################
#Author  : Max
#Date    : 2017-09-18
#Version : v0p10
#Usage   : do.pl  source_file(HF)
#Note	   : read CC-CEDICT source file and make mdict format
#Revision: 
#         0.01 09.04    initial
#         0.02 09.05    add process indicator
#         0.03 09.05    rewrite search code
#         0.04 09.06    add pinyin convert
#         0.05 09.08    improve pinyin convert
#         0.06 09.11    add possible no-dup feature
#         0.07 09.16    fix simple English word loop in pinyin 
#         0.08 09.17    fix nodup issue, add release date print
#         0.09 09.17    fix words with "·" 
#         0.10 09.18    add Pinyin convert switch
#######################################################################
use strict;
use utf8::all;

unlink "output_dict.txt";
unlink "report.log";

#Pinyin convert switch
my $pyswitch = 1;

my @linearray;						
my $arraylength;
my $line1;
my $line2;

open(HF,"$ARGV[0]");
open (TMP,"> tmp_output_dict.txt") or die "Error: Cannot open file to write\n";
open (OUT,"> output_dict.txt") or die "Error: Cannot open file to write\n";
open (REPORT,"> report.log") or die "Error: Cannot open file to write\n";
print "\n####Start Index Process:####\n"	;
my $entries;
my $date_year;
my $date_time;
foreach $line1 (<HF>){
	chomp($line1);
  next if($line1 =~ /^\s*\t*$/);			# ignore the blank line
  # get original index number
	if($line1 =~ /^#\! entries\=([0-9]+)$/){
	  $entries = $1;
	  next if(1);
	}
  # get data date
	if($line1 =~ /^#\! date\=([0-9\-]+)T([0-9\:]+)Z$/){
	  $date_year = $1;
	  $date_time = $2;
	  next if(1);
	}
	next if($line1 =~ /^#(.*)$/);
	$line1 =~s/^\s+//;
	$line1 =~s/\s+$//; 				# remove the blank at both ends of each line.
#	print "Line is $line1\n";
#	print LOG_R "$line1\n";
	push @linearray , $line1;			# push the hard link into array
	}
  
 # foreach (@linearray) { 
 # print REPORT "$_\n";	}

$arraylength = @linearray;				# get numbers of hard link
print "Number of entries is $entries\n";
print REPORT "Number of entries is $entries\n";
print "Latest Release is $date_year $date_time GMT\n";
print REPORT "Latest Release is $date_year $date_time GMT\n";
print "Indexing Number is $arraylength\n";
print REPORT "Index Number is $arraylength\n";


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

my $header_cht_exp = '[a-zA-Z0-9\x{2e80}-\x{9fa5}，\%○·]+';
my $headr_chs_exp = '[a-zA-Z0-9\x{2e80}-\x{9fa5}，\%○·]+';
my $pinyin_exp = '\[[^\]]+\]';
my $all_shiyi_exp = '\/.+\/';
print "\n####Extract Process:####\n"	;
for($i=0; $i<@linearray;$i++){
    if(($i%500==0)||($i==$arraylength-1)){
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

my $header_cht_length = @header_cht;
my $header_chs_length = @header_chs;
my $pinyin_length = @pinyin;
my $all_shiyi_length = @all_shiyi;


#process main pinyin
print "\n#####Main PinYin Process:#####\n"	;
my $eachpinyin;
my $eachpinyined;
my $py;
my @pinyin_after;
for ($py=0;$py<@pinyin;$py++){
    if(($py%500==0)||($py==$pinyin_length-1)){
    printf "%0.3f ",($py+1)/$pinyin_length;
    }
  $eachpinyin = $pinyin[$py];
  # [xxxxxxx]
  #remove the "[  ]"
#  print "Convert $eachpinyin\n";
  $eachpinyined = &convertpy_string($eachpinyin);
#  print "To $eachpinyined\n";
  push  @pinyin_after, $eachpinyined;
}
print "\n";


#process explanation pinyin
print "\n####Explanation PinYin Process:####\n"	;

my $eachitem;
my $eachitemed;
my @shiyipy;
my @shiyipy_ed;
my @all_shiyipy_after;
my $pyzz;
my $m;
my $n;
for($m=0;$m<@all_shiyi;$m++){
    if(($m%500==0)||($m==$all_shiyi_length-1)){
    printf "%0.3f ",($m+1)/$all_shiyi_length;
    }
    $eachitem = $all_shiyi[$m];
#    print "####convert $eachitem\n";
    $eachitemed = &convertpy_string($eachitem);

#    print "To $eachitemed\n";  
    push @all_shiyipy_after, $eachitemed;       
     
}
print "\n";

print "\n####Explanation Query Process####\n";
my $all_shiyipy_after_length = @all_shiyipy_after;
print "Explanation Index before process PinYin is $all_shiyi_length\n";
print "Explanation Index now is $all_shiyipy_after_length\n";
if($all_shiyipy_after_length!=$all_shiyi_length){
  die "Explanation Index no match\n";
  }else{
  print "####Continue Process####\n";
  }
#process explanation
# /to split the bill/to go Dutch/
#first "/"  --> <ul><li>
#middle "/"  --> </li><li>
#last "/"   ---> </li></ul>
#Chinese words --> <a href="entry://key#section">key</a>
print "\n####Explanation Post Process:####\n"	;
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
my $ch_exp = '[a-zA-Z0-9]*[\x{2e80}-\x{9fa5}，·]+';
my $bracket_exp = '\([^\)]+\)';
my $shiyi;
my @all_shiyi_after;
my @shiyi_splited;
for(my $v=0;$v<@all_shiyipy_after;$v++){
    if(($v%500==0)||($v==$all_shiyi_length-1)){
    printf "%0.3f ",($v+1)/$all_shiyi_length;
    }
#    print "$_\n";
    $shiyi = $all_shiyipy_after[$v];
    #replace "," with ", "
    $shiyi =~s/\s*,\s*/, /g;
    #deal with "/"
    $shiyi =~ s/^\/(.*)$/\1/;
    $shiyi =~ s/^(.*)\/$/\1/;
    @shiyi_splited = split /\//, "$shiyi";
    $shiyi = join "$middle_rep" , @shiyi_splited;
#    print  "1 $shiyi\n";  
#    deal with start and end of "/" 
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
#    print REPORT "$shiyi\n";
    push @all_shiyi_after, $shiyi;
  }
 
print "\n";    


#join the splited parts into one

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
my @total_index;
print "\n####Tmp File Process:####\n"	;
for($j=0;$j<$header_cht_length;$j++){
    if(($j % 500 ==0)||($j==$header_cht_length-1)){
    printf "%0.3f ",($j+1)/$header_cht_length;
    }
    $wd_tw =  $header_cht[$j];  
    $wd_cn =  $header_chs[$j];  
    $py = $pinyin_after[$j];
    $exp = $all_shiyi_after[$j];
    #format dict content    
    print TMP "$wd_tw^^^";
    push @total_index,$wd_tw; 
    print TMP "$dict_style";
    print TMP "$dict_top";
    print TMP "$header_style_cht1$wd_tw$header_style_cht2";
    print TMP "$header_style_chs1$wd_cn$header_style_chs2";
    print TMP "$header_style_pinyin1$py$header_style_pinyin2";
    print TMP "$shiyi_before$exp$shiyi_after";
    print TMP "$dict_end^^^";
    print TMP "$dict_delimiter\n";

    #link chs=header to cht-header if not same
    if($wd_tw ne $wd_cn){
        print TMP "$wd_cn^^^";
        push @total_index,$wd_cn; 
        print TMP "$dict_link$wd_tw^^^";
        print TMP "$dict_delimiter\n";
    }
}
my $total_index = @total_index;
#print "\n\n####Report####\n";
print "\nTotal index (may dup) is $total_index\n";

close(TMP);

print "\n####Dup Checking Process:####\n"	;

open(TD,"tmp_output_dict.txt");
my $tmp_line;
my @tmp_array;
foreach $tmp_line (<TD>){
	chomp ($tmp_line);
  push @tmp_array, $tmp_line;
 }
my $index_tmp = @tmp_array;
print "Reading index is $index_tmp\n";
print REPORT "Reading index is $index_tmp\n";

my %count1;
my %count2;
my @dup_index;
my @dict_nodup;
# grep will break the hash
@dict_nodup = grep {++$count1{$_} < 2} @tmp_array;
@dup_index = grep {++$count2{$_} > 1} @tmp_array;

my $dict_nodup_length = @dict_nodup;
my $dup_index_length = @dup_index;
print "Dupped index is $dup_index_length\n";
print REPORT "Dupped index is $dup_index_length\n";
print "No-Dupped index is $dict_nodup_length\n";
print REPORT "No-Dupped index is $dict_nodup_length\n";



print "\n####Dict Source File Process:####\n";
print REPORT "\n######Dupped Index#####\n";
foreach (@dup_index){
    $_ =~ s/\^\^\^/\n/g;
    print REPORT "$_\n";
}

my @dict_nodup_sorted = sort @dict_nodup;
my $kk;
for ($kk=0;$kk<@dict_nodup_sorted;$kk++){
    if(($kk % 500 ==0)||($kk==$dict_nodup_length-1)){
    printf "%0.3f ",($kk+1)/$dict_nodup_length;
    }
    my $dcit_index = $dict_nodup_sorted[$kk];
    $dcit_index =~ s/\^\^\^/\n/g;
    print OUT "$dcit_index\n";
   }



print "\n\nDict source file generated!\n";
print "Process dict content for CC-CEDICT finished!\n";



close(TD);
unlink "tmp_output_dict.txt";
close(HF);
close(REPORT);
close(OUT);



#sub function to convert pinyin in each $string
sub convertpy_string{
my ($string_to_convert) = @_;
my $string_converting;
my $string_converted;
my $py;
my $pyed;
$string_converting = $string_to_convert;
#print "&convertpy_string $string_converting\n";
AD:
if($string_converting =~ /(.*)\[([a-zA-Z1-5 \,·]+)\](.*)/){
      $py = $2;
#      print "Pinyin0 is $py\n";
      if($pyswitch){
      $pyed = &makepy(lc($py));
      }else{
      $pyed = $py;
      }  
#      print "Pinyin1 is $pyed\n"; 
#      print "----$py to $pyed----\n";  
#     [--^<  ]-->^
      $string_converting =~ s/\[$py\]/\^\<$pyed\>\^/g;
#      print "--> $string_converting\n";
      goto AD;     
    }
#   print "return $string_converting\n";
    $string_converting =~ s/\^\</\[/g;
    $string_converting =~ s/\>\^/\]/g;
    $string_converted = $string_converting;
    return($string_converted);
}


#
#TONES = { "1a":"ā", "2a":"á", "3a":"ǎ", "4a":"à", "5a":"a",
#          "1e":"ē", "2e":"é", "3e":"ě", "4e":"è", "5e":"e",
#          "1i":"ī", "2i":"í", "3i":"ǐ", "4i":"ì", "5i":"i",
#          "1o":"ō", "2o":"ó", "3o":"ǒ", "4o":"ò", "5o":"o",
#          "1u":"ū", "2u":"ú", "3u":"ǔ", "4u":"ù", "5u":"u",
#          "1v":"ǖ", "2v":"ǘ", "3v":"ǚ", "4v":"ǜ", "5v":"ü" }
#          "2m":"", "4m":"m̀"
#    # using v for the umlauded u
    
sub makepy{
my ($py) = @_;  # $chk_array is the array in sub
my $py_chk = $py;
my $pying;
my $eachpinyined;
my @return;
# print "&makepy $py_chk\n";
# del "[ ]"
$py_chk =~ s/\[//g;
$py_chk =~ s/\]//g;
my @py_chk = split / /, "$py_chk";
# print "0: @py_chk\n";    
foreach (@py_chk){
    $pying = $_;
#    print "&makepying $pying\n";
    if($pying =~ /(.*)a(.*)([1-5]+)/){
        $pying =~ s/(.*)a(.*)1/\1ā\2/g;
        $pying =~ s/(.*)a(.*)2/\1á\2/g;
        $pying =~ s/(.*)a(.*)3/\1ǎ\2/g;
        $pying =~ s/(.*)a(.*)4/\1à\2/g;
        $pying =~ s/(.*)a(.*)5/\1a\2/g;
#        print "1: $pying\n";
     }elsif($pying =~ /(.*)e(.*)([1-5]+)/){
        $pying =~ s/(.*)e(.*)1/\1ē\2/g;
        $pying =~ s/(.*)e(.*)2/\1é\2/g;
        $pying =~ s/(.*)e(.*)3/\1ě\2/g;
        $pying =~ s/(.*)e(.*)4/\1è\2/g;
        $pying =~ s/(.*)e(.*)5/\1e\2/g; 
#        print "2: $pying\n";
     }elsif($pying =~ /(.*)ou(.*)([1-5]+)/){
        $pying =~ s/(.*)ou(.*)1/\1ōu\2/g;
        $pying =~ s/(.*)ou(.*)2/\1óu\2/g;
        $pying =~ s/(.*)ou(.*)3/\1ǒu\2/g;
        $pying =~ s/(.*)ou(.*)4/\1òu\2/g;
        $pying =~ s/(.*)ou(.*)5/\1ou\2/g; 
#        print "3: $pying\n";
     }elsif($pying =~ /(.*)io(.*)([1-5]+)/){             
        $pying =~ s/(.*)io(.*)1/\1iō\2/g;
        $pying =~ s/(.*)io(.*)2/\1ió\2/g;
        $pying =~ s/(.*)io(.*)3/\1iǒ\2/g;
        $pying =~ s/(.*)io(.*)4/\1iò\2/g;
        $pying =~ s/(.*)io(.*)5/\1io\2/g; 
     }elsif($pying =~ /(.*)iu(.*)([1-5]+)/){
        $pying =~ s/(.*)iu(.*)1/\1iū\2/g;
        $pying =~ s/(.*)iu(.*)2/\1iú\2/g;
        $pying =~ s/(.*)iu(.*)3/\1iǔ\2/g;
        $pying =~ s/(.*)iu(.*)4/\1iù\2/g;
        $pying =~ s/(.*)iu(.*)5/\1iu\2/g;                     
     }elsif($pying =~ /(.*)ui(.*)([1-5]+)/){   
        $pying =~ s/(.*)ui(.*)1/\1uī\2/g;
        $pying =~ s/(.*)ui(.*)2/\1uí\2/g;
        $pying =~ s/(.*)ui(.*)3/\1uǐ\2/g;
        $pying =~ s/(.*)ui(.*)4/\1uì\2/g;
        $pying =~ s/(.*)ui(.*)5/\1ui\2/g; 
     }elsif($pying =~ /(.*)uo(.*)([1-5]+)/){       
        $pying =~ s/(.*)uo(.*)1/\1uō\2/g;
        $pying =~ s/(.*)uo(.*)2/\1uó\2/g;
        $pying =~ s/(.*)uo(.*)3/\1uǒ\2/g;
        $pying =~ s/(.*)uo(.*)4/\1uò\2/g;
        $pying =~ s/(.*)uo(.*)5/\1uo\2/g;  
     }elsif($pying =~ /(.*)i(.*)([1-5]+)/){   
        $pying =~ s/(.*)i(.*)1/\1ī\2/g;
        $pying =~ s/(.*)i(.*)2/\1í\2/g;
        $pying =~ s/(.*)i(.*)3/\1ǐ\2/g;
        $pying =~ s/(.*)i(.*)4/\1ì\2/g;
        $pying =~ s/(.*)i(.*)5/\1i\2/g;         
     }elsif($pying =~ /(.*)o(.*)([1-5]+)/){       
        $pying =~ s/(.*)o(.*)1/\1ō\2/g;
        $pying =~ s/(.*)o(.*)2/\1ó\2/g;
        $pying =~ s/(.*)o(.*)3/\1ǒ\2/g;
        $pying =~ s/(.*)o(.*)4/\1ò\2/g;
        $pying =~ s/(.*)o(.*)5/\1o\2/g;          
     }elsif($pying =~ /(.*)u:(.*)([1-5]+)/){         
        $pying =~ s/(.*)u:(.*)1/\1ǖ\2/g;
        $pying =~ s/(.*)u:(.*)2/\1ǘ\2/g;
        $pying =~ s/(.*)u:(.*)3/\1ǚ\2/g;
        $pying =~ s/(.*)u:(.*)4/\1ǜ\2/g;
        $pying =~ s/(.*)u:(.*)5/\1ü\2/g;               
     }elsif($pying =~ /(.*)u(.*)([1-5]+)/){
        $pying =~ s/(.*)u(.*)1/\1ū\2/g;
        $pying =~ s/(.*)u(.*)2/\1ú\2/g;
        $pying =~ s/(.*)u(.*)3/\1ǔ\2/g;
        $pying =~ s/(.*)u(.*)4/\1ù\2/g;
        $pying =~ s/(.*)u(.*)5/\1u\2/g; 
     }elsif($pying =~ /\,/){
        $pying =~ s/\,/\,/g;
      }elsif($pying =~ /r5/){
        $pying =~ s/r5/r/g;
      }elsif($pying =~ /xx5/){
        $pying =~ s/xx5/xx/g;
      }elsif($pying =~ /[a-z]+/){
      $pying = uc($pying);                #special for English in Pinyin
      }elsif($pying =~ /·/){
      $pying = $pying;                #special for · in Pinyin
      }elsif($pying =~ /(.*)m(.*)[1-5]+/){
        $pying =~ s/(.*)m(.*)2/\1\\u1e3f\2/g;
        $pying =~ s/(.*)m(.*)4/\1m̀\2/g;
     }else {
        print "Icorrect pattern $pying\n"; 
        print REPORT "Icorrect pattern $pying\n"; 
     } 
     push  @return  ,$pying;
}

  $eachpinyined = join " ", "@return";
  $eachpinyined =~ s/^\s+|\s+$//g;
#  print "&makepy result $eachpinyined\n";
  #add back "[]"
#  $eachpinyined =~ s/^(.*)$/\[\1\]/g;
  return ($eachpinyined);
}












	
	
