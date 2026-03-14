local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ammoText = playerGui:WaitForChild("gui"):WaitForChild("AmmoFrame"):WaitForChild("AmmoText")

local function checkAndFire()
    if ammoText.Text == "0" then
        local character = player.Character
        if character then
            local tool = character:FindFirstChildOfClass("Tool")
            
            if tool then
                -- dihh remote
                local rl = tool:FindFirstChild("rl")
                if rl and rl:IsA("RemoteEvent") then
                    rl:FireServer()
                end
            end
        end
    end
end

ammoText:GetPropertyChangedSignal("Text"):Connect(checkAndFire)

player.CharacterAppearanceLoaded:Connect(function(char)
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            checkAndFire()
        end
    end)
end)
