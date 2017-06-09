#! /usr/bin/perl

#######################################
# The purpose of this file is:
#   Pex format change
#   Tansfer .mipt(xRC) to .ict(QRC)
#
# 09/15 2014 by Huang Huijuan
# 2016.05.19 Max Wang     fix can not recognise profile mismatch
#######################################

use File::Basename;
($ARGV[0]) or die &usage;

my $fmipt,$fict;
my $dmipt;
my $line;
my $profilename;
my $key,$value;
my @kdiff,@kconduct,@kdielect,@kvia,@kbase;
my @vdiff,@vconduct,@vdielect,@vvia,@vbase;
my $minsp_polycont;
#for indie
my $aname;
my @idxa,@idxb,@data;


$fmipt=$ARGV[0];            # read in file
#print "fmipt = $fmipt\n";
$dmipt=dirname $ARGV[0];    # read in path
#print "dmipt = $dmipt\n";
$fict=basename $ARGV[0];    # read in file name with extension
#print "fict = $fict\n";
# s/// replace function, rename .mipt to .ict
$fict=~s/\.mipt$/\.ict/i;
#print "fict = $fict\n";

# if error, terminate the precess and print the message
open (MIPT,"< $fmipt") or die "ERROR: Cannot open $fmipt to read\n"; # read mipt file $fmipt to MIPT
open (ICT,"> $fict") or die "ERROR: Cannot open $fict to write\n";   # open ICT and write to $fict
# open '<' only read ,'>' only write

#process the mipt file
foreach $line (<MIPT>) {
  chomp $line;
  next if ($line=~/^\s*$/);

  if ($line =~ /process\s*=\s*(\w+)\s*$/) {
        print ICT "######## Process declaration ########\n";
        print ICT "process $1 \{\n";
        print ICT "  temp_reference 25\n";
        print ICT "  background_dielectric_constant 1.0\n";
        print ICT "\}\n";                                               # process message
  } elsif ($line =~ /type\s*=\s*(\w+)\s*$/) {                           # match type = *
        $layertype=$1;
  } elsif ($line =~ /^\s*profile\s*=\s*(\w+)\s*$/) {                    # match profile = *
        $profilename=$1;
  } elsif ($line =~ /end\sprofile\s*=\s*(\w+)\s*$/) {                   # match end profile = *
        if ($1!~/$profilename/) {                                       # !~ --> != not equal
        print "ERROR: Mismatch profile name:profile = $profilename:vs:$line\n";      # rev by Max 2016.05.19 to fix mismatch 
        }
  } else {
        ($key,$value)=&parse($line);                                    # &parse sub-function $key --> variable in ict , $value --> parameter
        $c="min_contact_poly_spacing";
        if ($key=~/min_contact_poly_spacing/) {
            $minsp_polycont=$value;                                     # transfer paramter of min_contact_poly_spacing to $minsp_polycont    
#            print "min_contact_poly_spacing = $minsp_polycont\n";           
            $key="ignore";
        }
    if ($layertype=~/diffusion/) {
        push @kdiff,$key;                                               # push add the element to the kast position of array
        push @vdiff,$value;
    } elsif ($layertype=~/poly/ || $layertype =~ /conductor/) {
#      print "test2:layertype: $layertype key $key\n";
        if ($layertype=~/poly/ && $key=~/name/) {
            $key=$key."_poly";                                          # add _poly to poly variable name
#            print" key = $key\n";
        }
#      print "test3:key $key = $value\n";     
        push @kconduct,$key;
        push @vconduct,$value;
    } elsif ($layertype=~/dielectric/) {
        push @kdielect,$key;
        push @vdielect,$value;
    } elsif ($layertype=~/contact/ || $layertype =~ /via/) {
        push @kvia,$key;
        push @vvia,$value;
    } elsif ($layertype=~/base/) {
        push @kbase,$key;
        push @vbase,$value;
    } else {
        if($layertype){                                                 # message of wrong layer type
            print "WARNING: Unexpexted layertype: $layertype\n";
        } else {
            print "WARNING: Undefined layertype: $line\n";
        }
     }
  }
}

&printdiff;
&printconduct;
&printdielect;
&printvia;

close(MIPT);
close(ICT);

