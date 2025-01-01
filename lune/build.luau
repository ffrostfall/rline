local async = require("@vendor/lunePackages/async")
local fs = require("@lune/fs")
local spawnProcess = require("@vendor/lunePackages/spawnProcess")
local styles = require("@ext/data/styles")

async(
	spawnProcess(
		"rojo",
		{ "sourcemap", "build-sourcemap.project.json", "--output", "build-sourcemap.json" }
	)
)

async(spawnProcess("darklua", { "process", "src/", "dist/", "--config", "build-darklua.json" }))
