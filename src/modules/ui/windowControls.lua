local WindowControls = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

function WindowControls.create(topBar, window, gui)
	local colors = {
		bg = Color3.fromRGB(35, 35, 35),
		hover = Color3.fromRGB(70, 70, 90),
		icon = Color3.fromRGB(255, 255, 255),
		hoverIcon = Color3.fromRGB(180, 200, 255)
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

		local originalSize = btn.Size
		local hoverSize = originalSize + UDim2.new(0,4,0,4)

		local hoverTween, leaveTween
		btn.MouseEnter:Connect(function()
			if leaveTween then leaveTween:Cancel() end
			hoverTween = TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				BackgroundTransparency = 0.1,
				ImageColor3 = colors.hoverIcon,
				Size = hoverSize
			})
			hoverTween:Play()
		end)
		btn.MouseLeave:Connect(function()
			if hoverTween then hoverTween:Cancel() end
			leaveTween = TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Sine), {
				BackgroundTransparency = 0.3,
				ImageColor3 = colors.icon,
				Size = originalSize
			})
			leaveTween:Play()
		end)
	end

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

	local fpsLabel = Instance.new("TextLabel")
	fpsLabel.Size = UDim2.new(0, 60, 0, 25)
	fpsLabel.Position = UDim2.new(0, 8, 0, 5)
	fpsLabel.BackgroundTransparency = 1
	fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	fpsLabel.Font = Enum.Font.Code
	fpsLabel.TextSize = 16
	fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
	fpsLabel.Parent = topBar

	local lastTime = tick()
	local frameCount = 0
	RunService.RenderStepped:Connect(function()
		frameCount = frameCount + 1
		if tick() - lastTime >= 1 then
			fpsLabel.Text = "FPS: "..frameCount
			frameCount = 0
			lastTime = tick()
		end
	end)

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
