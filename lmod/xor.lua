#!/usr/bin/env lua

-- TODO: add (C) TsT

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

local exit = assert(require("os").exit)

local files = {...}

if #files < 2 then
	print("ERROR: xor.lua <file1> <file2>")
	exit(1)
end

local fds = {}
-- open all
for i, file in ipairs(files) do
	local fd
	if file == "-" then
		fd = io.stdin
	else
		fd = io.open(file, "r")
	end
	fds[i]=fd
end

local eofs = {}

while true do

	local B = nil
	for i, fd in ipairs(fds) do
		if not eofs[i] then
			local c = fd:read(1)
			if not c then
				eofs[i]=true
			else
				if B == nil then
					B = c2b(c)
				else
					B = bxor(B,c2b(c))
				end
			end
		end
	end --/for
	if B~=nil then
		io.write(b2c(B))
		B=nil
	end
	if #eofs >= #fds then break end
end --/while

-- close all
for i, fd in ipairs(fds) do
	if fd then fd:close() end
end

