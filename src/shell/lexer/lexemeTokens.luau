export type Lexeme = {
	kind: "string",
	value: string,
} | {
	kind: "number",
	value: number,
} | {
	kind: "localuser",
} | {
	kind: "variableAccess",
} | {
	kind: "stmtSeparator",
} | {
	kind: "identifier",
	value: string,
} | {
	kind: "eof",
} | {
	kind: "minus",
} | {
	kind: "whitespace",
} | {
	kind: "exprSeparator",
} | {
	kind: "plus",
}

export type Tokenizer =
	& ((kind: "string", value: string) -> Lexeme)
	& ((kind: "number", value: number) -> Lexeme)
	& ((kind: "identifier", value: string) -> Lexeme)
	& ((kind: "localuser") -> Lexeme)
	& ((kind: "variableAccess") -> Lexeme)
	& ((kind: "flag") -> Lexeme)
	& ((kind: "stmtSeparator") -> Lexeme)
	& ((kind: "minus") -> Lexeme)
	& ((kind: "whitespace") -> Lexeme)
	& ((kind: "exprSeparator") -> Lexeme)
	& ((kind: "plus") -> Lexeme)
	& ((kind: "eof") -> Lexeme)

local tokenize = function(kind: any, value: any)
	return {
		kind = kind,
		value = value,
	} :: any
end :: Tokenizer

return {
	tokenize = tokenize,
}
