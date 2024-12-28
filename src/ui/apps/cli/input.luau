local container = require("@components/container")
local shell = require("@src/shell")
local state = require("@src/ui/state")
local styling = require("@src/ui/styling")
local vide = require("@pkg/vide")

return function()
	local textBox: TextBox
	textBox = vide.create("TextBox")({
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.fromScale(0.5, 0.5),
		AnchorPoint = Vector2.new(0.5, 0.5),

		BackgroundTransparency = 1,

		TextSize = styling.sizes.textSize,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = styling.palette.text,
		FontFace = styling.primaryFont,

		TextEditable = function()
			return not state.busy()
		end,

		FocusLost = function(enterPressed)
			if enterPressed then
				shell.exec(textBox.Text)

				textBox:CaptureFocus()

				task.delay(0, function()
					textBox.Text = "\0"
				end)
			end
		end,
	})

	vide.effect(function()
		local isOpen = state.open()

		if isOpen then
			textBox:CaptureFocus()
		end
	end)

	return container({
		-- props
		anchorPoint = Vector2.new(0.5, 1),
		size = UDim2.new(1, -styling.sizes.terminalPadding, 0, styling.sizes.lineHeight),
		position = UDim2.new(0.5, 0, 1, 0),
		transparency = 1,

		-- children
		textBox,
	})
end
