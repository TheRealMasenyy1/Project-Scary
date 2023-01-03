local Shortcut = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

function Shortcut:GetMousePos(MouseHit,MouseOrigin,MouseTarget,MaxDistance,DestroyOnClick)
	--local Distance = (player.Character.HumanoidRootPart.Position - MouseHit.Position)
	local player = Players.LocalPlayer
	local part
	part = Instance.new("Part",workspace)
	part.Size = Vector3.new(1,1,1)
	part.Anchored = true
	part.Transparency = 1
	part.CanCollide = false
	part.Name = "Marker"
	
	if MouseHit ~= nil then
		part.CFrame = MouseHit --+ Vector3.new(0,2,0)
	else
		part.CFrame = MouseOrigin
	end
	
	local Position = part.Position
	
	if (DestroyOnClick == nil or DestroyOnClick == true) then
		part:Destroy()
	end
	
	if MouseTarget ~= nil and MouseTarget.Name == "Zone" then
		part:Destroy()
		Position = MouseTarget.Position
		part = MouseTarget
	end
	
	return Position,part
end

function Shortcut:Debug(...)
	if RunService:IsStudio() then
		print(...)
	end
end

function Shortcut:SuperDebug(...)
	if RunService:IsStudio() then
		warn(...)
	end
end

function Shortcut:Getlength(Table)
	local amount = 0;
	
	for name,info in pairs(Table) do
		amount += 1;
	end

	return amount;
end

function Shortcut:CustomRayCast(player,Pos,Size)
	local HumanoidRootPart = player.HumanoidRootPart;

	local distance = (HumanoidRootPart.Position - Pos).Magnitude
	local p = Instance.new("Part",workspace.Debris)
	p.Anchored = true
	p.CanCollide = false
	p.Size = Vector3.new(Size, Size, distance+4)
	p.CFrame = CFrame.lookAt(HumanoidRootPart.Position + Vector3.new(0,0,2), Pos)*CFrame.new(0, 0, -distance/2)
	p.Name = player.Name.."- Attack"
	p.Transparency = 0
	
	return p
end

function Shortcut:GiveReward(playerName,Exp,Money)
	local player = game.Players:FindFirstChild(playerName)

	if player then 
		local Stats_Folder = player:WaitForChild("Stats")
		local EXP = Stats_Folder:WaitForChild("Exp")
		local MONEY = Stats_Folder:WaitForChild("Money")

		MONEY.Value += Money
		EXP.Value += Exp
	end
end

function Shortcut:Wait(t)
    t = typeof(t) == 'number' and t or 0

    local spent = 0
    repeat
        spent += RunService.Heartbeat:Wait()
    until spent >= t
end

function Shortcut.RayCast(Origin : Vector3,Diraction : Vector3,Params : RaycastParams)
	
	if Params == nil then
		local raycastParams = RaycastParams.new()
		raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
		raycastParams.FilterDescendantsInstances = {workspace.Map}
		raycastParams.IgnoreWater = true
		
		Params = raycastParams
	end
	
	local raycastResult = workspace:Raycast(Origin,Diraction,Params)
		
	return raycastResult
end

function Shortcut.Lightning(player,from,too,Damage,Off,Steps,SizeX,pSizeY,WaitTime)		
	local off = Off
	local Step = tonumber(Steps)

	local Touched = {}
	local Distance = (from-too).Magnitude
	
	lastPos = from
	
	if WaitTime == nil then
		WaitTime = 1
	end
--	print(WaitTime)
	for i=0,Distance,Step do
		
		local from = lastPos
		
		local offset = Vector3.new(
				math.random(-off,off),
				math.random(-off,off),
				math.random(-off,off)			
				)/10			
		
		
		local too = from +- (from-too).unit*Step + offset
		local New_Distance = (from-too).Magnitude
		
		local p =  script.bolt:Clone()
		p.Parent = workspace:WaitForChild("Lightning_Debris-"..player.Name)
		p.Size = Vector3.new(SizeX,pSizeY,New_Distance)
		p.CFrame = CFrame.new(from:Lerp(too,0.5), too)
		
		p.Touched:Connect(function(hit)
			local Humanoid = hit.Parent:FindFirstChild("Humanoid")
			
			if Humanoid and hit.Parent.Name ~= player.Name and not Touched[hit.Parent.Name] then
				Touched[hit.Parent.Name] = true
				Humanoid:TakeDamage(Damage)
				--print("Touched him: "..Humanoid.Health)
			end
		end)
		
		game.Debris:AddItem(p,WaitTime)
		
		lastPos = too
	end

end

function Shortcut:Hair(Character,Object)
	for i,GetObject in pairs(Character:GetChildren()) do
		if GetObject:IsA("Model") and GetObject.Name:find("Hair") then
			GetObject:Destroy()
		end
	end				
			
	local Hair = Object:Clone()
	Hair.Parent = Character
	Hair:SetPrimaryPartCFrame(Character.Head.CFrame * CFrame.new(0,0,0))
			
	local Weld = Instance.new("WeldConstraint",Character.Head)
	Weld.Part0 = Character.Head
	Weld.Part1 = Hair.PrimaryPart
end

---function 

function Shortcut.SmoothLookAt(player,Target)
	local Character : Instance;

	if game.Players:FindFirstChild(player.Name) then
		Character = player.Character
	else
		Character = player 
	end

	local Prop = {
		CFrame = CFrame.new(Character.HumanoidRootPart.Position,Vector3.new(Target.HumanoidRootPart.Position.X,Character.HumanoidRootPart.Position.Y,Target.HumanoidRootPart.Position.Z))
	}

	local TweenInfomation = TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false,.1)
	local Tween = TweenService:Create(player.HumanoidRootPart,TweenInfomation,Prop)

	Tween:Play()
	return Tween
end


function Shortcut.LookAt(player,Target)	local Character : Instance;

	if game.Players:FindFirstChild(player.Name) then
		Character = player.Character
	else
		Character = player 
	end
	
	player.HumanoidRootPart.CFrame = CFrame.new(Character.HumanoidRootPart.Position,Vector3.new(Target.HumanoidRootPart.Position.X,Character.HumanoidRootPart.Position.Y,Target.HumanoidRootPart.Position.Z))
	
	return true
end


function Shortcut.AttackAim(player,Target)
	local Character : Instance;

	if game.Players:FindFirstChild(player.Name) then
		Character = player.Character
	else
		Character = player 
	end

	return CFrame.new(Character.HumanoidRootPart.Position,Target)
end

return Shortcut