# end 
# sub-function definitions
sub printdiff {
  my $i;
  my $begin=1;
  my $thick;

  print ICT "######## Diffusion declaration ########\n";
  foreach ($i=0;$i<=$#kdiff;$i++) {
    next if ($kdiff[$i]=~/ignore/);                         # next operator,jump to end of the current loop 
    if ($kdiff[$i]=~/name/) {
        if ($begin==1) {
            $begin=0;                                       # name is in the end /fronf of array
        } else {
            print ICT "\}\n\n";
        }
      print ICT "conductor $vdiff[$i] \{\n";                # name ----> print xxxx
#    } elsif ($kdiff[$i]=~/r_sheet/) {
#      $vdiff[$i]=$vdiff[$i]*$thick;
#      $kdiff[$i]="resistivity";
#      print ICT "\t$kdiff[$i]\t $vdiff[$i]\n";
    } else {
      if ($kdiff[$i]=~/thickness/) {                        # thickness
        $thick=$vdiff[$i];                                  # get $value of thickness to $thick
#        print "thicnk = $thick\n";
      }
      print ICT "\t$kdiff[$i]\t $vdiff[$i]\n";              # print  like height/min_width/thickness/etc
#      print "\t$kdiff[$i]\t $vdiff[$i]\n";
    }
  }
  print ICT "\tgate_forming_layer\t true\n";                # recommended to add gate_forming_layer true to all conductor statements below the metal1 conductor statement
  print ICT "\tlayer_type\t diffusion\n";                   # (typically include poly /diffusion /local interconnect/copper contact layers
  print ICT "\}\n\n";

}

sub printconduct {
  my $i;
  my $polylayer=0;
  my $begin=1;
  my $indie,$vres;
  my $thick;
  my $sextraw,$vextraw;
  my $mwidth;

  print ICT "######## Conducting layer declaration ########\n";
  foreach ($i=0;$i<=$#kconduct;$i++) {
    next if ($kconduct[$i]=~/ignore/);                      # if ignore, jump to the end of loop
    if ($kconduct[$i]=~/name/) {
      if ($begin==1) {                                      # 
        $begin=0;
      } else {

### extra lines before end of a conduct layer ### 
         if ($polylayer==1) {                               # if poly layer
          print ICT "\tmin_contact_poly_spacing\t $minsp_polycont\n";
          print ICT "\tgate_forming_layer\t true\n";
          print ICT "\tlayer_type\t gate\n";
        } else {
          print ICT "\tgate_forming_layer\t false\n";
          if ($sextraw==1) {
            print ICT "\twire_top_enlargement\t $vextraw\n";        # twire_top_enlargement = extra_width/4
            print ICT "\twire_bottom_enlargement\t -$vextraw\n";
            print ICT "\twire_bottom_etching_c \{\n";
            print ICT "\t  wbe_silicon_widths $mwidth\n";
            print ICT "\t  wbe_bottom_thickness_adjustments 0.00000\n";
            print ICT "\t\}\n";
            print ICT "\twire_bottom_etching_r \{\n";
            print ICT "\t  wbe_silicon_widths $mwidth\n";
            print ICT "\t  wbe_bottom_thickness_adjustments 0.00000\n";
            print ICT "\t\}\n";
          }
        }
### process resistivity and indie file ###
        if ($indie) {
#      print "indie1 = $indie\n";                                   # I don't know the indie flow
#      print "thick1 = $thick\n";
          &processindie($indie,$thick);                             # $indie $thick are input parameters
        } elsif ($vres) {
#          print "vres = $vres\n";
          print ICT "\tresistivity\t $vres\n";                      # 
        } 

        $vres=0;
        $indie="";
        print ICT "\}\n\n";
      }

      if ($kconduct[$i]=~/_poly/){
        $polylayer=1;
      }else {
        $polylayer=0;
      }
      $sextraw=0;
      $vextraw=0;

      print ICT "conductor $vconduct[$i] \{\n";
    } elsif ($kconduct[$i]=~/resistivity/) {
      $vres=$vconduct[$i];                                      # value of r_sheet/resistivity ---> $vres
#    } elsif ($kconduct[$i]=~/r_sheet/) {
#      $vres=$vconduct[$i]*$thick;
    } elsif ($kconduct[$i]=~/extra_width/) {
      $sextraw=1;
      $vextraw=$vconduct[$i];                                   # vcont = extra_width/4
#      print "vextraw = $vextraw\n";
    } elsif ($kconduct[$i]=~/indie_file/) {
      $indie=$vconduct[$i];                                     # $indie --> full path of indie file
#      print "indie = $indie\n";
    } else {
      if ($kconduct[$i] =~ /thickness/) {
        $thick=$vconduct[$i];
      } elsif ($kconduct[$i] =~ /min_width/) {                  # get thickness/min_width to $thick/$mwidth
        $mwidth=$vconduct[$i];
      }
      print ICT "\t$kconduct[$i]\t $vconduct[$i]\n";             # print thickness/min_width/heignt/etc to ict
#      print  "\t$kconduct[$i]\t $vconduct[$i]\n";
    }
  }
  print ICT "\tgate_forming_layer\t false\n";
### process resistivity and indie file ###
  if ($indie) {
#    print "indie2 = $indie\n";
#    print "thick2 = $thick\n";
    &processindie($indie,$thick);
  } elsif ($vres) {
#    print "vres = $vres\n";
    print ICT "\tresistivity\t $vres\n";
  } 
#  print "test4:polylayer: $polylayer\n";
  print ICT "\}\n\n";

}

