local COMPILE_SCRIPTS_OUTPUT = true

 

-- START SCRIPTS TABLE
scripts = {
{id=1, section="Universal", name="Aimbot", description="Universal aimbot with FOV and tracer lines", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/universal/aimbot.lua"},
{id=2, section="Universal", name="Infinite Yield", description="Credits to iy devs", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/universal/iy.lua"},
{id=3, section="Universal", name="Fly GUI", description="A universal fly gui, doesnt work with body checking game (Eg games that check body velocity, hrp, so on, please use the Universal Powerful Fly script to bypass those types of game)", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/universal/flyscript.lua"},
{id=4, section="Universal", name="Universal Fly Car", description="A universal fly car", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/universal/flycar.lua"},
{id=5, section="Universal", name="Universal Server Hop", description="A universal server hopping tools, it allows you to switch server, select server, join low population server", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/universal/serverhop.lua"},
{id=6, section="Universal", name="Universal swimfly", description="A universal swim fly", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/universal/swimfly.lua"},
{id=7, section="Universal", name="Universal bang script", description="Fml", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/universal/bang.lua"},
{id=8, section="Universal", name="Universal esp ", description="A universal esp  tools", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/universal/esp.lua"},
{id=9, section="Universal", name="Anti Death", description="Universal anti death script, anti death script always return your character body to its death position, something like a respawn point where your character dies!", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/universal/antideath.lua"},
{id=10, section="Universal", name="Invisible tool", description="Allow yourself to be made invisible via the invisible tool!", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/universal/invistool.lua"},
{id=11, section="Prison Life", name="Kill aura", description="Kill aura for Prison Life", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/prisonlife/killaura.lua"},
{id=12, section="Prison Life", name="Super Kill", description="Super Kill script for Prison Life", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/prisonlife/superkill.lua"},
{id=13, section="Universal", name="Tp Gui", description="TP gui, allow yourself to be tpied anywhere, with a tp tool! universal", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/universal/tps/tpgui.lua"},
{id=14, section="Universal", name="TP Tool", description="A simple universal tp tool, allows your self to be tpied, if you wish to have gui please use the tp gui", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/universal/tps/tptool.lua"},
{id=15, section="Universal", name="Waypoint", description="Universal Waypoint ", url="https://raw.githubusercontent.com/wolf-whitz/WhitzHub/main/src/scripts/luas/universal/tps/waypoint.lua"}
}
-- END SCRIPTS TABLE

local WindowControls = import("./ui/windowControls")
local LeftPanel = import("./ui/leftPanel")
local RightPanel = import("./ui/rightPanel")
local Players = game:GetService("Players")

local Main = {}
Main.scripts = scripts

function Main.create()
    local player = Players.LocalPlayer
    if not player then return end

    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local window = Instance.new("Frame")
    window.Size = UDim2.new(0, 700, 0, 450)
    window.Position = UDim2.new(0.05, 0, 0.05, 0)
    window.BackgroundTransparency = 0.7
    window.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    window.BorderSizePixel = 0
    window.ClipsDescendants = true
    window.Parent = gui

    local corner = Instance.new("UICorner", window)
    corner.CornerRadius = UDim.new(0, 12)

    local gradient = Instance.new("UIGradient", window)
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 35)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15))
    }
    gradient.Rotation = 90

    local blur = Instance.new("UIStroke", window)
    blur.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    blur.Color = Color3.fromRGB(180, 180, 255)
    blur.Transparency = 0.6
    blur.Thickness = 1.5

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 35)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundTransparency = 0.8
    topBar.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    topBar.BorderSizePixel = 0
    topBar.Parent = window

    WindowControls.create(topBar, window, gui)

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 1, -35)
    content.Position = UDim2.new(0, 0, 0, 35)
    content.BackgroundTransparency = 1
    content.Parent = window

    local rightPanel = RightPanel.create(content)
    local activeSection = nil
    local leftPanel
    leftPanel, _ = LeftPanel.create(content, function(sectionName)
        activeSection = sectionName
        rightPanel.switchTo(sectionName)
    end)

    local orderedSections, addedSections = {}, {}
    for _, data in ipairs(Main.scripts) do
        if not addedSections[data.section] then
            table.insert(orderedSections, data.section)
            addedSections[data.section] = true
        end
        rightPanel.addButton(data.section, data)
    end

    for i, name in ipairs(orderedSections) do
        LeftPanel.addTab(name, i)
    end

    if #orderedSections > 0 then
        activeSection = orderedSections[1]
        rightPanel.switchTo(activeSection)
    end
end

return Main
