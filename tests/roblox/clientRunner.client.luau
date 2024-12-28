local ContextActionService = game:GetService("ContextActionService")

local client = require("@src/net/client")
local rline = require("@src/")

local visible = false

rline.command({
	name = "echo",
	description = "Echoes text back into output",
	context = "server",

	capabilities = { "player" },
	parameters = {
		rline.t.string(),
	},

	execute = function(params, ctx)
		ctx.print(params[1])
	end,
})

task.delay(2, function()
	client.invokeCommand("echo", {
		{
			kind = "boolean",
			value = true,
		},
	})
end)

ContextActionService:BindAction("rline", function(_, state)
	if state == Enum.UserInputState.Begin then
		return
	end

	rline.ui.setVisible(not visible)
	visible = not visible
	return Enum.ContextActionResult.Sink
end, false, Enum.KeyCode.E)
