--!strict
local module = {}

module.wait = function(t)
	local maxSafeWait = _G.BB.Settings.MaxSafeWait

	if maxSafeWait == 0 then
		return task.wait(t)
	end
	
	local totalWait = 0

	local timeRemaining = t
	while timeRemaining > 0 do
		local dt = task.wait()
		totalWait += dt
		if dt < maxSafeWait then
			timeRemaining -= dt
		end
	end
	
	return totalWait
end

return module