local Players = game:GetService("Players")

local rline = ...
local externalLogger = ...
local playerType = rline.t.new({
	parse = function(str: string)
		return Players:FindFirstChild(str) or error("h")
	end,
	autofill = function(partial: string) end,
})

rline.command({
	name = "echo",
	context = "client",

	parameters = {
		text = rline.param({
			kind = "string",
			optional = true,
		}),
	},

	execute = function(params, ctx)
		ctx.print(params.text)
	end,
})

rline.command({
	name = "kick",
	description = "Kicks a player",
	context = "server",

	capabilities = { "player", "admin" },
	parameters = function()
		return playerType
	end,

	execute = function(ctx, player: Player) -- parameter specified type
		externalLogger(`Admin {ctx.caller.UserId} ran kick command on {player.UserId}`)

		player:Kick()

		ctx.print(`Successfully kicked {player.Name}`)
	end,
})
