import sys
import os.path
import json

infn = sys.argv[1]
with open(infn, 'r') as inf:
	data = json.loads(inf.read())

	gid = os.path.basename(infn).split('-')[0]
	with open(os.path.join(os.path.dirname(infn), '{0}-User.txt'.format(gid)), 'w') as outf:
		for note in data:
			outf.write("N0:{0}:{1}\n".format(note['Address'], json.dumps(note['Note'])))