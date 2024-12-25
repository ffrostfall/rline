local json = require("@src/util/json")
local types = require("@src/types")

local function encodeCommand(cmd: types.InternalCommand)
	return json.encode(cmd)
end

local function decodeCommand(data: string): types.InternalCommand
	return json.decode(data)
end

return {
	encodeCommand = encodeCommand,
	decodeCommand = decodeCommand,
}
