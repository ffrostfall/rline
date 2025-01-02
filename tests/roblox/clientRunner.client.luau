local ContextActionService = game:GetService("ContextActionService")

local rline = require("@src/")

local visible = false

rline.addClientCommand({
	name = "echo",
	description = "Echoes text back into output",

	capabilities = { "player" },
	parameters = function()
		return rline.t.string(), rline.t.number()
	end,

	execute = function(ctx, text)
		ctx.print(text)
	end,
})

ContextActionService:BindAction("rline", function(_, state)
	if state == Enum.UserInputState.Begin then
		return
	end

	rline.ui.setVisible(not visible)
	visible = not visible
	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.E)
