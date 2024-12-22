local signal = require("@pkg/signal")

local lineAdded = signal()
local output: { string } = {}
local env: { [string]: string } = {}

local terminal = {}

function terminal.print(text: string)
	table.insert(output, text)
	lineAdded:fire()
end

function terminal.setEnv(key: string, value: string)
	env[key] = value
end

function terminal.getEnv(key: string): string
	return env[key]
end

function terminal.onLineAdded(callback: () -> ())
	return lineAdded:connect(callback)
end

return terminal
