local RunService = game:GetService("RunService")

local onClientStart = require("./onClientStart")
local onServerStart = require("./onServerStart")

local runContext: "server" | "client" = if RunService:IsServer() then "server" else "client"

local scripts = {}

function scripts.run()
	if runContext == "server" then
		onServerStart()
	elseif runContext == "client" then
		onClientStart()
	end
end

return scripts
