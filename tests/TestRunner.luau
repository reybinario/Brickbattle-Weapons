--!strict
--[[
TestRunner: the smallest harness that works. A suite is a named list of
tests; each test is a function that

  - returns quietly when it passes,
  - calls TestRunner.skip(reason) when it does not apply on this branch
    (for example, a validator that has not merged yet), or
  - errors (usually via an expect* helper below) when it fails.

TestRunner.run prints one line per test so the CI log reads like a story.
]]
local TestRunner = {}

local SKIP_MARKER = "ENGINE_TEST_SKIP:"

-- Marks the current test as not applicable on this branch.
function TestRunner.skip(reason: string)
	error(SKIP_MARKER .. reason, 0)
end

function TestRunner.expectTrue(value: boolean, message: string)
	if not value then
		error("expected true - " .. message, 2)
	end
end

function TestRunner.expectFalse(value: boolean, message: string)
	if value then
		error("expected false - " .. message, 2)
	end
end

function TestRunner.expectApprox(actual: number, expected: number, tolerance: number, message: string)
	if math.abs(actual - expected) > tolerance then
		error(("expected %.4f +/- %.4f, got %.4f - %s"):format(expected, tolerance, actual, message), 2)
	end
end

export type Test = { name: string, run: () -> () }
export type Suite = { name: string, tests: { Test } }

-- Runs every suite in order. Returns passed, failed, skipped counts.
function TestRunner.run(suites: { Suite }): (number, number, number)
	local passed, failed, skipped = 0, 0, 0
	for _, suite in suites do
		print("== " .. suite.name .. " ==")
		for _, test in suite.tests do
			local ok, err = pcall(test.run)
			if ok then
				passed += 1
				print("  PASS " .. test.name)
			elseif typeof(err) == "string" and string.sub(err, 1, #SKIP_MARKER) == SKIP_MARKER then
				skipped += 1
				print("  SKIP " .. test.name .. " (" .. string.sub(err, #SKIP_MARKER + 1) .. ")")
			else
				failed += 1
				warn("  FAIL " .. test.name .. ": " .. tostring(err))
			end
		end
	end
	return passed, failed, skipped
end

return TestRunner
