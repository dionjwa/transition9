#!/usr/bin/env python

import glob
import logging
import os
import re
import json
import string
import StringIO
import subprocess
import xml.etree.ElementTree as xml
import argparse
import fnmatch
import build_utils

XML_NAMESPACE = "{http://macromedia/2003/swfx}"

def get_swf_files(swfpaths, swffolders):
	swfs = []
	if swfpaths is not None:
		swfs = swfpaths + swfs
	if swffolders is not None:
		for swffolder in swffolders:
			for root, dirnames, filenames in os.walk(swffolder):
				for filename in fnmatch.filter(filenames, '*.swf'):
					swfs.append(os.path.join(root, filename))
	return swfs

def get_flex_swfdump_path(flexpath):
	swfdump_name = 'swfdump.exe' if build_utils.is_windows() else 'swfdump'
	swfdump_path = os.path.join(flexpath, 'bin', swfdump_name)
	return swfdump_path
	
def get_swf_classnames(swf_path, swfdump_path):
	if not build_utils.verify_is_executable(swfdump_path):
		return []
	
	classnames = []
	cmd = [swfdump_path, '-noactions', '-nofunctions', '-noglyphs', swf_path]
	logging.info("cmd: %s" % string.join(cmd, " "))
	print cmd
	try:
		proc = subprocess.Popen(cmd, shell=False, stdout=subprocess.PIPE)
		
		outdata, errdata = proc.communicate()
		if errdata:
			logging.error("Error running swfdump: %s" % errdata)
		else:
			try:
				outdata = outdata.decode('cp1252').encode('utf8')   # handle invalid xml - copyright symbol breaks parsing
			except UnicodeDecodeError:
				pass
			try:
				tree = xml.parse(StringIO.StringIO(outdata))
			except xml.ParseError as xmlerror:
				logging.error("Error parsing swfdump xml: %s" % xmlerror)
				return []
			symbol_list = tree.findall("%sSymbolClass/%sSymbol" % (XML_NAMESPACE, XML_NAMESPACE))
			if symbol_list:
				for symbol in symbol_list:
					if symbol.attrib.has_key("className"):
						classnames.append(symbol.attrib["className"])
					else:
						logging.error("Could not find className attribute in node: %s %s" % (symbol.tag, symbol.attrib))
			else:
				logging.warn("no symbols found in swf: %s" % swf_path)
		classnames.sort()
		return classnames
	except RuntimeError as e:
		logging.error("Error running swfdump: %s" % e)
		return []

def main(namespace):
	#Create the swf JSON
	swfs = get_swf_files(namespace.swf, namespace.dir)
	data = {}
	data["swfs"] = {}
	for swf in swfs:
		swfname = swf.split(os.sep)[-1]
		print swfname
		data["swfs"][swfname] = {}
		data["swfs"][swfname]["path"] = swf
		symbols = []
		data["swfs"][swfname]["symbols"] = symbols
		for symbol in get_swf_classnames(swf, get_flex_swfdump_path(namespace.flexsdk)): 
			symbols.append(symbol)
	symbols.sort()
	if namespace.out is not None:
		f = open(namespace.out, 'w')
		f.write(json.dumps(data, sort_keys=True, indent=4))
		f.close()
	print json.dumps(data, sort_keys=True, indent=4)
	
if __name__=="__main__":
	parser = argparse.ArgumentParser(description='Create a json blob with swfs and their symbols')
	parser.add_argument('--flexsdk', default='.', help='Location of the flex sdk')
	parser.add_argument('--swf', action='append', default=[], help='A swf file to parse')
	parser.add_argument('--dir', action='append', default=[], help='Folders to recursively look for swf files to parse')
	parser.add_argument('--out', default=["swfmanifest.json"], help='JSON output')
	namespace = parser.parse_args()
	main(namespace)
