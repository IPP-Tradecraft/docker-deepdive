# Written by Scott Phillpott
# 23 August 2016
# Intent is to have this program covert all .docx filenames in directory to .txt format.

import pypandoc
import os

docroot="./docxdocuments"

intype= input("What format for input? ")
outtype= input("what output for output? ")

for filename in os.listdir(docroot):
	if filename.endswith(intype):
		fullpath = os.path.join(docroot, filename);
		output = pypandoc.convert_file(fullpath, outtype)
		outfile = fullpath[:-4]  + outtype
		f = open(outfile, 'w')
		f.write(output)
		f.close()
