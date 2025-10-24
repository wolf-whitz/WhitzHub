local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

local module = {}
module.AUTO_SHOOT = true
module.TRIGGER_WHILE_AIMING = true
module.SHOOT_INTERVAL = 0.03

local mouse = LocalPlayer:GetMouse()
local userShooting = false
local currentTarget = nil
local lastShot = 0

mouse.Button1Down:Connect(function()
    userShooting = true
end)

mouse.Button1Up:Connect(function()
    userShooting = false
end)

function module:UpdateTarget(target)
    currentTarget = target
end

RunService.RenderStepped:Connect(function(delta)
    if not module.AUTO_SHOOT then return end
    if module.TRIGGER_WHILE_AIMING and not userShooting then return end
    if not currentTarget or not currentTarget.Character then return end

    local humanoid = currentTarget.Character:FindFirstChildWhichIsA("Humanoid")
    if humanoid and humanoid.Health > 0 then
        lastShot = lastShot + delta
        if lastShot >= module.SHOOT_INTERVAL then
            mouse1press()
            task.wait(0.01)
            mouse1release()
            lastShot = 0
        end
    end
end)

return module