sub printdielect {
  my $i;
  my $begin=1;

  print ICT "######## Dielectric layer declaration ########\n";
  foreach ($i=0;$i<=$#kdielect;$i++) {
    next if ($kdielect[$i]=~/ignore/);
    if ($kdielect[$i]=~/name/) {
      if ($begin==1) {
        $begin=0;
      } else {
        print ICT "\}\n\n";                                         # name is the begin or end of one defination
      }
      print ICT "dielectric $vdielect[$i] \{\n";
    } else {
      print ICT "\t$kdielect[$i]\t $vdielect[$i]\n";                # print all syntax and value
#      print "\t$kdielect[$i]\t $vdielect[$i]\n";
    }
  }
  print ICT "\}\n\n";

}

sub printvia {
  my $i;
  my $begin=1;

  print ICT "######## Contacts and via declaration ########\n";
  foreach ($i=0;$i<=$#kvia;$i++) {
    next if ($kvia[$i]=~/ignore/);
    if ($kvia[$i]=~/name/) {
      if ($begin==1) {
        $begin=0;                                                        # name is the begin or end of one defination
      } else {
        print ICT "\}\n\n";
      }
      print ICT "via $vvia[$i] \{\n";
    } else {
      print ICT "\t$kvia[$i]\t $vvia[$i]\n";                            # print all syntax and value
#      print "\t$kvia[$i]\t $vvia[$i]\n";
    }
  }
  print ICT "\}\n\n";

}

sub printbase {
  my $i;
  my $begin=1;

  print ICT "######## Base layer declaration ########\n";
  foreach ($i=0;$i<=$#kbase;$i++) {
    next if ($kbase[$i]=~/ignore/);
    if ($kbase[$i]=~/name/) {
      if ($begin==1) {
        $begin=0;                                                       # name is the begin or end of one defination
      } else {
        print ICT "\}\n\n";
      }
      print ICT "base $vbase[$i] \{\n";
    } else {
      print ICT "$kbase[$i] $vbase[$i]\n";                              # print all syntax and value
#      print "$kbase[$i] $vbase[$i]\n";
    }
  }
  print ICT "\}\n\n";

}

# process indie file
sub processindie {
  my $fname;
  my $item;
  my @atmp;
  my $i;
  my $na,$nb;
  my $sign=0;
  my $thk;
#global variable
#  my $aname;
#  my @idxa,@idxb,@data;

  $fname= shift;                                # input indie file
#  print "fname = $fname\n";
  $thk= shift;
#  print "thk = $thk\n";                         # input thickness value  
#print "test5:dmipt:$dmipt fname:$fname\n";
  if ($fname!~/^\//) {                          # "/" in front
    $fname=$dmipt."/".$fname;                   # add "/" into $dmipt/$fname;$dmipt is the path, so $fname is the full path of indie file
  }                                             # 1.indie --> ./1.indie
#print "test5:$fname\n";

  open (FINDIE,"<$fname") or warn "WARNING: Cannot open $fname to read\n";
  foreach $item (<FINDIE>) {
    next if ($item=~/^\s*$/);                 # if match blank line jump to the end of loop
#    print "item1 = $item\n";
    next if ($item=~/name/);                  # if match name jump to the end of loop
#    print "item2 = $item\n";
    chomp $item;
#    print "item2 = $item\n";
    $item=~s/^\s+//;
    $item=~s/\s+$//;                          # remove blank in front and end

#print "test7:$item\n";
    if ($item=~/^\*/) {                        # match * in indie file 
      if ($sign==1) {
        if ($i!=$nb) {
          print "ERROR: Unmatched v index number:idx $nb data $i name $aname\n";
        }
#print "test1x:$aname\n";
        &printarray($thk);
      }
#      if ($item =~ /rho/ || $item =~ /width/ ) {
      if ($item =~ /rho/ || $item =~ /width/ || $item =~ /thickness/) {                     # switch to match thickness
        $sign=1;
#        print "item1 = $item\n";
        @atmp =split /\s+/,$item;               # get the array raw and column to array @atmp
#        print "atmp2 = $atmp[0]/$atmp[1]/$atmp[2]/$atmp[3]\n";
        $aname=$atmp[1];                        # array name
        $nb=$atmp[2];                           # raw number
        $na=$atmp[3];                           # column number
#       print "size = $aname/ $nb/ $na\n";
      } else {
        $sign=0;
      }
#print "test6:$sign $nb $na $item\n";

    } elsif ($item=~/^x/) {                 # first line of array block
      next if (!$sign);
      @idxa=();
      @idxb=();
      @data=();
      @idxa=split /\s+/,$item;
      shift @idxa;
      if ($#idxa!=$na-1) {
        print "ERROR: Unmatched h index number:idx $na data $#idxa+1\n  $item\n";
      }
      $i=0;
    } elsif ($item=~ /^\d+/) {
      next if (!$sign);
      @atmp =split /\s+/,$item;
      $idxb[$i]=shift @atmp;
      if ($#atmp!=$na-1) {
        print "ERROR: Unmatched h index number:idx $na data $#atmp+1\n  $item\n";
      }
      for ($j=0;$j<=$#atmp;$j++) {
        $data[$i][$j]=$atmp[$j];
#print "test8:$data[$i][$j]\n";
      }
      $i++;
    } else {
      print "WARNING: Unrecognized line:$fname\n  $item\n";
    }
  }

  if ($sign==1) {
    if ($i!=$nb) {
      print "ERROR: Unmatched v index number:idx $nb data $i name $aname\n";
    }
    &printarray($thk);
  }

  close (FINDIE);
}

