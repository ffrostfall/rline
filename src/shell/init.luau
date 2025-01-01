local lexer = require("@src/shell/lexer")
local parser = require("@src/shell/parser")
local result = require("@src/util/result")
local solver = require("@src/shell/solver")
local vm = require("./vm")

local shell = {}

function shell.parse(input: string): result.Identity<{ vm.CommandTask }>
	local lexed = lexer(input)
	if not lexed.success then
		warn(`[lexer]: {lexed.err}`)
		print(lexed.trace)
		return lexed
	end

	local parsed = parser(lexed.value)
	if not parsed.success then
		warn(`[parser]: {parsed.err}`)
		print(parsed.trace)
		return parsed
	end

	local commands = {}
	for _, cmd in parsed.value do
		local solvedParams = {}

		for _, expr in cmd.params do
			table.insert(solvedParams, solver.solveExpr(expr))
		end

		table.insert(commands, {
			name = cmd.name,
			params = solvedParams,
		})
	end

	return result(true, commands)
end

function shell.vm(): vm.Identity
	return vm.new()
end

return shell
