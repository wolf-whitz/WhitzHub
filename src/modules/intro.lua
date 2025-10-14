local Intro = {}

function Intro.createIntro(callback)
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")

    local player = Players.LocalPlayer
    if not player then
        if callback then callback() end
        return
    end

    local playerGui = player:WaitForChild("PlayerGui")

    local gui = Instance.new("ScreenGui")
    gui.Name = "WhitzHubIntro"
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 100
    gui.Parent = playerGui

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 1
    bg.Parent = gui

    local gradient = Instance.new("UIGradient", bg)
    gradient.Rotation = 90
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
    })

    local blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = game:GetService("Lighting")

    local title = Instance.new("TextLabel")
    title.Text = "WhitzHub"
    title.Size = UDim2.new(0, 400, 0, 80)
    title.Position = UDim2.new(0.5, 0, 0.45, 0)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBlack
    title.BackgroundTransparency = 1
    title.TextTransparency = 1
    title.Parent = gui

    local subtitle = Instance.new("TextLabel")
    subtitle.Text = "created by whitzscott"
    subtitle.Size = UDim2.new(0, 400, 0, 35)
    subtitle.Position = UDim2.new(0.5, 0, 0.56, 0)
    subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    subtitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    subtitle.TextScaled = true
    subtitle.Font = Enum.Font.Gotham
    subtitle.BackgroundTransparency = 1
    subtitle.TextTransparency = 1
    subtitle.Parent = gui

    local glow = Instance.new("UIStroke", title)
    glow.Thickness = 1.6
    glow.Transparency = 1
    glow.Color = Color3.fromRGB(100, 100, 255)

    local tweenIn = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local tweenOut = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

    local bgFadeIn = TweenService:Create(bg, tweenIn, {BackgroundTransparency = 0.2})
    local blurIn = TweenService:Create(blur, tweenIn, {Size = 12})
    local titleIn = TweenService:Create(title, tweenIn, {TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.43, 0)})
    local subtitleIn = TweenService:Create(subtitle, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {TextTransparency = 0})

    local glowIn = TweenService:Create(glow, TweenInfo.new(1, Enum.EasingStyle.Quad), {Transparency = 0.5})
    local glowPulse = TweenService:Create(glow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.2})

    local fadeOut = TweenService:Create(bg, tweenOut, {BackgroundTransparency = 1})
    local blurOut = TweenService:Create(blur, tweenOut, {Size = 0})
    local titleOut = TweenService:Create(title, tweenOut, {TextTransparency = 1, Position = UDim2.new(0.5, 0, 0.4, 0)})
    local subtitleOut = TweenService:Create(subtitle, tweenOut, {TextTransparency = 1, Position = UDim2.new(0.5, 0, 0.6, 0)})

    bgFadeIn:Play()
    blurIn:Play()
    titleIn:Play()
    subtitleIn:Play()
    glowIn:Play()

    task.wait(0.8)
    glowPulse:Play()

    task.wait(2.5)

    fadeOut:Play()
    blurOut:Play()
    titleOut:Play()
    subtitleOut:Play()

    titleOut.Completed:Wait()

    glowPulse:Cancel()
    blur:Destroy()
    gui:Destroy()

    if callback and type(callback) == "function" then
        task.spawn(callback)
    end
end

return Intro
