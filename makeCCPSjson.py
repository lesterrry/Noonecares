'''''''''''''''''''''''''''''
COPYRIGHT LESTERRRY,
2022

'''''''''''''''''''''''''''''
import sys
from PIL import Image
from tqdm import tqdm
import os
import json

RED = "\033[31m"
GRN = "\033[32m"
ORG = "\033[33m"
CYN = "\033[36m"
BLD = "\033[1m"
RES = "\033[0m"

def my_except_hook(exctype, value, traceback):
	print(f'{RED + BLD}ERROR:{RES} {value}')
	exit(1)
sys.excepthook = my_except_hook

argv = sys.argv
if len(argv) != 3:
	raise ValueError("erroneous arguments: expected <PATH> <FILENAME>")
path = argv[1]
filename = argv[2]
images = []

def handle_image(path_to_image):
	image = Image.open(path_to_image)
	pixels = list(image.getdata())
	width, height = image.size
	pixels = [pixels[i * width:(i + 1) * width] for i in range(height)]
	images.append(pixels)

def has_hidden_attribute(filepath):
	try:
		assert attrs != -1
		result = bool(attrs & 2)
	except (AttributeError, AssertionError):
		result = False
	return result

if os.path.isfile(path):
	handle_image(path)
elif os.path.isdir(path):
	files = [os.path.join(path, f) for f in os.listdir(path) if os.path.isfile(os.path.join(path, f)) and not f.startswith('.')]
	for i in tqdm(range(len(files))):
		handle_image(files[i])
else:
	raise ValueError("neither a file nor a directory")
for i in images:
	for j in range(0, len(i)):
		if (j + 1) % 2 == 0:
			continue
		i[j] = list(reversed(i[j]))

with open(f"{filename}.json", 'w') as fp:
	json.dump(images, fp)
print(f"{GRN + BLD}SUCCESSFULLY{RES} created json files")
