#!/usr/bin/env luajit

-- (c) 2015-2022 TsT tst2005@gmail.com. Licensed under the MIT License.
-- v0.3.0

local c2b = string.sub

local function main(args)

	if #args < 1 or args[1]=="--help" or args[1]=="-h" then
		print("Usage: "..(arg and arg[0] or "xor2.lua").." [-m] <file>")
		print("It will result to stdout a XOR between stdin (master size) and <file>")
		print("if -m <file> is use then <file> becomes the master size")
		return 1
	end

	local BLOCKSIZE = 1024 --4096
	local mfd,sfd
	if arg[1]=="-m" then
		mfd = io.open(args[2], "r")
		sfd = io.stdin
	else
		mfd = io.stdin
		sfd = io.open(args[1], "r")
	end

	local stdout=io.stdout
	local table_concat=table.concat
	while true do
		local B = nil
		local m = mfd:read(BLOCKSIZE)
		if not m then
			break -- breaks if master eof reached
		end
		local s = sfd:read(#m) or "" -- if no data available, use an empty string
		assert(#s<=#m)
		if #s < #m then -- padding...
			s = s .. ("\0"):rep(#m-#s)
		end
		assert(#s==#m)

		local function xor_str(aa,bb)
			assert(#aa==#bb)
			for i=1,#aa do
				stdout:write( c2b(aa,i,i), c2b(bb,i,i) )
			end
		end
		xor_str(m,s)
	end --/while

	-- close all
	mfd:close()
	sfd:close()
end

local retcode = main {...}
require"os".exit(retcode)
