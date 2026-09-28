--!strict
local CreationReceiver = require(script.CreationReceiver)
local PhysicsReceiver = require(script.PhysicsReceiver)
local ValidationReceiver = require(script.ValidationReceiver)

local Receiver = {}


function Receiver.setCallbacks()
    print("setting receiver callbacks")
    CreationReceiver.setCallback()
    PhysicsReceiver.setCallback()
    ValidationReceiver.setCallback()
end

return Receiver
