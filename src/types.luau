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

export type InternalCommand = Command<any>

--[[
	Public
]]

export type Context = {
	caller: Player,

	print: (text: string) -> (),
}

export type Command<T...> = {
	name: string,
	description: string,
	context: "client" | "server",

	capabilities: { string },
	parameters: <T...>() -> T...,

	execute: (ctx: Context, T...) -> (),
}

return nil
