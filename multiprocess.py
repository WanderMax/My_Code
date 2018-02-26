#!/usr/bin/env python
#coding=utf-8

# Note   : batch run the 5 corners of mipt/ict files in same folder
# usage  : .py
# example: 
# version: v0.01


import sys
import io 
import os, time, datetime
import glob
import multiprocessing 
#sys.stdout = io.TextIOWrapper(sys.stdout.buffer,encoding='utf-8')
starttime = datetime.datetime.now()
def func(msg):
    nowTime=datetime.datetime.now().strftime(' %Y-%m-%d %H:%M:%S')
    for i in xrange(3):
	   # print msg + nowTime
	    time.sleep(1)
    return "done " + msg + nowTime

if __name__ == "__main__":
    pool = multiprocessing.Pool(processes=3)
    result = []
    for i in xrange(12):
        msg = "hello %d" %(i)
        result.append(pool.apply_async(func, (msg, )))
    pool.close()
    pool.join()
    for res in result:
        print res.get()
    print "Sub-process(es) done."
    endtime = datetime.datetime.now()
    print (endtime - starttime)
