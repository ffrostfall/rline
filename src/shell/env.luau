local types = require("@src/types")

local dict: { [string]: types.Value } = {}

local env = {}

function env.set(key: string, value: types.Value)
	dict[key] = value
end

function env.get(key: string): types.Value
	return dict[key]
end

return env
