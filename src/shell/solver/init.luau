local env = require("@src/shell/env")
local parser = require("@src/shell/parser")
local types = require("@src/types")

local function assertNumber(value: parser.Expr): types.NumberValue
	if value.kind ~= "number" then
		error("runtime error, TODO: proper errors")
	end

	return value
end

local function recursiveSolving(expr: parser.Expr): types.Value
	if expr.kind == "add" then
		local leftSolved = recursiveSolving(expr.leftExpr)
		local rightSolved = recursiveSolving(expr.rightExpr)

		local left = assertNumber(leftSolved)
		local right = assertNumber(rightSolved)

		return {
			kind = "number",
			value = left.value + right.value,
		}
	elseif expr.kind == "negate" then
		local solved = recursiveSolving(expr)
		local node = assertNumber(solved)

		return {
			kind = "number",
			value = -node.value,
		}
	elseif expr.kind == "boolean" then
		return expr
	elseif expr.kind == "number" then
		return expr
	elseif expr.kind == "string" then
		return expr
	elseif expr.kind == "variable" then
		return env.get(expr.name)
	end

	return error("unreachable")
end

export type ShellCommand = {
	cmd: string,
	parameters: { any },
}
export type ShellResult = { ShellCommand }

local solver = {}

function solver.input(stmts: { parser.Stmt }): ShellResult
	local commands = {}

	for _, stmt in stmts do
		table.insert(commands, solver.solveCommand(stmt))
	end

	return commands
end

function solver.solveCommand(stmt: parser.Stmt): ShellCommand
	local parameters = {}

	for _, expr in stmt.params do
		table.insert(parameters, solver.solveExpr(expr))
	end

	return {
		cmd = stmt.name,

		parameters = parameters,
	}
end

function solver.solveExpr(expr: parser.Expr): types.Value
	return recursiveSolving(expr)
end

return solver
