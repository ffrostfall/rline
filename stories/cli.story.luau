local cli = require("@src/ui/apps/cli")
local colorful = require("@src/colorful")
local state = require("@src/ui/state")
local uilabs = require("@dev-pkg/ui-labs")
local vide = require("@pkg/vide")

return uilabs.CreateVideStory({
	vide = vide,

	controls = {
		lineCount = uilabs.Number(5, 1, 50, 1, true),
	},
}, function(props)
	local app = cli()

	local style = colorful.combineStyles({ colorful.color.red, colorful.modifier.bold })
	local style2 = colorful.combineStyles({ colorful.color.green, colorful.modifier.italic })
	local style3 = colorful.combineStyles({ colorful.color.cyan, colorful.modifier.strikethrough })

	state.lines({
		style("test1"),
		style3("test2"),
		style2("test3"),
		"test4",
	})

	return function()
		return app
	end
end)
