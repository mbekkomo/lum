local L = require "Lust"

--- @class lum
--[[
The lum module
]]
local lum = {}

local execute = os.execute

--- @param prompt? string The prompt string
--- @return boolean # The return of confirmation
--[[
<s>
Return `true` if selection is affirmative, otherwise `false` if selection is negative.
]]
function lum.confirm(prompt)
	local _,_,code = execute("gum confirm "..(prompt or ""))

	return code < 1
end

return lum
