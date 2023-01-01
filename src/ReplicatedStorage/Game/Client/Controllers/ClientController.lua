local ClientController = {}

local player = game:GetService("Players").LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage.Game
local Shared = Modules.Shared

local Assets = ReplicatedStorage.Assets
local Sounds = Assets.Sounds
local Animations = Assets.Animations
local Events = ReplicatedStorage.Events
local player_Events = Events.Player

local CameraManager = require(Shared.Managers.CameraManager)
local Camera = CameraManager.Setup(Character)


function ToolController(Tool)
    if Tool:IsA("Tool") then
        local Folder = Tool.Folder
        local IsOn = false

        Tool.Activated:Connect(function()
            print("Pressed", IsOn)
            if not IsOn then
                player_Events.PlaySound:Invoke({
                    SoundName = "FlashlightOn";
                    SoundParent = Tool; -- or workspace.Enemies.Hollow etc ..
                    SoundLoop = false; -- use if needed
                    LoopTime = 0; --- 5 seconds only works if SoundLoop is true
                    Function = "play";
                })
                -- local Animation = player.Character.Humanoid.Animator:LoadAnimation(Animations.LightOn)
                -- Animation:Play()
        
                Folder.Event:FireServer()
            else
                player_Events.PlaySound:Invoke({
                    SoundName = "FlashlightOff";
                    SoundParent = Tool; -- or workspace.Enemies.Hollow etc ..
                    SoundLoop = false; -- use if needed
                    LoopTime = 0; --- 5 seconds only works if SoundLoop is true
                    Function = "play";
                })
                Folder.Event:FireServer()
            end
        end)
    end
end

Character.ChildAdded:Connect(ToolController)

UserInputService.InputEnded:Connect(function(input)
    local Key = input.KeyCode.Name

    if Key == "LeftControl" then
        Camera.IsLookingAround = false
        warn("IsLooking around")
    end
end)

UserInputService.InputBegan:Connect(function(input,ingame)
    local Key = input.KeyCode.Name

    if Key == "LeftControl" then
        Camera.IsLookingAround = true
        warn("IsLooking around")
    end

    print(Key)
end)


return ClientController