local CameraManager = {}
CameraManager.__index = CameraManager

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Camera = workspace.CurrentCamera
local Mouse = game.Players.LocalPlayer:GetMouse()
local UserGameSettings = UserSettings():GetService("UserGameSettings")
local xAngle, yAngle = 0,0

local Game_Folder = ReplicatedStorage.Game
local Shared = Game_Folder.Shared

local Shortcut = require(Shared.Utility.Shortcut)

function CameraManager.Setup(Character)
    local self = setmetatable({},CameraManager)

    self.IsActivated = true;
    self.FOV = 70;
    self.ShowMouse = true
    self.LockMouse = true;
    self.IsLookingAround = false;
    self.WobbleSpeed = 5 -- Changes the how strong the camera wobbles
    self.Multiplier = .1 -- Changes the speed of the camera wobble
    self.FIRST_PERSON_OFFSET = Vector3.new(0, 1.5, -.5)
    self.PartsToShow = {
        ["RightUpperArm"] = true;
        ["RightLowerArm"] = true;
        ["RightHand"] = true;
        ["LeftUpperArm"] = true;
        ["LeftLowerArm"] = true;
        ["LeftHand"] = true;
    };
    -- Camera.

    coroutine.wrap(function()
        local xRot = 0
        local yRot = 0
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
		raycastParams.FilterDescendantsInstances = {Character}
		raycastParams.IgnoreWater = false

        Camera.CameraType = Enum.CameraType.Scriptable
        self:SetView(Character)
        Mouse.Icon = "rbxassetid://12029359473"

        RunService.RenderStepped:Connect(function()

            if Character then
                local RightUpperArm = Character.RightUpperArm
                local RightShoulder = RightUpperArm.RightShoulder
                Camera.CameraSubject = Character.Head
                -- local Mouse = UserInputService:GetMouseLocation()
                local Delta = UserInputService:GetMouseDelta()
                xAngle = xAngle - Delta.X
                yAngle = math.clamp(yAngle - Delta.Y, -80, 80)

                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                local Head = Character:FindFirstChild("HumanoidRootPart")
                if HumanoidRootPart then
                    -- warn("X: ",xAngle,"Y: ",yAngle)
                    local StartPosition = HumanoidRootPart.CFrame * self.FIRST_PERSON_OFFSET
                    local StartOrientation = CFrame.Angles(0, math.rad(xAngle), 0) * CFrame.Angles(math.rad(yAngle), 0, 0) + StartPosition
                    local CameraFocus = StartOrientation + StartOrientation:VectorToWorldSpace(Vector3.new(0, 0, -5))
                    local mouseDelta = UserInputService:GetMouseDelta()
                    local currentTime = tick()
                    local mouseSensitivity = UserGameSettings.MouseSensitivity
                    -- warn(CameraFocus.Position)

                    xRot += math.rad((mouseDelta.X*0.25)*mouseSensitivity * -1)
                    yRot += math.rad((mouseDelta.Y*0.25)*mouseSensitivity * -1)
                    
                    yRot = math.clamp(yRot,math.rad(-75),math.rad(75))

                    if not self.IsLookingAround then --! Add so that camera returns to the prviouse position
                        local Y = math.clamp(yAngle,0,180) --! Max = -20
                        local WobbleX = math.cos(currentTime * self.WobbleSpeed) * self.Multiplier
                        local WobbleY = math.abs(math.sin(currentTime * self.WobbleSpeed)) * self.Multiplier

                        Camera.CameraSubject = Character.Head

                        local Origin = Camera.CFrame.Position
                        local Direction = Vector3.new(0,0,0)
                        local Wobble = Vector3.new(WobbleX,WobbleY,0)
                        -- local Raycast = Shortcut.RayCast(Origin,Camera.CFrame.LookVector * 1000,raycastParams)

                        -- HumanoidRootPart.CFrame = CFrame.Angles(0, math.rad(xAngle), 0) + HumanoidRootPart.Position
                        -- Camera.CFrame = CFrame.new(StartPosition, CameraFocus.Position)
                        
                        HumanoidRootPart.CFrame = CFrame.Angles(0, xRot, 0) + HumanoidRootPart.Position
                        Camera.Focus = CFrame.new(Camera.CameraSubject.Position)

                        if Character.Humanoid.MoveDirection.Magnitude > 0 then
                            Camera.CFrame = Camera.Focus + Wobble
                        else
                            Camera.CFrame = Camera.Focus:Lerp(Camera.Focus,.7)
                        end
                        
                        Camera.CFrame *= CFrame.fromEulerAnglesYXZ(yRot, xRot, 0) * CFrame.new(0,0,-1)

                        Character.Humanoid.CameraOffset = Character.Humanoid.CameraOffset:lerp(Wobble,.25)

                    else              
                        local rX, rY, rZ = Camera.CFrame:ToOrientation()
                        local limX = math.clamp(math.deg(rX), -45, 45)

                        -- xRot = math.clamp(xRot,math.rad(-75),math.rad(75))

                        Camera.Focus = CFrame.new(Camera.CameraSubject.Position)
                        Camera.CFrame = Camera.Focus
                        Camera.CFrame *= CFrame.fromEulerAnglesYXZ(yRot, xRot, 0) * CFrame.new(0,0,-1)

                        -- Camera.CameraSubject = Character.Humanoid
                        -- Camera.CFrame = CFrame.new(StartPosition) * CFrame.fromOrientation(math.rad(limX),rY, rZ)
                        
                        -- warn("X: ",xAngle," Y: ", yAngle," Z: ", rZ) --Xmin: 0.036302827298641205 , Xmax: 0.17191436886787415
                    end
                    
                end
            end

            UserInputService.MouseIconEnabled = self.ShowMouse

            if self.LockMouse then
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            else
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default                
            end
        end)
    end)()

    return self
