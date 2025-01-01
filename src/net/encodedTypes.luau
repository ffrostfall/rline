local json = require("@src/util/json")
local t = require("@pkg/t")
local types = require("@src/types")

local function encodeCommand(cmd: types.InternalCommand)
	return json.encode(cmd)
end

local function decodeCommand(data: string): types.InternalCommand
	return json.decode(data)
end

export type CommandExecutionPacket = {
	cmd: string,
	parameters: { types.ShellValue },
}

export type CommandExecutionResponse = {
	lines: { string },
}

return {
	encodeCommand = encodeCommand,
	decodeCommand = decodeCommand,

	validatePacket = t.strictInterface({
		cmd = t.string,
		parameters = t.array(t.strictInterface({
			kind = t.string,
			value = t.union(t.string, t.number, t.boolean),
		})),
	}),
}
