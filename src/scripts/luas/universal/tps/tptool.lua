local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local backpack = player:WaitForChild("Backpack")
local tool = Instance.new("Tool")
tool.Name = "TP Tool"
tool.RequiresHandle = false
tool.CanBeDropped = false
tool.Parent = backpack

tool.Activated:Connect(function()
	local target = mouse.Hit
	if not target then return end
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = CFrame.new(target.Position + Vector3.new(0, 3, 0))
	end
end)
