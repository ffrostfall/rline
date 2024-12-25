type Identity = {
	encode: <T>(data: T) -> string,
	decode: <T>(data: string) -> T,
}

local function lune()
	local serde = (require)("@lune/serde")

	return {
		encode = function(data: any)
			return serde.encode("json", data, false)
		end,

		decode = function(data: string)
			return serde.decode("json", data)
		end,
	}
end

local function roblox()
	local HttpService = game:GetService("HttpService")

	return {
		encode = function(data: any)
			return HttpService:JSONEncode(data)
		end,

		decode = function(data: string)
			return HttpService:JSONDecode(data)
		end,
	}
end

return (if game then roblox() else lune()) :: Identity
