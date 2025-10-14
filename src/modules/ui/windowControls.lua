local WindowControls = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

function WindowControls.create(topBar, window, gui)
    local buttonSize = UDim2.new(0, 30, 0, 30)
    local spacing = 5

    local function createButton(index, imageId)
        local btn = Instance.new("ImageButton")
        btn.Size = buttonSize
        btn.Position = UDim2.new(1, -(index * (buttonSize.X.Offset + spacing)), 0, 2)
        btn.Image = imageId
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.BackgroundTransparency = 0.4
        btn.BorderSizePixel = 0
        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 6)
        btn.Parent = topBar
        local hoverTween = TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2})
        local leaveTween = TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.4})
        btn.MouseEnter:Connect(function() hoverTween:Play() end)
        btn.MouseLeave:Connect(function() leaveTween:Play() end)
        return btn
    end

    local closeButton = createButton(1, "rbxassetid://116533143721125")
    local minimizeButton = createButton(2, "rbxassetid://10137941941")
    local maximizeButton = createButton(3, "rbxassetid://11036884234")

    local isMinimized = false
    local isMaximized = false
    local originalSize = window.Size
    local originalPos = window.Position

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -35)
    contentFrame.Position = UDim2.new(0, 0, 0, 35)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true
    contentFrame.Parent = window

    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    minimizeButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        local goalSize = isMinimized and UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, 35) or originalSize
        TweenService:Create(window, tweenInfo, {Size = goalSize}):Play()
    end)

    closeButton.MouseButton1Click:Connect(function()
        local flash = Instance.new("Frame")
        flash.Size = UDim2.new(1,0,1,0)
        flash.BackgroundColor3 = Color3.fromRGB(255,0,0)
        flash.BackgroundTransparency = 0.7
        flash.BorderSizePixel = 0
        flash.Parent = window
        TweenService:Create(flash, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        local tween = TweenService:Create(window, TweenInfo.new(0.25), {Position = window.Position + UDim2.new(0,0,0,20), Size = UDim2.new(0,0,0,0)})
        tween:Play()
        tween.Completed:Connect(function() gui:Destroy() end)
    end)

    maximizeButton.MouseButton1Click:Connect(function()
        isMaximized = not isMaximized
        local goal = isMaximized and {Size = UDim2.new(1,-20,1,-20), Position = UDim2.new(0,10,0,10)} or {Size = originalSize, Position = originalPos}
        TweenService:Create(window, tweenInfo, goal):Play()
    end)

    local dragging = false
    local dragInput, mousePos, framePos
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
            window.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)

    return contentFrame
end

return WindowControls
