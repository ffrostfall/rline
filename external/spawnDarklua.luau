local spawnProcess = require("@vendor/lunePackages/spawnProcess")

return function()
	spawnProcess("darklua", {
		"process",
		"src/",
		"build/package/",
		"--config",
		"dev-darklua.json",
		"--watch",
	})

	spawnProcess("darklua", {
		"process",
		"stories/",
		"build/stories/",
		"--config",
		"dev-darklua.json",
		"--watch",
	})

	spawnProcess("darklua", {
		"process",
		"tests/roblox/",
		"build/tests/",
		"--config",
		"dev-darklua.json",
		"--watch",
	})
end
