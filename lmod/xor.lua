#!/usr/bin/env lua

-- (c) 2015-2016 TsT tst2005@gmail.com. Licensed under the MIT License.
-- v0.2.0

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

local function main(files)

	if #files < 2 then
		print("Usage: "..(arg and arg[0] or "xor.lua").." [<option>] <input> [<option>] <input> [[<option>] <input N>] [...]")
		print "Options:"
		print "  -m|--master           stop everything at end-of-file of the next file argument"
		print "  -w|--write <path>     the read input data will be write in the <path> file"
		print "Inputs:"
		print "  -                     use stdin as input"
		print "  <path>                open and read the <path> file"
		return 1
	end

	local fds = {} -- input files
	local masters = {}
	local outfiles = {} -- copy of input files

	-- open all
	for i, file in ipairs(files) do
		if outfiles[i] == false then
			local fd
			if file == "-" then
				fd = io.stdout
			else
				fd = io.open(file, "wb")
			end
			outfiles[#fds] = fd
		else
			local fd
			if file == "-" then
				fd = io.stdin
			elseif file == "-m" or file == "--master" then
				masters[#fds+1] = true
			elseif file == "-w" or file == "--write" then
				outfiles[i+1] = false
			elseif file == "-o" or file == "--output" then
				error("not implemented yet", 2)
			else
				fd = io.open(file, "r")
			end
			if fd then
				fds[#fds+1]=fd
			end
		end
	end

	local eofs = {}

	while true do
		-- check if a master file got an EOF
		local function needexit()
			for i, fd in ipairs(fds) do
				if masters[i] then
					if fd:read(0) == nil then
						return true
					end
				end
			end
			return false
		end
		if needexit() then break end

		local B = nil
		for i, fd in ipairs(fds) do
			if not eofs[i] then
				local c = fd:read(1)
				if not c then
					eofs[i]=true
				else
					if outfiles[i] then
						outfiles[i]:write(c)
					end
					if B == nil then
						B = c2b(c)
					else
						B = bxor(B,c2b(c))
					end
				end
			end
		end --/for
		if B~=nil then
			io.stdout:write(b2c(B))
			B=nil
		end
		if #eofs >= #fds then break end
	end --/while

	-- close all
	for i, fd in ipairs(fds) do
		if fd then fd:close() end
		if outfiles[i] then
			outfiles[i]:close()
		end
	end
end

local exit = assert(require("os").exit)
local retcode = main {...}
exit(retcode)
