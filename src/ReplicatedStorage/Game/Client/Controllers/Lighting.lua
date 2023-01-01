local Lighting = {}
local GameLighting = game:GetService("Lighting")
-- Lighting.__index = Lighting

-- function Lighting.Setup()
--     local self = setmetatable({}, Lighting)



--     return self
-- end

function Lighting:HauntedMode()
    local Prop = {
        ["Brightness"] = 0;
        ["OutdoorAmbient"] = Color3.fromRGB(25, 27, 24); -- Color3.fromRGB(0, 0, 0);
        ["ClockTime"] = 0; -- 00:00:00
        ["EnvironmentDiffuseScale"] = 0; -- Indoor  ["EnvironmentDiffuseScale"] = 0.337;
        ["EnvironmentSpecularScale"] = 0;
    }    

    -- for Name,Value in pairs(Prop) do
    --     GameLighting[Name] = Value
    -- end
end

Lighting:HauntedMode()

return Lighting