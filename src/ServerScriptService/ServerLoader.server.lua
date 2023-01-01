local ServerScriptService = game:GetService("ServerScriptService")
local Server = ServerScriptService.Server
-- local Gameplay = Server.Gameplay

local Storage = {}

for _,Modules in pairs(Server:GetDescendants()) do
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