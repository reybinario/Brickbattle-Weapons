--!strict

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ClientConfig = require(script.Parent.Management.ClientConfig)
local ComboManager = require(script.Parent.Input.ComboUtils)
local InputGateway = require(script.Parent.Input.InputGateway)
local TargetingManager = require(script.Parent.Input.TargetResolver)
local Receiver = require(script.Parent.Network.Receiver)

function start()
    print("Thank you for using Vulcan Brickbattle Weapons. Setting up client...")
    ClientConfig.acquireConfiguration()
    ComboManager.setupLocalCharacterCollisionGroups(LocalPlayer)
    addTargetingRules()
    InputGateway.listenForInput()
    Receiver.setCallbacks()
    print("Vulcan Brickbattle Weapons client setup completed.")
end

function addTargetingRules()
    TargetingManager.addTargetingCallback("CanCollide", function(hit: BasePart, _: Vector3): boolean
        if isHumanoidPart(hit) then
            return true
        end
        return hit.CanCollide
    end)
    TargetingManager.addTargetingCallback("CanTouch", function(hit: BasePart, _: Vector3): boolean
        if isHumanoidPart(hit) then
            return true
        end
        return hit.CanTouch
    end)
    TargetingManager.addTargetingCallback("CanQuery", function(hit: BasePart, _: Vector3): boolean
        if isHumanoidPart(hit) then
            return true
        end
        return hit.CanQuery
    end)
    TargetingManager.addTargetingCallback("Transparency", function(hit: BasePart, _: Vector3): boolean
        if isHumanoidPart(hit) then
            return true
        end
        return hit.Transparency < 0.91
    end)
end

function isHumanoidPart(hit: BasePart)
    return hit.Parent ~= nil and hit.Parent:FindFirstChildWhichIsA("Humanoid")
end
start()
