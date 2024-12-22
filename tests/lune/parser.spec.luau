local lexemeTokens = require("@src/terminal/shell/lexer/lexemeTokens")
local lexer = require("@src/terminal/shell/lexer")
local parser = require("@src/terminal/shell/parser")
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

case("regular command works", function(interface)
	local tree = ast("identifier")
	print(tree)
end)

return eof()
