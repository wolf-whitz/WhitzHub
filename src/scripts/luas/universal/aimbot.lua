local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AIM_SMOOTHNESS = 0.05
local FIELD_OF_VIEW = 250
local ENABLE_TEAM_CHECK = false

StarterGui:SetCore("SendNotification", {
	Title = "Universal Aimbot",
	Text = "Credit to Whitzscott for developing this universal aim bot",
	Duration = 6
})

local tracerLine = Drawing.new("Line")
tracerLine.Color = Color3.fromRGB(255, 0, 0)
tracerLine.Thickness = 2
tracerLine.Transparency = 1
tracerLine.Visible = true

local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(0, 255, 255)
fovCircle.Thickness = 2
fovCircle.NumSides = 64
fovCircle.Radius = FIELD_OF_VIEW
fovCircle.Visible = true
fovCircle.Filled = false
fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

local espData = {}

local function isRealPlayer(player)
	if player == LocalPlayer then return false end
	if ENABLE_TEAM_CHECK and player.Team == LocalPlayer.Team then return false end
	local char = player.Character
	if not char or not char:IsDescendantOf(workspace) then return false end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	return hrp and humanoid and humanoid.Health > 0
end

local function getClosestTarget()
	local closest, dist = nil, FIELD_OF_VIEW
	for _, player in ipairs(Players:GetPlayers()) do
		if isRealPlayer(player) then
			local head = player.Character:FindFirstChild("Head")
			if head then
				local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local mag = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
					if mag < dist then
						dist = mag
						closest = player
					end
				end
			end
		end
	end
	return closest
end

local function getBoxCorners(char)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local size = Vector3.new(4, 6, 0)
	local topLeft = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(-size.X, size.Y, 0))
	local bottomRight = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(size.X, -size.Y, 0))
	return Vector2.new(topLeft.X, topLeft.Y), Vector2.new(bottomRight.X, bottomRight.Y)
end

local function initESP(player)
	if espData[player] then return end
	espData[player] = {
		box = Drawing.new("Square"),
		name = Drawing.new("Text"),
		health = Drawing.new("Text"),
	}
	espData[player].box.Thickness = 1
	espData[player].box.Color = Color3.fromRGB(0, 255, 0)
	espData[player].box.Transparency = 1
	espData[player].box.Filled = false
	espData[player].name.Size = 13
	espData[player].name.Color = Color3.fromRGB(255, 255, 255)
	espData[player].name.Center = true
	espData[player].name.Outline = true
	espData[player].health.Size = 13
	espData[player].health.Color = Color3.fromRGB(0, 255, 0)
	espData[player].health.Center = true
	espData[player].health.Outline = true
end

local function removeESP(player)
	if not espData[player] then return end
	espData[player].box:Remove()
	espData[player].name:Remove()
	espData[player].health:Remove()
	espData[player] = nil
end

local function updateESP(player)
	local data = espData[player]
	if not data then return end
	local char = player.Character
	if not char then
		removeESP(player)
		return
	end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	if not hrp or not head or not humanoid then
		removeESP(player)
		return
	end
	local tl, br = getBoxCorners(char)
	if tl and br then
		data.box.Position = tl
		data.box.Size = br - tl
		data.box.Visible = true
		local namePos = Vector2.new((tl.X + br.X) / 2, tl.Y - 16)
		local healthPos = Vector2.new((tl.X + br.X) / 2, tl.Y - 2)
		data.name.Text = player.DisplayName
		data.name.Position = namePos
		data.name.Visible = true
		data.health.Text = math.floor(humanoid.Health) .. " HP"
		data.health.Position = healthPos
		data.health.Visible = true
	else
		removeESP(player)
	end
end

-- Handle players joining / respawning
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		initESP(player)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	removeESP(player)
end)

-- Initialize existing players
for _, player in ipairs(Players:GetPlayers()) do
	if player ~= LocalPlayer then
		player.CharacterAdded:Connect(function()
			initESP(player)
		end)
		if player.Character then
			initESP(player)
		end
	end
end

RunService.RenderStepped:Connect(function()
	fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	local target = getClosestTarget()
	if target and target.Character then
		local head = target.Character:FindFirstChild("Head")
		if head then
			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
			if onScreen then
				tracerLine.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
				tracerLine.To = Vector2.new(screenPos.X, screenPos.Y)
				tracerLine.Visible = true
			else
				tracerLine.Visible = false
			end
			local goal = (head.Position - Camera.CFrame.Position).Unit
			local current = Camera.CFrame.LookVector
			local blended = (current:Lerp(goal, AIM_SMOOTHNESS)).Unit
			local newCF = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + blended)
			Camera.CFrame = newCF
		end
	else
		tracerLine.Visible = false
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if isRealPlayer(player) then
			initESP(player)
			updateESP(player)
		elseif espData[player] then
			removeESP(player)
		end
	end
end)