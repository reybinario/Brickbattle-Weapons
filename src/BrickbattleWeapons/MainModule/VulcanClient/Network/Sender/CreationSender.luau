--!strict
local NetworkClient = require(script.Parent.Parent.NetworkClient)
local CreationSender = {}

function CreationSender.sendCreateRequest(weapon: string, createData: any)
	local createEvent = NetworkClient[weapon .. "Create"]
	if not createEvent then
		error("No event for " .. weapon)
	end
	createEvent.Fire(createData)
end

return CreationSender
