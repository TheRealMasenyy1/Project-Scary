local SoundController = {}

local player = game:GetService("Players").LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Events = ReplicatedStorage.Events
local Camera = workspace.CurrentCamera

local Game_Folder = ReplicatedStorage.Game
local Shared = Game_Folder.Shared
local player_Events = Events.Player

local SoundRegions = workspace.SoundRegion

print("REQUIRED...")
local Zone = require(Shared.Utility.Zone)
local soundmanager = require(Shared.Managers.SoundManager)
local SoundManager = soundmanager.Setup(player)

local filter = OverlapParams.new()
filter.FilterType = Enum.RaycastFilterType.Blacklist
filter.FilterDescendantsInstances = { workspace.SoundRegion }

function LoopTime(Time)
	local dt = 0

	while dt < Time do
		dt += RunService.Heartbeat:Wait()
	end

	return
end

--[[

    SoundData Example

    {
        SoundName = "HollowRoar";
        SoundParent = Hollow; -- or workspace.Enemies.Hollow etc ..
        SoundLoop = true; -- use if needed
        LoopTime = 5; --- 5 seconds only works if SoundLoop is true
        Function = "play"; or get
    }

--]]

function SoundController:Play(SoundData)
	local SoundFunction = string.lower(SoundData["Function"]) -- This could be Play or Stop or Pause
	local SoundName = SoundData["SoundName"]
	local SoundParent = SoundData["SoundParent"] or player.Character --? Where to place the sound Instance
	local SoundLoop = SoundData["SoundLoop"] or false

	print("This is working as it should | ", SoundData, " | ", SoundLoop)

	if SoundName ~= nil and not SoundLoop and not SoundParent:FindFirstChild(SoundName) then
		-- local ConvertedFunction = Functions[SoundFunction]
		SoundManager:PlaySoundFromService(SoundName, SoundParent)
		warn("SOUND WAS PLAYED")
	elseif SoundName ~= nil and SoundLoop and not SoundParent:FindFirstChild(SoundName) then
		local Sound = SoundManager:GetSoundFromService(SoundName, SoundParent)
		local Time = SoundData["LoopTime"]
		-- warn("This is the Sound | ", Sound)
		Sound.Looped = SoundLoop
		Sound:Play()	 
		SoundManager.SoundStatus = "Playing"

		if Time then
			LoopTime(Time)
		end

		Sound:Destroy()
	else
		error("Missed to Input, probably SoundName | " .. SoundName .. " | ", 2)
	end
end


player_Events.PlaySound.OnInvoke = function(SoundData)
    SoundController:Play(SoundData)
end

player_Events.UseSound.OnClientEvent:Connect(function(SoundData)
    SoundController:Play(SoundData)
end)

function SoundController:PlayAmbient()
	for _,SoundRegions in pairs(SoundRegions:GetChildren()) do
		if SoundRegions:IsA("Folder") then
			local ZoneDetector = Zone.new(SoundRegions) 
			ZoneDetector.name = SoundRegions.Name
			ZoneDetector.localPlayerEntered:Connect(function(TEST,SECOND)
				local Location = SoundRegions.name
	
				print(Location.." : Here")
				--print(Location[1].Parent.Name)
	
				if Location ~= nil then
					print(Location)
					SoundManager:StartAmbient(Location,{["Volume"] = 0.017,["Parent"] = player.Character})
					-- Last_Location = Location
				end
			end)
		end
	end
end

coroutine.wrap(function()
    RunService.Heartbeat:Connect(function()
        if SoundManager.PlayWalkingSound and player.Character then
            local Origin = player.Character.HumanoidRootPart.Position
			local Humanoid = player.Character.Humanoid
            local Direction = Vector3.new(0,-3,0)
            -- local Raycast = Shortcut.RayCast(Origin,Direction,SoundManager.raycastParams)

            --Shortcut:CustomRayCast(player.Character,Direction,1)
			-- warn(player.Character.Humanoid.FloorMaterial)
            if Humanoid.FloorMaterial and Humanoid.MoveDirection.Magnitude > 0 then
                SoundManager:GroundSound(player,Humanoid.FloorMaterial.Name)
			elseif SoundManager.CurrentSound and Humanoid.MoveDirection.Magnitude == 0 then
				SoundManager:Stop(SoundManager.CurrentSound,{["Volume"] = 0})
				SoundManager.WalkingSoundIsPlaying = false
            end
            
            --workspace.Debris:ClearAllChildren()
        end

    end)

	SoundController:PlayAmbient()
end)()


--[[
		Zone.localPlayerEntered:Connect(function(TEST,SECOND)
			local Location = GetSoundZones.name

			print(Last_Location.." : "..GetSoundZones.name)
			--print(Location[1].Parent.Name)

			if Location ~= nil then
				print(Location)
				Sound:GetAudio(Location)
				Last_Location = Location
			end
		end)
]]--

return SoundController
