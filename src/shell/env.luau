local types = require("@src/types")

local dict: { [string]: types.ShellValue } = {}

local env = {}

function env.set(key: string, value: types.ShellValue)
	dict[key] = value
end

function env.get(key: string): types.ShellValue
	return dict[key]
end

return env
