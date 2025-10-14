local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ENABLE_TEAM_CHECK = false
local SHOW_DISTANCE = true
local ESP_COLOR = Color3.fromRGB(0, 255, 0)
local BOX_THICKNESS = 1
local NAME_SIZE = 13
local HEALTH_SIZE = 13

local espData = {}

local function isValidPlayer(player)
	if player == LocalPlayer then return false end
	if ENABLE_TEAM_CHECK and player.Team == LocalPlayer.Team then return false end
	local char = player.Character
	if not char or not char:IsDescendantOf(workspace) then return false end
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	return hrp and humanoid and humanoid.Health > 0
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
		health = Drawing.new("Text")
	}
	local data = espData[player]
	data.box.Thickness = BOX_THICKNESS
	data.box.Color = ESP_COLOR
	data.box.Transparency = 1
	data.box.Filled = false
	data.name.Size = NAME_SIZE
	data.name.Color = ESP_COLOR
	data.name.Center = true
	data.name.Outline = true
	data.health.Size = HEALTH_SIZE
	data.health.Color = ESP_COLOR
	data.health.Center = true
	data.health.Outline = true
end

local function removeESP(player)
	if not espData[player] then return end
	local data = espData[player]
	data.box:Remove()
	data.name:Remove()
	data.health:Remove()
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
	local humanoid = char:FindFirstChildWhichIsA("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not hrp then
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

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		initESP(player)
	end)
end)

Players.PlayerRemoving:Connect(removeESP)

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
	for _, player in ipairs(Players:GetPlayers()) do
		if isValidPlayer(player) then
			initESP(player)
			updateESP(player)
		elseif espData[player] then
			removeESP(player)
		end
	end
end)
