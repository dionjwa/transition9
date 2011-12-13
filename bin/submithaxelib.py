#!/usr/bin/env python

#Creates and installs (submits) the haxelib package
import os, os.path

os.system("createhaxelib.py etc/haxelib.xml src")

#haxelib install the first found zip file
for f in os.listdir("."):
	if f.endswith(".zip"):
		os.system("haxelib test " + f)
		os.remove(f)
		break;

