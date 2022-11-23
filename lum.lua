--[[
MIT License

Copyright (c) 2022 kooshie

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

--[[
 TODO:
 - Implement `gum spin` with function
 - Add support for Windows
]]

--[[ Start ]]--

--- @class lum
--[[
The lum module
]]
local lum = {}

--[[ Misc. ]]--

local os_execute = os.execute
local io_popen,io_open = io.popen,io.open
local table_insert,table_concat = table.insert,table.concat

local toption = {
	join = {
		horizontal = "--horizontal",
		vertical = "--vertical",
		align = "--align"
	}
}

local function table_copy(orig)
	-- Src: http://lua-users.org/wiki/CopyTable
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

local function iswindows()
	return type(package) == 'table' and type(package.config) == 'string' and package.config:sub(1,1) == '\\'
end

local function cmd_handle(fn_name,cmd,option)
	local cmd_buff = {}
	cmd_buff[1] = cmd

	local fn_option = toption[fn_name]
	for o_name,o_val in pairs(option) do
		if not fn_option[o_name] then
			error("Invalid option: "..o_name)
		end

		if type(o_val) == "boolean" then
			table_insert(cmd_buff,o_val and fn_option[o_name] or "")
		else
			table_insert(cmd_buff,fn_option[o_name].."='"..tostring(o_val).."'")
		end
	end
	return cmd_buff
end

--[[ API ]]--

--- @type boolean
lum._winsupport = false

if iswindows() and not lum._winsupport then
	error "Lum only works with POSIX shell (`sh`), especially Linux. But you can enable Windows support by changing `lum._winsupport` to `true`."
end

--- @param prompt? string The prompt string
--- @return boolean confirmation The return of confirmation
--[[
<s>
Return `true` if selection is affirmative, otherwise `false` if selection is negative.
]]
function lum.confirm(prompt)
	local _,_,code = os_execute("gum confirm "..(prompt or ""))
	return code < 1
end

--- @return string text The text
--[[
<s>
Start a multi-line prompt
]]
function lum.write()
	local gum = io_popen "gum write"
	local data = gum:read "a":gsub("\n$","")
	gum:close()
	return data
end

--- @param path? string The path to select the file
--- @return string file The file that user selected
--[[
<s>
Start a prompt to select file in `path`
]]
function lum.file(path)
	local gum = io_popen("gum file "..(path or "."))
	local data = gum:read "a":gsub("\n$","")
	gum:close()
	return data
end

---@param ... any Any value to join
---@return string joined_text The joined value into string
--[[
<s>
Join (or concatenate) values, used to join Gum's styled texts.
]]
function lum.join(...)
	local option = {
		horizontal = false,
		vertical = false,
		align = "left"
	}

	local vararg = {...}
	if type(vararg[#vararg]) == "table" and next(vararg[#vararg]) then
		option = table_copy(vararg[#vararg])
		vararg[#vararg] = nil
	elseif type(vararg[#vararg]) == "table" and not next(vararg[#vararg]) then
		vararg[#vararg] = nil
	end
	local cmd = cmd_handle("join","gum join",option)

	local buff = {}
	for _,v in pairs(vararg) do
		table_insert(buff,"'"..tostring(v).."'")
	end

	local gum = io_popen(table_concat(cmd," ").." "..table_concat(buff," "))
	local data = gum:read "a":gsub("\n$","")
	gum:close()
	return data
end

return lum
