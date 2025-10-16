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

	local padding = Instance.new("UIPadding", scroll)
	padding.PaddingTop = UDim.new(0, 8)
	padding.PaddingLeft = UDim.new(0, 6)
	padding.PaddingRight = UDim.new(0, 6)

	local sectionButtons = {}
	local currentExpandedButton

	local self = {}

	function self.addButton(section, data)
		if not sectionButtons[section] then
			sectionButtons[section] = {}
		end

		local btnFrame = Instance.new("TextButton")
		btnFrame.Size = UDim2.new(1, -10, 0, 42)
		btnFrame.BackgroundColor3 = BtnColor
		btnFrame.Text = ""
		btnFrame.AutoButtonColor = false
		btnFrame.Parent = scroll

		local corner = Instance.new("UICorner", btnFrame)
		corner.CornerRadius = UDim.new(0, 8)

		local stroke = Instance.new("UIStroke", btnFrame)
		stroke.Color = TextColor
		stroke.Transparency = 0.7
		stroke.Thickness = 1

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -90, 0, 42)
		nameLabel.Position = UDim2.new(0, 5, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = TextColor
		nameLabel.Text = data.name
		nameLabel.Font = Enum.Font.GothamMedium
		nameLabel.TextSize = 15
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = btnFrame

		local executeBtn = Instance.new("TextButton")
		executeBtn.Size = UDim2.new(0, 70, 0, 30)
		executeBtn.Position = UDim2.new(1, -75, 0, 6)
		executeBtn.BackgroundColor3 = ExecuteColor
		executeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		executeBtn.Text = "Execute"
		executeBtn.Font = Enum.Font.Gotham
		executeBtn.TextSize = 14
		executeBtn.AutoButtonColor = false
		executeBtn.Parent = btnFrame

		local cornerEx = Instance.new("UICorner", executeBtn)
		cornerEx.CornerRadius = UDim.new(0, 6)

		local descLabel
		local expanded = false
		local dropdownHeight = 50

		local function showDropdown()
			if descLabel then descLabel:Destroy() end
			descLabel = Instance.new("TextLabel")
			descLabel.Size = UDim2.new(1, -10, 0, dropdownHeight)
			descLabel.Position = UDim2.new(0, 5, 0, 42)
			descLabel.BackgroundTransparency = 1
			descLabel.TextColor3 = TextColor
			descLabel.Text = data.description or "No description"
			descLabel.TextWrapped = true
			descLabel.TextXAlignment = Enum.TextXAlignment.Left
			descLabel.TextYAlignment = Enum.TextYAlignment.Top
			descLabel.Font = Enum.Font.Gotham
			descLabel.TextSize = 14
			descLabel.Parent = btnFrame
		end

		local function hideDropdown()
			if descLabel then
				descLabel:Destroy()
				descLabel = nil
			end
		end

		btnFrame.MouseButton1Click:Connect(function()
			if currentExpandedButton and currentExpandedButton ~= btnFrame then
				TweenService:Create(currentExpandedButton, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(1, -10, 0, 42)}):Play()
				local otherDesc = currentExpandedButton:FindFirstChildWhichIsA("TextLabel")
				if otherDesc then otherDesc:Destroy() end
			end

			expanded = not expanded
			local goalSize = expanded and 42 + dropdownHeight or 42
			TweenService:Create(btnFrame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(1, -10, 0, goalSize)}):Play()

			if expanded then showDropdown() else hideDropdown() end

			currentExpandedButton = expanded and btnFrame or nil
		end)

		executeBtn.MouseEnter:Connect(function()
			TweenService:Create(executeBtn, TweenInfo.new(0.2), {BackgroundColor3 = ExecuteHover}):Play()
		end)
		executeBtn.MouseLeave:Connect(function()
			TweenService:Create(executeBtn, TweenInfo.new(0.2), {BackgroundColor3 = ExecuteColor}):Play()
		end)

		executeBtn.MouseButton1Click:Connect(function()
			if not data.url or #data.url == 0 then return end
			if not string.match(data.url, "^https://raw%.githubusercontent%.com/wolf%-whitz/WhitzHub/") then
				warn("[⚠️] Script blocked! Only scripts from wolf-whitz/WhitzHub are allowed.")
				return
			end
			local success, err = pcall(function()
				local func, loadErr = loadstring(game:HttpGet(data.url, true))
				if not func then error(loadErr) end
				func()
			end)
			if not success then warn("[⚠️] Failed to execute script:", err) end
		end)

		table.insert(sectionButtons[section], btnFrame)
	end

	function self.switchTo(section)
		for sec, buttons in pairs(sectionButtons) do
			for _, btn in ipairs(buttons) do
				btn.Visible = (sec == section)
			end
		end
	end

	return self
end

return RightPanel
