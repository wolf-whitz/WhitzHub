local CustomNotification = {}
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

function CustomNotification.show(title, text, callback, dark)
	local player = Players.LocalPlayer
	local gui = player:WaitForChild("PlayerGui")

	local TextColor = dark and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(30, 30, 30)
	local NotifColor = dark and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(230, 230, 230)
	local ButtonColor = dark and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(200, 200, 200)
	local ButtonHover = dark and Color3.fromRGB(90, 90, 120) or Color3.fromRGB(150, 180, 255)

	local notif = Instance.new("Frame")
	notif.Size = UDim2.new(0, 300, 0, 120)
	notif.AnchorPoint = Vector2.new(0.5, 0.5)
	notif.Position = UDim2.new(0.5, 0, 0.5, 0)
	notif.BackgroundColor3 = NotifColor
	notif.BorderSizePixel = 0
	notif.ZIndex = 100
	notif.ClipsDescendants = true
	notif.Parent = gui

	local corner = Instance.new("UICorner", notif)
	corner.CornerRadius = UDim.new(0, 10)

	local titleLabel = Instance.new("TextLabel", notif)
	titleLabel.Size = UDim2.new(1, -20, 0, 30)
	titleLabel.Position = UDim2.new(0, 10, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = TextColor
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 16
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left

	local textLabel = Instance.new("TextLabel", notif)
	textLabel.Size = UDim2.new(1, -20, 0, 40)
	textLabel.Position = UDim2.new(0, 10, 0, 40)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = text
	textLabel.TextColor3 = TextColor
	textLabel.Font = Enum.Font.Gotham
	textLabel.TextSize = 14
	textLabel.TextWrapped = true
	textLabel.TextXAlignment = Enum.TextXAlignment.Left
	textLabel.TextYAlignment = Enum.TextYAlignment.Top

	local yesBtn = Instance.new("TextButton", notif)
	yesBtn.Size = UDim2.new(0, 100, 0, 30)
	yesBtn.Position = UDim2.new(0, 20, 1, -40)
	yesBtn.BackgroundColor3 = ButtonColor
	yesBtn.TextColor3 = TextColor
	yesBtn.Text = "Yes"
	yesBtn.Font = Enum.Font.Gotham
	yesBtn.TextSize = 14
	local yesCorner = Instance.new("UICorner", yesBtn)
	yesCorner.CornerRadius = UDim.new(0, 6)

	local noBtn = Instance.new("TextButton", notif)
	noBtn.Size = UDim2.new(0, 100, 0, 30)
	noBtn.Position = UDim2.new(1, -120, 1, -40)
	noBtn.BackgroundColor3 = ButtonColor
	noBtn.TextColor3 = TextColor
	noBtn.Text = "No"
	noBtn.Font = Enum.Font.Gotham
	noBtn.TextSize = 14
	local noCorner = Instance.new("UICorner", noBtn)
	noCorner.CornerRadius = UDim.new(0, 6)

	local function animateButton(button, color)
		TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
	end

	yesBtn.MouseEnter:Connect(function() animateButton(yesBtn, ButtonHover) end)
	yesBtn.MouseLeave:Connect(function() animateButton(yesBtn, ButtonColor) end)
	noBtn.MouseEnter:Connect(function() animateButton(noBtn, ButtonHover) end)
	noBtn.MouseLeave:Connect(function() animateButton(noBtn, ButtonColor) end)

	yesBtn.MouseButton1Click:Connect(function()
		notif:Destroy()
		if callback then callback(true) end
	end)
	noBtn.MouseButton1Click:Connect(function()
		notif:Destroy()
		if callback then callback(false) end
	end)
end

return CustomNotification
