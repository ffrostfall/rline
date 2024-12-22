--[[
	A command is: <identifier>(expression=>whitespace)+<separator | eof>
]]

local lexemeTokens = require("@src/terminal/shell/lexer/lexemeTokens")
local reduceKeywords = require("@src/terminal/shell/parser/reduceKeywords")
local result = require("@src/util/result")

export type NumberNode = {
	kind: "number",
	value: number,
}
export type StringNode = {
	kind: "string",
	value: string,
}
export type BooleanNode = {
	kind: "boolean",
	value: boolean,
}
export type ValueNode = | NumberNode | StringNode | BooleanNode

export type NegExpr = {
	kind: "negative",
	node: Expr,
}

export type UnaryExpr = | NegExpr

export type AddExpr = {
	kind: "add",
	left: Expr,
	right: Expr,
}

export type BinaryExpr = | AddExpr

export type Expr = ValueNode | UnaryExpr | BinaryExpr

type CommandNode = {
	kind: "command",
	cmd: string,

	exprs: { Expr },
}

export type Stmt = CommandNode

local function cut<T>(array: { T }, start: number, stop: number): { T }
	local result: { T } = table.create((stop - start) + 1, nil)

	for i = start, stop do
		result[i - start + 1] = array[i]
	end

	return result
end

local function parseExpr(tokens: { reduceKeywords.ReductionNode }): Expr
	if #tokens == 0 then
		error("malformed expression")
	end

	local cursor = 1

	local left: Expr? = nil

	while cursor <= #tokens do
		local token = tokens[cursor]
		cursor += 1

		if token.kind == "boolean" then -- Leftexpr is here
			left = {
				kind = "boolean",
				value = token.value,
			}
		elseif token.kind == "number" then
			left = {
				kind = "number",
				value = token.value,
			}
		elseif token.kind == "string" then
			left = {
				kind = "string",
				value = token.value,
			}
		elseif token.kind == "minus" then -- Operations start here
			local oneAhead = tokens[cursor + 1]
			assert(oneAhead.kind == "number", "cannot negate something that isn't a number")

			cursor += 1
			return {
				kind = "negative",

				node = {
					kind = "number",
					value = oneAhead.value,
				},
			}
		elseif token.kind == "plus" then
			if not left then
				error("malformed expression")
			end

			local right = parseExpr(cut(tokens, cursor, #tokens))

			return {
				kind = "add",

				left = left,
				right = right,
			}
		end
	end

	if left then
		return left
	else
		error("malformed expression")
	end
end

return function(lexemes: { lexemeTokens.Lexeme }): result.Identity<{ Stmt }>
	local reduced = reduceKeywords(lexemes)
	if not reduced.success then
		return result(false, reduced.err)
	end

	local tokens = reduced.value
	local stmts: { Stmt } = {}

	local cursor = 1
	while cursor <= #tokens do
		local token = tokens[cursor]

		if token.kind == "identifier" then
			local paramTokens: { reduceKeywords.ReductionNode } = {}

			while cursor <= #tokens do
				cursor += 1
				local currentToken = tokens[cursor]
				if currentToken.kind == "stmtSeparator" or currentToken.kind == "eof" then
					break
				end

				table.insert(paramTokens, currentToken)
			end

			local exprs: { Expr } = {}
			local exprSlice: { reduceKeywords.ReductionNode } = {}

			for i, currentToken in paramTokens do
				if currentToken.kind == "exprSeparator" then
					table.insert(exprs, parseExpr(exprSlice))
					table.clear(exprSlice)
				elseif i == #paramTokens then
					table.insert(exprSlice, currentToken)

					table.insert(exprs, parseExpr(exprSlice))
					table.clear(exprSlice)
				else
					table.insert(exprSlice, currentToken)
				end
			end

			table.insert(stmts, {
				kind = "command",
				cmd = token.value,

				exprs = exprs,
			})
		elseif token.kind == "eof" then
			break
		else
			error(`unexpected token {token.kind}`)
		end
	end

	return result(true, stmts)
end
