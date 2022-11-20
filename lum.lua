--- @class lum
--[[
The lum module
]]
local lum = {}

local os_execute = os.execute
local io_popen = io.popen

-- TODO:
--  Implement `gum spin` with function instead command.

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
	local gum = io.popen("gum file "..(path or "."))
	local data = gum:read "a":gsub("\n$","")
	gum:close()
	return data
end

return lum
