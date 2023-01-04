local UIController = {}

local player = game.Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local playerGui = player:WaitForChild("PlayerGui")

local GameUI = playerGui:WaitForChild("GameUI")

local Events = ReplicatedStorage.Events
local player_Events = Events.Player

local Stamina = GameUI:WaitForChild("Stamina")
local Staminabar = Stamina:WaitForChild("Staminabar")


function Stamina(Stamina,ToDo) -- For the stamina UI
    local AddStamina = (1-Stamina/100)
    local TweenProp = {
        Size = UDim2.new(1,0,Stamina/100,0)
    }
    local TweenInformation = TweenInfo.new(.2)
    local Tween = TweenService:Create(Staminabar,TweenInformation,TweenProp)
    Tween:Play()

    Tween.Completed:Connect(function()
        Tween:Destroy()
    end)    

    if ToDo == "Decrease" then -- Decrease the stamina
        -- Staminabar.Changed:Connect(function()
            warn("How much we're adding ",AddStamina)
            player_Events.Sounds.PlayStaminaSound:Invoke(AddStamina)
        -- end)
    elseif ToDo == "Increase" then -- Increase the stamina
        -- Staminabar.Changed:Connect(function()
            -- if Staminabar.Size.Y.Scale
            player_Events.Sounds.StopStaminaSound:Invoke(AddStamina)

        -- end)
    end

end

player_Events.Stamina.OnClientEvent:Connect(Stamina)


return UIController