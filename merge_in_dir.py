#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Change default encoding to utf8 

##########################################################################
#Author  : Max
#Date    : 2017/11/15
#Note    : Merge all files in the specified folder into one file
#Usage   : python merge_in_dir.py full_target_dir
#Version : v0.02
#Revision: 
#          v0.01 2017/11/14   initial
#          v0.02 2017/11/15   add specified contents removal

###########################################################################

import sys
import io 
import os
import re
from bs4 import BeautifulSoup
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
    file_open = open(source_folder+'/'+i,'r',encoding='utf-8')
    fout.write(i+'\n')
    fout.write(r'<head><meta http-equiv="content-type" content="text/html; charset=utf-8"><link rel="stylesheet" href="aaa.css"/><script type="text/javascript" src="aaa.js"></script></head>'+'\n')
    html = BeautifulSoup(file_open,'html.parser')
#   add elements to be removed from the file
    # left and right navi-part
    list_a = html.find_all(class_='q_right')
    list_b = html.find_all(class_='q_left')
    # top center search column
    list_c = html.find_all(class_='main_01')   
    list_d = html.find_all(class_='q_m_ricon') 
    # embedded script file and push part
    list_e = html.find_all('script')
    list_f = html.find_all(id=re.compile('div-gpt-ad-.*'))
    # merge remove list
    del_list = list_a + list_b + list_c + list_d + list_e + list_f
    for del_i in del_list:
        del_i.extract()
    html_strings = str(html)   
    comment_lines = re.compile(r'<!--[\s\S]*?-->')
    blank_lines = re.compile(r'^\s*$',re.M)
    contents = blank_lines.sub('',comment_lines.sub('',html_strings)).replace('\n','')
#   remove \n 
    fout.write(contents.strip())
#   remove all \n in file content
#   fout.write(file_content.read().replace('\n',''))
    fout.write('\n</>\n')
    file_open.close()
  except:
    print('process file failed:',i)
    log.write(i,'failed\n')
  
fout.close()
log.close()
print('\n#### Merge Files Done ####')




# define the sub-function to remove contents in specified class and id

#def del_class_content(html_Doc,class_Name):
    



