sub printarray {
  my $i,$j;
  my $thk;

  $thk=shift; 

#print "test1x:$aname\n";
  if ($aname=~/rho/) {
    print ICT "\trho\n";
  } elsif ($aname=~/width/) {
    print ICT "\twire_edge_enlargement \{\n";
  } elsif ($aname=~/thickness/){
    print ICT "\twire_thickness_ratio \{\n";
    print ICT "\t  wtr_tile_width 100\n";
    print ICT "\t  wtr_densities 1\n";
  } 

  if ($aname=~/rho/) {
    print ICT "\t  rho_widths";
  } elsif ($aname=~/width/) {
    print ICT "\t  wee_widths";
  } elsif ($aname=~/thickness/){
    print ICT "\t  wtr_widths";
  } 
  for ($i=0;$i<=$#idxb;$i++) {
    print ICT " $idxb[$i]";
  }
  print ICT "\n";

  if ($aname=~/rho/) {
    print ICT "\t  rho_spacings";
  } elsif ($aname=~/width/) {
    print ICT "\t  wee_spacings";
  } elsif ($aname=~/thickness/){
    print ICT "\t  wtr_spacings";
  } 
  for ($i=0;$i<=$#idxa;$i++) {
    print ICT " $idxa[$i]";
  }
  print ICT "\n";
 
  if ($aname=~/rho/) {
    print ICT "\t  rho_values";
  } elsif ($aname=~/width/) {
    print ICT "\t  wee_adjustments";
  } elsif ($aname=~/thickness/){
    print ICT "\t  wtr_adjustments";
  } 

#print "test2x:$#idxa,$#idxb\n";
#print "test1x:thk $thk\n";
  for ($i=0;$i<=$#idxa;$i++) {
    if ($i!=0) {
      print ICT "\t   ";
    }
    for ($j=0;$j<=$#idxb;$j++) {
      $tmp=0;
      if ($aname=~/rho/) {
        $tmp=$data[$j][$i];                         # print rho array to ict
      } elsif ($aname=~/width/) {
        $tmp=($data[$j][$i]-$idxb[$j])/2;           # print (silicon width-draw width)/2 to ict
        $tmp=sprintf "%.5f",$tmp;
#print "i:$i test1x:idx $idxb[$i] data $data[$i][$j] tmp $tmp\n";
      } elsif ($aname=~/thickness/){
#        $tmp=$data[$i][$j];
        $tmp=$data[$j][$i]/$thk;                    # print silicon thickness/idle to ict 
        $tmp=sprintf "%.7f",$tmp;
      }

      print ICT " $tmp";
    }
    print ICT "\n";
  }
  if ($aname=~/width/ || $aname=~/thickness/) {
    print ICT "\t\}\n";
  }
}


