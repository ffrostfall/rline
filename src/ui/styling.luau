local black = Color3.fromHex("#0a090c")
local white = Color3.fromHex("#f0edee")
local pastelblue = Color3.fromHex("a6b3de")
local blueishgray = Color3.fromHex("#1F2832")

return {
	palette = {
		text = white,
		scroll = white,
		background = black,

		border = blueishgray,

		highlight = pastelblue,
	},

	sizing = {
		terminalWidth = 0.8,
		terminalPadding = 4,

		lineHeight = 18,
		linePadding = 1,
		baseLines = 20,

		textSize = 18,

		additionalLines = 50,
	},

	primaryFont = Font.new("rbxassetid://16658246179"),
}
