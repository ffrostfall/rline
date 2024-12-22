local ESCAPE = string.char(27)
local ANSI_16_MATCH_CAPTURE = `{ESCAPE}%[(%d+)m`
local ANSI_16_MATCH_NOCAPTURE = `{ESCAPE}%[%d+m`

local CODEMAP = {
	[22] = "</b>",
	[23] = "</i>",
	[24] = "</u>",
	[29] = "</s>",
	[39] = "</font>",

	[31] = '<font color="rgb(255,102,50)">',
	[34] = '<font color="rgb(50,102,255)">',
	[36] = '<font color="rgb(153, 255, 255)">',
	[90] = '<font color="rgb(160, 160, 160)">',
	[30] = '<font color="rgb(0, 0, 0)">',
	[32] = '<font color="rgb(102, 255, 102)">',
	[37] = '<font color="rgb(255, 255, 255)">',
	[33] = '<font color="rgb(255, 255, 153)">',
	[35] = '<font color="rgb(255, 0, 255)">',

	[1] = "<b>",
	[3] = "<i>",
	[4] = "<u>",
	[9] = "<s>",
}

type Code = number

local function parse(text: string): string
	return string.gsub(text, ANSI_16_MATCH_NOCAPTURE, function(sequence)
		local match = string.match(sequence, ANSI_16_MATCH_CAPTURE)

		return CODEMAP[tonumber(match) or error("invalid ansi code")]
	end)
end

return parse
