#!/usr/bin/env python3
#coding=utf-8

# Note   : remove the specified contents via the id/class name
# usage  : python3 del_content_class.py target_file  class_name
# example: to remove content from test.html in class name "div_tab": python3 del_content_class.py test.html div_tab
# version: v0.01

from bs4 import BeautifulSoup
import sys,io,os

sys.stdout = io.TextIOWrapper(sys.stdout.buffer,encoding='utf-8')

	
# print(html_doc)
# open file as the html file
with open(sys.argv[1], encoding='utf-8') as doc:
  with open('output.txt','w+', encoding='utf-8') as fout:   #overwrite the existing content
    # parser the html file via BeautifulSoup module to my file
    myfile = BeautifulSoup(doc,'html.parser')
#    fout.write(myfile.prettify())
    # find the content to be removed
    class_find = sys.argv[2] 
########### type-I ################################ 
#    del_content = myfile.find_all(class_=class_find)
#    for i in del_content:
#      print(i)
#      i.extract()
 
########### type-II ###############################  
    del_content = myfile.find(class_=class_find)
    while del_content:
        print(del_content)
        del_content.extract()
        del_content = myfile.find(class_=class_find)              
    #print(myfile)
    fout.write(myfile.prettify())
    


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