sub parse {                             # convert syntax from mipt to ict
  my $line_i;
  my $a,$b,$c;

  $line_i=shift;                        # shift the left one of array to $line_i
#  print "test0:$line_i\n";
  $line_i=~s/^\s+//;                    # remove blank in the front of $line_i
#  print "test01:$line_i\n";            # s/// replace function
  $line_i=~s/\s+$//;                    # remove blank in the end of $line_i
#  print "test02:$line_i\n";
  ($a,$b)=split /\s*=\s*/,$line_i;      # split variable and parameter via " = " to $a and $b
#  print "test1:a b:$a $b\n";

  if ($a=~/name/) {                     # map variables from mipt to that of ict
    $c="name";                          # name --> name
  } elsif ($a=~/zbottom/) {
    $c="height\t";                      # zbottom --> height
  } elsif ($a=~/thickness/) {
    $c="thickness";                     # thickness --> thickness
  } elsif ($a=~/conformal/) {           # conformal =true|false is only mipt 1.0 syntax
    $c=$a;                              # conformal --> conformal
#print "test6:$c\n";
  } elsif ($a=~/diel_type/) {           # diel_type = confromal|planar for mipt
    $c="conformal";                     # diel_type --> confromal
    if ($b=~/conformal/) {
      $b="true";
    } elsif ($b=~/planar/) {
      $b="false";
    } else {
      $b="false";
    }
  } elsif ($a=~/edge_bias/) {
    $c="ignore";                        # edge_bias --> ignore it
  } elsif ($a=~/eps/) {
    $c="dielectric_constant";           # eps --> dielectric_constant
  } elsif ($a=~/ref_layer/) {
    $c="expandedFrom";                  # ref_layer --> expandedFrom
  } elsif ($a=~/swthk/) {
    $c="sideExpand";                    # swthk ---> sideExpand
  } elsif ($a=~/topthk/) {
    $c="topThickness";                  # topthk --> topThickness
  } elsif ($a=~/resistivity/||$a=~/r_sheet/) {
    $c="resistivity";                   # resistivity/r_sheet --> resistivity
#  } elsif ($a=~/r_sheet/) {
#    $c="r_sheet";
  } elsif ($a=~/min_width/) {
    $c="min_width";                     # min_width --> min_width
  } elsif ($a=~/min_spacing/) {
    $c="min_spacing";                   # min_spacing --> min_spacing
  } elsif ($a=~/tc1/) {
    $c="temp_tc1";                      # tc1 --> temp_tc1
  } elsif ($a=~/tc2/) {
    $c="temp_tc2";                      # tc2 --> temp_tc2
  } elsif ($a=~/n1/) {                  # n1 --> ohms x microns squared
    $c="area_resistance";
    $b=$b." 1";                         # n1 --> area_resistance 1(area) //area_resistance res area
#print "area_res = $b\n";
  } elsif ($a=~/n2/) {
    $c="ignore";                        # n2 --> ignore it
  } elsif ($a=~/layer_bias/) {
    $c="ignore";                        # layer_bias --> ignore it
#    $c="wire_edge_enlargement";
  } elsif ($a=~/extra_width/) {
    $c="extra_width";                   # extra_width --> wire_top_enlargemnet
#    $c="wire_top_enlargemnet";
    $b=$b/4;                            # parameter --> parameter/4
  } elsif ($a=~/measured_from/) {
    $c="bottom_layer";                   # measured_from --> bottom_layer
  } elsif ($a=~/measured_to/) {
    $c="top_layer";                      # measured_to --> top_layer
  } elsif ($a=~/area/) {
    $c="ignore";                         # area --> ignore it
  } elsif ($a=~/resistance/) {
    $c="contact_resistance";             # resistance --> contact_resistance
  } elsif ($a=~/enclosure_up/) {
    $c="min_top_encl";                   # enclosure_up --> min_top_encl
  } elsif ($a=~/enclosure_down/) {
    $c="min_bot_encl";                   # enclosure_down --> min_bot_encl
  } elsif ($a=~/min_poly_cont_spacing/) {
    $c="min_contact_poly_spacing";       # min_poly_cont_spacing --> min_contact_poly_spacing
  } elsif ($a=~/gate_to_cont_spacing_min/) {
    $c="min_contact_poly_spacing";       # gate_to_cont_spacing_min --> min_contact_poly_spacing
  } elsif ($a=~/gate_to_via_spacing_min/) {
    $c="ignore";                         # gate_to_via_spacing_min --> ignore it
  } elsif ($a=~/indie_file/) {
    $c="indie_file";                     # indie file --> process in other function
  } else {
    $c="ignore";
  }

  if (!defined $b) {
    $b="null";
  }
#print "test:c b:: $c   $b\n";  
  return ($c,$b);                        # return variable $key and parameter $value for ict
}

sub usage {
  print "$0 <filename>.mipt\n";
}
