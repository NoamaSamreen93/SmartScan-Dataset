import os

print('Enter path you want to organize files [use /]: ')
path = input('> ')
for filename in os.listdir(path):
	with open(filename,'w') as fh:
		for line in fh:
			if line.startswith("pragma solidity 0.3"):
				doesExist = os.path.isdir(f'{path}/0.3')
				if doesExist:
					print(f'{path}/{filename}')
					os.replace(f"{path}/{filename}", f"{path}/0.3/{filename}")
				else:
					os.mkdir(f'{path}/0.3')
					os.replace(f"{path}/{filename}", f"{path}/0.3/{filename}")
			elif line.startswith("pragma solidity ^0.3"):
				doesExist = os.path.isdir(f'{path}/0.3')
				if doesExist:
					print(f'{path}/{filename}')
					os.replace(f"{path}/{filename}", f"{path}/0.3/{filename}")
				else:
					os.mkdir(f'{path}/0.3')
					os.replace(f"{path}/{filename}", f"{path}/0.3/{filename}")
			elif line.startswith("pragma solidity ^0.4"):
				doesExist = os.path.isdir(f'{path}/0.4')
				if doesExist:
					print(f'{path}/{filename}')
					os.replace(f"{path}/{filename}", f"{path}/0.4/{filename}")
				else:
					os.mkdir(f'{path}/0.4')
					os.replace(f"{path}/{filename}", f"{path}/0.4/{filename}")
			elif line.startswith("pragma solidity 0.4"):
				doesExist = os.path.isdir(f'{path}/0.4')
				if doesExist:
					print(f'{path}/{filename}')
					os.replace(f"{path}/{filename}", f"{path}/0.4/{filename}")
				else:
					os.mkdir(f'{path}/0.4')
					os.replace(f"{path}/{filename}", f"{path}/0.4/{filename}")
			elif line.startswith("pragma solidity ^0.5"):
				doesExist = os.path.isdir(f'{path}/0.5')
				if doesExist:
					print(f'{path}/{filename}')
					os.replace(f"{path}/{filename}", f"{path}/0.5/{filename}")
				else:
					os.mkdir(f'{path}/0.5')
					os.replace(f"{path}/{filename}", f"{path}/0.5/{filename}")
			elif line.startswith("pragma solidity 0.5"):
				doesExist = os.path.isdir(f'{path}/0.5')
				if doesExist:
					print(f'{path}/{filename}')
					os.replace(f"{path}/{filename}", f"{path}/0.5/{filename}")
				else:
					os.mkdir(f'{path}/0.5')
					os.replace(f"{path}/{filename}", f"{path}/0.5/{filename}")	
			elif line.startswith("pragma solidity 0.6"):
				doesExist = os.path.isdir(f'{path}/0.6')
				if doesExist:
					print(f'{path}/{filename}')
					os.replace(f"{path}/{filename}", f"{path}/0.6/{filename}")
				else:
					os.mkdir(f'{path}/0.6')
					os.replace(f"{path}/{filename}", f"{path}/0.6/{filename}")	
			elif line.startswith("pragma solidity ^0.6"):
				doesExist = os.path.isdir(f'{path}/0.6')
				if doesExist:
					print(f'{path}/{filename}')
					os.replace(f"{path}/{filename}", f"{path}/0.6/{filename}")
				else:
					os.mkdir(f'{path}/0.6')
					os.replace(f"{path}/{filename}", f"{path}/0.6/{filename}")
			elif line.startswith("pragma solidity ^0.7"):
				doesExist = os.path.isdir(f'{path}/0.7')
				if doesExist:
					print(f'{path}/{filename}')
					os.replace(f"{path}/{filename}", f"{path}/0.7/{filename}")
				else:
					os.mkdir(f'{path}/0.7')
					os.replace(f"{path}/{filename}", f"{path}/0.7/{filename}")
			elif line.startswith("pragma solidity 0.7"):
				doesExist = os.path.isdir(f'{path}/0.7')
				if doesExist:
					print(f'{path}/{filename}')
					os.replace(f"{path}/{filename}", f"{path}/0.7/{filename}")
				else:
					os.mkdir(f'{path}/0.7')
					os.replace(f"{path}/{filename}", f"{path}/0.7/{filename}")
			elif line.startswith("pragma solidity ^0.8"):
				doesExist = os.path.isdir(f'{path}/0.8')
				if doesExist:
					print(f'{path}/{filename}')
					os.replace(f"{path}/{filename}", f"{path}/0.8/{filename}")
				else:
					os.mkdir(f'{path}/0.7')
					os.replace(f"{path}/{filename}", f"{path}/0.8/{filename}")
			elif line.startswith("pragma solidity 0.8"):
				doesExist = os.path.isdir(f'{path}/0.8')
				if doesExist:
					print(f'{path}/{filename}')
					os.replace(f"{path}/{filename}", f"{path}/0.8/{filename}")
				else:
					os.mkdir(f'{path}/0.8')
					os.replace(f"{path}/{filename}", f"{path}/0.8/{filename}")
			else:
				continue