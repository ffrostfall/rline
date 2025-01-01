--[[
	Private
]]
export type CommandExecutor<T...> = (ctx: Context, T...) -> ()

-- shell value type
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

export type ShellValue = | NumberValue | StringValue | BooleanValue

-- Shell commands

export type Parameter = {
	kind: "number" | "string" | "boolean",
	optional: boolean,
}

export type InternalCommand = Command<...any>

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

	capabilities: { string },
	parameters: () -> T...,

	execute: CommandExecutor<T...>,
}

return nil
