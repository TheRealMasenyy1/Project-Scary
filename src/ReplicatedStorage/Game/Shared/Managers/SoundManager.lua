local Players = game.Players
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage.Events

local UseSound = Events.Player.UseSound
local Assets = ReplicatedStorage.Assets
local Sounds = Assets.Sounds


local SoundManager = {}
SoundManager.__index = SoundManager

--[[

--! CLASS REVAMP NO YET DONE

--]]


function SoundManager.Setup(player)
	local self = setmetatable({},SoundManager)

	self.CurrentSound = nil;
	self.SoundStatus = nil;
    self.PlayWalkingSound = true;
    self.WalkingSoundIsPlaying = false;
    self.raycastParams = RaycastParams.new()
    self.raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
    self.raycastParams.FilterDescendantsInstances = {workspace.Map}
    self.raycastParams.IgnoreWater = true
    
    self.MaterialSound = {
        ["Wood"] = "Walk on Wood";
    }

	return self
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
			self.CurrentSound = Audio
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
end

function SoundManager:GroundSound(player,Material)

    if not self.WalkingSoundIsPlaying and self.MaterialSound[Material] and not player.Character:FindFirstChild(self.MaterialSound[Material]) then
        local Sound = SoundManager:GetSoundFromService(self.MaterialSound[Material], player.Character)
        warn("This is the Sound | ", player.Character.Humanoid:GetState())
        Sound.Looped = true
        Sound:Play()
        SoundManager.SoundStatus = "Playing" 
        self.WalkingSoundIsPlaying = true
    elseif self.WalkingSoundIsPlaying  and self.CurrentSound ~= nil and self.CurrentSound.Name ~= self.MaterialSound[Material] then
        self.CurrentSound:Destroy()
        self.WalkingSoundIsPlaying = false
    end

end

function SoundManager:GetSoundFromService(Name,Object)
    local Found = false

	for i,GetAudio in pairs(Sounds:GetDescendants()) do
		local Wanted_Audio = GetAudio:FindFirstChild(Name)

		if Wanted_Audio and Found == false then

			Found = true

			local Audio = Wanted_Audio:Clone()
			Audio.Parent = Object
			self.CurrentSound = Audio

			
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
