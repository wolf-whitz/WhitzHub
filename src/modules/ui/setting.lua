local Setting = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local SETTINGS_FILE = "settings.json"

local function readSettings()
	local data
	pcall(function()
		if isfile and isfile(SETTINGS_FILE) then
			data = HttpService:JSONDecode(readfile(SETTINGS_FILE))
		end
	end)
	return data or {
		animations = true,
		darkmode = true,
		tooltips = true
	}
end

local function saveSettings(data)
	pcall(function()
		if writefile then
			writefile(SETTINGS_FILE, HttpService:JSONEncode(data))
		end
	end)
end

function Setting.open(gui)
	if gui:FindFirstChild("SettingWindow") then return end
	local settings = readSettings()

	local blur = Instance.new("Frame")
	blur.Size = UDim2.new(1, 0, 1, 0)
	blur.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	blur.BackgroundTransparency = 1
	blur.ZIndex = 8
	blur.Parent = gui

	local window = Instance.new("Frame")
	window.Name = "SettingWindow"
	window.Size = UDim2.new(0, 420, 0, 320)
	window.Position = UDim2.new(0.5, 0, 0.5, 0)
	window.AnchorPoint = Vector2.new(0.5, 0.5)
	window.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	window.BackgroundTransparency = 0.2
	window.ZIndex = 9
	window.ClipsDescendants = true
	window.Parent = gui

	local corner = Instance.new("UICorner", window)
	corner.CornerRadius = UDim.new(0, 10)
	local stroke = Instance.new("UIStroke", window)
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 1.5
	stroke.Transparency = 0

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -40, 0, 40)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "Settings"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.TextColor3 = Color3.fromRGB(240, 240, 240)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 10
	title.Parent = window

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0, 26, 0, 26)
	close.Position = UDim2.new(1, -32, 0, 8)
	close.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	close.BackgroundTransparency = 0.4
	close.Text = "✕"
	close.Font = Enum.Font.GothamBold
	close.TextSize = 16
	close.TextColor3 = Color3.fromRGB(240, 240, 240)
	close.ZIndex = 10
	close.Parent = window
	local closeCorner = Instance.new("UICorner", close)
	closeCorner.CornerRadius = UDim.new(0, 6)

	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, -40, 1, -60)
	body.Position = UDim2.new(0, 20, 0, 50)
	body.BackgroundTransparency = 1
	body.ZIndex = 9
	body.Parent = window

	local layout = Instance.new("UIListLayout", body)
	layout.Padding = UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder

	local function createToggle(text, key)
		local toggle = Instance.new("TextButton")
		toggle.Size = UDim2.new(1, 0, 0, 36)
		toggle.BackgroundColor3 = settings[key] and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(40, 40, 40)
		toggle.TextColor3 = Color3.fromRGB(240, 240, 240)
		toggle.Text = text .. ": " .. (settings[key] and "ON" or "OFF")
		toggle.Font = Enum.Font.Gotham
		toggle.TextSize = 16
		toggle.AutoButtonColor = false
		toggle.ZIndex = 9
		toggle.Parent = body
		local corner = Instance.new("UICorner", toggle)
		corner.CornerRadius = UDim.new(0, 8)
		local stroke = Instance.new("UIStroke", toggle)
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Transparency = 0
		toggle.MouseEnter:Connect(function()
			TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = settings[key] and Color3.fromRGB(100, 140, 255) or Color3.fromRGB(60, 60, 60)}):Play()
		end)
		toggle.MouseLeave:Connect(function()
			TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = settings[key] and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(40, 40, 40)}):Play()
		end)
		toggle.MouseButton1Click:Connect(function()
			settings[key] = not settings[key]
			saveSettings(settings)
			toggle.Text = text .. ": " .. (settings[key] and "ON" or "OFF")
			TweenService:Create(toggle, TweenInfo.new(0.25), {BackgroundColor3 = settings[key] and Color3.fromRGB(80, 120, 255) or Color3.fromRGB(40, 40, 40)}):Play()
		end)
	end

	createToggle("Enable animations", "animations")
	createToggle("Dark mode", "darkmode")
	createToggle("Show tooltips", "tooltips")

	local reset = Instance.new("TextButton")
	reset.Size = UDim2.new(1, 0, 0, 36)
	reset.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
	reset.TextColor3 = Color3.fromRGB(240, 240, 240)
	reset.Text = "Reset settings"
	reset.Font = Enum.Font.GothamBold
	reset.TextSize = 16
	reset.AutoButtonColor = false
	reset.ZIndex = 9
	reset.Parent = body
	local resetCorner = Instance.new("UICorner", reset)
	resetCorner.CornerRadius = UDim.new(0, 8)
	local resetStroke = Instance.new("UIStroke", reset)
	resetStroke.Color = Color3.fromRGB(255, 255, 255)
	resetStroke.Transparency = 0
	reset.MouseButton1Click:Connect(function()
		settings = {animations = true, darkmode = true, tooltips = true}
		saveSettings(settings)
		window:Destroy()
		blur:Destroy()
		Setting.open(gui)
	end)

	window.BackgroundTransparency = 1
	window.Size = UDim2.new(0, 0, 0, 0)
	TweenService:Create(blur, TweenInfo.new(0.25), {BackgroundTransparency = 0.5}):Play()
	TweenService:Create(window, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0.2,
		Size = UDim2.new(0, 420, 0, 320)
	}):Play()

	close.MouseButton1Click:Connect(function()
		TweenService:Create(blur, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
		local tween = TweenService:Create(
			window,
			TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In),
			{Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}
		)
		tween:Play()
		tween.Completed:Connect(function()
			window:Destroy()
			blur:Destroy()
		end)
	end)

	local dragging, dragInput, mousePos, framePos
	title.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = window.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	title.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			window.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
		end
	end)
end

return Setting
