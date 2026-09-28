--!strict
--[[
ValidationReceiver applies the server's verdict for each superball.

Every replicated ball is born inert: CreationReceiver writes the validation
flag as an attribute the moment the ball appears. A "validated" verdict flips
that flag live; a rejection destroys the inert copy. Damage and destruction
consumers must check the attribute - those consumers are later slices.
]]
local NetworkClient = require(script.Parent.Parent.NetworkClient)
local SuperballLocator = require(script.Parent.SuperballLocator)

local ValidationReceiver = {}

ValidationReceiver.VALIDATED_ATTRIBUTE = "VulcanValidated"

function ValidationReceiver.setCallback()
    NetworkClient.superballValidation.On(function(data)
        local ball = SuperballLocator.find(data.player, data.count)
        if not ball then
            return
        end
        if data.validated then
            ball:SetAttribute(ValidationReceiver.VALIDATED_ATTRIBUTE, true)
        else
            ball:Destroy()
        end
    end)
end

return ValidationReceiver
