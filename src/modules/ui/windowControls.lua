local WindowControls = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local SETTINGS_FILE = "settings.json"

local function readSettings()
	local data
	pcall(function()
		if isfile and isfile(SETTINGS_FILE) then
			data = HttpService:JSONDecode(readfile(SETTINGS_FILE))
		end
	end)
	return data or { darkmode = true }
end

function WindowControls.create(topBar, window, gui)
	local settings = readSettings()
	local dark = settings.darkmode

	local colors = dark and {
		bg = Color3.fromRGB(35, 35, 35),
		hover = Color3.fromRGB(70, 70, 90),
		icon = Color3.fromRGB(255, 255, 255),
		hoverIcon = Color3.fromRGB(180, 200, 255)
	} or {
		bg = Color3.fromRGB(230, 230, 230),
		hover = Color3.fromRGB(210, 210, 255),
		icon = Color3.fromRGB(30, 30, 30),
		hoverIcon = Color3.fromRGB(70, 100, 255)
	}

	local function styleButton(btn)
		btn.BackgroundColor3 = colors.bg
		btn.BackgroundTransparency = 0.3
		btn.ImageColor3 = colors.icon
		btn.AutoButtonColor = false
		btn.BorderSizePixel = 0
		btn.ZIndex = 2
		local corner = Instance.new("UICorner", btn)
		corner.CornerRadius = UDim.new(0, 6)
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.1,
				ImageColor3 = colors.hoverIcon,
				BackgroundColor3 = colors.hover
			}):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.3,
				ImageColor3 = colors.icon,
				BackgroundColor3 = colors.bg
			}):Play()
		end)
	end

	local settingsButton = Instance.new("ImageButton")
	settingsButton.Size = UDim2.new(0, 30, 0, 30)
	settingsButton.Position = UDim2.new(0, 8, 0, 2)
	settingsButton.Image = "rbxassetid://102254373423014"
	settingsButton.ImageRectOffset = Vector2.new(964, 324)
	settingsButton.ImageRectSize = Vector2.new(36, 36)
	styleButton(settingsButton)
	settingsButton.Parent = topBar

	local closeButton = Instance.new("ImageButton")
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -35, 0, 2)
	closeButton.Image = "rbxassetid://116533143721125"
	styleButton(closeButton)
	closeButton.Parent = topBar

	local minimizeButton = Instance.new("ImageButton")
	minimizeButton.Size = UDim2.new(0, 30, 0, 30)
	minimizeButton.Position = UDim2.new(1, -70, 0, 2)
	minimizeButton.Image = "rbxassetid://10137941941"
	styleButton(minimizeButton)
	minimizeButton.Parent = topBar

	local maximizeButton = Instance.new("ImageButton")
	maximizeButton.Size = UDim2.new(0, 30, 0, 30)
	maximizeButton.Position = UDim2.new(1, -105, 0, 2)
	maximizeButton.Image = "rbxassetid://11036884234"
	styleButton(maximizeButton)
	maximizeButton.Parent = topBar

	local isMinimized, isMaximized = false, false
	local originalSize = window.Size
	local originalPos = window.Position

	local contentFrame = Instance.new("Frame")
	contentFrame.Name = "ContentFrame"
	contentFrame.Size = UDim2.new(1, 0, 1, -35)
	contentFrame.Position = UDim2.new(0, 0, 0, 35)
	contentFrame.BackgroundTransparency = 1
	contentFrame.ClipsDescendants = true
	contentFrame.Parent = window

	local function updateContentFrame()
		local topBarHeight = topBar.AbsoluteSize.Y
		contentFrame.Size = UDim2.new(1, 0, 1, -topBarHeight)
		contentFrame.Position = UDim2.new(0, 0, 0, topBarHeight)
	end

	window:GetPropertyChangedSignal("Size"):Connect(updateContentFrame)
	window:GetPropertyChangedSignal("Position"):Connect(updateContentFrame)

	local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	settingsButton.MouseButton1Click:Connect(function()
		local ok, Setting = pcall(function()
			return import("./setting")
		end)
		if ok and Setting and Setting.open then
			Setting.open(gui)
		end
	end)

	minimizeButton.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		local goal = isMinimized and UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 35) or originalSize
		TweenService:Create(window, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = goal }):Play()
	end)

	maximizeButton.MouseButton1Click:Connect(function()
		isMaximized = not isMaximized
		local goal = isMaximized and { Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10) } or { Size = originalSize, Position = originalPos }
		TweenService:Create(window, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), goal):Play()
	end)

	closeButton.MouseButton1Click:Connect(function()
		local flash = Instance.new("Frame")
		flash.Size = UDim2.new(1, 0, 1, 0)
		flash.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
		flash.BackgroundTransparency = 0.7
		flash.BorderSizePixel = 0
		flash.ZIndex = 3
		flash.Parent = window
		TweenService:Create(flash, TweenInfo.new(0.15), { BackgroundTransparency = 1 }):Play()
		local tween = TweenService:Create(window, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Position = window.Position + UDim2.new(0, 0, 0, 40),
			Size = UDim2.new(0, 0, 0, 0)
		})
		tween:Play()
		tween.Completed:Connect(function()
			gui:Destroy()
		end)
	end)

	local dragging, dragInput, mousePos, framePos
	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = window.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	topBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			window.Position = UDim2.new(
				framePos.X.Scale,
				framePos.X.Offset + delta.X,
				framePos.Y.Scale,
				framePos.Y.Offset + delta.Y
			)
		end
	end)

	updateContentFrame()

	return contentFrame
end

return WindowControls
