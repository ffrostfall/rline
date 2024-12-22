local lexemeTokens = require("@src/terminal/shell/lexer/lexemeTokens")
local result = require("@src/util/result")

export type Identifier = {
	kind: "identifier",
	value: string,
}
export type Minus = {
	kind: "minus",
}
export type Plus = {
	kind: "plus",
}
export type NumberVal = {
	kind: "number",
	value: number,
}
export type BooleanVal = {
	kind: "boolean",
	value: boolean,
}
export type StringVal = {
	kind: "string",
	value: string,
}
export type EnvVarAccess = {
	kind: "environmentVariableAccess",
	value: string,
}
export type StmtSeparator = {
	kind: "stmtSeparator",
}
export type Whitespace = {
	kind: "whitespace",
}
export type Eof = {
	kind: "eof",
}
export type ExprSeparator = {
	kind: "exprSeparator",
}

export type ReductionNode =
	| Eof
	| Identifier
	| Minus
	| NumberVal
	| BooleanVal
	| Flag
	| EnvVarAccess
	| StringVal
	| StmtSeparator
	| ExprSeparator
	| Whitespace
	| Plus

return function(lexemes: { lexemeTokens.Lexeme }): result.Identity<{ ReductionNode }>
	local cursor = 1
	local nodes: { ReductionNode } = {}

	while cursor <= #lexemes do
		local lexeme = lexemes[cursor]

		if lexeme.kind == "identifier" then
			-- Check keywords
			if lexeme.value == "true" then
				table.insert(nodes, {
					kind = "boolean",
					value = true,
				})
			elseif lexeme.value == "false" then
				table.insert(nodes, {
					kind = "boolean",
					value = false,
				})
			elseif lexeme.value == "nan" then
				table.insert(nodes, {
					kind = "number",
					value = 0 / 0,
				})
			elseif lexeme.value == "inf" then
				table.insert(nodes, {
					kind = "number",
					value = math.huge,
				})
			else
				table.insert(nodes, {
					kind = "identifier",
					value = lexeme.value,
				})
			end

			cursor += 1
		elseif lexeme.kind == "localuser" then
			-- ~ is shorthand for %localuser%
			table.insert(nodes, {
				kind = "environmentVariableAccess",
				value = "localuser",
			})
			cursor += 1
		elseif lexeme.kind == "number" then
			table.insert(nodes, {
				kind = "number",
				value = lexeme.value,
			})
			cursor += 1
		elseif lexeme.kind == "minus" then
			table.insert(nodes, {
				kind = "minus",
			})
			cursor += 1
		elseif lexeme.kind == "environmentVariable" then
			local oneAhead, twoAhead = lexemes[cursor + 1], lexemes[cursor + 2]
			if oneAhead.kind == "identifier" and twoAhead.kind == "environmentVariable" then
				table.insert(nodes, {
					kind = "environmentVariableAccess",
					value = oneAhead.value,
				})
				cursor += 3
			else
				return result(false, "malformed environment variable access")
			end
		elseif lexeme.kind == "string" then
			table.insert(nodes, {
				kind = "string",
				value = lexeme.value,
			})
			cursor += 1
		elseif lexeme.kind == "stmtSeparator" then
			table.insert(nodes, {
				kind = "stmtSeparator",
			})
			cursor += 1
		elseif lexeme.kind == "exprSeparator" then
			table.insert(nodes, {
				kind = "exprSeparator",
			})
			cursor += 1
		elseif lexeme.kind == "eof" then
			table.insert(nodes, {
				kind = "eof",
			})
			cursor += 1
		elseif lexeme.kind == "whitespace" then
			table.insert(nodes, {
				kind = "whitespace",
			})
			cursor += 1
		elseif lexeme.kind == "plus" then
			table.insert(nodes, {
				kind = "plus",
			})
			cursor += 1
		end
	end

	return result(true, nodes)
end
