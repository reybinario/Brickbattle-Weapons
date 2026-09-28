--!strict
--[[
Runs every engine test suite. Suites that target code which has not merged
yet report SKIP rather than FAIL, so this runner works on every branch and
grows stricter as the validator slices land.
]]
local TestRunner = require(script.Parent.TestRunner)

return function(): (number, number, number)
	return TestRunner.run({
		require(script.Parent.PhysicsGroundTruthTests),
		require(script.Parent.CoreValidationTests),
		require(script.Parent.CreationValidatorTests),
		require(script.Parent.UpdateValidatorTests),
	})
end
