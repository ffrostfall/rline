local Players = game:GetService("Players")

local rline = ...
local externalLogger = ...
local playerType = rline.t.new({
	parse = function<T>(str: string): T
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
		return rline.t.string(), rline.t.number()
	end,

	execute = function(ctx, playerName)
		externalLogger(`Admin {ctx.caller.UserId} ran kick command`)

		local player = Players:FindFirstChild(playerName) :: Player
		if not player then
			ctx.print(`Player {playerName} not found`)
			return
		end
		-- plr:
		player:Kick()
		ctx.print(`Successfully kicked {playerName}`)
	end,
})
