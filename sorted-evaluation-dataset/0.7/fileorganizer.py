import os
import shutil
import time 

print('Enter path you want to organize files [use /]: ')
path = input('> ')
for filename in os.listdir(path):
	with open(filename,encoding="utf8",errors="ignore") as fh:
		for line in fh:
			if line.startswith("pragma solidity 0.3") or line.startswith("pragma solidity ^0.3"):
				time.sleep(1)
				shutil.copy(f"{path}/{filename}", f"C:/Users/noama/OneDrive/Documents/GitHub/SmartScan-Dataset/evaluation-dataset/sorted-evaluation-dataset/0.3/{filename}")
			elif line.startswith("pragma solidity ^0.4") or line.startswith("pragma solidity 0.4"):
				time.sleep(1)
				shutil.copy(f"{path}/{filename}", f"C:/Users/noama/OneDrive/Documents/GitHub/SmartScan-Dataset/evaluation-dataset/sorted-evaluation-dataset/0.4/{filename}")
			elif line.startswith("pragma solidity ^0.5") or line.startswith("pragma solidity 0.5"):
				time.sleep(1)
				shutil.copy(f"{path}/{filename}", f"C:/Users/noama/OneDrive/Documents/GitHub/SmartScan-Dataset/evaluation-dataset/sorted-evaluation-dataset/0.5/{filename}")
			elif line.startswith("pragma solidity 0.6") or line.startswith("pragma solidity ^0.6"):
				time.sleep(1)
				shutil.copy(f"{path}/{filename}", f"C:/Users/noama/OneDrive/Documents/GitHub/SmartScan-Dataset/evaluation-dataset/sorted-evaluation-dataset/0.6/{filename}")	
			elif line.startswith("pragma solidity ^0.7") or line.startswith("pragma solidity 0.7"):
				time.sleep(1)
				shutil.copy(f"{path}/{filename}",f"C:/Users/noama/OneDrive/Documents/GitHub/SmartScan-Dataset/evaluation-dataset/sorted-evaluation-dataset/0.7/{filename}")
			elif line.startswith("pragma solidity ^0.8") or line.startswith("pragma solidity 0.8"):
				time.sleep(1)
				shutil.copy(f"{path}/{filename}", f"C:/Users/noama/OneDrive/Documents/GitHub/SmartScan-Dataset/evaluation-dataset/sorted-evaluation-dataset/0.8/{filename}")
			else:
				continue