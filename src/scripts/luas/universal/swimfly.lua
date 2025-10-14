local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local Flying = false
local Speed = 50
local Smoothness = 0.2
local Keys = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.5, -100, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BackgroundTransparency = 0.2
Frame.BorderSizePixel = 2
Frame.Parent = ScreenGui

local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(1, -20, 0, 40)
FlyButton.Position = UDim2.new(0, 10, 0, 10)
FlyButton.Text = "Toggle Air Swim"
FlyButton.TextColor3 = Color3.fromRGB(255,255,255)
FlyButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
FlyButton.Parent = Frame

local SpeedSlider = Instance.new("TextBox")
SpeedSlider.Size = UDim2.new(1, -20, 0, 40)
SpeedSlider.Position = UDim2.new(0, 10, 0, 60)
SpeedSlider.PlaceholderText = "Set Speed (current: 50)"
SpeedSlider.Text = ""
SpeedSlider.TextColor3 = Color3.fromRGB(255,255,255)
SpeedSlider.BackgroundColor3 = Color3.fromRGB(50,50,50)
SpeedSlider.ClearTextOnFocus = false
SpeedSlider.Parent = Frame

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.Keyboard then
		Keys[input.KeyCode] = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		Keys[input.KeyCode] = false
	end
end)

FlyButton.MouseButton1Click:Connect(function()
	Flying = not Flying
	if Flying then
		Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	else
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end)

SpeedSlider.FocusLost:Connect(function(enterPressed)
	local num = tonumber(SpeedSlider.Text)
	if num and num > 0 and num <= 500 then
		Speed = num
		SpeedSlider.PlaceholderText = "Set Speed (current: "..Speed..")"
	else
		SpeedSlider.Text = ""
	end
end)

RunService.RenderStepped:Connect(function(delta)
	if Flying then
		Humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
		local camCFrame = workspace.CurrentCamera.CFrame
		local moveDir = Vector3.new(0,0,0)

		if Keys[Enum.KeyCode.W] then moveDir = moveDir + camCFrame.LookVector end
		if Keys[Enum.KeyCode.S] then moveDir = moveDir - camCFrame.LookVector end
		if Keys[Enum.KeyCode.A] then moveDir = moveDir - camCFrame.RightVector end
		if Keys[Enum.KeyCode.D] then moveDir = moveDir + camCFrame.RightVector end
		if Keys[Enum.KeyCode.Space] then moveDir = moveDir + Vector3.new(0,1,0) end
		if Keys[Enum.KeyCode.LeftControl] then moveDir = moveDir - Vector3.new(0,1,0) end

		moveDir = moveDir + Humanoid.MoveDirection

		if moveDir.Magnitude > 0 then
			moveDir = moveDir.Unit * Speed
			HumanoidRootPart.Velocity = HumanoidRootPart.Velocity:Lerp(moveDir, Smoothness)
		else
			HumanoidRootPart.Velocity = HumanoidRootPart.Velocity:Lerp(Vector3.new(0,0,0), Smoothness)
		end

		Humanoid.PlatformStand = false
	else
		Humanoid.PlatformStand = false
	end
end)
