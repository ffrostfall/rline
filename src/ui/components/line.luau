local ansiToRichText = require("@src/ui/ansiToRichText")
local removeAnsi = require("@src/ui/removeAnsi")
local styling = require("@src/ui/styling")
local vide = require("@pkg/vide")

export type Props = {
	context: "server" | "client",
	order: number,
	text: string,
}

return function(props: Props)
	local richText = ansiToRichText(props.text)
	local rawText = removeAnsi(props.text)
	local focused = vide.source(false) :: vide.Source<boolean>

	return vide.create("TextBox")({
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(1, 0, 0, styling.sizing.lineHeight + styling.sizing.linePadding),
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

		TextXAlignment = Enum.TextXAlignment.Left,

		Focused = function()
			focused(true)
		end,

		FocusLost = function()
			focused(false)
		end,
	})
end
