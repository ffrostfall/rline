local result = require("@src/util/result")
local signal = require("@pkg/signal")
local types = require("@src/types")

export type CommandTask = {
	name: string,
	params: { types.ShellValue },
}

type ThreadTask = {
	executor: types.CommandExecutor<any>,
	params: { string | boolean | number },
	ctx: types.Context,

	callingThread: thread,
}

local vm = {}
local metatable = { __index = vm }
export type Identity = typeof(setmetatable(
	{} :: {
		taskQueue: { ThreadTask },
		thread: thread,

		onLineAdded: signal.Identity<string>,
		commands: { [string]: types.InternalCommand },
		output: { string },
	},
	metatable
))

local function constructor(): Identity
	local self = setmetatable({
		taskQueue = {},

		commands = {},
		output = {},
		onLineAdded = signal(),
	}, metatable)

	self.thread = task.spawn(function()
		while true do
			local success, err = pcall(self.step, self)
			table.clear(self.taskQueue)

			if not success then
				warn(`vm step failed with error: {err}`)
			end

			task.wait(1 / 30)
		end
	end)

	return self
end

function vm.runCommandAsync(
	self: Identity,
	caller: Player,
	commandTask: CommandTask
): result.Identity<{ string }>
	local command = self.commands[commandTask.name]
	if not command then
		return result(false, "command not found")
	end

	local desiredParams = { command.parameters() }
	local callingParams = {}
	for index, paramType in desiredParams do
		local param = commandTask.params[index]
		if not param.kind then
			return result(false, "i dont actually know")
		end

		if param.kind ~= paramType.kind then
			return result(
				false,
				`type mismatch for parameter {index} on command {command.name}. expected {paramType.kind}, got {param.kind}`
			)
		end

		table.insert(callingParams, param.value)
	end

	local output = {}

	local function shellprint(text: string)
		table.insert(self.output, text)
		table.insert(output, text)
	end
	local ctx = {
		caller = caller,
		print = shellprint,
	}

	table.insert(self.taskQueue, {
		executor = command.execute,
		params = callingParams,
		ctx = ctx,

		callingThread = coroutine.running(),
	})

	local executionResult = coroutine.yield() :: result.Identity<string>
	if executionResult.success then
		return result(true, output)
	else
		return executionResult
	end
end

function vm.print(self: Identity, text: string)
	table.insert(self.output, text)
	self.onLineAdded:fire(text)
end

function vm.addCommand(self: Identity, config: types.InternalCommand)
	self.commands[config.name] = config
end

function vm.hasCommand(self: Identity, name: string): boolean
	return self.commands[name] ~= nil
end

function vm.step(self: Identity)
	for i = #self.taskQueue, 1, -1 do
		local threadTask = self.taskQueue[i]

		local success, err: any =
			pcall(threadTask.executor, threadTask.ctx, table.unpack(threadTask.params))
		table.remove(self.taskQueue, i)

		if not success then
			warn("command failed with error: " .. err)
			task.spawn(threadTask.callingThread, result(false, err))
		else
			task.spawn(threadTask.callingThread, result(true, "success"))
		end
	end
end

return {
	new = constructor,
}
