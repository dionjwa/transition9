#Utils for build scripts

import logging
import os
import platform

def is_linux():
	return platform.system() == 'Linux'

def is_windows():
	return platform.system() == 'Windows'

def is_mac():
	return platform.system() == 'Darwin'
	
def verify_is_executable(path):
	if not os.path.isfile(path):
		logging.error('file does not exist: %s', path)
		return False
	if not os.access(path, os.X_OK):
		logging.error('file is not executable: %s', path)
		return False
	return True
