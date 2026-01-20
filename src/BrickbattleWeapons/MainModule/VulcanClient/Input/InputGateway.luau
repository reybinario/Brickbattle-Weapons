--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Camera: Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local VulcanClient = script.Parent.Parent
local ClientConfig = require(VulcanClient.Management.ClientConfig)
local ConfigSchema = require(VulcanClient.Management.ConfigSchema)
local ToolActivator = require(script.Parent.ToolActivator)
local TargetResolver = require(script.Parent.TargetResolver)
local Trove = require(game.ReplicatedStorage.Packages:WaitForChild("trove"))

local GAMEPAD_FIRE_BUTTON = Enum.KeyCode.ButtonR2
local GAMEPAD_THUMBSTICK = Enum.KeyCode.Thumbstick2
local gamepadAim: Vector2 = Vector2.zero

local InputGateway = {}

local clientConfig: ConfigSchema.Config = ClientConfig.get()
local lastUsed: {[string]: number} = {}
local toolCache: {[Tool]: string} = {}

local VULCAN_ATTRIBUTE_NAME = "VulcanName"

local moduleTrove = Trove.new()
local characterTrove = nil

local function trackTool(tool: Tool)
    if toolCache[tool] then
        return
    end

    local vulcanName = tool:GetAttribute(VULCAN_ATTRIBUTE_NAME)
    if type(vulcanName) ~= "string" then
        return
    end

    local trove = Trove.new()
    characterTrove:Add(trove)
    trove:AttachToInstance(tool)

    toolCache[tool] = vulcanName

    trove:Add(function()
        toolCache[tool] = nil
    end)
end

local function hasTool(): boolean
    local character = LocalPlayer.Character
    if not character then
        return false
    end

    local tool = character:FindFirstChildWhichIsA("Tool")
    if not tool then
        return false
    end

    trackTool(tool)
    return toolCache[tool] ~= nil
end

local function isReady(tool: Tool): boolean
    local vulcanName = toolCache[tool]
    if not vulcanName then
        return false
    end

    local now = time()
    local last = lastUsed[vulcanName]

    if not last or (now - last) >= clientConfig[vulcanName].ReloadTime then
        lastUsed[vulcanName] = now
        return true
    end

    return false
end

local function passesActivationRules(_tool: Tool, _targetRay: Ray): boolean
    return true
end

local function processGamepadFire()
    if not hasTool() then
        return
    end

    local viewport = Camera.ViewportSize
    local centerX = viewport.X * 0.5
    local centerY = viewport.Y * 0.5

    local sensitivity = 300
    local offsetX = gamepadAim.X * sensitivity
    local offsetY = -gamepadAim.Y * sensitivity

    local targetRay = Camera:ViewportPointToRay(
        centerX + offsetX,
        centerY + offsetY
    )

    InputGateway.processInput(targetRay)
end


function InputGateway.processInput(targetRay: Ray)
    local character = LocalPlayer.Character
    if not character then
        return
    end

    local tool = character:FindFirstChildWhichIsA("Tool")
    if not tool then
        return
    end

    if isReady(tool) and passesActivationRules(tool, targetRay) then
        local endPosition, hit = TargetResolver.get3DPosition(targetRay)
        ToolActivator.activateTool(tool, hit, endPosition)
    end
end

function InputGateway.processTouch(position: Vector2, processedByUI: boolean)
    if processedByUI then
        return
    end

    if not hasTool() then
        return
    end

    local targetRay = Camera:ViewportPointToRay(position.X, position.Y)
    InputGateway.processInput(targetRay)
end

function InputGateway.processClick(input: InputObject, gameProcessedEvent: boolean)
    if gameProcessedEvent then
        return
    end

    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    if not hasTool() then
        return
    end

    local targetRay = Camera:ScreenPointToRay(input.Position.X, input.Position.Y)
    InputGateway.processInput(targetRay)
end

local function onCharacterAdded(character: Model)
    if characterTrove then
        characterTrove:Clean()
    end

    characterTrove = Trove.new()
    moduleTrove:Add(characterTrove)
    characterTrove:AttachToInstance(character)

    for _, child in character:GetChildren() do
        if child:IsA("Tool") then
            trackTool(child)
        end
    end

    characterTrove:Add(
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                trackTool(child)
            end
        end)
    )
end

function InputGateway.listenForInput()
    moduleTrove:Add(
        LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    )

    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end

    moduleTrove:Add(
        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Gamepad1
                and input.KeyCode == GAMEPAD_THUMBSTICK then
                gamepadAim = input.Position
            end
        end)
    )

    moduleTrove:Add(
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then
                return
            end

            if input.UserInputType == Enum.UserInputType.Gamepad1
                and input.KeyCode == GAMEPAD_FIRE_BUTTON then
                processGamepadFire()
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                InputGateway.processClick(input, gameProcessed)
            end
        end)
    )

    if UserInputService.TouchEnabled then
        moduleTrove:Add(
            UserInputService.TouchTapInWorld:Connect(InputGateway.processTouch)
        )
    end
end


return InputGateway
