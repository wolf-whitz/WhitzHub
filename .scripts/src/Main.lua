local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local GUI = import("./gui")
local Aimbot = import("./aimbot")
local AutoShoot = import("./autoshoot")

local toggles = GUI:CreateGUI()

local function getToggleValue(toggle)
    if toggle and toggle.Text then
        return toggle.Text == "ON"
    end
    return false
end

local function updateAimbotFromGUI()
    Aimbot.AIM_ASSIST = getToggleValue(toggles.AIMToggle)
    AutoShoot.AUTO_SHOOT = getToggleValue(toggles.ShootToggle)
    Aimbot.ENABLE_TEAM_CHECK = getToggleValue(toggles.TeamToggle)
    Aimbot.HIGHLIGHT_ENABLED = getToggleValue(toggles.ESPToggle)  

    if toggles.AimSmoothControl then
        Aimbot.AIM_SMOOTHNESS = toggles.AimSmoothControl.getValue()
    end
    if toggles.FOVControl then
        Aimbot.FIELD_OF_VIEW = toggles.FOVControl.getValue()
    end
    if toggles.PredictionControl then
        Aimbot.PREDICTION_FACTOR = toggles.PredictionControl.getValue()
    end
    if toggles.PartDropdown and toggles.PartDropdown.Text then
        Aimbot.TARGET_PART = toggles.PartDropdown.Text
    end
end

RunService.RenderStepped:Connect(function(delta)
    updateAimbotFromGUI()

    local target = Aimbot:GetClosestTarget()
    if target and Aimbot.AIM_ASSIST then
        Aimbot:ApplyAim(target)
    end

    AutoShoot:UpdateTarget(target)
end)
