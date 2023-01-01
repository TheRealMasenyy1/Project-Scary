local CameraManager = {}
CameraManager.__index = CameraManager

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera
local Mouse = game.Players.LocalPlayer:GetMouse()
local xAngle, yAngle = 0,0

function CameraManager.Setup(Character)
    local self = setmetatable({},CameraManager)

    self.IsActivated = true;
    self.FOV = 70;
    self.ShowMouse = false
    self.LockMouse = true;
    self.IsLookingAround = false;
    self.FIRST_PERSON_OFFSET = Vector3.new(0, 2, 0)
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
        self:SetView(Character)
        
        RunService.RenderStepped:Connect(function()

            if Character then
                local RightUpperArm = Character.RightUpperArm
                local RightShoulder = RightUpperArm.RightShoulder

                local Mouse = UserInputService:GetMouseLocation()
                local Delta = UserInputService:GetMouseDelta()
                xAngle = xAngle - Delta.X
                yAngle = math.clamp(yAngle - Delta.Y, -80, 80)

                local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
                
                if HumanoidRootPart then
                    warn("X: ",xAngle,"Y: ",yAngle)
                    local StartPosition = HumanoidRootPart.CFrame * self.FIRST_PERSON_OFFSET
                    local StartOrientation = CFrame.Angles(0, math.rad(xAngle), 0) * CFrame.Angles(math.rad(yAngle), 0, 0) + StartPosition
                    local CameraFocus = StartOrientation + StartOrientation:VectorToWorldSpace(Vector3.new(0, 0, -5))
                    
                    -- warn(CameraFocus.Position)
                    if not self.IsLookingAround then --! Add so that camera returns to the prviouse position
                        local Y = math.clamp(yAngle,0,180) --! Max = -20
                        local riseMagnitude = 0.9
                        local RC1 = CFrame.new(1, .5, 0, 0, 0, riseMagnitude, 0, riseMagnitude, 0, -riseMagnitude, 0, 0)
                        local offset = CFrame.Angles(0,0,Camera.CFrame.LookVector.Y)
                        local camCF = Camera.CoordinateFrame


                        HumanoidRootPart.CFrame = CFrame.Angles(0, math.rad(xAngle), 0) + HumanoidRootPart.Position
                        Camera.CFrame = CFrame.new(StartPosition, CameraFocus.Position)
                        --RightShoulder.C1 * CFrame.Angles(math.rad(yAngle), 0, 0)
                        local cf = RightUpperArm.CFrame * CFrame.Angles(math.pi/2, 0, 0) * CFrame.new(0, 1.5, 0);
                        -- update the C1 value needed to for the arm to be at cf (do this by rearranging the joint equality from before)
                        RightShoulder.C1 = RightShoulder.C1 * CFrame.new(RightShoulder.C1.Position,Vector3.new(0,10,0))
                        -- RightShoulder.C0:lerp((camCF * CFrame.new(1, -1, 0)):ToObjectSpace(Character.UpperTorso.CFrame):Inverse() * CFrame.Angles(0, math.pi/2, 0), 0.4)
                    else              
                        local rX, rY, rZ = Camera.CFrame:ToOrientation()
                        local limX = math.clamp(math.deg(rX), -45, 45)

                        Camera.CFrame = CFrame.new(StartPosition) * CFrame.fromOrientation(math.rad(limX),rY, rZ)
                        
                        warn("X: ",xAngle," Y: ", yAngle," Z: ", rZ) --Xmin: 0.036302827298641205 , Xmax: 0.17191436886787415
 
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

function CameraManager:SetView(Character)

    repeat
        task.wait()
    until Character.HumanoidRootPart

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