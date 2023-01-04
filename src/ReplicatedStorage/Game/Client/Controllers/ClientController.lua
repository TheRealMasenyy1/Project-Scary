local ClientController = {}

local player = game:GetService("Players").LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()

local RunService = game:GetService("RunService")
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

local HeartIsBeating = false


function ToolController(Tool)
    if Tool:IsA("Tool") then
        local Folder = Tool.Folder
        local IsOn = false

        local Animation = player.Character.Humanoid.Animator:LoadAnimation(Animations[Tool:GetAttribute("Idle")])
        Animation:Play()


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

                -- Weld.C0 = Body.CFrame:Inverse() 
                -- Weld.C1 = CFrame.Angles(math.rad(30),0,math.rad(90)) * Handle.CFrame:Inverse() * (CFrame.new(0,1.8,.8))        

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


function CameraStop()
    warn("BROOOOO WORK WORK WORK")
    ClientController:StopSprint()
end

function ClientController:Sprint(playerdata)
    local Stamina = playerdata["Stamina"]
    Camera.WobbleSpeed = 8
    Camera.Multiplier = .25

    player_Events.Sprint:FireServer("Sprint")
    HeartIsBeating = true

    -- coroutine.wrap(function()
    --     while HeartIsBeating do
    --         if (Stamina/1000) < 1 then
    --             print(Stamina/1000)
    --             -- player_Events.PlayStaminaSound:Invoke(Stamina/100)
    --         end
    --         task.wait(.7)
    --     end
    -- end)()
end

function ClientController:StopSprint()
    local playerdata = player_Events.getPlayerdata:InvokeServer()
    local Stamina = playerdata["Stamina"]
    Camera.WobbleSpeed = 5
    Camera.Multiplier = .1

    player_Events.Sprint:FireServer("Stop")
    HeartIsBeating = false

    -- player_Events.Sounds.StopStaminaSound:Invoke(Stamina/100)
end

UserInputService.InputEnded:Connect(function(input,ingame)
    local Key = input.KeyCode.Name
    local playerdata = player_Events.getPlayerdata:InvokeServer()
    local Inputs  = playerdata["Inputs"]
    if not ingame then    
        warn(Inputs)
        if Key == "LeftControl" then
            Camera.IsLookingAround = false
            warn("IsLooking around")
        end
            
        if Inputs[Key] then
            ClientController:StopSprint()
        end
    end
end)

UserInputService.InputBegan:Connect(function(input,ingame)
    local Key = input.KeyCode.Name
    local playerdata = player_Events.getPlayerdata:InvokeServer()
    local Inputs  = playerdata["Inputs"]
    if not ingame then   
        
        --warn(Inputs)
        if Inputs[Key] then
            ClientController:Sprint(playerdata)
        end

        if Key == "LeftControl" then
            Camera.IsLookingAround = true
            warn("IsLooking around")
        end

    end
    print(Key)
end)

Character.ChildAdded:Connect(ToolController)
player_Events.ResetCamera.OnClientEvent:Connect(CameraStop)

return ClientController