end

function CameraManager:GetAxis(originCF, targetPos, l1, l2)
	-- build intial values for solving
	local localized = originCF:pointToObjectSpace(targetPos)
	local localizedUnit = localized.unit
	local l3 = localized.magnitude

	-- build a "rolled" planeCF for a more natural arm look
	local axis = Vector3.new(0, 0, -1):Cross(localizedUnit)
	local angle = math.acos(-localizedUnit.Z)
	local planeCF = originCF * CFrame.fromAxisAngle(axis, angle)

	-- case: point is to close, unreachable
	-- action: push back planeCF so the "hand" still reaches, angles fully compressed
	if l3 < math.max(l2, l1) - math.min(l2, l1) then
		return planeCF * CFrame.new(0, 0,  math.max(l2, l1) - math.min(l2, l1) - l3), -math.pi/2, math.pi

		-- case: point is to far, unreachable
		-- action: for forward planeCF so the "hand" still reaches, angles fully extended
	elseif l3 > l1 + l2 then
		return planeCF * CFrame.new(0, 0, l1 + l2 - l3), math.pi/2, 0
		-- case: point is reachable
		-- action: planeCF is fine, solve the angles of the triangle
	else
		local a1 = -math.acos((-(l2 * l2) + (l1 * l1) + (l3 * l3)) / (2 * l1 * l3))
		local a2 = math.acos(((l2  * l2) - (l1 * l1) + (l3 * l3)) / (2 * l2 * l3))

		return planeCF, math.pi/2, 0
	end
end

function CameraManager:FABRIK(Character,Goal1)
	local upperTorso	= Character:WaitForChild("UpperTorso")
	local RootPart = Character:WaitForChild("HumanoidRootPart")

	local rightShoulder = Character:WaitForChild("RightUpperArm"):WaitForChild("RightShoulder")
	local rightElbow	= Character:WaitForChild("RightLowerArm"):WaitForChild("RightElbow")
	local rightWrist	= Character:WaitForChild("RightHand"):WaitForChild("RightWrist")

	local SHOULDER_C0_CACHE		= rightShoulder.C0
	local ELBOW_C0_CACHE		= rightElbow.C0

	local UPPER_LENGTH			= math.abs(rightShoulder.C1.Y) + math.abs(rightElbow.C0.Y)
	local LOWER_LENGTH			= math.abs(rightElbow.C1.Y) + math.abs(rightWrist.C0.Y) + math.abs(rightWrist.C1.Y)

		local shoulderCFrame = upperTorso.CFrame * SHOULDER_C0_CACHE

		local goalPosition = Goal1	
		local planeCF, shoulderAngle, elbowAngle = self:GetAxis(shoulderCFrame, goalPosition, UPPER_LENGTH, LOWER_LENGTH)

		rightShoulder.C0 = upperTorso.CFrame:toObjectSpace(planeCF) * CFrame.Angles(shoulderAngle, 0, 0)
		rightElbow.C0 = ELBOW_C0_CACHE * CFrame.Angles(elbowAngle, 0, 0)

	-- local ArmSet = RunService.Stepped:Connect(function()
	-- 	rightShoulder.Transform = CFrame.new()
	-- 	rightElbow.Transform = CFrame.new()
	-- 	rightWrist.Transform = CFrame.new()
	-- end)

	return rightShoulder,rightElbow,rightWrist
end

function CameraManager:SetView(Character)

    repeat
        task.wait()
    until Character.Humanoid

    Character.Humanoid:RemoveAccessories()

    for _,Parts in pairs(Character:GetChildren()) do
        if Parts:IsA("BasePart") and not self.PartsToShow[Parts.Name] then
            Parts.Transparency = 1
        end
    end
end

function CameraManager:Disable()
    
end

return CameraManager