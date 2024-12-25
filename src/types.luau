--[[
	Private
]]

-- Shell env
export type NumberValue = {
	kind: "number",
	value: number,
}
export type StringValue = {
	kind: "string",
	value: string,
}
export type BooleanValue = {
	kind: "boolean",
	value: boolean,
}

export type Value = | NumberValue | StringValue | BooleanValue

-- Shell commands

export type Parameter = {
	kind: "number" | "string" | "boolean",
	optional: boolean,
}

export type InternalCommand = Command<{ [number]: Parameter }>

--[[
	Public
]]

export type Context = {
	caller: Player,

	print: (text: string) -> (),
}

export type Command<T> = {
	name: string,
	description: string,
	context: "client" | "server",

	capabilities: { string },
	parameters: T,

	execute: (params: T, ctx: Context) -> (),
}

return nil
