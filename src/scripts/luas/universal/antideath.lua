local Players = game:GetService("Players")
local player = Players.LocalPlayer
local lastDeathPos
local teleported = false

local function onCharacter(char)
    teleported = false
    local humanoid = char:WaitForChild("Humanoid", 5)

    if humanoid then
        humanoid.Died:Connect(function()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                lastDeathPos = hrp.Position
            end
        end)
    end

    if lastDeathPos and not teleported then
        task.spawn(function()
            task.wait(0.25)
            local hrp = char:WaitForChild("HumanoidRootPart", 5)
            local hum = char:WaitForChild("Humanoid", 5)
            if hrp and hum and hum.Health > 0 then
                hrp.CFrame = CFrame.new(lastDeathPos + Vector3.new(0, 5, 0))
                hrp.Velocity = Vector3.new(0, 0, 0)
                teleported = true
                lastDeathPos = nil
            end
        end)
    end
end

if player.Character then onCharacter(player.Character) end
player.CharacterAdded:Connect(onCharacter)
