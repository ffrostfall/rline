local RunService = game:GetService("RunService")

local runContext: "server" | "client" = if RunService:IsServer() then "server" else "client"

local client = require("@src/net/client")
local server = require("@src/net/server")

local net = {}

function net.init()
	if runContext == "server" then
		server.init()
	elseif runContext == "client" then
		client.init()
	end
end

return net
