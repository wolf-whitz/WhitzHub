local TweenService = game:GetService("TweenService")
local DEFAULTS = import("./defaultscripts")

local LeftPanel = {}

local THEME = {
    TabDefault = Color3.fromRGB(50, 50, 50),
    TabHover = Color3.fromRGB(70, 70, 70),
    TabActive = Color3.fromRGB(100, 100, 255),
    TextColor = Color3.fromRGB(240, 240, 240),
    Accent = Color3.fromRGB(0, 120, 255),
}

function LeftPanel.create(parent, onTabClick)
    local frame = Instance.new("Frame")
    frame.Name = "LeftPanel"
    frame.Size = UDim2.new(0, 160, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local activeButton = nil
    local tabButtons = {}

    local topBtn = Instance.new("TextButton")
    topBtn.Name = "TopButton"
    topBtn.Size = UDim2.new(1, -12, 0, 36)
    topBtn.Position = UDim2.new(0, 6, 0, 8)
    topBtn.BackgroundColor3 = THEME.TabDefault
    topBtn.BackgroundTransparency = 0
    topBtn.TextColor3 = THEME.TextColor
    topBtn.Font = Enum.Font.GothamMedium
    topBtn.TextSize = 16
    topBtn.Text = "Defaults"
    topBtn.AutoButtonColor = false
    topBtn.Parent = frame

    local topCorner = Instance.new("UICorner", topBtn)
    topCorner.CornerRadius = UDim.new(0, 8)

    local topAccent = Instance.new("Frame")
    topAccent.Name = "Accent"
    topAccent.Size = UDim2.new(0, 0, 1, 0)
    topAccent.BackgroundColor3 = THEME.Accent
    topAccent.BorderSizePixel = 0
    topAccent.ZIndex = 2
    topAccent.Parent = topBtn

    local hoverSizeTop = UDim2.new(topBtn.Size.X.Scale, topBtn.Size.X.Offset + 4, topBtn.Size.Y.Scale, topBtn.Size.Y.Offset + 4)

    topBtn.MouseEnter:Connect(function()
        if topBtn ~= activeButton then
            TweenService:Create(topBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.TabHover, Size = hoverSizeTop}):Play()
        end
    end)

    topBtn.MouseLeave:Connect(function()
        if topBtn ~= activeButton then
            TweenService:Create(topBtn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.TabDefault, Size = topBtn.Size}):Play()
        end
    end)

    topBtn.MouseButton1Click:Connect(function()
        activeButton = topBtn
        TweenService:Create(topBtn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.TabActive}):Play()
        TweenService:Create(topAccent, TweenInfo.new(0.25), {Size = UDim2.new(0, 4, 1, 0)}):Play()
        if DEFAULTS then print("[✅] Loaded default scripts:", DEFAULTS) else warn("[⚠️] No default scripts found!") end
        if onTabClick then onTabClick("Defaults") end
    end)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, -52)
    scroll.Position = UDim2.new(0, 0, 0, 52)
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

    local function activateButton(btn)
        if activeButton == btn then return end
        if activeButton and activeButton ~= topBtn then
            local prevAccent = activeButton:FindFirstChild("Accent")
            TweenService:Create(activeButton, TweenInfo.new(0.2), {BackgroundColor3 = THEME.TabDefault}):Play()
            if prevAccent then
                TweenService:Create(prevAccent, TweenInfo.new(0.25), {Size = UDim2.new(0, 0, 1, 0)}):Play()
            end
        end
        activeButton = btn
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = THEME.TabActive}):Play()
        if btn:FindFirstChild("Accent") then
            TweenService:Create(btn.Accent, TweenInfo.new(0.25), {Size = UDim2.new(0, 4, 1, 0)}):Play()
        end
    end

    function LeftPanel.addTab(name, order)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(1, -4, 0, 42)
        btn.Text = name
        btn.TextColor3 = THEME.TextColor
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 16
        btn.BackgroundColor3 = THEME.TabDefault
        btn.BackgroundTransparency = 0
        btn.AutoButtonColor = false
        btn.LayoutOrder = order or 1
        btn.Parent = scroll

        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0, 8)

        local accent = Instance.new("Frame")
        accent.Name = "Accent"
        accent.Size = UDim2.new(0, 0, 1, 0)
        accent.BackgroundColor3 = THEME.Accent
        accent.BorderSizePixel = 0
        accent.ZIndex = 2
        accent.Parent = btn

        tabButtons[name] = btn

        local hoverSize = UDim2.new(btn.Size.X.Scale, btn.Size.X.Offset + 4, btn.Size.Y.Scale, btn.Size.Y.Offset + 4)

        btn.MouseEnter:Connect(function()
            if btn ~= activeButton then
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.TabHover, Size = hoverSize}):Play()
            end
        end)

        btn.MouseLeave:Connect(function()
            if btn ~= activeButton then
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = THEME.TabDefault, Size = btn.Size}):Play()
            end
        end)

        btn.MouseButton1Click:Connect(function()
            activateButton(btn)
            if onTabClick then onTabClick(name) end
        end)
    end

    function LeftPanel.switchTo(name)
        local btn = tabButtons[name]
        if btn then
            activateButton(btn)
            if onTabClick then onTabClick(name) end
        end
    end

    return LeftPanel, frame
end

return LeftPanel
