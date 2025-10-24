local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local module = {}

local highlights = {}

local function isAlive(player)
    local char = player.Character
    if not char or not char:IsDescendantOf(workspace) then return false end
    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function isEnemy(player)
    if player == LocalPlayer then return false end
    if not module.ESP_ALL and module.ENABLE_TEAM_CHECK and player.Team == LocalPlayer.Team then return false end
    return isAlive(player)
end

local function predictPosition(part)
    local vel = part.Velocity or Vector3.new()
    local dist = (part.Position - Camera.CFrame.Position).Magnitude
    local bulletSpeed = 300
    local travelTime = dist / bulletSpeed
    return part.Position + vel * travelTime * (module.PREDICTION_FACTOR or 0)
end

function module:GetClosestTarget()
    if not module.AIM_ASSIST then return nil end
    local closest, dist = nil, module.FIELD_OF_VIEW or 0
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) then
            local part = player.Character:FindFirstChild(module.TARGET_PART) or player.Character:FindFirstChild("Head")
            if part then
                local predictedPos = predictPosition(part)
                local screenPos, onScreen = Camera:WorldToViewportPoint(predictedPos)
                if onScreen then
                    local mag = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mag < dist then
                        dist = mag
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

function module:ApplyAim(target)
    if not module.AIM_ASSIST then return end
    if not target or not target.Character then return end
    local part = target.Character:FindFirstChild(module.TARGET_PART) or target.Character:FindFirstChild("Head")
    if not part then return end
    local predictedPos = predictPosition(part)
    local goal = (predictedPos - Camera.CFrame.Position).Unit
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + (Camera.CFrame.LookVector:Lerp(goal, module.AIM_SMOOTHNESS or 0)).Unit)
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) then
            if not highlights[player] then
                local hl = Instance.new("Highlight")
                hl.Adornee = player.Character
                hl.FillColor = Color3.fromRGB(255,0,0)
                hl.FillTransparency = 0.5
                hl.OutlineColor = Color3.fromRGB(255,0,0)
                hl.OutlineTransparency = 0
                hl.Parent = workspace
                highlights[player] = hl
            end
            highlights[player].Enabled = module.HIGHLIGHT_ENABLED
        elseif highlights[player] then
            highlights[player].Enabled = false
        end
    end
end)

return module
