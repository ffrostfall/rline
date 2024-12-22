local vide = require("@pkg/vide")

--[[
	Private
]]

-- UI
export type UsedAs<T> = vide.Source<T> | T

-- Terminal
export type TypeValidator<T> = {
	validate: (value: unknown) -> boolean,

	fromString: (value: T) -> string,
	toString: (text: string) -> T,
}

export type Parameter<T> = {
	name: string,
	description: string,
	position: number,

	type: TypeValidator<T>,
	default: T,
}

export type Flag = {
	name: string,
	default: boolean,
}

export type Command = {
	name: string,
	description: string,

	parameters: { Parameter<any> },
}

--[[
	Public
]]

return nil
