local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local FLYING = false
local QEfly = true
local iyflyspeed = 1
local vehicleflyspeed = 1
local SPEED_MULTIPLIER = 1
local BV_MULTIPLIER = 50
local flyKeyDown, flyKeyUp

local CONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
local lCONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
local SPEED = 0

local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart")
end

local function sFLY(vfly)
    repeat task.wait() until player and player.Character and getRoot(player.Character)
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end

    local T = getRoot(player.Character)

    local function FLY()
        FLYING = true
        local BG = Instance.new('BodyGyro', T)
        local BV = Instance.new('BodyVelocity', T)
        BG.P = 9e4
        BG.maxTorque = Vector3.new(9e9,9e9,9e9)
        BG.CFrame = T.CFrame
        BV.velocity = Vector3.new(0,0,0)
        BV.maxForce = Vector3.new(9e9,9e9,9e9)

        task.spawn(function()
            while FLYING do
                task.wait()
                if not vfly and player.Character:FindFirstChildOfClass('Humanoid') then
                    player.Character:FindFirstChildOfClass('Humanoid').PlatformStand = true
                end
                if vfly and T then
                    T.CanCollide = false
                end
                if CONTROL.F+CONTROL.B ~=0 or CONTROL.L+CONTROL.R~=0 or CONTROL.Q+CONTROL.E~=0 then
                    SPEED = BV_MULTIPLIER * SPEED_MULTIPLIER
                else
                    SPEED = 0
                end
                if SPEED ~=0 then
                    local cam = workspace.CurrentCamera
                    BV.velocity = ((cam.CFrame.LookVector*(CONTROL.F+CONTROL.B)) + ((cam.CFrame*CFrame.new(CONTROL.L+CONTROL.R,(CONTROL.F+CONTROL.B+CONTROL.Q+CONTROL.E)*0.2,0)).p - cam.CFrame.p)) * SPEED
                    lCONTROL = {F=CONTROL.F,B=CONTROL.B,L=CONTROL.L,R=CONTROL.R,Q=CONTROL.Q,E=CONTROL.E}
                else
                    BV.velocity = Vector3.new(0,0,0)
                end
                BG.CFrame = workspace.CurrentCamera.CFrame
            end
            CONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
            lCONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
            SPEED = 0
            BG:Destroy()
            BV:Destroy()
            if player.Character:FindFirstChildOfClass('Humanoid') then
                player.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
            end
        end)
    end

    flyKeyDown = UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        local KEY = input.KeyCode
        if KEY == Enum.KeyCode.W then CONTROL.F = (vfly and vehicleflyspeed or iyflyspeed)
        elseif KEY == Enum.KeyCode.S then CONTROL.B = -(vfly and vehicleflyspeed or iyflyspeed)
        elseif KEY == Enum.KeyCode.A then CONTROL.L = -(vfly and vehicleflyspeed or iyflyspeed)
        elseif KEY == Enum.KeyCode.D then CONTROL.R = (vfly and vehicleflyspeed or iyflyspeed)
        elseif QEfly and KEY == Enum.KeyCode.E then CONTROL.Q = (vfly and vehicleflyspeed or iyflyspeed)*2
        elseif QEfly and KEY == Enum.KeyCode.Q then CONTROL.E = -(vfly and vehicleflyspeed or iyflyspeed)*2
        end
        pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Track end)
    end)

    flyKeyUp = UserInputService.InputEnded:Connect(function(input, gpe)
        if gpe then return end
        local KEY = input.KeyCode
        if KEY == Enum.KeyCode.W then CONTROL.F = 0
        elseif KEY == Enum.KeyCode.S then CONTROL.B = 0
        elseif KEY == Enum.KeyCode.A then CONTROL.L = 0
        elseif KEY == Enum.KeyCode.D then CONTROL.R = 0
        elseif KEY == Enum.KeyCode.E then CONTROL.Q = 0
        elseif KEY == Enum.KeyCode.Q then CONTROL.E = 0
        end
    end)

    FLY()
end

