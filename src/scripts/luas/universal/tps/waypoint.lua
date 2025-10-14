local Players = game:GetService("Players")
local player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = player:WaitForChild("PlayerGui")

local waypointFolder = ReplicatedStorage:FindFirstChild("Waypoints")
if not waypointFolder then
	waypointFolder = Instance.new("Folder")
	waypointFolder.Name = "Waypoints"
	waypointFolder.Parent = ReplicatedStorage
end

local playerWaypoints = waypointFolder:FindFirstChild(player.Name)
if not playerWaypoints then
	playerWaypoints = Instance.new("Folder")
	playerWaypoints.Name = player.Name
	playerWaypoints.Parent = waypointFolder
end

local waypoints = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WaypointGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 300)
frame.Position = UDim2.new(0.5, -125, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Text = "Waypoint GUI"
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = frame

local addBtn = Instance.new("TextButton")
addBtn.Size = UDim2.new(1, -20, 0, 35)
addBtn.Position = UDim2.new(0, 10, 0, 50)
addBtn.Text = "Add Waypoint at Mouse"
addBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
addBtn.TextColor3 = Color3.fromRGB(255,255,255)
addBtn.Font = Enum.Font.Gotham
addBtn.TextSize = 18
addBtn.Parent = frame

local waypointList = Instance.new("ScrollingFrame")
waypointList.Size = UDim2.new(1, -20, 1, -100)
waypointList.Position = UDim2.new(0, 10, 0, 90)
waypointList.CanvasSize = UDim2.new(0,0,0,0)
waypointList.ScrollBarThickness = 6
waypointList.BackgroundTransparency = 1
waypointList.Parent = frame

local function saveWaypoint(position)
	local wpPart = Instance.new("Vector3Value")
	wpPart.Name = "Waypoint"..(#waypoints+1)
	wpPart.Value = position
	wpPart.Parent = playerWaypoints
end

local function refreshList()
	waypointList:ClearAllChildren()
	local yPos = 0
	for i, wp in ipairs(waypoints) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1,0,0,35)
		btn.Position = UDim2.new(0,0,0,yPos)
		btn.Text = "Waypoint "..i
		btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
		btn.TextColor3 = Color3.fromRGB(255,255,255)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 16
		btn.Parent = waypointList
		btn.MouseButton1Click:Connect(function()
			local char = player.Character or player.CharacterAdded:Wait()
			local hrp = char:WaitForChild("HumanoidRootPart")
			hrp.CFrame = CFrame.new(wp + Vector3.new(0,3,0))
		end)
		yPos = yPos + 40
	end
	waypointList.CanvasSize = UDim2.new(0,0,0,yPos)
end

addBtn.MouseButton1Click:Connect(function()
	local mouse = player:GetMouse()
	table.insert(waypoints, mouse.Hit.Position)
	saveWaypoint(mouse.Hit.Position)
	refreshList()
end)

screenGui.Enabled = true

player.CharacterAdded:Connect(function(char)
	local saved = playerWaypoints:GetChildren()
	waypoints = {}
	for _, wp in ipairs(saved) do
		table.insert(waypoints, wp.Value)
	end
	refreshList()
end)
