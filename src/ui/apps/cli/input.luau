local container = require("@components/container")
local state = require("@src/ui/state")
local styling = require("@src/ui/styling")
local vide = require("@pkg/vide")

return function()
	local textBox = vide.create("TextBox")({
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),

		BackgroundTransparency = 1,

		TextSize = styling.sizing.textSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = styling.palette.text,
		FontFace = styling.primaryFont,
	})

	vide.effect(function()
		local isOpen = state.open()

		if isOpen then textBox:CaptureFocus() end
	end)

	return container({
		anchorPoint = Vector2.new(0.5, 1),
		size = UDim2.new(1, -styling.sizing.terminalPadding, 0, styling.sizing.lineHeight),
		position = UDim2.new(0.5, 0, 1, 0),

		transparency = 1,
		textBox,
	})
end
