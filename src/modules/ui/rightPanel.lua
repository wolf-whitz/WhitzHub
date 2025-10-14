local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local RightPanel = {}

function RightPanel.create(parent)
    local frame = Instance.new("Frame")
    frame.Name = "RightPanel"
    frame.Size = UDim2.new(1, -160, 1, 0)
    frame.Position = UDim2.new(0, 160, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local layout = Instance.new("UIListLayout", frame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 5)

    local tooltip = Instance.new("TextLabel")
    tooltip.Name = "Tooltip"
    tooltip.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    tooltip.BackgroundTransparency = 0.3
    tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
    tooltip.TextSize = 16
    tooltip.RichText = true
    tooltip.TextWrapped = true
    tooltip.TextXAlignment = Enum.TextXAlignment.Left
    tooltip.TextYAlignment = Enum.TextYAlignment.Top
    tooltip.Visible = false
    tooltip.Parent = parent.Parent
    local corner = Instance.new("UICorner", tooltip)
    corner.CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", tooltip)
    stroke.Color = Color3.fromRGB(200,200,200)
    stroke.Transparency = 0.5
    stroke.Thickness = 2

    local sectionButtons = {}

    function RightPanel.addButton(section, data)
        if not sectionButtons[section] then sectionButtons[section] = {} end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 40)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = data.name
        btn.Visible = false
        btn.LayoutOrder = data.id
        btn.Parent = frame

        local corner = Instance.new("UICorner", btn)
        corner.CornerRadius = UDim.new(0, 6)

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(85,85,85)}):Play()
            tooltip.Text = data.description or ""
            tooltip.Size = UDim2.new(0, 250, 0, math.clamp(tooltip.TextBounds.Y + 8, 40, 200))
            local mousePos = UserInputService:GetMouseLocation()
            local screenSize = workspace.CurrentCamera.ViewportSize
            tooltip.Position = UDim2.new(0, math.clamp(mousePos.X + 10, 0, screenSize.X - tooltip.Size.X.Offset),
                                         0, math.clamp(mousePos.Y + 10, 0, screenSize.Y - tooltip.Size.Y.Offset))
            tooltip.Visible = true
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60,60,60)}):Play()
            tooltip.Visible = false
        end)
        btn.MouseButton1Click:Connect(function()
            if data.url and #data.url > 0 then
                local success, err = pcall(function()
                    local func, loadErr = loadstring(game:HttpGet(data.url, true))
                    if not func then error(loadErr) end
                    func()
                end)
                if not success then warn("[⚠️] Failed to execute script:", err) end
            end
        end)

        table.insert(sectionButtons[section], btn)
    end

    function RightPanel.switchTo(section)
        for sec, buttons in pairs(sectionButtons) do
            for _, btn in ipairs(buttons) do
                btn.Visible = (sec == section)
            end
        end
    end

    return RightPanel
end

return RightPanel
