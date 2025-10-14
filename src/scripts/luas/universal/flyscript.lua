local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local flying = false
local infiniteJump = false
local noclip = false
local speed = 80
local keys = {W=false,A=false,S=false,D=false,Space=false,LShift=false}

local character
local humanoid
local hrp
local lastHealth = 100

local function bindCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	hrp = char:WaitForChild("HumanoidRootPart")
	flying = false
	humanoid.PlatformStand = false
	lastHealth = humanoid.Health
	humanoid.HealthChanged:Connect(function(h)
		if flying and h < lastHealth then
			humanoid.Health = lastHealth
		else
			lastHealth = h
		end
	end)
end

if player.Character then bindCharacter(player.Character) end
player.CharacterAdded:Connect(bindCharacter)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 260)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(35,35,35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.Position = UDim2.new(0,0,0,0)
title.Text = "Fly & Infinite Jump"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(1,-20,0,40)
flyButton.Position = UDim2.new(0,10,0,40)
flyButton.Text = "Enable Fly"
flyButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
flyButton.TextColor3 = Color3.fromRGB(255,255,255)
flyButton.Parent = frame

local jumpButton = Instance.new("TextButton")
jumpButton.Size = UDim2.new(1,-20,0,40)
jumpButton.Position = UDim2.new(0,10,0,85)
jumpButton.Text = "Infinite Jump: Off"
jumpButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
jumpButton.TextColor3 = Color3.fromRGB(255,255,255)
jumpButton.Parent = frame

local noclipButton = Instance.new("TextButton")
noclipButton.Size = UDim2.new(1,-20,0,40)
noclipButton.Position = UDim2.new(0,10,0,130)
noclipButton.Text = "Noclip: Off"
noclipButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
noclipButton.TextColor3 = Color3.fromRGB(255,255,255)
noclipButton.Parent = frame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1,-20,0,20)
speedLabel.Position = UDim2.new(0,10,0,175)
speedLabel.Text = "Speed: "..speed
speedLabel.TextColor3 = Color3.fromRGB(255,255,255)
speedLabel.BackgroundTransparency = 1
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextSize = 16
speedLabel.Parent = frame

local increaseButton = Instance.new("TextButton")
increaseButton.Size = UDim2.new(0.45,-10,0,30)
increaseButton.Position = UDim2.new(0,10,0,200)
increaseButton.Text = "Speed +"
increaseButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
increaseButton.TextColor3 = Color3.fromRGB(255,255,255)
increaseButton.Parent = frame

local decreaseButton = Instance.new("TextButton")
decreaseButton.Size = UDim2.new(0.45,-10,0,30)
decreaseButton.Position = UDim2.new(0.55,0,0,200)
decreaseButton.Text = "Speed -"
decreaseButton.BackgroundColor3 = Color3.fromRGB(0,170,255)
decreaseButton.TextColor3 = Color3.fromRGB(255,255,255)
decreaseButton.Parent = frame

flyButton.MouseButton1Click:Connect(function()
	if not humanoid or not hrp then return end
	flying = not flying
	humanoid.PlatformStand = flying
	flyButton.Text = flying and "Disable Fly" or "Enable Fly"
end)

jumpButton.MouseButton1Click:Connect(function()
	infiniteJump = not infiniteJump
	jumpButton.Text = "Infinite Jump: "..(infiniteJump and "On" or "Off")
end)

noclipButton.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipButton.Text = "Noclip: "..(noclip and "On" or "Off")
end)

increaseButton.MouseButton1Click:Connect(function()
	speed = math.min(speed + 20, 500)
	speedLabel.Text = "Speed: "..speed
end)

decreaseButton.MouseButton1Click:Connect(function()
	speed = math.max(speed - 20, 20)
	speedLabel.Text = "Speed: "..speed
end)

UserInputService.InputBegan:Connect(function(input,processed)
	if processed then return end
	if keys[input.KeyCode.Name] ~= nil then keys[input.KeyCode.Name] = true end
	if input.KeyCode == Enum.KeyCode.Space and infiniteJump and humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if keys[input.KeyCode.Name] ~= nil then keys[input.KeyCode.Name] = false end
end)

RunService.RenderStepped:Connect(function()
	if not character or not hrp then return end

	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") and noclip then
			part.CanCollide = false
		end
	end

	if flying then
		local cam = Workspace.CurrentCamera
		local moveDir = Vector3.new()
		if keys.W then moveDir = moveDir + cam.CFrame.LookVector end
		if keys.S then moveDir = moveDir - cam.CFrame.LookVector end
		if keys.A then moveDir = moveDir - cam.CFrame.RightVector end
		if keys.D then moveDir = moveDir + cam.CFrame.RightVector end
		if keys.Space then moveDir = moveDir + Vector3.new(0,1,0) end
		if keys.LShift then moveDir = moveDir - Vector3.new(0,1,0) end

		if moveDir.Magnitude > 0 then
			moveDir = moveDir.Unit * speed
		else
			moveDir = Vector3.new(0,1,0) * 0.1
		end

		hrp.Velocity = moveDir
		hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
	end
end)
