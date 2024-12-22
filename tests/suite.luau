local colorful = require("@vendor/lunePackages/colorful/init")

local blue = colorful.color.blueBright
local bold = colorful.modifier.bold
local red = colorful.color.redBright
local errorStyle = colorful.combineStyles({ red })
local infoStyle = colorful.combineStyles({ blue })
local logStyle = colorful.combineStyles({ bold })

local failureFormatStrings = {
	equality = `\t{infoStyle("Left:    ") .. "%*"}\n\t{infoStyle("Right:   ") .. "%*"}\n\n\t{logStyle(
		"Expected values to be equal"
	)}`,

	truthy = `\t{"Expected value [%*] to be truthy"}\n`,
}

export type Interface = {
	expect: {
		equal: <T>(left: T, right: T) -> (),
		truthy: <T>(value: T) -> (),
	},
}

local function printTable(tbl: { [unknown]: unknown })
	local lines = {}

	for key, value in tbl do
		if typeof(value) ~= "table" then
			table.insert(lines, `\t\[{key}] = {value}`)
		elseif typeof(value) == "table" then
			local result = printTable(value :: {})
			local replaced = string.gsub(result, "\n", "\n\t")

			table.insert(lines, `\t\[{key}] = {replaced}`)
		end
	end

	return `\{\n{table.concat(lines, ",\n")}\n\}`
end

local function formatTostring(value: unknown): string
	if typeof(value) == "table" then
		return printTable(value :: any)
	else
		return tostring(value)
	end
end

local function shallowEquals(tableA: {}, tableB: {})
	if tableA == tableB then
		return true
	end

	for key, value in tableA do
		if tableB[key] ~= value then
			return false
		end
	end

	for key, value in tableB do
		if tableA[key] ~= value then
			return false
		end
	end

	return true
end

local function interface(failCallback: (err: string) -> (), successCallback: () -> ()): Interface
	local formatString = failureFormatStrings.equality

	local function expectEqual<T>(left: T, right: T)
		if typeof(left) == "table" and typeof(right == "table") then
			if shallowEquals(left, right) then
				successCallback()
				return
			end
		elseif typeof(left) == "number" and typeof(right) == "number" then
			if math.abs(left - right) < 0.0001 then
				successCallback()
				return
			end
		elseif left == right then
			successCallback()
			return
		end

		local leftStr = formatTostring(left)
		local rightStr = formatTostring(right)

		failCallback(string.format(formatString, leftStr, rightStr))
	end

	local function expectTruthy<T>(value: T)
		if value then
			successCallback()
			return
		end

		failCallback(string.format(failureFormatStrings.truthy, formatTostring(value)))
	end

	return {
		expect = {
			equal = expectEqual,
			truthy = expectTruthy,
		},
	}
end

local function case(cases: { () -> boolean }, name: string, test: (interface: Interface) -> ())
	local checks: { boolean } = {}
	local failureMessages: { string } = {}

	local caseInterface = interface(function(err)
		table.insert(checks, false)
		table.insert(failureMessages, err)
	end, function()
		table.insert(checks, true)
	end)

	table.insert(cases, function(): boolean
		local success, err: any = pcall(test, caseInterface)

		if success and not table.find(checks, false) then
			print(infoStyle("\t- Test case passed: ") .. name)
			return true
		elseif success and table.find(checks, false) then
			print(`\t{errorStyle("- Test case failed: ")}{name}`)
			for _, message in failureMessages do
				print(message)
			end
			return false
		elseif not success then
			print(errorStyle("\t- Error in test case: ") .. name .. "\n\n", err, "\n")
		end

		return false
	end)
end

return function()
	local cases: { () -> boolean } = {}

	return function(name: string, test: (interface: Interface) -> ())
		case(cases, name, test)
	end, function()
		return cases
	end
end