local function NOFLY()
    FLYING = false
    if flyKeyDown then flyKeyDown:Disconnect() end
    if flyKeyUp then flyKeyUp:Disconnect() end
    if player.Character and player.Character:FindFirstChildOfClass('Humanoid') then
        player.Character:FindFirstChildOfClass('Humanoid').PlatformStand = false
    end
    pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Custom end)
end

-- GUI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "FlyGui"

local Container = Instance.new("Frame", ScreenGui)
Container.Size = UDim2.new(0, 300, 0, 250)
Container.Position = UDim2.new(0.5, -150, 0.1, 0)
Container.BackgroundColor3 = Color3.fromRGB(40,40,50)
Container.BorderSizePixel = 0
local corner = Instance.new("UICorner", Container)
corner.CornerRadius = UDim.new(0,10)

-- Dragging
local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    Container.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
end
Container.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Container.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
Container.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

local FlyButton = Instance.new("TextButton", Container)
FlyButton.Size = UDim2.new(0, 120, 0, 40)
FlyButton.Position = UDim2.new(0, 10, 0, 10)
FlyButton.BackgroundColor3 = Color3.fromRGB(100,100,255)
FlyButton.TextColor3 = Color3.fromRGB(255,255,255)
FlyButton.Font = Enum.Font.Gotham
FlyButton.TextSize = 16
FlyButton.Text = "Toggle Fly"

local CloseButton = Instance.new("TextButton", Container)
CloseButton.Size = UDim2.new(0,40,0,40)
CloseButton.Position = UDim2.new(1,-50,0,10)
CloseButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255,255,255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    NOFLY()
end)

local SpeedLabel = Instance.new("TextLabel", Container)
SpeedLabel.Size = UDim2.new(0, 120, 0, 20)
SpeedLabel.Position = UDim2.new(0, 10, 0, 60)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextColor3 = Color3.fromRGB(255,255,255)
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.TextSize = 14
SpeedLabel.Text = "Speed: "..SPEED_MULTIPLIER

local MinusBtn = Instance.new("TextButton", Container)
MinusBtn.Size = UDim2.new(0, 30, 0, 30)
MinusBtn.Position = UDim2.new(0,10,0,85)
MinusBtn.Text = "-"
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.TextSize = 18
MinusBtn.BackgroundColor3 = Color3.fromRGB(80,80,100)
MinusBtn.TextColor3 = Color3.fromRGB(255,255,255)
MinusBtn.MouseButton1Click:Connect(function()
    SPEED_MULTIPLIER = math.max(0.1, SPEED_MULTIPLIER - 0.5)
    SpeedLabel.Text = "Speed: "..SPEED_MULTIPLIER
end)

local PlusBtn = Instance.new("TextButton", Container)
PlusBtn.Size = UDim2.new(0, 30, 0, 30)
PlusBtn.Position = UDim2.new(0,50,0,85)
PlusBtn.Text = "+"
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.TextSize = 18
PlusBtn.BackgroundColor3 = Color3.fromRGB(80,80,100)
PlusBtn.TextColor3 = Color3.fromRGB(255,255,255)
PlusBtn.MouseButton1Click:Connect(function()
    SPEED_MULTIPLIER = SPEED_MULTIPLIER + 0.5
    SpeedLabel.Text = "Speed: "..SPEED_MULTIPLIER
end)

local QECheck = Instance.new("TextButton", Container)
QECheck.Size = UDim2.new(0, 120, 0, 30)
QECheck.Position = UDim2.new(0,10,0,125)
QECheck.BackgroundColor3 = Color3.fromRGB(80,80,100)
QECheck.TextColor3 = Color3.fromRGB(255,255,255)
QECheck.Font = Enum.Font.Gotham
QECheck.TextSize = 14
QECheck.Text = "QE Fly: "..tostring(QEfly)
QECheck.MouseButton1Click:Connect(function()
    QEfly = not QEfly
    QECheck.Text = "QE Fly: "..tostring(QEfly)
end)

FlyButton.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then warn("Humanoid not found!") return end
    if not hum.SeatPart and hum.Sit == false then
        warn("You must be seated to fly!")
        return
    end
    if FLYING then
        NOFLY()
    else
        sFLY(true)
    end
end)
