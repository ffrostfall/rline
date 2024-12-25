local case, eof = require("@tests/suite")()
local lexemeTokens = require("@src/shell/lexer/lexemeTokens")
local lexer = require("@src/shell/lexer/init")

local token = lexemeTokens.tokenize

local function validLex(input: string): { lexemeTokens.Lexeme }
	local result = lexer(input)

	if not result.success then
		error(result.err)
	else
		return result.value
	end
end

case("lex numbers", function(interface)
	interface.expect.equal(validLex("123"), {
		token("number", 123),
		token("eof"),
	})
end)

case("separate whitespace", function(interface)
	interface.expect.equal(validLex("1 2 3"), {
		token("number", 1),
		token("whitespace"),
		token("number", 2),
		token("whitespace"),
		token("number", 3),
		token("eof"),
	})
end)

case("lex separator", function(interface)
	interface.expect.equal(validLex("hi;hi"), {
		token("identifier", "hi"),
		token("stmtSeparator"),
		token("identifier", "hi"),
		token("eof"),
	})
end)

case("lex unary", function(interface)
	interface.expect.equal(validLex("-"), {
		token("minus"),
		token("eof"),
	})
end)

case("empty", function(interface)
	interface.expect.equal(validLex(""), {
		token("eof"),
	})
end)

case("lex identifiers", function(interface)
	interface.expect.equal(validLex("these are identifiers"), {
		token("identifier", "these"),
		token("whitespace"),
		token("identifier", "are"),
		token("whitespace"),
		token("identifier", "identifiers"),
		token("eof"),
	})
end)

case("lex strings", function(interface)
	interface.expect.equal(validLex(`"im a string"`), {
		token("string", "im a string"),
		token("eof"),
	})
end)

case("lex multiple", function(interface)
	interface.expect.equal(validLex('"Hello world"-identifier1 12345'), {
		token("string", "Hello world"),
		token("minus"),
		token("identifier", "identifier1"),
		token("whitespace"),
		token("number", 12345),
		token("eof"),
	})
end)

return eof()
