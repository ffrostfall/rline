local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local encodedTypes = require("@src/net/encodedTypes")
local env = require("@src/shell/env")
local shell = require("@src/shell")
local state = require("@src/ui/state")
local types = require("@src/types")

local client = {}

function client.invokeCommand(name: string, calledParams: { types.Value })
	state.busy(true)
	local invoke = ReplicatedStorage:WaitForChild("rline-executecommand") :: RemoteFunction

	local packet: encodedTypes.CommandExecutionPacket = {
		cmd = name,
		parameters = calledParams,
	}

	local output = invoke:InvokeServer(packet)

	for _, line in output do
		shell.print(line)
	end
	state.busy(false)
end

function client.init()
	env.set("localuser", {
		kind = "number",
		value = Players.LocalPlayer.UserId,
	})
end

return client
