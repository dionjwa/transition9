#!/usr/bin/env python

#Creates the haxelib package
import os, os.path, string, sys, shutil, tempfile, re, zipfile
from xml.dom import minidom
import argparse

def main (haxelibPath, srcFolders, nonSrcFolders, isLive):
	
	srcFolders = list(set(srcFolders))
	nonSrcFolders = list(set(nonSrcFolders))
	
	print "haxelibPath=", haxelibPath
	print "srcFolders=", srcFolders
	print "nonSrcFolders=", nonSrcFolders
	print "isLive=", isLive
	
	if not os.path.exists(haxelibPath):
		print haxelibPath + " doesn't exist."
		sys.exit(0)
	
	dom = minidom.parse(haxelibPath)
	projectName = dom.documentElement.attributes["name"].value.strip()
	print "Project name: " + projectName
	
	tmpfolder = tempfile.mkdtemp()
	
	def nodot (item):
		return item[0] != '.'
	
	if srcFolders != None:
		for src in srcFolders:
			if not os.path.exists(src):
				continue
			print "Adding", src
			addFolder(src, tmpfolder, True);
	
	if nonSrcFolders != None:
		for src in nonSrcFolders:
			if not os.path.exists(src):
				continue
			print "Adding", src
			addFolder(src, tmpfolder, False);
		
	shutil.copyfile(haxelibPath, os.path.join(tmpfolder, os.path.basename(haxelibPath)))
	zipFileName = os.path.join("/tmp", projectName + ".zip")
	z = zipfile.ZipFile(zipFileName, "w")
	
	for root, dirnames, files in os.walk(tmpfolder, followlinks=True):
		for file in files:
			if file != projectName + ".zip":
				z.write(os.path.join(root, file), os.path.join(root, file).replace(tmpfolder, ""), zipfile.ZIP_DEFLATED )
	z.close()
	
	if isLive:
		command = "haxelib submit " + zipFileName
	else:
		command = "haxelib test " + zipFileName
	print command
	os.system(command)
	shutil.rmtree(tmpfolder)
	os.remove(zipFileName)

def addFolder(src, dest, isSource=False):
	if not isSource:
		dest = os.path.join(dest, os.path.basename(src))
	def nodot (item):
		return item[0] != '.'
	for f in filter(nodot, os.listdir(src)):
		fullfilepath = os.path.join(src, f);
		if os.path.isdir(fullfilepath):
			shutil.copytree(fullfilepath, os.path.join(dest, f), ignore=shutil.ignore_patterns(".DS_Store", ".git", ".svn", "*.xml", "*.zip", "*.sh", "*.hg", "build"	))
		elif re.match(".*(haxelib\.xml|\.hx|\.hxml|\.js|\.nmml|\.png)$", f):
			shutil.copyfile(fullfilepath, os.path.join(dest, f))

if __name__=="__main__":
	parser = argparse.ArgumentParser(description='Package and submit a haxelib package')
	parser.add_argument('--src', action='append', default=["src"], help='A src folder (base folder is ignored, only *.hx files added)')
	parser.add_argument('--extra', action='append', default=[], help='An additional folder to add (base folder included, all files added') #"demo", "demos"
	parser.add_argument('--live', default=False, action="store_true", help='Without this, installs locally only')
	parser.add_argument( '--haxelib', default="etc/haxelib.xml", help='Path to the haxelib.xml file')
	namespace = parser.parse_args()
	main(namespace.haxelib, namespace.src, namespace.extra, namespace.live)
