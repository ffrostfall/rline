local lexemeTokens = require("@src/shell/lexer/lexemeTokens")
local lexer = require("@src/shell/lexer")
local parser = require("@src/shell/parser")
local case, eof = require("@tests/suite")()

local function validLex(input: string): { lexemeTokens.Lexeme }
	local result = lexer(input)

	if not result.success then
		error(result.err)
	else
		return result.value
	end
end

local function validParse(input: { lexemeTokens.Lexeme }): { parser.Stmt }
	local result = parser(input)

	if not result.success then
		error(result.err)
	else
		return result.value
	end
end

local function ast(source: string): { parser.Stmt }
	return validParse(validLex(source))
end

local function localuserToken(): parser.VariableExpr
	return {
		kind = "variable",
		name = "localuser",
	}
end

case("produce command", function(interface)
	local tree = ast("identifier")

	interface.expect.equal(tree, {
		{
			kind = "cmd",
			name = "identifier",
			params = {},
		},
	})
end)

case("command with localuser argument", function(interface)
	local tree = ast("identifier ~")

	interface.expect.equal(tree, {
		{
			kind = "cmd",
			name = "identifier",
			params = {
				localuserToken(),
			},
		},
	})
end)

case("separated commands", function(interface)
	local tree = ast("one;two;three")

	interface.expect.equal(tree, {
		{
			kind = "cmd",
			name = "one",
			params = {},
		},
		{
			kind = "cmd",
			name = "two",
			params = {},
		},
		{
			kind = "cmd",
			name = "three",
			params = {},
		},
	})
end)

case("separated commands with arguments", function(interface)
	local tree = ast("one ~;two ~;three ~")

	interface.expect.equal(tree, {
		{
			kind = "cmd",
			name = "one",
			params = { localuserToken() },
		},
		{
			kind = "cmd",
			name = "two",
			params = { localuserToken() },
		},
		{
			kind = "cmd",
			name = "three",
			params = { localuserToken() },
		},
	})
end)

case("command with variable access", function(interface)
	local tree = ast("identifier $localuser")

	interface.expect.equal(tree, {
		{
			kind = "cmd",
			name = "identifier",
			params = {
				localuserToken(),
			},
		},
	})
end)

case("command with addition & negation", function(interface)
	local tree = ast("identifier 5 + -5")

	interface.expect.equal(tree, {
		{
			kind = "cmd",
			name = "identifier",
			params = {
				{
					kind = "add",

					leftExpr = {
						kind = "number",
						value = 5,
					},
					rightExpr = {
						kind = "negate",
						expr = {
							kind = "number",
							value = 5,
						},
					},
				},
			},
		},
	})
end)

return eof()
