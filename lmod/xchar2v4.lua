#!/usr/bin/env luajit

-- (c) 2015-2022 TsT tst2005@gmail.com. Licensed under the MIT License.

local os = require "os"
local io = require "io"

local sub = string.sub

local function main(args)

	if #args < 1 or args[1]=="--help" or args[1]=="-h" then
		print("Usage: "..(arg and arg[0] or "xor2.lua").." [-m] <file>")
		print("It will result to stdout an alternate read (byte per byte) between stdin (master size) and <file>")
		print("if -m <file> is use then <file> becomes the master size")
		return 1
	end

	local BLOCKSIZE = tonumber(os.getenv("BLOCKSIZE") or "") or 1024
	local mfd,sfd
	if arg[1]=="-m" then
		mfd = io.open(args[2], "r")
		sfd = io.stdin
	else
		mfd = io.stdin
		sfd = io.open(args[1], "r")
	end

	local stdout=io.stdout
	while true do
		local m = mfd:read(BLOCKSIZE)
		if not m then
			break -- breaks if master eof reached
		end
		local s = sfd:read(#m) or "" -- if no data available, use an empty string
		assert(#s<=#m)
		for i=1,#s do
			stdout:write( sub(m,i,i), sub(s,i,i) )
		end
		for i=#s+1,#m do
			stdout:write( sub(m,i,i), "\0" )
		end
	end --/while

	-- close all
	mfd:close()
	sfd:close()
end

local retcode = main {...}
os.exit(retcode)
