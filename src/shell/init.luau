local colorful = require("@src/colorful")
local lexer = require("@src/shell/lexer")
local parser = require("@src/shell/parser")
local signal = require("@pkg/signal")
local solver = require("@src/shell/solver")
local types = require("@src/types")

export type ShellFunction = () -> ()

local errorStyle = colorful.combineStyles({ colorful.color.red, colorful.modifier.bold })
local lineAdded = signal()
local lines: { string } = {}
local cmds: { [string]: (parameters: { types.Value }) -> string } = {
	["echo"] = function(parameters: { types.Value })
		print(parameters)
		return tostring(parameters[1].value)
	end,
}

local shell = {}

function shell.exec(input: string)
	shell.print(`>{input}`)

	local lexed = lexer(input)
	if not lexed.success then
		shell.print(errorStyle(`failure to lex command: {lexed.err}`))
		warn(`[lexer]: {lexed.err}`)
		print(lexed.trace)
		return
	end

	local parsed = parser(lexed.value)
	if not parsed.success then
		shell.print(errorStyle(`failure to parse command: {parsed.err}`))
		warn(`[parser]: {parsed.err}`)
		print(parsed.trace)
		return
	end

	local solved = solver.input(parsed.value)

	for _, command in solved do
		local func = cmds[command.cmd]
		if not func then
			shell.print(errorStyle(`{command.cmd} is not the name of a command in the registry`))
			continue
		end

		shell.print(func(command.parameters))
	end
end

function shell.setFunction(name: string, func: (params: { types.Value }) -> ()) end

function shell.print(text: string)
	table.insert(lines, text)
	lineAdded:fire()
end

function shell.onLineAdded(callback: () -> ())
	return lineAdded:connect(callback)
end

shell.lines = lines

return shell
