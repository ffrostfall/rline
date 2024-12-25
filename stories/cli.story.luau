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

	state.lines(table.create(props.controls.lineCount(), style("test")))

	return function()
		return app
	end
end)
