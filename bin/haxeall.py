#!/usr/bin/env python
# calls haxe <build file> on all build files found in subdirectories

import os, os.path, sys, re

for root, dirs, files in os.walk(os.getcwd()):
    for fileName in files:
    	if fileName.endswith(".hxml") and fileName.find("cpp") == -1 and fileName.find("base") == -1:
    		path = os.path.join(root, fileName)[len(os.getcwd()) + 1:]
    		print "       " + path
    		os.system("haxe " + path)

