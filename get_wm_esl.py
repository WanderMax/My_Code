#!/usr/bin/env python3
#coding=utf-8

# Note   : remove the specified contents via the id/class name
# usage  : python3 del_content_id.py target_file  id_name
# example: to remove content from test.html in id name "div_tab": python3 del_content_id.py test.html div_tab
# version: v0.01
#
#
# 
#抓取 http://learnersdictionary.com/browse/learners/ 下面词头和对应索引链接
# 
#############################################

from bs4 import BeautifulSoup
import sys,io,os

sys.stdout = io.TextIOWrapper(sys.stdout.buffer,encoding='utf-8')




# 抓取 entries


# 抓取 http://learnersdictionary.com/browse/learners 下 alphalinks 字母头
runPath = os.getcwd()
try:
    os.remove(runPath + '\\' + 'fetch_wm_error.txt')
except:
    pass
# 全局错误日志
fetch_error = open(runPath + '\\' + 'fetch_wm_error.txt','a', encoding='utf-8')

alphalink = r'http://learnersdictionary.com/browse/learners'
print('fetch',alphalink,end='->')
alphalink_code, alphalink_content = get_web(alphalink)
alphalinks = []
if not alphalink_code:
    print('success')
    alphalink_html = BeautifulSoup(alphalink_content,'html.parser')
    alphalink_block = alphalink_html.find(class_='alphalinks')
    alphalink_list = alphalink_block.find_all('li')
    for i in alphalink_list:
        alphalinks.append(i.a.attrs['href'])
    print('get',len(alphalinks),'alpha links')
else:
    print('failed')
    break

alphalinkFile = open(runPath + '\\' + 'fetch_alphalink.txt','a', encoding='utf-8')
json.dump(alphalinks, alphalinkFile, indent =2)
alphalinkFile.close()
    

# 获取每个字母头下 分段链接索引
if os.exist(r'alpha_entry_link.json'):
    os.rename('alpha_entry_link.json','alpha_entry_link_old.json')
    alpha_entry_link_old = open(r'alpha_entry_link_old.json','r', encoding='utf-8')
    entries = json.load(alpha_entry_link_old)
else:
    entries = {}
entrylink_count = 0
for j in alphalinks:
    if j not in entries.keys() or not entries[j]:
    # 每个字母对应的入口链接列表
        alphaentries=[]
        print('fetch',j,end='->')
        entry_code, entry_content = get_web(j)
        if not entry_code:
            print('success')
            try:
                entry_html = BeautifulSoup(entry_content,'html.parser')
                entry_block = entry_html.find(class_='entries')
                entrylink_list = entry_block.find_all('li')
                for ei in entrylink_list:
                    # 填充字母下面入口链接
                    alphaentries.append(ei.a.attrs['href'])
                    entrylink_count + =1
            except:
                fetch_error.write(j + 'failed\n')
            print('get',len(alphaentries),'entry links')
            # 填入词典
            entries[j] = alphaentries
        else:
        fetch_error.write(j + 'failed\n')
    else:
        print('fetch',j,end='->')
        print('existed')
print('get',entrylink_count,'entry links')
alpha_entry_link = open(r'alpha_entry_link.json','a', encoding='utf-8')
json.dump(entries, alpha_entry_link, indent =2)
alpha_entry_link.close()
# 删除旧的 alpha_entry_link_old
try:
    os.remove(r'alpha_entry_link_old.json')
except:
    pass


# 抓取分段入口内单个词头索引
if os.exist(r'word_entry_link.json'):
    os.rename('word_entry_link.json','word_entry_link_old.json')
    word_entry_link_old = open(r'word_entry_link_old.json','r', encoding='utf-8')
    word_entries = json.load(word_entry_link_old)
else:
    word_entries = {}
wordlink_count = 0
# 遍历字母分块链接
for m in entries:
    # 词头链接词典中不存在 或 存在且长度为空
    if m not in word_entries.keys() or not word_entries[m]:
        kw_links=[]
        print('fetch',m,end='->')
        word_code, word_content = get_web(m)
        if not word_code:
            print('success')
            try:
                word_html = BeautifulSoup(word_content,'html.parser')
                word_block = word_html.find(class_='entries')
                word_link_list = word_block.find_all('li')
                for ki in word_link_list:
                    # 填充字母下面入口链接
                    kw_links.append(ki.a.attrs['href'])
                    wordlink_count + =1
            except:
                fetch_error.write(m + 'failed\n')
            print('get',len(kw_links),'word links')
            # 填入词典
            word_entries[m] = kw_links
        else:
        fetch_error.write(m + 'failed\n')
    else:
        print('fetch',m,end='->')
        print('existed')

print('get',wordlink_count,'word links')
word_entry_link = open(r'word_entry_link.json','a', encoding='utf-8')
json.dump(word_entries, word_entry_link, indent =2)
word_entry_link.close()
# 删除旧的 word_entry_link_old
try:
    os.remove(r'word_entry_link_old.json')
except:
    pass

# 获取单纯的词头链接
word_link = []
for iii in word_entries:
    word_link.append(word_entries[iii])
    
print('convert to',len(word_link),'word links')





    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    



