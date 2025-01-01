local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local colorful = require("@src/colorful")
local env = require("@src/shell/env")
local json = require("@src/util/json")
local shell = require("@src/shell")
local state = require("@src/ui/state")
local types = require("@src/types")
local vm = require("@src/shell/vm")

local serverCommands: StringValue = nil
local errorStyle = colorful.combineStyles({ colorful.color.red, colorful.modifier.bold })
local knownServerCommands: { string } = {}
local invokeCommand: RemoteFunction = nil

local client = {
	vm = shell.vm(),
}

function client.init()
	invokeCommand = ReplicatedStorage:WaitForChild("rline-executecommand") :: RemoteFunction
	serverCommands = Players.LocalPlayer.PlayerGui:WaitForChild("rline") :: StringValue
	env.set("localuser", {
		kind = "number",
		value = Players.LocalPlayer.UserId,
	})

	client.vm:print("rline")

	state.lines(client.vm.output)
	client.vm.onLineAdded:connect(function()
		state.lines(client.vm.output)
	end)

	client._onServerCommandsChanged()
	serverCommands.Changed:Connect(client._onServerCommandsChanged)
end

function client._onServerCommandsChanged()
	knownServerCommands = json.decode(serverCommands.Value)
end

function client.addCommand(config: types.InternalCommand)
	client.vm:addCommand(config)
end

function client.execute(input: string)
	client.vm:print(`>{input}`)
	local commands = shell.parse(input)

	if commands.success then
		for _, command in commands.value do
			client.localExecute(command)
		end
	else
		client.vm:print(errorStyle(commands.err))
	end
end

function client.localExecute(commandTask: vm.CommandTask)
	if client.vm:hasCommand(commandTask.name) then
		client.vm:runCommandAsync(Players.LocalPlayer, commandTask)
	elseif table.find(knownServerCommands, commandTask.name) then
		local output = invokeCommand:InvokeServer(commandTask) :: { string }

		for _, line in output do
			client.vm:print(line)
		end
	else
		client.vm:print("not found")
	end
end

return client
