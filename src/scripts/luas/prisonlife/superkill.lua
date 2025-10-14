local player = game.Players.LocalPlayer
local mainRemotes = game.ReplicatedStorage:FindFirstChild("meleeEvent") or Instance.new("RemoteEvent", game.ReplicatedStorage)
mainRemotes.Name = "meleeEvent"

local punchingTarget = nil
local punchingActive = false
local highlightBox = nil

local function punchTarget(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    for i = 1, 8 do
        mainRemotes:FireServer(target)
    end
end

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0.5, -125, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local textBox = Instance.new("TextBox")
textBox.Size = UDim2.new(1,-10,0,30)
textBox.Position = UDim2.new(0,5,0,5)
textBox.ClearTextOnFocus = false
textBox.PlaceholderText = "Type player display name..."
textBox.Parent = frame

local listFrame = Instance.new("ScrollingFrame")
listFrame.Size = UDim2.new(1,-10,0,200)
listFrame.Position = UDim2.new(0,5,0,35)
listFrame.CanvasSize = UDim2.new(0,0,0,0)
listFrame.ScrollBarThickness = 6
listFrame.BackgroundTransparency = 1
listFrame.Parent = frame

local submitButton = Instance.new("TextButton")
submitButton.Size = UDim2.new(1,-10,0,30)
submitButton.Position = UDim2.new(0,5,0,245)
submitButton.Text = "Submit"
submitButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
submitButton.TextColor3 = Color3.new(1,1,1)
submitButton.Parent = frame

local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(1,-10,0,30)
stopButton.Position = UDim2.new(0,5,0,275)
stopButton.Text = "Stop"
stopButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
stopButton.TextColor3 = Color3.new(1,1,1)
stopButton.Parent = frame

local selectedPlayer = nil

-- update player list
local function updatePlayerList()
    for _, child in pairs(listFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local input = textBox.Text:lower()
    local yOffset = 0
    for _, plr in pairs(game.Players:GetPlayers()) do
        if plr.DisplayName:lower():find(input) then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1,0,0,25)
            btn.Position = UDim2.new(0,0,0,yOffset)
            btn.Text = plr.DisplayName
            btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Parent = listFrame

            btn.MouseButton1Click:Connect(function()
                selectedPlayer = plr
                -- highlight selection
                for _, b in pairs(listFrame:GetChildren()) do
                    if b:IsA("TextButton") then
                        b.BackgroundColor3 = Color3.fromRGB(70,70,70)
                    end
                end
                btn.BackgroundColor3 = Color3.fromRGB(0,150,0)
            end)

            yOffset = yOffset + 25
        end
    end
    listFrame.CanvasSize = UDim2.new(0,0,0,yOffset)
end

textBox:GetPropertyChangedSignal("Text"):Connect(updatePlayerList)
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)
updatePlayerList()

submitButton.MouseButton1Click:Connect(function()
    if selectedPlayer then
        punchingTarget = selectedPlayer
        punchingActive = true

        -- add highlight box
        if highlightBox then highlightBox:Destroy() end
        highlightBox = Instance.new("SelectionBox")
        highlightBox.Adornee = punchingTarget.Character
        highlightBox.LineThickness = 0.05
        highlightBox.Color3 = Color3.fromRGB(0,255,0)
        highlightBox.SurfaceTransparency = 0.8
        highlightBox.Parent = punchingTarget.Character

        spawn(function()
            while punchingActive do
                if not punchingTarget or not punchingTarget.Character or punchingTarget.Character.Humanoid.Health <= 0 then
                    punchingActive = false
                    if highlightBox then highlightBox:Destroy() highlightBox = nil end
                    break
                end
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and punchingTarget.Character:FindFirstChild("HumanoidRootPart") then
                    player.Character.HumanoidRootPart.CFrame = punchingTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3)
                    for i = 1, 10 do -- faster punching
                        mainRemotes:FireServer(punchingTarget)
                    end
                end
                wait(0.05)
            end
        end)
    end
end)

stopButton.MouseButton1Click:Connect(function()
    punchingActive = false
    punchingTarget = nil
    if highlightBox then highlightBox:Destroy() highlightBox = nil end
end)
