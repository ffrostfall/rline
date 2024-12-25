local ESCAPE = string.char(27)
local ANSI_16_MATCH_NOCAPTURE = `{ESCAPE}%[%d+m`
local NEWLINE = "\n"

local ansiToRichText = require("@src/ui/ansiToRichText")
local styling = require("@src/ui/styling")
local vide = require("@pkg/vide")

export type Props = {
	order: number,
	text: string,
}

local function process(text: string): string
	local removedAnsi = string.gsub(text, ANSI_16_MATCH_NOCAPTURE, "")
	local removedNewline = string.gsub(removedAnsi, NEWLINE, "")

	return removedNewline
end

return function(props: Props)
	local richText = ansiToRichText(props.text)
	local rawText = process(props.text)
	local focused = vide.source(false) :: vide.Source<boolean>

	return vide.create("TextBox")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, 0, 0, styling.sizing.lineHeight),
		LayoutOrder = props.order,

		BackgroundTransparency = 1,

		Text = function()
			return if focused() then rawText else richText
		end,

		TextColor3 = styling.palette.text,
		TextSize = styling.sizing.textSize,
		TextEditable = false,

		FontFace = styling.primaryFont,

		RichText = true,
		MultiLine = false,

		TextXAlignment = Enum.TextXAlignment.Left,

		Focused = function()
			focused(true)
		end,

		FocusLost = function()
			focused(false)
		end,
	})
end
