local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local colorful = require("@src/colorful")
local encodedTypes = require("@src/net/encodedTypes")
local solver = require("@src/shell/solver")
local types = require("@src/types")

local function findValue(player: Player): StringValue
	local value = player.PlayerGui:WaitForChild("rline", 1) :: StringValue
	assert(value, "rline value not found under player")

	return value
end

local cmds: { [string]: types.InternalCommand } = {}

local server = {}

function server.init()
	Players.PlayerAdded:Connect(server._onPlayerAdded)

	local executeCommand = Instance.new("RemoteFunction")
	executeCommand.Name = "rline-executecommand"
	executeCommand.Parent = ReplicatedStorage

	executeCommand.OnServerInvoke = function(player, raw)
		local valid = encodedTypes.validatePacket(raw)
		if not valid then
			return
		end

		local data = raw :: encodedTypes.CommandExecutionPacket
		local chosenCommand = cmds[data.cmd]
		local chosenCommandParams = table.pack(chosenCommand.parameters())
		local output: { string } = {}
		local rawParams: { string | number | boolean } = {}

		for index, param in data.parameters do
			local desiredType = (chosenCommandParams[index] :: any).kind
			if param.kind ~= desiredType then
				return {
					colorful.color.red(
						`expected parameter {index} to be of type {desiredType}, got {param.kind}`
					),
				}
			end

			table.insert(rawParams, solver.value(param))
		end

		chosenCommand.execute({
			caller = player,
			print = function(text: string)
				table.insert(output, text)
			end,
		}, table.unpack(rawParams))

		return output
	end
end

function server._onPlayerAdded(player: Player)
	local value = Instance.new("StringValue")
	value.Name = "rline"

	-- Parent to PlayerGui to prevent replication
	value.Parent = player.PlayerGui

	value:SetAttribute("")
end

function server.addCommand(config: types.InternalCommand)
	cmds[config.name] = config
end

function server.updateServerCommandData(player: Player, commandJSON: string)
	findValue(player).Value = commandJSON
end

function server.giveCapability(player: Player, capability: string)
	findValue(player):SetAttribute(capability, true)
end

function server.hasCapability(player: Player, capability: string)
	return findValue(player):GetAttribute(capability) ~= nil
end

function server.revokeCapability(player: Player, capability: string)
	findValue(player):SetAttribute(capability, nil)
end

return server
