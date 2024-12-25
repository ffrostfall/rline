local Players = game:GetService("Players")

local rline = ...
local externalLogger = ...

rline.command({
	name = "echo",
	description = "Echoes text back into output",
	context = "client",

	capabilities = { "player" },
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
	parameters = {
		playerName = rline.param({
			kind = "string",
			optional = false,
		}),
	},

	execute = function(params, ctx)
		externalLogger(`Admin {ctx.caller.UserId} ran kick command`)

		local player = Players:FindFirstChild(params.playerName) :: Player
		if not player then
			ctx.print(`Player {params.playerName} not found`)
			return
		end

		player:Kick()
		ctx.print(`Successfully kicked {params.playerName}`)
	end,
})
