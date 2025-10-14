local RightPanel = {}
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

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

function RightPanel.create(parent)
	local settings = readSettings()
	local dark = settings.darkmode

	local TextColor = dark and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(30, 30, 30)
	local BtnColor = dark and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(240, 240, 240)
	local ExecuteColor = Color3.fromRGB(100, 100, 255)
	local ExecuteHover = Color3.fromRGB(150, 150, 255)

	local frame = Instance.new("Frame")
	frame.Name = "RightPanel"
	frame.Size = UDim2.new(1, -160, 1, 0)
	frame.Position = UDim2.new(0, 160, 0, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollBarThickness = 6
	scroll.BackgroundTransparency = 1
	scroll.Parent = frame

	local layout = Instance.new("UIListLayout", scroll)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)

	local sectionButtons = {}

	function RightPanel.addButton(section, data)
		if not sectionButtons[section] then
			sectionButtons[section] = {}
		end

		local btn = Instance.new("Frame")
		btn.Size = UDim2.new(1, -10, 0, 42)
		btn.BackgroundColor3 = BtnColor
		btn.Parent = scroll

		local corner = Instance.new("UICorner", btn)
		corner.CornerRadius = UDim.new(0, 8)

		local stroke = Instance.new("UIStroke", btn)
		stroke.Color = TextColor
		stroke.Transparency = 0.7
		stroke.Thickness = 1

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -90, 1, 0)
		nameLabel.Position = UDim2.new(0, 5, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = TextColor
		nameLabel.Text = data.name
		nameLabel.Font = Enum.Font.GothamMedium
		nameLabel.TextSize = 15
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = btn

		local executeBtn = Instance.new("TextButton")
		executeBtn.Size = UDim2.new(0, 70, 0, 30)
		executeBtn.Position = UDim2.new(1, -75, 0, 6)
		executeBtn.BackgroundColor3 = ExecuteColor
		executeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		executeBtn.Text = "Execute"
		executeBtn.Font = Enum.Font.Gotham
		executeBtn.TextSize = 14
		executeBtn.AutoButtonColor = false
		executeBtn.Parent = btn

		local cornerEx = Instance.new("UICorner", executeBtn)
		cornerEx.CornerRadius = UDim.new(0, 6)

		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(1, -10, 0, 0)
		descLabel.Position = UDim2.new(0, 5, 1, 5)
		descLabel.BackgroundTransparency = 1
		descLabel.TextColor3 = TextColor
		descLabel.Text = data.description or "No description"
		descLabel.TextWrapped = true
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.TextYAlignment = Enum.TextYAlignment.Top
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextSize = 14
		descLabel.Parent = btn

		executeBtn.MouseEnter:Connect(function()
			TweenService:Create(descLabel, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(1, -10, 0, 50)}):Play()
			TweenService:Create(executeBtn, TweenInfo.new(0.2), {BackgroundColor3 = ExecuteHover}):Play()
		end)

		executeBtn.MouseLeave:Connect(function()
			TweenService:Create(descLabel, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(1, -10, 0, 0)}):Play()
			TweenService:Create(executeBtn, TweenInfo.new(0.2), {BackgroundColor3 = ExecuteColor}):Play()
		end)

		executeBtn.MouseButton1Click:Connect(function()
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
