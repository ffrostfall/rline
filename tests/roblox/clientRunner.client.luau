local ContextActionService = game:GetService("ContextActionService")

local rline = require("@src/")

local visible = false

rline.command({
	name = "echo",
	description = "Echoes text back into output",
	context = "client",

	capabilities = { "player" },
	parameters = {
		rline.t.string(),
	},

	execute = function(params, ctx)
		ctx.print(params[1])
	end,
})

ContextActionService:BindAction("rline", function(_, state)
	if state == Enum.UserInputState.Begin then
		return
	end

	rline.setVisible(not visible)
	visible = not visible
	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.E)
