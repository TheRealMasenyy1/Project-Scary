-- local ToolController = {}

-- local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- local Assets = ReplicatedStorage.Assets
-- local Animations = Assets.Animations

-- local Events = ReplicatedStorage.Events
-- local player_Events = Events.Player

-- local player = game.Players.LocalPlayer
-- local Character = player.Character or player.CharacterAdded:Wait()

-- function ToolController.new(Tool)
--     local self = setmetatable({}, ToolController)

--     self.Tool = Tool or nil
--     self.Usage = 100; -- Shouldn't be here
--     self.Recharges = 0; -- Should be server sided

--     return self
-- end

-- function getTool(Tool)
--     if Tool:IsA("Tool") then
--         local Folder = Tool.Folder
--         local IsOn = false

--         local Animation = player.Character.Humanoid.Animator:LoadAnimation(Animations[Tool:GetAttribute("Idle")])
--         Animation:Play()


--         Tool.Activated:Connect(function()
--             print("Pressed", IsOn)
--             if not IsOn then
--                 player_Events.PlaySound:Invoke({
--                     SoundName = "FlashlightOn";
--                     SoundParent = Tool; -- or workspace.Enemies.Hollow etc ..
--                     SoundLoop = false; -- use if needed
--                     LoopTime = 0; --- 5 seconds only works if SoundLoop is true
--                     Function = "play";
--                 })

--                 -- Weld.C0 = Body.CFrame:Inverse() 
--                 -- Weld.C1 = CFrame.Angles(math.rad(30),0,math.rad(90)) * Handle.CFrame:Inverse() * (CFrame.new(0,1.8,.8))        

--                 Folder.Event:FireServer()
--             else
--                 player_Events.PlaySound:Invoke({
--                     SoundName = "FlashlightOff";
--                     SoundParent = Tool; -- or workspace.Enemies.Hollow etc ..
--                     SoundLoop = false; -- use if needed
--                     LoopTime = 0; --- 5 seconds only works if SoundLoop is true
--                     Function = "play";
--                 })
--                 Folder.Event:FireServer()
--             end

--         end)


--     end
-- end

-- Character.ChildAdded:Connect(getTool)



-- return ToolController