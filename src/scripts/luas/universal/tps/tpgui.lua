local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local backpack = player:WaitForChild("Backpack")

local function getClosestPlayerByDisplay(partial)
	local bestMatch, shortest = nil, math.huge
	local lowerPartial = partial:lower()
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			local dName = p.DisplayName:lower()
			if dName:sub(1,#lowerPartial) == lowerPartial then
				local diff = #dName - #partial
				if diff < shortest then
					shortest = diff
					bestMatch = p
				end
			end
		end
	end
	return bestMatch
end

local function teleportToCharacter(hrp, targetChar)
	if hrp and targetChar then
		local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
		if targetHrp then
			hrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
		end
	end
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 330)
frame.Position = UDim2.new(0.5, -150, 0.5, -165)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "Teleport System"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame

local playerBox = Instance.new("TextBox")
playerBox.PlaceholderText = "Enter player display name"
playerBox.Size = UDim2.new(1, -20, 0, 40)
playerBox.Position = UDim2.new(0, 10, 0, 50)
playerBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
playerBox.TextColor3 = Color3.fromRGB(255,255,255)
playerBox.Font = Enum.Font.Gotham
playerBox.TextSize = 18
playerBox.ClearTextOnFocus = false
playerBox.Parent = frame

local playerBtn = Instance.new("TextButton")
playerBtn.Text = "Teleport to Player"
playerBtn.Size = UDim2.new(1,-20,0,35)
playerBtn.Position = UDim2.new(0,10,0,95)
playerBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
playerBtn.TextColor3 = Color3.fromRGB(255,255,255)
playerBtn.Font = Enum.Font.GothamBold
playerBtn.TextSize = 18
playerBtn.Parent = frame

-- Did you mean label
local didYouMeanLabel = Instance.new("TextLabel")
didYouMeanLabel.Size = UDim2.new(1, -20, 0, 25)
didYouMeanLabel.Position = UDim2.new(0, 10, 0, 135)
didYouMeanLabel.BackgroundTransparency = 1
didYouMeanLabel.TextColor3 = Color3.fromRGB(200,200,200)
didYouMeanLabel.Font = Enum.Font.Gotham
didYouMeanLabel.TextSize = 16
didYouMeanLabel.Text = ""
didYouMeanLabel.TextXAlignment = Enum.TextXAlignment.Left
didYouMeanLabel.Parent = frame

local teamBox = Instance.new("TextBox")
teamBox.PlaceholderText = "Enter team name"
teamBox.Size = UDim2.new(1,-20,0,40)
teamBox.Position = UDim2.new(0,10,0,160)
teamBox.BackgroundColor3 = Color3.fromRGB(60,60,60)
teamBox.TextColor3 = Color3.fromRGB(255,255,255)
teamBox.Font = Enum.Font.Gotham
teamBox.TextSize = 18
teamBox.ClearTextOnFocus = false
teamBox.Parent = frame

local teamBtn = Instance.new("TextButton")
teamBtn.Text = "Teleport to Team"
teamBtn.Size = UDim2.new(1,-20,0,35)
teamBtn.Position = UDim2.new(0,10,0,205)
teamBtn.BackgroundColor3 = Color3.fromRGB(80,80,80)
teamBtn.TextColor3 = Color3.fromRGB(255,255,255)
teamBtn.Font = Enum.Font.GothamBold
teamBtn.TextSize = 18
teamBtn.Parent = frame

-- Update "Did you mean" text
playerBox:GetPropertyChangedSignal("Text"):Connect(function()
	local partial = playerBox.Text
	if partial == "" then
		didYouMeanLabel.Text = ""
		return
	end
	local match = getClosestPlayerByDisplay(partial)
	if match then
		didYouMeanLabel.Text = "Did you mean: " .. match.DisplayName
	else
		didYouMeanLabel.Text = ""
	end
end)

playerBtn.MouseButton1Click:Connect(function()
	local text = playerBox.Text
	if text == "" then return end
	local match = getClosestPlayerByDisplay(text)
	if match then
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local targetChar = match.Character or match.CharacterAdded:Wait()
		teleportToCharacter(hrp,targetChar)
	end
end)

teamBtn.MouseButton1Click:Connect(function()
	local text = teamBox.Text
	if text == "" then return end
	local team = Teams:FindFirstChild(text)
	if team then
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Team == team and p ~= player then
					local targetChar = p.Character or p.CharacterAdded:Wait()
					teleportToCharacter(hrp,targetChar)
					task.wait(0.25)
				end
			end
		end
	end
end)

-- ===== FIXED CHAT COMMAND =====
player.Chatted:Connect(function(msg)
	local lower = msg:lower()
	if not lower:match("^!tp") then return end
	
	local arg = msg:sub(5):gsub("^%s*(.-)%s*$", "%1")
	if arg == "" then return end

	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local targetPlayer = getClosestPlayerByDisplay(arg)
	if targetPlayer then
		local targetChar = targetPlayer.Character or targetPlayer.CharacterAdded:Wait()
		teleportToCharacter(hrp,targetChar)
		return
	end

	for _, team in ipairs(Teams:GetTeams()) do
		if team.Name:lower() == arg:lower() then
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Team == team and p ~= player then
					local targetChar = p.Character or p.CharacterAdded:Wait()
					teleportToCharacter(hrp,targetChar)
					task.wait(0.25)
				end
			end
			return
		end
	end
end)

local mouse = player:GetMouse()
local tpTool = Instance.new("Tool")
tpTool.Name = "TP Tool"
tpTool.RequiresHandle = false
tpTool.CanBeDropped = false
tpTool.Parent = backpack

tpTool.Activated:Connect(function()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp and mouse.Hit then
		hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0))
	end
end)
