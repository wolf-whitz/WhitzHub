local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local RunService = game:GetService("RunService")
local backpack = player:WaitForChild("Backpack")

-- remove existing tool
local existingTool = backpack:FindFirstChild("Teleport Tool")
if existingTool then
	existingTool:Destroy()
end

local tool = Instance.new("Tool")
tool.Name = "Teleport Tool"
tool.RequiresHandle = false
tool.CanBeDropped = false
tool.Parent = backpack

local originalCFrame
local active = false

tool.Equipped:Connect(function()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	originalCFrame = hrp.CFrame
	active = true

	local conn
	conn = RunService.RenderStepped:Connect(function()
		if active and hrp then
			local targetPos = mouse.Hit.Position
			hrp.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0))
		else
			if conn then
				conn:Disconnect()
			end
		end
	end)
end)

tool.Unequipped:Connect(function()
	active = false
	if not originalCFrame then return end
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	hrp.CFrame = originalCFrame
end)
