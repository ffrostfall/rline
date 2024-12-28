local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local colorful = require("@src/colorful")
local env = require("@src/shell/env")
local mount = require("@src/ui/mount")
local net = require("@src/net")
local server = require("@src/net/server")
local shell = require("@src/shell")
local state = require("@src/ui/state")
local types = require("@src/types")

local runContext: "server" | "client" = if RunService:IsServer() then "server" else "client"

local function assertRunContext(requiredContext: "server" | "client")
	assert(
		runContext == requiredContext,
		`Cannot use a {requiredContext} function on the {runContext}`
	)
end

local function parameter(kind, optional): types.Parameter
	return {
		kind = kind,
		optional = optional,
	}
end

local rline = {
	capabilities = {},
	t = {},
	shell = {},
	ui = {},

	colorful = colorful,
}

function rline.ui.open()
	assertRunContext("client")

	state.open(true)
end

function rline.ui.setVisible(visible: boolean)
	assertRunContext("client")

	state.open(visible)
end

function rline.capabilities.give(player: Player, capability: string)
	assertRunContext("server")

	server.giveCapability(player, capability)
end

function rline.capabilities.revoke(player: Player, capability: string)
	assertRunContext("server")

	server.revokeCapability(player, capability)
end

function rline.command<T>(config: types.Command<T>) end

function rline.shell.setEnv(name: string, value: types.Value)
	assertRunContext("client")

	env.set(name, value)
end

function rline.shell.print(text: string)
	assertRunContext("client")

	shell.print(text)
end

--[[
	Parameter types
]]

function rline.t.number(): number
	return parameter("number", false) :: any
end

function rline.t.string()
	return parameter("string", false) :: any
end

function rline.t.boolean()
	return parameter("boolean", false) :: any
end

net.init()

if RunService:IsClient() then
	mount(Players.LocalPlayer.PlayerGui)
end

return rline
