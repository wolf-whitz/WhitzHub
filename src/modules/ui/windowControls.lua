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
    -- ✦ Styling: Modern flat look
    topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    topBar.BorderSizePixel = 0
    topBar.ClipsDescendants = true

    local shadow = Instance.new("UIStroke", topBar)
    shadow.Thickness = 1
    shadow.Color = Color3.fromRGB(60, 60, 80)
    shadow.Transparency = 0.5

    -- ✦ Title Label
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -160, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(235, 235, 255)
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "WhitzHub | FPS: 0"
    title.Parent = topBar

    -- ✦ FPS Counter
    do
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

    -- ✦ Button Factory
    local function createButton(icon, posX, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 32, 0, 32)
        btn.Position = UDim2.new(1, posX, 0, 2)
        btn.BackgroundColor3 = color
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.AutoButtonColor = false
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.Text = icon == "X" and icon or ""
        btn.ZIndex = 2
        btn.Parent = topBar

        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 6)

        -- Icon Image
        if icon ~= "X" then
            local img = Instance.new("ImageLabel")
            img.Size = UDim2.new(0, 18, 0, 18)
            img.AnchorPoint = Vector2.new(0.5, 0.5)
            img.Position = UDim2.new(0.5, 0, 0.5, 0)
            img.BackgroundTransparency = 1
            img.Image = icon
            img.ImageColor3 = Color3.fromRGB(240, 240, 240)
            img.ZIndex = 3
            img.Parent = btn
        end

        -- Hover Effect
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = color:Lerp(Color3.fromRGB(255, 255, 255), 0.15)
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = color}):Play()
        end)

        return btn
    end

    -- ✦ Buttons
    local closeButton = createButton(ICONS.Close, -38, Color3.fromRGB(230, 70, 80))
    local minimizeButton = createButton(ICONS.Minimize, -74, Color3.fromRGB(90, 90, 110))
    local maximizeButton = createButton(ICONS.Maximize, -110, Color3.fromRGB(90, 90, 110))

    -- ✦ State Tracking
    local isMinimized, isMaximized = false, false
    local originalSize = window.Size
    local originalPosition = window.Position

    -- ✦ Minimize Logic
    minimizeButton.MouseButton1Click:Connect(function()
        if isMaximized then return end
        isMinimized = not isMinimized
        local goalSize = isMinimized
            and UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, topBar.AbsoluteSize.Y)
            or originalSize

        TweenService:Create(window, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = goalSize
        }):Play()
    end)

    -- ✦ Maximize Logic
    maximizeButton.MouseButton1Click:Connect(function()
        isMaximized = not isMaximized
        if isMaximized then
            originalSize = window.Size
            originalPosition = window.Position
            TweenService:Create(window, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Size = UDim2.new(1, -20, 1, -20),
                Position = UDim2.new(0, 10, 0, 10)
            }):Play()
        else
            TweenService:Create(window, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                Size = originalSize,
                Position = originalPosition
            }):Play()
        end
    end)

    -- ✦ Close Animation
    closeButton.MouseButton1Click:Connect(function()
        local flash = Instance.new("Frame")
        flash.Size = UDim2.new(1, 0, 1, 0)
        flash.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
        flash.BackgroundTransparency = 0.7
        flash.BorderSizePixel = 0
        flash.ZIndex = 3
        flash.Parent = window

        TweenService:Create(flash, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()

        local tween = TweenService:Create(window, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = window.Position + UDim2.new(0, 0, 0, 50),
            Size = UDim2.new(0, 0, 0, 0)
        })
        tween:Play()
        tween.Completed:Connect(function()
            gui:Destroy()
        end)
    end)

    -- ✦ Dragging System
    local dragging, dragInput, mousePos, framePos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = window.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
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
