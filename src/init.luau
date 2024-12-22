local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local colorful = require("@src/colorful")
local mount = require("@src/ui/mount")
local net = require("@src/net")

local rline = {}

function rline.addServerCommand() end

function rline.addClientCommand() end

rline.colorful = colorful

net.init()

if RunService:IsClient() then mount(Players.LocalPlayer.PlayerGui) end

return rline
