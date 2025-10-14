local player = game.Players.LocalPlayer
local mainRemotes = game.ReplicatedStorage:FindFirstChild("meleeEvent") or Instance.new("RemoteEvent", game.ReplicatedStorage)
mainRemotes.Name = "meleeEvent"

local punchingActive = false
local auraRadius = 20 -- studs
local cooldown = false

-- Create Range Indicator
local rangePart = Instance.new("Part")
rangePart.Shape = Enum.PartType.Ball
rangePart.Size = Vector3.new(auraRadius*2, auraRadius*2, auraRadius*2)
rangePart.Transparency = 0.6
rangePart.Anchored = true
rangePart.CanCollide = false
rangePart.Color = Color3.fromRGB(0, 200, 255)
rangePart.Material = Enum.Material.Neon
rangePart.Parent = workspace

local function updateRangePosition()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        rangePart.CFrame = player.Character.HumanoidRootPart.CFrame
    end
end

-- Punch Function
local function punchTarget(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    for i = 1, 8 do
        mainRemotes:FireServer(target)
    end
end

-- Kill Aura Loop
local function startKillAura()
    punchingActive = true
    spawn(function()
        while punchingActive do
            updateRangePosition()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local myPos = player.Character.HumanoidRootPart.Position
                local closest = nil
                local closestDist = auraRadius + 1
                for _, plr in pairs(game.Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Humanoid").Health > 0 then
                        local distance = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
                        if distance <= auraRadius and distance < closestDist then
                            closest = plr
                            closestDist = distance
                        end
                    end
                end
                if closest then
                    punchTarget(closest)
                end
            end
            wait(0.05)
        end
    end)
end

local function stopKillAura()
    punchingActive = false
end

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,200,0,120)
frame.Position = UDim2.new(0.5,-100,0.5,-60)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(1,-10,0,40)
startButton.Position = UDim2.new(0,5,0,5)
startButton.Text = "Start Kill Aura"
startButton.BackgroundColor3 = Color3.fromRGB(50,200,50)
startButton.TextColor3 = Color3.new(1,1,1)
startButton.Parent = frame
startButton.MouseButton1Click:Connect(startKillAura)

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(1,-10,0,40)
stopButton.Position = UDim2.new(0,5,0,55)
stopButton.Text = "Stop Kill Aura"
stopButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
stopButton.TextColor3 = Color3.new(1,1,1)
stopButton.Parent = frame
stopButton.MouseButton1Click:Connect(stopKillAura)
