#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Change default encoding to utf8 

##########################################################################
#Author  : Max
#Date    : 2017/11/14
#Note    : Merge all files in the specified folder into one file
#Usage   : python merge_in_dir.py full_target_dir
#Version : v0.01
#Revision: 
#          v0.01 2017/11/14   initial

###########################################################################

import sys
import io 
import os
sys.stdout = io.TextIOWrapper(sys.stdout.buffer,encoding='utf-8')

if len(sys.argv)!=2:
  print('Please execute script as below:\n  python merge_in_dir.py full_target_dir\n...Exit')
  sys.exit()
else:
  source_folder = sys.argv[1]

print('\n#### Process Info ####')
# get path delimiter for different platform
if sys.platform == "win32":
  spliter = '\\'
else:
  spliter = r'/'
print(sys.platform,'system spliter:',spliter)

 
print('source folder:',source_folder) 
foler_name = source_folder.split('/')[-1]
print('parentfolder name:',foler_name)

if os.path.exists(source_folder):
  file_list = os.listdir(source_folder)
  print('files containing:',len(file_list))

print('\n#### File Merging ####')
output_name = foler_name + '_merged.txt'
if os.path.exists(output_name):
  os.remove(output_name)
if os.path.exists(foler_name + '_log.txt'):
  os.remove(foler_name + '_log.txt')

fout = open(output_name,'a',encoding='utf-8')
log = open(foler_name + '_log.txt','a',encoding='utf-8')

for i in file_list:
  print('processing file:',i)
  try:
    file_content = open(source_folder+'/'+i,'r',encoding='utf-8')
    fout.write(i+'\n')
#   remove \n 
    fout.write(file_content.read().strip())
#   remove all \n in file content
#   fout.write(file_content.read().replace('\n',''))
    fout.write('\n</>\n')
    file_content.close()
  except:
    print('process file failed:',i)
    log.write(i,'failed\n')
  
fout.close()
log.close()
print('\n#### Merge Files Done ####')
