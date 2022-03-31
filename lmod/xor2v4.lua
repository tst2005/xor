#!/usr/bin/env luajit

-- (c) 2015-2022 TsT tst2005@gmail.com. Licensed under the MIT License.

local os = require "os"
local io = require "io"

local bit
pcall(function() bit = require "bit" end) -- using the luajit
pcall(function() bit = require "bit32" end) -- lua 5.2
pcall(function() bit = require "bit.numberlua" end)
assert(bit, "bit support required")

local bxor = assert(bit.bxor, "bitwise support is required")

local c2b = string.byte -- char(string) to byte(number)
local b2c = string.char -- byte(number) to char(string)

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

	local stdout=io.stdout
	while true do
		local m = mfd:read(BLOCKSIZE)
		if not m then
			break -- breaks if master eof reached
		end
		local s = sfd:read(#m) or "" -- if no data available, use an empty string
		assert(#s<=#m)
		local ta = {c2b(m,1,-1)}
		local tb = {c2b(s,1,-1)}
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
os.exit(retcode)
