local lum = require "lum"

local confirm = lum.confirm("Does Lua is more fast than Python?")
lum.spin(os.execute) "sleep 1"
if confirm then
	print "That's good (:"
else
	print "D:"
end
