local PlayerHandler = {}
PlayerHandler.__index = PlayerHandler

function PlayerHandler.new(player)
    local self = setmetatable({},PlayerHandler)

    

    return self
end


game.Players.PlayerAdded:Connect(function(player)
    local playerdata = PlayerHandler.new(player)


    player.CharacterAdded:Connect(function(character)
        character.Humanoid.WalkSpeed = 8
    end)
end)

return PlayerHandler