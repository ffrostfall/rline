local parser = require("@src/terminal/shell/parser")

local function assertNumber(value: parser.ValueNode): parser.NumberNode
	if value.kind ~= "number" then
		error("runtime error, TODO: proper errors")
	end

	return value
end

local function recursiveSolving(expr: parser.Expr): parser.ValueNode
	if expr.kind == "add" then
		local leftSolved = recursiveSolving(expr.left)
		local rightSolved = recursiveSolving(expr.right)

		local left = assertNumber(leftSolved)
		local right = assertNumber(rightSolved)

		return {
			kind = "number",
			value = left.value + right.value,
		}
	elseif expr.kind == "negative" then
		local solved = recursiveSolving(expr.node)
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
	end

	return error("unreachable")
end

local solver = {}

function solver.solveCommand(stmt: parser.Stmt): {
	command: string,
	parameters: { parser.ValueNode },
}
	local parameters = {}
	for _, expr in stmt.exprs do
		table.insert(parameters, solver.solveExpr(expr))
	end

	return {
		command = stmt.cmd,

		parameters = parameters,
	}
end

function solver.solveExpr(expr: parser.Expr): parser.ValueNode
	return recursiveSolving(expr)
end

return solver
