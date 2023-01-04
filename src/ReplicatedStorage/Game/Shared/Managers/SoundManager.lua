local Players = game.Players

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Events = ReplicatedStorage.Events

local UseSound = Events.Player.UseSound
local Assets = ReplicatedStorage.Assets
local Sounds = Assets.Sounds

local Game_Folder = ReplicatedStorage.Game
local Shared = Game_Folder.Shared

local Shortcut = require(Shared.Utility.Shortcut)


local SoundManager = {}
SoundManager.__index = SoundManager

--[[

--! CLASS REVAMP NO YET DONE

--]]


function SoundManager.Setup(player)
	local self = setmetatable({},SoundManager)

	self.CurrentSound = nil;
	self.CurrentAmbient = nil;
	self.CurrentPlayerSound = {};
	self.SoundStatus = nil;
    self.PlayWalkingSound = true;
	self.AmbientSounds = {};
    self.WalkingSoundIsPlaying = false;
    self.raycastParams = RaycastParams.new()
    self.raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    self.raycastParams.FilterDescendantsInstances = {workspace.Map,workspace.Terrain}
    self.raycastParams.IgnoreWater = true
    
    self.MaterialSound = {
        ["Wood"] = "Walk on Wood";
		["Grass"] = "Walk on Grass";
		["WoodPlanks"] = "Walk on Staircase"
    }
	self.SoundVolume = {
		["Walk on Wood"] = .25;
		["Walk on Grass"] = .5;

	}

	return self
end

function SoundManager:RemoveSound(Name)

	for SoundName,Table in pairs(self.AmbientSound) do
		if SoundName == Name then
			Table["Audio"]:Destroy()
			return true
		end
	end

	if Name == self.CurrentSound.Name then
		self.CurrentSound:Destroy()
		return true
	end

	return false
end

function SoundManager:PlaySoundFromService(Name,Object,Value,SoundData)
	local Found = Value or false

	for i,GetAudio in pairs(Sounds:GetDescendants()) do
		local Wanted_Audio = GetAudio:FindFirstChild(Name) or Sounds:FindFirstChild(Name)

		if Wanted_Audio and (Found == false or not Object:FindFirstChild(Name)) then

			Found = true

			local Audio = Wanted_Audio:Clone()
			Audio.Parent = Object
            -- Audio.TimePosition
			if not SoundData["Type"] then
				self.CurrentSound = Audio
			else
				self.CurrentAmbient = Audio
			end

            warn("Sound has been found ", Object.Name)
        

			Audio:Play()
			self.SoundStatus = "Playing"

			Audio.Ended:Connect(function()
				self.SoundStatus = "Ended"
				Audio:Destroy()
			end)

			return Audio
		end

		if Found == true then
			break
		end
	end	

	warn("Couldn't find the sound")
	return nil
end

function SoundManager:Play(Sound,Data)
	local VolumeTo = Data["Volume"] or 1
	local Loop = Data["Loop"] or true
	local TimeToWait = Data["Time"] or .5

	
	local ChangeVolume = {Volume = VolumeTo,Looped = Loop}
	local TweenInformation = TweenInfo.new(TimeToWait)
	
	local Tween = TweenService:Create(Sound,TweenInformation,ChangeVolume)
	Tween:Play()

	
	Tween.Completed:Connect(function()
		warn("sound here the Volume ", Sound.Volume)
		Tween:Destroy()
	end)
end

function SoundManager:StopPlayerSound(Name,Time)
	local Sound = self.CurrentPlayerSound[Name]
	Name = Name or nil
	Time = Time or 2

	if Sound then
		-- SoundManager:Stop(Sound,{["Volume"] = 0,["Time"] = Time})
		self.CurrentPlayerSound[Name] = nil
		return true
	end

	return false
end

