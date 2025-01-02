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
local clientvm: vm.Identity = nil

local client = {}

function client.init()
	clientvm = shell.vm()

	invokeCommand = ReplicatedStorage:WaitForChild("rline-executecommand") :: RemoteFunction
	serverCommands = Players.LocalPlayer.PlayerGui:WaitForChild("rline") :: StringValue
	env.set("localuser", {
		kind = "number",
		value = Players.LocalPlayer.UserId,
	})

	clientvm:print("rline")

	state.lines(clientvm.output)
	clientvm.onLineAdded:connect(function()
		state.lines(clientvm.output)
	end)

	client._onServerCommandsChanged()
	serverCommands.Changed:Connect(client._onServerCommandsChanged)
end

function client._onServerCommandsChanged()
	knownServerCommands = json.decode(serverCommands.Value)
end

function client.addCommand(config: types.InternalCommand)
	clientvm:addCommand(config)
end

function client.execute(input: string)
	clientvm:print(`>{input}`)
	local commands = shell.parse(input)

	if commands.success then
		for _, command in commands.value do
			client.localExecute(command)
		end
	else
		clientvm:print(errorStyle(commands.err))
	end
end

function client.localExecute(commandTask: vm.CommandTask)
	if clientvm:hasCommand(commandTask.name) then
		local output = clientvm:runCommandAsync(Players.LocalPlayer, commandTask)

		if not output.success then
			clientvm:print(errorStyle(output.err))
		end
	elseif table.find(knownServerCommands, commandTask.name) then
		local output = invokeCommand:InvokeServer(commandTask) :: { string }

		for _, line in output do
			clientvm:print(line)
		end
	else
		clientvm:print("not found")
	end
end

return client
