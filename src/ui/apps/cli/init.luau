local container = require("@components/container")
local input = require("./input")
local line = require("@components/line")
local state = require("@src/ui/state")
local styling = require("@src/ui/styling")
local vide = require("@pkg/vide")

local sizing = styling.sizing

return function()
	local height = vide.source() :: vide.Source<number>

	vide.effect(function()
		height(sizing.baseLines * sizing.lineHeight)
	end)

	local scroll: ScrollingFrame
	scroll = vide.create("ScrollingFrame")({
		Size = UDim2.new(1, -styling.sizing.terminalPadding, 1, -styling.sizing.lineHeight),
		Position = UDim2.fromScale(0.5, 0),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0),
		CanvasSize = function()
			local scrollHeight = #state.lines() * styling.sizing.lineHeight
			if scroll then
				scroll.CanvasPosition = Vector2.new(0, scrollHeight)
			end

			return UDim2.new(0, 0, 0, scrollHeight)
		end,

		ScrollBarImageColor3 = styling.palette.scroll,
		ScrollBarImageTransparency = 1,
		TopImage = "",
		BottomImage = "",

		vide.create("UIListLayout")({
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Vertical,

			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		}),

		vide.indexes(state.lines, function(text, index)
			return line({
				text = text(),
				order = index,
			})
		end),
	})

	return container({
		size = function()
			return UDim2.new(sizing.terminalWidth, 0, 0, height())
		end,
		position = UDim2.fromScale(0.5, 0.5),

		transparency = 0,
		color = styling.palette.background,

		vide.create("UICorner")({
			CornerRadius = UDim.new(0, 4),
		}),

		vide.create("UIStroke")({
			Thickness = 4,

			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			LineJoinMode = Enum.LineJoinMode.Bevel,

			Color = styling.palette.background,
		}),

		scroll,
		input(),
	})
end
