local WindowControls = {}
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ICONS = {
    Minimize = "rbxassetid://10137941941",
    Maximize = "rbxassetid://11036884234",
    Close = "X"
}

function WindowControls.create(topBar, window, gui)
    topBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    topBar.ClipsDescendants = true

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -150, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "WhitzHub | FPS: 0"
    title.Parent = topBar

    local function updateFPS()
        local lastTime, frameCount = tick(), 0
        RunService.RenderStepped:Connect(function()
            frameCount = frameCount + 1
            if tick() - lastTime >= 1 then
                title.Text = "WhitzHub | FPS: " .. tostring(frameCount)
                frameCount = 0
                lastTime = tick()
            end
        end)
    end
    updateFPS()

    local function createButton(icon, posX, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 30, 0, 30)
        btn.Position = UDim2.new(1, posX, 0, 2)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.AutoButtonColor = false
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.Text = icon == "X" and icon or ""
        btn.Parent = topBar

        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 6)

        if icon ~= "X" then
            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(0, 16, 0, 16)
            img.Position = UDim2.new(0.5, -8, 0.5, -8)
            img.BackgroundTransparency = 1
            img.Image = icon
            img.Parent = btn
        end

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.7}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
        end)

        return btn
    end

    local closeButton = createButton(ICONS.Close, -35, Color3.fromRGB(255, 80, 90))
    local minimizeButton = createButton(ICONS.Minimize, -70, Color3.fromRGB(100, 100, 100))
    local maximizeButton = createButton(ICONS.Maximize, -105, Color3.fromRGB(100, 100, 100))

    local isMinimized, isMaximized = false, false

    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local goalSize = isMinimized and UDim2.new(window.Size.X.Scale, window.Size.X.Offset, 0, topBar.AbsoluteSize.Y) or window.Size
        TweenService:Create(window, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = goalSize}):Play()
    end)

    maximizeButton.MouseButton1Click:Connect(function()
        isMaximized = not isMaximized
        local goalSize, goalPos
        if isMaximized then
            goalSize = UDim2.new(1, -20, 1, -20)
            goalPos = UDim2.new(0, 10, 0, 10)
        else
            goalSize = window.Size
            goalPos = window.Position
        end
        TweenService:Create(window, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = goalSize, Position = goalPos}):Play()
    end)

    closeButton.MouseButton1Click:Connect(function()
        local flash = Instance.new("Frame")
        flash.Size = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        flash.BackgroundTransparency = 0.7
        flash.BorderSizePixel = 0
        flash.ZIndex = 3
        flash.Parent = window
        TweenService:Create(flash, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()

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
                framePos.X.Scale, framePos.X.Offset + delta.X,
                framePos.Y.Scale, framePos.Y.Offset + delta.Y
            )
        end
    end)
end

return WindowControls