function SoundManager:Stop(Sound,Data)
	local VolumeTo = Data["Volume"] or 0
	local TimeToWait = Data["Time"] or .5

	local ChangeVolume = {Volume = VolumeTo}
	local TweenInformation = TweenInfo.new(TimeToWait)

	local Tween = TweenService:Create(Sound,TweenInformation,ChangeVolume)
	Tween:Play()

	--warn("Changing Volume of ", Sound.Name)

	Tween.Completed:Connect(function()
		-- if Data["Destroy"] then
		-- 	Sound:Destroy()
		-- 	-- self.AmbientSound
		-- end
		task.wait(TimeToWait)
		Sound:Destroy()
		Tween:Destroy()
	end)
end

function SoundManager:GetSoundFrom(Object,SoundName)
	local Sound = Object:FindFirstChild(SoundName)

	if Sound then
		return Sound
	else
		warn("Couldn't Find the Sound | ", SoundName, " |")
	end

	return nil
end

function SoundManager:ChangeSoundSpeed(Sound,Speed)
	if Sound then
		warn("Stopping the sound ",Speed)
		Sound.PlaybackSpeed += Speed
		return Sound
	end

	return nil
end

function SoundManager:StartAmbient(Name,Data)

	if Shortcut:Getlength(self.AmbientSounds) <= 0 and not self.AmbientSounds[Name] then
		local Sound = self:GetSoundFromService(Name, Data["Parent"],"Ambient")
		Sound:Play()
		self.AmbientSounds[Name] = Sound
		--Sound.Parent = P
		self:Play(Sound,Data)
		warn("Playing from here ", Sound.Name)
	elseif Shortcut:Getlength(self.AmbientSounds) > 0 and (not self.AmbientSounds[Name] or self.AmbientSounds[Name] == false) then
		for _,Sounds in pairs(self.AmbientSounds) do

			if Sounds then
				self:Stop(Sounds,{["Volume"] = 0})
			end
			
			local Sound = self:GetSoundFromService(Name, Data["Parent"])
			self.AmbientSounds[Name] = Sound
			self:Play(Sound,Data)

		end
	end

end

function SoundManager:GroundSound(player,Material)

    if not self.WalkingSoundIsPlaying and self.MaterialSound[Material] and not player.Character:FindFirstChild(self.MaterialSound[Material]) then
        local Sound = self:GetSoundFromService(self.MaterialSound[Material], player.Character,nil)
        warn("This is the Sound | ", player.Character.Humanoid:GetState())
		Sound:Play()
        self:Play(Sound,{["Volume"] = self.SoundVolume[Sound.Name],["Loop"] = true,["Time"] = 1})
        SoundManager.SoundStatus = "Playing" 
        self.WalkingSoundIsPlaying = true
    elseif self.WalkingSoundIsPlaying  and self.CurrentSound ~= nil and self.CurrentSound.Name ~= self.MaterialSound[Material] then
		--warn("Stopping this sound ", self.CurrentSound.Name)
		self:Stop(self.CurrentSound,{["Volume"] = 0})
		self.WalkingSoundIsPlaying = false
    end

end

function SoundManager:GetSoundFromService(Name,Object,Type)
    local Found = false

	for i,GetAudio in pairs(Sounds:GetDescendants()) do
		local Wanted_Audio = GetAudio:FindFirstChild(Name) or Sounds:FindFirstChild(Name)

		if Wanted_Audio and Found == false then

			Found = true

			local Audio = Wanted_Audio:Clone()
			Audio.Parent = Object

			if not Type then
				self.CurrentSound = Audio
			elseif Type == "player" then
				self.CurrentPlayerSound = Audio
			else
				self.CurrentAmbient = Audio
			end

			
			return Audio
		end

		if Found == true then
			break
		end


	end	

end

function SoundManager:Stringformat(ID)
	return string.format("rbxassetid://%d",ID)
end 

function SoundManager:PlayClient(Player,Name,Object)
	for i,GetAudio in pairs(Sounds:GetDescendants()) do
		local Wanted_Audio = GetAudio.Name == Name and true or false

		if Wanted_Audio then
			local SoundData = {["SoundName"] = Name, ["SoundParent"] = Object, ["Function"] = "Play"}
			UseSound:FireClient(Player,SoundData)
		end
	end
end

return SoundManager
