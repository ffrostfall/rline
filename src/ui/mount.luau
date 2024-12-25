local cli = require("./apps/cli")
local colorful = require("@src/colorful")
local shell = require("@src/shell")
local state = require("@src/ui/state")
local vide = require("@pkg/vide")

return function(target: Instance)
	shell.onLineAdded(function()
		state.lines(shell.lines)
	end)

	shell.print(colorful.modifier.underline("rline"))

	vide.mount(function()
		return {
			vide.create("ScreenGui")({
				cli(),

				Enabled = state.open,
			}),
		}
	end, target)
end
