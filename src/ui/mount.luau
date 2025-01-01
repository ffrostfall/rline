local cli = require("./apps/cli")
local state = require("@src/ui/state")
local vide = require("@pkg/vide")

return function(target: Instance)
	vide.mount(function()
		return {
			vide.create("ScreenGui")({
				cli(),

				Enabled = state.open,
			}),
		}
	end, target)
end
