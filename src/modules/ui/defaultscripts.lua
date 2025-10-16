local function defaults()
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
	ScreenGui.Name = "DefaultModifiers"

	local frame = Instance.new("Frame", ScreenGui)
	frame.Size = UDim2.new(0, 220, 0, 160)
	frame.Position = UDim2.new(0.5, -110, 0.5, -80)
	frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	frame.Active = true
	frame.Draggable = true

	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 8)

	local title = Instance.new("TextLabel", frame)
	title.Size = UDim2.new(1, 0, 0, 30)
	title.BackgroundTransparency = 1
	title.Text = "Character Modifiers"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.TextColor3 = Color3.fromRGB(255, 255, 255)

	local function createSlider(labelText, min, max, default, callback)
		local holder = Instance.new("Frame", frame)
		holder.Size = UDim2.new(1, -20, 0, 40)
		holder.Position = UDim2.new(0, 10, 0, 35 + (#frame:GetChildren() - 2) * 45)
		holder.BackgroundTransparency = 1

		local label = Instance.new("TextLabel", holder)
		label.Size = UDim2.new(1, 0, 0, 20)
		label.BackgroundTransparency = 1
		label.Text = labelText .. ": " .. default
		label.Font = Enum.Font.Gotham
		label.TextSize = 14
		label.TextColor3 = Color3.fromRGB(200, 200, 200)
		label.TextXAlignment = Enum.TextXAlignment.Left

		local slider = Instance.new("TextBox", holder)
		slider.Size = UDim2.new(1, 0, 0, 20)
		slider.Position = UDim2.new(0, 0, 0, 20)
		slider.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		slider.TextColor3 = Color3.fromRGB(255, 255, 255)
		slider.Text = tostring(default)
		slider.Font = Enum.Font.Gotham
		slider.TextSize = 14
		slider.ClearTextOnFocus = false

		local corner2 = Instance.new("UICorner", slider)
		corner2.CornerRadius = UDim.new(0, 4)

		slider.FocusLost:Connect(function()
			local val = tonumber(slider.Text)
			if val then
				val = math.clamp(val, min, max)
				slider.Text = tostring(val)
				label.Text = labelText .. ": " .. val
				callback(val)
			else
				slider.Text = tostring(default)
			end
		end)
	end

	createSlider("WalkSpeed", 8, 300, humanoid.WalkSpeed, function(v)
		humanoid.WalkSpeed = v
	end)

	createSlider("JumpPower", 10, 500, humanoid.JumpPower, function(v)
		humanoid.JumpPower = v
	end)

	createSlider("HipHeight", 0, 50, humanoid.HipHeight, function(v)
		humanoid.HipHeight = v
	end)

	return "Default modifiers loaded"
end

return defaults
