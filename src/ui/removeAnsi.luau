local ESCAPE = string.char(27)
local ANSI_16_MATCH_NOCAPTURE = `{ESCAPE}%[%d+m`

return function(text: string): string
	return string.gsub(text, ANSI_16_MATCH_NOCAPTURE, "")
end
