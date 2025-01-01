local spawnProcess = require("@vendor/lunePackages/spawnProcess")

return function(watch: boolean?): thread
	local parameters = {
		"sourcemap",
		"test-source.project.json",
		"--output",
		"dev-sourcemap.json",
	}

	if watch then
		table.insert(parameters, "--watch")
	end

	return spawnProcess("rojo", parameters)
end
