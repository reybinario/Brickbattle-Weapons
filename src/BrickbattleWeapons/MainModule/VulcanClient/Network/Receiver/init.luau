--!strict
local CreationReceiver = require(script.CreationReceiver)
local SuperballPhysicsReceiver = require(script.SuperballPhysicsReceiver)

local Receiver = {}


function Receiver.setCallbacks()
    print("setting receiver callbacks")
    CreationReceiver.setCallback()
    SuperballPhysicsReceiver.setCallback()
end

return Receiver
