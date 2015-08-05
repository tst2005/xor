 * use /bin/sh and special shellcode to launch appropriate lua interpretor

 * add a size option (by default the size follow the biggest stream) it should be mandatory to set which stream to follow in case of use of infinite random stream...
 * option like: -s size, -[[N]N]N to set the argument stream to follow (-a 1 or -1) (-a 0 | -a min) -A = -a max  -0 -A -m -M
	-1  | -a 1
	-2  | -a 2
	-m  | -a min
	-M  | -a max
        -0  |  ???
