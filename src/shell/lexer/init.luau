local errors = require("@src/shell/lexer/errors")
local lexemeTokens = require("@src/shell/lexer/lexemeTokens")
local result = require("@src/util/result")

local function isNumeric(char: string): boolean
	return tonumber(char) ~= nil
end

local function isAlphanumerical(char: string): boolean
	return string.match(char or "", "%w") ~= nil
end

local function isWhitespace(char: string): boolean
	return string.match(char or "", "%s") ~= nil
end

return function(input: string): result.Identity<{ lexemeTokens.Lexeme }>
	local asArray = string.split(input, "")
	local lexemes: { lexemeTokens.Lexeme } = {}

	local token = function(kind: any, value: any)
		table.insert(lexemes, lexemeTokens.tokenize(kind, value))
	end :: lexemeTokens.Tokenizer

	local cursor = 1
	while cursor <= #asArray do
		local char = asArray[cursor]

		if char == ";" then
			token("stmtSeparator")
			cursor += 1
		elseif char == "," then
			token("exprSeparator")
			cursor += 1
		elseif char == "+" then
			token("plus")
			cursor += 1
		elseif char == "~" then
			token("localuser")
			cursor += 1
		elseif char == '"' then
			local str = ""
			local escaped = false

			while cursor <= #asArray do
				cursor += 1
				if asArray[cursor] == '"' then
					cursor += 1
					escaped = true
					break
				end

				str ..= asArray[cursor]
			end

			if (cursor > #asArray) and not escaped then
				return result(false, errors.UNESCAPED_STRING)
			end

			token("string", str)
		elseif char == "-" then
			token("minus")
			cursor += 1
		elseif isNumeric(char) then
			local str = char

			while cursor <= #asArray do
				cursor += 1
				if not tonumber(asArray[cursor]) then
					break
				end

				str ..= asArray[cursor]
			end

			local asNumber = tonumber(str)
			if not asNumber then
				return result(false, errors.UNKNOWN_NUMBER)
			end

			token("number", asNumber)
		elseif isAlphanumerical(char) then
			local str = char

			while cursor <= #asArray do
				cursor += 1
				if not isAlphanumerical(asArray[cursor]) then
					break
				end

				str ..= asArray[cursor]
			end

			token("identifier", str)
		elseif isWhitespace(char) then
			cursor += 1
			token("whitespace")
		elseif char == "$" then
			cursor += 1
			token("variableAccess")
		else
			return result(false, errors.UNKNOWN_CHARACTER)
		end
	end

	token("eof")

	return result(true, lexemes)
end
