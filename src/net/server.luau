local Players = game:GetService("Players")

local function findValue(player: Player): StringValue
	local value = player.PlayerGui:WaitForChild("rline", 1) :: StringValue
	assert(value, "rline value not found under player")

	return value
end

local server = {}

function server.init()
	Players.PlayerAdded:Connect(server._onPlayerAdded)
end

function server._onPlayerAdded(player: Player)
	local value = Instance.new("StringValue")
	value.Name = "rline"

	-- Parent to PlayerGui to prevent replication
	value.Parent = player.PlayerGui

	value:SetAttribute("")
end

function server.addCommand() end

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
