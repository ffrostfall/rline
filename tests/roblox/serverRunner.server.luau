local rline = require("@src")
local server = require("@src/net/server")

server.addCommand({
	name = "echo",
	description = "",
	context = "server",

	capabilities = {},
	parameters = function()
		return rline.t.boolean()
	end,

	execute = function(ctx, text)
		task.wait(2)
		ctx.print(tostring(text))
	end,
})
