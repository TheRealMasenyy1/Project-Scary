local PlayerHandler = {}
PlayerHandler.__index = PlayerHandler


local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Assets = ReplicatedStorage.Assets;
local Animations = Assets.Animations;
local Events = ReplicatedStorage.Events;
local Player_Events = Events.Player;

function PlayerHandler.new(player)
    local self = setmetatable({},PlayerHandler)

    self.Stamina = 100
    self.WalkSpeed = 6
    self.RunSpeed = 12
    self.IsRunning = false
    self.Inputs = {
        ["LeftShift"] = "Sprint";
        ["LeftControl"] = "LookAround"
    }

    return self
end


game.Players.PlayerAdded:Connect(function(player)
    local self = PlayerHandler.new(player)
    local StaminaLoop
    local isLooping = false

    player.CharacterAdded:Connect(function(character)
        character.Humanoid.WalkSpeed = self.WalkSpeed
    end)

    local getPlayerData = function()
        return self
    end

    local Sprint = function(plr,Action)

        if Action == "Sprint" and not StaminaLoop then
            self.IsRunning = true
            plr.Character.Humanoid.WalkSpeed = self.RunSpeed

            StaminaLoop = coroutine.wrap(function()
                while self.IsRunning do
                    if self.Stamina > 0 then
                        self.Stamina -= 1
                        -- Player_Events.PlayStaminaSound:FireClient(plr,self.Stamina)
                        Player_Events.Stamina:FireClient(plr,self.Stamina,"Decrease")
                    else
                        warn("Server | Stopped Sprinting |")
                        self.IsRunning = false
                        plr.Character.Humanoid.WalkSpeed = self.WalkSpeed
                        Player_Events.ResetCamera:FireClient(plr)
                    end
                    task.wait(.15)
                end
                StaminaLoop = nil
            end)()

        elseif Action == "Stop" then
            self.IsRunning = false
            
            if StaminaLoop then
                StaminaLoop = nil
            end

            StaminaLoop = coroutine.wrap(function()
                while not self.IsRunning and self.Stamina < 100 do
                    self.Stamina += 1
                    Player_Events.Stamina:FireClient(plr,self.Stamina,"Increase")
                    task.wait(.15)
                end
                StaminaLoop = nil
            end)()

            plr.Character.Humanoid.WalkSpeed = self.WalkSpeed
        end
    end

    Player_Events.Sprint.OnServerEvent:Connect(Sprint)
    Player_Events.getPlayerdata.OnServerInvoke = getPlayerData
    
end)

return PlayerHandler