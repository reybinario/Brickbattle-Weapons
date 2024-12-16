--!strict

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ClientConfig = require(script.Parent.Management.ClientConfig)
local ComboManager = require(script.Parent.Input.ComboManager)
local InputGateway = require(script.Parent.Input.InputGateway)

function start()
    print("Thank you for using Vulcan Brickbattle Weapons. Setting up client...")
    ClientConfig.acquireConfiguration()
    ComboManager.setupLocalCharacterCollisionGroups(LocalPlayer)
    InputGateway.listenForInput()
end

start()
