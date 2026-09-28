--!strict
--[[
Entry point for the in-engine test run. The GitHub Action
(.github/workflows/engine-tests.yml) builds test.project.json, uploads it to
our throwaway test place, and then asks Roblox's Open Cloud Luau Execution
API to run THIS script inside a real server instance of that place.

Anything printed here lands in the Action's logs. An error marks the task -
and therefore the CI check - as failed.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local runAll = require(ReplicatedStorage.Tests.runAll)

local passed, failed, skipped = runAll()

print(("engine tests: %d passed, %d failed, %d skipped"):format(passed, failed, skipped))

if failed > 0 then
	error("engine tests failed", 0)
end
