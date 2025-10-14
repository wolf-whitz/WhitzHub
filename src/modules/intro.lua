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
    gui.Parent = playerGui
    gui.IgnoreGuiInset = true

    -- Background Fade
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 1
    bg.Parent = gui

    -- Title
    local title = Instance.new("TextLabel")
    title.Text = "WhitzHub"
    title.Size = UDim2.new(0, 400, 0, 80)
    title.Position = UDim2.new(0.5, 0, 0.4, 0)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.BackgroundTransparency = 1
    title.TextTransparency = 1
    title.Parent = gui

    -- Subtitle
    local subtitle = Instance.new("TextLabel")
    subtitle.Text = "Created by whitzscott"
    subtitle.Size = UDim2.new(0, 400, 0, 40)
    subtitle.Position = UDim2.new(0.5, 0, 0.55, 0)
    subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
    subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    subtitle.TextScaled = true
    subtitle.Font = Enum.Font.Gotham
    subtitle.BackgroundTransparency = 1
    subtitle.TextTransparency = 1
    subtitle.Position = subtitle.Position + UDim2.new(0, 0, 0.1, 0) -- start slightly lower
    subtitle.Parent = gui

    -- Tween Info
    local tweenInfoIn = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tweenInfoOut = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local bgFadeIn = TweenService:Create(bg, tweenInfoIn, {BackgroundTransparency = 0.3})
    local bgFadeOut = TweenService:Create(bg, tweenInfoOut, {BackgroundTransparency = 1})

    local titleFadeIn = TweenService:Create(title, tweenInfoIn, {TextTransparency = 0})
    local titleScale = TweenService:Create(title, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 90)})
    local titleFadeOut = TweenService:Create(title, tweenInfoOut, {TextTransparency = 1})
    local titleShrink = TweenService:Create(title, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 400, 0, 80)})

    local subtitleFadeIn = TweenService:Create(subtitle, tweenInfoIn, {TextTransparency = 0, Position = UDim2.new(0.5, 0, 0.55, 0)})
    local subtitleFadeOut = TweenService:Create(subtitle, tweenInfoOut, {TextTransparency = 1, Position = subtitle.Position + UDim2.new(0, 0, 0.1, 0)})

    -- Play Tweens
    bgFadeIn:Play()
    titleFadeIn:Play()
    titleScale:Play()
    subtitleFadeIn:Play()

    titleFadeIn.Completed:Wait()
    task.wait(2) -- wait before fading out

    bgFadeOut:Play()
    titleFadeOut:Play()
    titleShrink:Play()
    subtitleFadeOut:Play()

    titleFadeOut.Completed:Wait()
    gui:Destroy()

    if callback and type(callback) == "function" then
        callback()
    end
end

return Intro
