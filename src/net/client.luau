local Players = game:GetService("Players")

local env = require("@src/shell/env")

local client = {}

function client.addCommand() end

function client.init()
	env.set("localuser", {
		kind = "number",
		value = Players.LocalPlayer.UserId,
	})
end

return client
