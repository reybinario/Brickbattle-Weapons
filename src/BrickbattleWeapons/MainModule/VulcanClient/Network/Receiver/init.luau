--!strict
local CreationReceiver = require(script.CreationReceiver)

local Receiver = {}


function Receiver.setCallbacks()
    print("setting receiver callbacks")
    CreationReceiver.setCallback()
end

return Receiver