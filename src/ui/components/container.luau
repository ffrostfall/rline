local types = require("@src/types")
local vide = require("@pkg/vide")

return function(props: {
	size: types.UsedAs<UDim2>?,
	position: types.UsedAs<UDim2>?,
	anchorPoint: types.UsedAs<Vector2>?,

	color: types.UsedAs<Color3>?,
	transparency: types.UsedAs<number>?,

	[number]: Instance | (() -> any) | (() -> { any }),
})
	return vide.create("Frame")({
		Size = props.size or UDim2.fromScale(1, 1),
		Position = props.position or UDim2.fromScale(0.5, 0.5),
		AnchorPoint = props.anchorPoint or Vector2.new(0.5, 0.5),

		BackgroundTransparency = props.transparency or 1,
		BackgroundColor3 = props.color or Color3.new(),

		table.unpack(props),
	})
end
