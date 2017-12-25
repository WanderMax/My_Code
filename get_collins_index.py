#!/usr/bin/env python3
#coding=utf-8

# Note   : remove the specified contents via the id/class name
# usage  : python3 del_content_id.py target_file  id_name
# example: to remove content from test.html in id name "div_tab": python3 del_content_id.py test.html div_tab
# version: v0.01
#
#
# 
#抓取 https://www.collinsdictionary.com/browse/english/words-starting-with-digit 下面词头和对应索引链接
# 
#############################################

from bs4 import BeautifulSoup
import sys,io,os

sys.stdout = io.TextIOWrapper(sys.stdout.buffer,encoding='utf-8')

letters = ['https://www.collinsdictionary.com/browse/english/words-starting-with-a','https://www.collinsdictionary.com/browse/english/words-starting-with-b','https://www.collinsdictionary.com/browse/english/words-starting-with-c','https://www.collinsdictionary.com/browse/english/words-starting-with-d','https://www.collinsdictionary.com/browse/english/words-starting-with-e','https://www.collinsdictionary.com/browse/english/words-starting-with-f','https://www.collinsdictionary.com/browse/english/words-starting-with-g','https://www.collinsdictionary.com/browse/english/words-starting-with-h','https://www.collinsdictionary.com/browse/english/words-starting-with-i','https://www.collinsdictionary.com/browse/english/words-starting-with-j','https://www.collinsdictionary.com/browse/english/words-starting-with-k','https://www.collinsdictionary.com/browse/english/words-starting-with-l','https://www.collinsdictionary.com/browse/english/words-starting-with-m','https://www.collinsdictionary.com/browse/english/words-starting-with-n','https://www.collinsdictionary.com/browse/english/words-starting-with-o','https://www.collinsdictionary.com/browse/english/words-starting-with-p','https://www.collinsdictionary.com/browse/english/words-starting-with-q','https://www.collinsdictionary.com/browse/english/words-starting-with-r','https://www.collinsdictionary.com/browse/english/words-starting-with-s','https://www.collinsdictionary.com/browse/english/words-starting-with-t','https://www.collinsdictionary.com/browse/english/words-starting-with-u','https://www.collinsdictionary.com/browse/english/words-starting-with-v','https://www.collinsdictionary.com/browse/english/words-starting-with-w','https://www.collinsdictionary.com/browse/english/words-starting-with-x','https://www.collinsdictionary.com/browse/english/words-starting-with-y','https://www.collinsdictionary.com/browse/english/words-starting-with-z']


# 直接添加到分块链接里面
digit_link = r'https://www.collinsdictionary.com/browse/english/words-starting-with-digit'

runPath = os.getcwd()
try:
    os.remove(runPath + os.sep + 'fetch_collins_error.txt')
except:
    pass
# 全局错误日志
fetch_error = open(runPath + os.sep + 'fetch_collins_error.txt','a', encoding='utf-8')

# 抓取每个字母下面的分块链接部分 抓取26次
# 全部字母的分块索引词典
all_letter_block_dict = {}
for letter_link in letters:
    print('fetch',letter_link,end='->')
    letter_link_code, letter_link_content = get_web(letter_link)
    # 单个字母下全部分块索引列表
    letter_block = []
    # 抓取成功
    if not letter_link_code:
        print('success')
        try:
            html = BeautifulSoup(letter_link_content,'html.parser')
            # 分块列表
            browse_list = html.find(class_='columns2 browse-list')
            block_list = browse_list.find_all('li')
            for i in block_list:
                letter_block.append(i.a.attrs['href'])
            print('get',len(letter_block),'block links')
            # 填入词典
            all_letter_block_dict[letter_link] = letter_block
        except:
            fetch_error.write(letter_link + 'failed\n')
    else:
        print('failed')
        fetch_error.write(letter_link + 'failed\n')
# 填充 digit 部分
all_letter_block_dict[digit_link] = digit_link
# 保存为 json
all_letter_block = open(runPath + os.sep + 'all_letter_block.json','a', encoding='utf-8')
json.dump(all_letter_block_dict, all_letter_block, indent =2)
all_letter_block.close()
print('get block link number:',len(all_letter_block_dict.values()))

# 抓取每个分块链接中 真词头索引链接 抓取很多次

if os.exist(r'all_index_dict.json'):
    os.rename('all_index_dict.json','all_index_dict_old.json')
    all_index_dict_old = open(r'all_index_dict_old.json','r', encoding='utf-8')
    index_dict = json.load(all_index_dict_old)
    all_index_dict_old.close()
    os.remove(r'all_index_dict_old.json')
else:
    index_dict = {}

for block_link in all_letter_block_dict.values():
    print('fetch',block_link,end='->')
    # 不存在 或 抓取失败
    if block_link not in index_dict or not index_dict[block_link]:
        block_link_code, block_link_content = get_web(block_link)
        # 单个分块下全部词头索引列表
        index_block = []
        # 抓取成功
        if not block_link_code:
            print('success')
            try:
                html = BeautifulSoup(block_link_content,'html.parser')
                # 词头列表
                browse_list = html.find(class_='columns2 browse-list')
                index_list = browse_list.find_all('li')
                for i in index_list:
                    index_block.append(i.a.attrs['href'])
                print('get',len(index_block),'index links')
                # 填入词典
                index_dict[block_link] = index_block
            except:
                fetch_error.write(block_link + 'failed\n')
        else:
            print('failed')
            fetch_error.write(block_link + 'failed\n')
    else:
        print('existed')
        continue
# 保存 index_dict 为 json
all_index_dict = open(runPath + os.sep + 'all_index_dict.json','a', encoding='utf-8')
json.dump(index_dict, all_index_dict, indent =2)
all_index_dict.close()


# 保存词头索引列表
all_index = open(runPath + os.sep + 'all_index.json','a', encoding='utf-8')
json.dump(list(index_dict.values()), all_index, indent =2)
all_index.close()
print('get index link number:',len(index_dict.values()))




    


