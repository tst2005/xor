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
local string_char = string.char
local b2c = function(b)
	return string_char( tonumber( b
		 --bit.band(0xff, b)
	) )
end

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
			local ta = {c2b(aa,1,-1)}
			local tb = {c2b(bb,1,-1)}
			local tc = {}
			assert(#ta==#tb)
			for i=1,#ta do
				tc[i] = b2c( bxor(ta[i], tb[i]) )
			end
			return table_concat(tc,"")
		end
		local r = xor_str(m,s)
		stdout:write(r)
	end --/while

	-- close all
	mfd:close()
	sfd:close()
end

local retcode = main {...}
require"os".exit(retcode)
