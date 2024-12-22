local async = require("@vendor/lunePackages/async")
local colorful = require("@vendor/lunePackages/colorful")
local spawnDarklua = require("@ext/spawnDarklua")
local spawnProcess = require("@vendor/lunePackages/spawnProcess")
local spawnSourcemap = require("@ext/spawnSourcemap")
local task = require("@lune/task")

print(colorful.color.blueBright("Starting development server"))

spawnSourcemap(true)

-- avoid sourcemap dependency issues
task.wait(0.5)

spawnDarklua()

async(spawnProcess("rojo", {
	"serve",
	"test-build.project.json",
}))
