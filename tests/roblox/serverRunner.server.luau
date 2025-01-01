local Players = game:GetService("Players")

local rline = require("@src")

rline.addServerCommand({
	name = "giveperm",
	description = "",

	capabilities = { "mod" },
	parameters = function()
		return rline.t.string()
	end,

	execute = function(ctx, capability)
		rline.capabilities.give(ctx.caller, capability)
	end,
})

rline.addServerCommand({
	name = "revokeperm",
	description = "",

	capabilities = { "mod" },
	parameters = function()
		return rline.t.string()
	end,

	execute = function(ctx, capability)
		rline.capabilities.revoke(ctx.caller, capability)
	end,
})

rline.addServerCommand({
	name = "serverecho",
	description = "",

	capabilities = { "mod" },
	parameters = function()
		return rline.t.boolean()
	end,

	execute = function(ctx, text)
		task.wait(2)
		ctx.print(typeof(text))
		ctx.print(tostring(text))
	end,
})

rline.addServerCommand({
	name = "shout",
	description = "",

	capabilities = { "admin" },
	parameters = function()
		return rline.t.string()
	end,

	execute = function(ctx, text)
		ctx.print(tostring(text))
	end,
})

local function playerAdded(player: Player)
	rline.capabilities.give(player, "mod")
end

Players.PlayerAdded:Connect(playerAdded)
