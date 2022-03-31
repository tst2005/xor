#!/usr/bin/env luajit

-- (c) 2015-2022 TsT tst2005@gmail.com. Licensed under the MIT License.
-- v0.3.0

local bit
pcall(function() bit = require "bit" end) -- using the luajit
pcall(function() bit = require "bit32" end) -- lua 5.2
pcall(function() bit = require "bit.numberlua" end)
assert(bit, "bit support required")

local bxor = assert(bit.bxor, "bitwise support is required")

local c2b = string.byte
local b2c = string.char

local function main(args)

	if #args < 1 or args[1]=="--help" or args[1]=="-h" then
		print("Usage: "..(arg and arg[0] or "xor2.lua").." [-m] <file>")
		print("It will result to stdout a XOR between stdin (master size) and <file>")
		print("if -m <file> is use then <file> becomes the master size")
		return 1
	end

	local BLOCKSIZE = tonumber(os.getenv("XOR_BLOCKSIZE") or "") or 4096
	local mfd,sfd
	if arg[1]=="-m" then
		mfd = io.open(args[2], "r")
		sfd = io.stdin
	else
		mfd = io.stdin
		sfd = io.open(args[1], "r")
	end
	assert(mfd, "unable to open master file")
	assert(sfd, "unable to open slave file")

	local stdout=io.stdout
	local ta,tb,m,s
	while true do
		m = mfd:read(BLOCKSIZE)
		if not m then
			break -- breaks if master eof reached
		end
		s = sfd:read(#m) or "" -- if no data available, use an empty string
		assert(#s<=#m)
		ta = {c2b(m,1,-1)}
		tb = {c2b(s,1,-1)}
		assert(#ta>=#tb)
		for i=1,#tb do
			stdout:write( b2c( bxor(ta[i], tb[i]) ) )
		end
		for i=#tb+1,#ta do
			stdout:write( b2c( bxor(ta[i], 0) ) )
		end
	end --/while

	-- close all
	mfd:close()
	sfd:close()
end

local retcode = main {...}
require"os".exit(retcode)
