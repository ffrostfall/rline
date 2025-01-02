local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local colorful = require("@src/colorful")
local json = require("@src/util/json")
local types = require("@src/types")
local vm = require("@src/shell/vm")

local errorStyle = colorful.combineStyles({ colorful.color.red, colorful.modifier.bold })
local serverCommands: { [string]: types.InternalCommand } = {}
local servervm: vm.Identity = nil

local function findValue(player: Player): StringValue
	local value = player.PlayerGui:WaitForChild("rline", 1) :: StringValue
	assert(value, "rline value not found under player")

	return value
end

local server = {}

function server.init()
	servervm = vm.new()

	Players.PlayerAdded:Connect(server._onPlayerAdded)

	local executeCommand = Instance.new("RemoteFunction")
	executeCommand.Name = "rline-executecommand"
	executeCommand.Parent = ReplicatedStorage

	executeCommand.OnServerInvoke = function(player, raw: vm.CommandTask)
		local command = serverCommands[raw.name]
		if not command then
			return {
				errorStyle(`command not found`),
			}
		end

		for _, capability in command.capabilities do
			if not server.hasCapability(player, capability) then
				return {
					errorStyle(`you do not have permission to run this command`),
				}
			end
		end

		local executionResult = servervm:runCommandAsync(player, raw)

		if executionResult.success then
			return executionResult.value
		else
			return {
				errorStyle(`command execution failed: {executionResult.err}`),
			}
		end
	end
end

function server._onPlayerAdded(player: Player)
	local value = Instance.new("StringValue")
	value.Name = "rline"
	value.Value = "[]"
	-- Parent to PlayerGui to prevent replication
	value.Parent = player.PlayerGui

	server.computeCommandsFor(player)
end

function server.computeCommandsFor(player: Player)
	local value = findValue(player)
	local allCapabilities = {}
	for capability in value:GetAttributes() do
		table.insert(allCapabilities, capability)
	end

	local accessableCommands = {}
	for commandName, command in serverCommands do
		local hasAllCapabilities = true
		for _, capability in command.capabilities do
			if not table.find(allCapabilities, capability) then
				hasAllCapabilities = false
				break
			end
		end

		if hasAllCapabilities then
			table.insert(accessableCommands, commandName)
		end
	end

	value.Value = json.encode(accessableCommands)
end

function server.addCommand(config: types.InternalCommand)
	serverCommands[config.name] = config
	servervm:addCommand(config)

	for _, player in Players:GetPlayers() do
		server.computeCommandsFor(player)
	end
end

function server.giveCapability(player: Player, capability: string)
	local value = findValue(player)

	value:SetAttribute(capability, true)
	server.computeCommandsFor(player)
end

function server.hasCapability(player: Player, capability: string)
	return findValue(player):GetAttribute(capability) ~= nil
end

function server.revokeCapability(player: Player, capability: string)
	findValue(player):SetAttribute(capability, nil)
	server.computeCommandsFor(player)
end

return server
