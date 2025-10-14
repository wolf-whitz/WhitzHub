local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local UI = Instance.new("ScreenGui")
UI.Name = "BangGUI"
UI.ResetOnSpawn = false
UI.Parent = game:GetService("CoreGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 220)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = UI

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 8)

local inputBox = Instance.new("TextBox")
inputBox.Size = UDim2.new(1, -20, 0, 30)
inputBox.Position = UDim2.new(0, 10, 0, 10)
inputBox.PlaceholderText = "Enter Display Name..."
inputBox.TextColor3 = Color3.fromRGB(240,240,240)
inputBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
inputBox.ClearTextOnFocus = false
inputBox.Font = Enum.Font.Gotham
inputBox.TextSize = 14
inputBox.Parent = mainFrame

local cornerInput = Instance.new("UICorner", inputBox)
cornerInput.CornerRadius = UDim.new(0,6)

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 50)
speedBox.PlaceholderText = "Animation Speed (default 3)"
speedBox.TextColor3 = Color3.fromRGB(240,240,240)
speedBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
speedBox.ClearTextOnFocus = false
speedBox.Font = Enum.Font.Gotham
speedBox.TextSize = 14
speedBox.Parent = mainFrame

local cornerSpeed = Instance.new("UICorner", speedBox)
cornerSpeed.CornerRadius = UDim.new(0,6)

local suggestionFrame = Instance.new("Frame")
suggestionFrame.Size = UDim2.new(1, -20, 0, 60)
suggestionFrame.Position = UDim2.new(0, 10, 0, 90)
suggestionFrame.BackgroundTransparency = 1
suggestionFrame.Parent = mainFrame

local layout = Instance.new("UIListLayout", suggestionFrame)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,2)

local function updateSuggestions()
    suggestionFrame:ClearAllChildren()
    local text = inputBox.Text:lower()
    if text == "" then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player.DisplayName:lower():sub(1, #text) == text then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,25)
            btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
            btn.TextColor3 = Color3.fromRGB(240,240,240)
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 14
            btn.Text = player.DisplayName
            btn.Parent = suggestionFrame

            local cornerBtn = Instance.new("UICorner", btn)
            cornerBtn.CornerRadius = UDim.new(0,4)

            btn.MouseButton1Click:Connect(function()
                inputBox.Text = player.DisplayName
                suggestionFrame:ClearAllChildren()
            end)
        end
    end
end

inputBox:GetPropertyChangedSignal("Text"):Connect(updateSuggestions)

local bangBtn = Instance.new("TextButton")
bangBtn.Size = UDim2.new(0, 100, 0, 30)
bangBtn.Position = UDim2.new(0.25, -50, 1, -50)
bangBtn.BackgroundColor3 = Color3.fromRGB(100,100,255)
bangBtn.TextColor3 = Color3.new(1,1,1)
bangBtn.Text = "Bang!"
bangBtn.Font = Enum.Font.Gotham
bangBtn.TextSize = 14
bangBtn.Parent = mainFrame

local cornerBtn = Instance.new("UICorner", bangBtn)
cornerBtn.CornerRadius = UDim.new(0,6)

local unbangBtn = Instance.new("TextButton")
unbangBtn.Size = UDim2.new(0, 100, 0, 30)
unbangBtn.Position = UDim2.new(0.75, -50, 1, -50)
unbangBtn.BackgroundColor3 = Color3.fromRGB(255,100,100)
unbangBtn.TextColor3 = Color3.new(1,1,1)
unbangBtn.Text = "Unbang"
unbangBtn.Font = Enum.Font.Gotham
unbangBtn.TextSize = 14
unbangBtn.Parent = mainFrame

local cornerUnbang = Instance.new("UICorner", unbangBtn)
cornerUnbang.CornerRadius = UDim.new(0,6)

local function getPlayerByDisplayName(name)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.DisplayName:lower() == name:lower() then
            return player
        end
    end
end

local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

local function r15(player)
    return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.RigType == Enum.HumanoidRigType.R15
end

local function getTorso(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

local bangAnim, bang, bangDied, bangLoop

bangBtn.MouseButton1Click:Connect(function()
    local targetName = inputBox.Text
    local speed = tonumber(speedBox.Text) or 3
    local targetPlayer = getPlayerByDisplayName(targetName)
    if not targetPlayer then
        warn("Player not found!")
        return
    end
    local speaker = LocalPlayer
    local humanoid = speaker.Character and speaker.Character:FindFirstChildWhichIsA("Humanoid")
    if not humanoid then return end

    if bangDied then
        bangDied:Disconnect()
        bang:Stop()
        bangAnim:Destroy()
        if bangLoop then bangLoop:Disconnect() end
    end

    bangAnim = Instance.new("Animation")
    bangAnim.AnimationId = not r15(speaker) and "rbxassetid://148840371" or "rbxassetid://5918726674"
    bang = humanoid:LoadAnimation(bangAnim)
    bang:Play(0.1,1,1)
    bang:AdjustSpeed(speed)

    bangDied = humanoid.Died:Connect(function()
        bang:Stop()
        bangAnim:Destroy()
        bangDied:Disconnect()
        if bangLoop then bangLoop:Disconnect() end
    end)

    local offset = CFrame.new(0,0,1.1)
    bangLoop = RunService.Stepped:Connect(function()
        pcall(function()
            local otherRoot = getTorso(targetPlayer.Character)
            getRoot(speaker.Character).CFrame = otherRoot.CFrame * offset
        end)
    end)
end)

unbangBtn.MouseButton1Click:Connect(function()
    if bangDied then
        bangDied:Disconnect()
        bang:Stop()
        bangAnim:Destroy()
        if bangLoop then bangLoop:Disconnect() end
    end
end)
