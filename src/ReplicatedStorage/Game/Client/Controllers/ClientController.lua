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


function ToolController(Tool)
    if Tool:IsA("Tool") then
        local Folder = Tool.Folder
        local IsOn = false

        local Lantern = Tool.lantern
        local Handle = Tool.Handle
        local Body = Lantern.Body
        -- local Weld = Handle.Weld
        -- local Angle = 0

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
        coroutine.wrap(function()
            -- local min = 10
            -- local max = 60
            -- local isMax = false
            -- local weldC1 = Weld.C1
            -- RunService.RenderStepped:Connect(function()
            --     local State = Character.Humanoid:GetState()
            --     local X = math.clamp(Angle,-60,60)

            --     warn(State)
            --     if State == Enum.HumanoidStateType.Running then
            --         if Angle >= max then
            --             isMax = true
            --         elseif Angle <= min then
            --             isMax = false
            --         end
                    
            --         if isMax then
            --             Angle -= .5
            --         else
            --             Angle += .5              
            --         end
            --     end

            --     warn(Angle)
            --     Weld.C1 = Weld.C1:Lerp((weldC1 * CFrame.new(0,1.6,-.1)) * CFrame.Angles(math.rad(X),0,math.rad(90)),1)

            --     --Weld.C1 = Weld.C1:Lerp(CFrame.new(Weld.C1.Position) * CFrame.Angles(math.rad(X),0,math.rad(90)),.2)
            --     -- Weld.Part1.CFrame = Weld.Part1.CFrame * 
            -- end)
        end)()

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