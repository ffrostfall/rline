local lexemeTokens = require("@src/shell/lexer/lexemeTokens")
local result = require("@src/util/result")
local types = require("@src/types")

export type VariableExpr = {
	kind: "variable",
	name: string,
}

export type ValueExpr = types.Value | VariableExpr

export type NegateExpr = {
	kind: "negate",
	expr: Expr,
}

export type UnaryExpr = | NegateExpr

export type AdditionExpr = {
	kind: "add",

	leftExpr: Expr,
	rightExpr: Expr,
}

export type BinaryExpr = | AdditionExpr

export type Expr = ValueExpr | UnaryExpr | BinaryExpr

export type CommandStmt = {
	kind: "cmd",
	name: string,

	params: { Expr },
}

export type Stmt = | CommandStmt

local function cut<T>(array: { T }, start: number, stop: number): { T }
	local result: { T } = table.create((stop - start) + 1, nil)

	for i = start, stop do
		result[i - start + 1] = array[i]
	end

	return result
end

local function lexemeLiteralToValue(token: lexemeTokens.Lexeme): ValueExpr?
	if token.kind == "identifier" then
		if token.value == "false" then
			return {
				kind = "boolean",
				value = false,
			}
		elseif token.value == "true" then
			return {
				kind = "boolean",
				value = true,
			}
		elseif token.value == "inf" then
			return {
				kind = "number",
				value = math.huge,
			}
		elseif token.value == "nan" then
			return {
				kind = "number",
				value = 0 / 0,
			}
		else
			return nil
		end
	elseif token.kind == "number" then
		return {
			kind = "number",
			value = token.value,
		}
	elseif token.kind == "string" then
		return {
			kind = "string",
			value = token.value,
		}
	end

	return nil
end

local function parseExpression(tokens: { lexemeTokens.Lexeme }): result.Identity<Expr>
	-- handle the case of a singular value
	if #tokens == 0 then
		return result(false, "malformed expression")
	end

	local cursor = 1

	local left: Expr? = nil

	while cursor <= #tokens do
		local token = tokens[cursor]
		cursor += 1

		local asValue = lexemeLiteralToValue(token)
		if asValue then -- Leftexpr is here
			left = asValue
		elseif token.kind == "minus" then -- Operations start here
			local right = parseExpression(cut(tokens, cursor, #tokens))
			if not right.success then
				return right
			end

			return result(true, {
				kind = "negate" :: "negate",
				expr = right.value,
			})
		elseif token.kind == "plus" then
			if not left then
				return result(false, "malformed addition")
			end

			local right = parseExpression(cut(tokens, cursor, #tokens))
			if not right.success then
				return right
			end

			return result(true, {
				kind = "add" :: "add",

				leftExpr = left,
				rightExpr = right.value,
			})
		elseif token.kind == "variableAccess" then
			local oneAhead = tokens[cursor]
			if oneAhead.kind ~= "identifier" then
				return result(false, "malformed variable access")
			end

			return result(true, {
				kind = "variable" :: "variable",
				name = oneAhead.value,
			})
		elseif token.kind == "localuser" then
			left = {
				kind = "variable",
				name = "localuser",
			}
		end
	end

	if left then
		return result(true, left)
	else
		return result(false, "empty statement")
	end
end

return function(lexemes: { lexemeTokens.Lexeme }): result.Identity<{ Stmt }>
	local cursor = 1
	local stmts: { Stmt } = {}

	while cursor <= #lexemes do
		local lexeme = lexemes[cursor]

		if lexeme.kind == "identifier" then
			local paramLexemes: { lexemeTokens.Lexeme } = {}

			while true do
				cursor += 1
				local currentLexeme = lexemes[cursor]
				if not currentLexeme then
					break
				end

				if currentLexeme.kind == "stmtSeparator" then
					break
				end

				table.insert(paramLexemes, currentLexeme)
			end

			cursor += 1

			local exprs: { Expr } = {}
			local exprLexemeSlices: { { lexemeTokens.Lexeme } } = {}
			local lexemeSlice: { lexemeTokens.Lexeme } = {}

			for i, v in paramLexemes do
				if v.kind == "exprSeparator" then
					table.insert(exprLexemeSlices, lexemeSlice)
					lexemeSlice = {}
				elseif i == #paramLexemes then
					table.insert(lexemeSlice, v)
					table.insert(exprLexemeSlices, lexemeSlice)
					lexemeSlice = {}
				else
					table.insert(lexemeSlice, v)
				end
			end

			for _, slice in exprLexemeSlices do
				if slice[1] and slice[1].kind == "eof" then
					continue
				end

				local exprResult = parseExpression(slice)

				if exprResult.success then
					table.insert(exprs, exprResult.value)
				else
					return exprResult
				end
			end

			table.insert(stmts, {
				kind = "cmd",
				name = lexeme.value,

				params = exprs,
			})
		elseif lexeme.kind == "whitespace" then
			cursor += 1
			continue
		elseif lexeme.kind == "eof" then
			return result(true, stmts)
		else
			return result(false, `unexpected lexeme kind {lexeme.kind}`)
		end
	end

	return result(true, stmts)
end
