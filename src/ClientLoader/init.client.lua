local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Game = ReplicatedStorage.Game
local Client = Game.Client

local Storage = {}

for _,Modules in pairs(Client:GetDescendants()) do
    if Modules:IsA("ModuleScript") and not Storage[Modules] then

        local succ = pcall(function()
            Storage[Modules.Name] = require(Modules)
        end)

        if succ then
            warn("| "..Modules.Name .. " | Has been loaded")
        else
            warn("| "..Modules.Name .. " | Didn't get loaded")
        end

    end
end