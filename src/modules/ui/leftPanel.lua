local TweenService = game:GetService("TweenService")

local LeftPanel = {}

local THEME = {
    Background = Color3.fromRGB(25, 25, 25),
    TabDefault = Color3.fromRGB(50, 50, 50),
    TabHover = Color3.fromRGB(75, 75, 75),
    TabActive = Color3.fromRGB(100, 100, 255),
    TextColor = Color3.fromRGB(240, 240, 240),
    Accent = Color3.fromRGB(0, 120, 255),
}

function LeftPanel.create(parent, onTabClick)
    local frame = Instance.new("Frame")
    frame.Name = "LeftPanel"
    frame.Size = UDim2.new(0, 160, 1, 0)
    frame.BackgroundColor3 = THEME.Background
    frame.BackgroundTransparency = 0.2
    frame.Parent = parent

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

    local gradient = Instance.new("UIGradient", frame)
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
    }
    gradient.Rotation = 90

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.ScrollBarThickness = 6
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = frame

    local layout = Instance.new("UIListLayout", scroll)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)

    local padding = Instance.new("UIPadding", scroll)
    padding.PaddingTop = UDim.new(0, 8)
    padding.PaddingLeft = UDim.new(0, 6)
    padding.PaddingRight = UDim.new(0, 6)

    local activeButton = nil
    local tabButtons = {}

    function LeftPanel.addTab(name, order)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(1, -4, 0, 42)
        btn.Text = name
        btn.TextColor3 = THEME.TextColor
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 16
        btn.BackgroundColor3 = THEME.TabDefault
        btn.AutoButtonColor = false
        btn.LayoutOrder = order or 1
        btn.Parent = scroll

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local accent = Instance.new("Frame")
        accent.Name = "Accent"
        accent.Size = UDim2.new(0, 0, 1, 0)
        accent.Position = UDim2.new(0, 0, 0, 0)
        accent.BackgroundColor3 = THEME.Accent
        accent.BorderSizePixel = 0
        accent.ZIndex = 2
        accent.Parent = btn

        tabButtons[name] = btn

        -- Hover animation
        btn.MouseEnter:Connect(function()
            if btn ~= activeButton then
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.TabHover}):Play()
            end
        end)

        btn.MouseLeave:Connect(function()
            if btn ~= activeButton then
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.TabDefault}):Play()
            end
        end)

        -- Click event
        btn.MouseButton1Click:Connect(function()
            if activeButton == btn then
                -- Already active; allow re-click without breaking hover state
                if onTabClick then onTabClick(name) end
                return
            end

            -- Reset previous tab visuals
            if activeButton then
                TweenService:Create(activeButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = THEME.TabDefault
                }):Play()
                local prevAccent = activeButton:FindFirstChild("Accent")
                if prevAccent then
                    TweenService:Create(prevAccent, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 1, 0)}):Play()
                end
            end

            -- Set new active tab
            activeButton = btn
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.TabActive}):Play()
            TweenService:Create(accent, TweenInfo.new(0.25), {Size = UDim2.new(0, 4, 1, 0)}):Play()

            if onTabClick then
                onTabClick(name)
            end
        end)
    end

    function LeftPanel.switchTo(name)
        local btn = tabButtons[name]
        if btn then
            btn.MouseButton1Click:Fire()
        end
    end

    return LeftPanel, frame
end

return LeftPanel
