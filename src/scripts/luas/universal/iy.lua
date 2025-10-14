local __mod0 = (function()
local Defaults = {}

Defaults.Frame = {
	BackgroundColor3 = Color3.fromRGB(25, 25, 25),
	BorderSizePixel = 0,
	Size = UDim2.new(0, 200, 0, 150),
	Shadow = {
		Color = Color3.fromRGB(0, 0, 0),
		Thickness = 1,
		Transparency = 0.8
	}
}

Defaults.Button = {
	BackgroundColor3 = Color3.fromRGB(80, 80, 80),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	Size = UDim2.new(1, -20, 0, 35),
	Shadow = {
		Color = Color3.fromRGB(0, 0, 0),
		Thickness = 1,
		Transparency = 0.7
	}
}

Defaults.TextBox = {
	BackgroundColor3 = Color3.fromRGB(60, 60, 60),
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.Gotham,
	TextSize = 18,
	ClearTextOnFocus = false,
	Size = UDim2.new(1, -20, 0, 40),
	Shadow = {
		Color = Color3.fromRGB(0, 0, 0),
		Thickness = 1,
		Transparency = 0.8
	}
}

Defaults.Label = {
	BackgroundTransparency = 1,
	TextColor3 = Color3.fromRGB(255, 255, 255),
	Font = Enum.Font.GothamBold,
	TextSize = 18,
	Size = UDim2.new(1, -20, 0, 25),
	TextXAlignment = Enum.TextXAlignment.Left,
	Shadow = {
		Color = Color3.fromRGB(0, 0, 0),
		Thickness = 1,
		Transparency = 0.85
	}
}

return Defaults

end)()

local __mod1 = (function()
local GuiStyle = {}
GuiStyle.__index = GuiStyle

local Defaults = __mod0
GuiStyle.Defaults = Defaults

function GuiStyle.Merge(base, custom)
	local merged = {}
	for k, v in pairs(base or {}) do merged[k] = v end
	for k, v in pairs(custom or {}) do merged[k] = v end
	return merged
end

function GuiStyle.Apply(obj, style)
	for k, v in pairs(style or {}) do
		if k == "bg" then
			obj.BackgroundColor3 = v
		elseif k == "text" then
			obj.Text = v
		elseif k == "textColor" then
			obj.TextColor3 = v
		elseif k == "size" then
			obj.Size = v
		elseif k == "pos" then
			obj.Position = v
		elseif k == "font" then
			obj.Font = v
		elseif k == "textSize" then
			obj.TextSize = v
		elseif k == "corner" then
			local c = Instance.new("UICorner")
			c.CornerRadius = v
			c.Parent = obj
		elseif k == "shadow" then
			local defaults = Defaults[obj.ClassName] and Defaults[obj.ClassName].Shadow
			if typeof(v) == "table" then
				local s = Instance.new("UIStroke")
				s.Color = v.Color or (defaults and defaults.Color) or Color3.fromRGB(0, 0, 0)
				s.Thickness = v.Thickness or (defaults and defaults.Thickness) or 1
				s.Transparency = v.Transparency or (defaults and defaults.Transparency) or 0.8
				s.Parent = obj
			elseif v == true and defaults then
				local s = Instance.new("UIStroke")
				s.Color = defaults.Color
				s.Thickness = defaults.Thickness
				s.Transparency = defaults.Transparency
				s.Parent = obj
			end
		elseif k == "bgTransparency" then
			obj.BackgroundTransparency = v
		elseif k == "textTransparency" and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
			obj.TextTransparency = v
		elseif k == "align" and (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
			obj.TextXAlignment = v
		end
	end
end

return GuiStyle

end)()

local __mod2 = (function()
local Engine = {}
Engine.__index = Engine

local GuiStyle = __mod1
local AnimationEngine = import("./animation")

Engine.Style = GuiStyle
Engine.Animate = AnimationEngine

function Engine:Start()
	print("[Engine] GUI Styling & Animation Engine Initialized ✅")
	return self
end

function Engine:CreateElement(typeName, parent, style)
	local obj

	if typeName == "Frame" then
		obj = Instance.new("Frame")
	elseif typeName == "Button" then
		obj = Instance.new("TextButton")
		obj.Text = style.text or ""
		obj.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	elseif typeName == "TextBox" then
		obj = Instance.new("TextBox")
	elseif typeName == "Label" then
		obj = Instance.new("TextLabel")
		obj.Text = style.text or ""
		obj.BackgroundTransparency = 1
	else
		error("Unsupported element type: " .. tostring(typeName))
	end

	local defaults = GuiStyle.Defaults[typeName] or {}
	local finalStyle = GuiStyle.Merge(defaults, style)
	GuiStyle.Apply(obj, finalStyle)
	obj.Parent = parent

	-- Optional built-in button effects for interactive elements
	if obj:IsA("TextButton") then
		AnimationEngine.Hover(obj)
		AnimationEngine.ClickEffect(obj)
	end

	return obj
end

function Engine:Start()
	print("[Engine] GUI Styling & Animation Engine Initialized ✅")
	return self
end

return Engine:Start()

end)()

local __mod3 = (function()
local WindowControls = {}
local Engine = __mod2
local UserInputService = game:GetService("UserInputService")

function WindowControls.create(topBar, window, gui)
	local buttonSize = UDim2.new(0, 30, 0, 30)
	local spacing = 5

	-- Icon asset IDs
	local ICONS = {
		close = 0,                 -- Replace with asset IDs if needed
		minimize = 0,
		restoreDown = 10137941941,
		maximize = 11036884234
	}

	-- Helper to create a button with an icon
	local function createButton(assetId, index)
		-- Create a TextButton so MouseButton1Click works
		local btn = Engine:CreateElement("Button", topBar, {
			size = buttonSize,
			pos = UDim2.new(1, -(index * (buttonSize.X.Offset + spacing)), 0, 0),
			text = "",
			corner = UDim.new(0, 4)
		})

		-- Add image icon if assetId is provided
		if assetId ~= 0 then
			local img = Instance.new("ImageLabel")
			img.Size = UDim2.new(0, buttonSize.X.Offset, 0, buttonSize.Y.Offset)
			img.Position = UDim2.new(0, 0, 0, 0)
			img.BackgroundTransparency = 1
			img.Image = "rbxassetid://" .. assetId
			img.Parent = btn
		end

		-- Hover effects
		btn.MouseEnter:Connect(function()
			Engine.Animate.Tween(btn, { bg = Color3.fromRGB(80, 80, 80) }, 0.15)
		end)

		btn.MouseLeave:Connect(function()
			Engine.Animate.Tween(btn, { bg = Color3.fromRGB(50, 50, 50) }, 0.2)
		end)

		return btn
	end

	local closeButton = createButton(ICONS.close, 1)
	local minimizeButton = createButton(ICONS.minimize, 2)
	local maximizeButton = createButton(ICONS.maximize, 3)

	local isMinimized = false
	local isMaximized = false
	local originalSize = window.Size
	local originalPos = window.Position

	-- Minimize
	minimizeButton.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		if isMinimized then
			Engine.Animate.Tween(window, {
				size = UDim2.new(originalSize.X.Scale, originalSize.X.Offset, 0, topBar.Size.Y.Offset)
			}, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		else
			Engine.Animate.Tween(window, { size = originalSize }, 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		end
	end)

	-- Close
	closeButton.MouseButton1Click:Connect(function()
		Engine.Animate.Fade(window, 1, 0.25, function()
			gui:Destroy()
		end)
	end)

	-- Maximize / Restore
	maximizeButton.MouseButton1Click:Connect(function()
		isMaximized = not isMaximized
		if isMaximized then
			Engine.Animate.Tween(window, {
				size = UDim2.new(1, -20, 1, -20),
				pos = UDim2.new(0, 10, 0, 10)
			}, 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		else
			Engine.Animate.Tween(window, {
				size = originalSize,
				pos = originalPos
			}, 0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		end
	end)

	-- Make the window draggable
	local dragging = false
	local dragInput, mousePos, framePos

	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			mousePos = input.Position
			framePos = window.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	topBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - mousePos
			window.Position = UDim2.new(
				framePos.X.Scale,
				framePos.X.Offset + delta.X,
				framePos.Y.Scale,
				framePos.Y.Offset + delta.Y
			)
		end
	end)
end

return WindowControls

end)()

local __mod4 = (function()
local Main = {}

local Engine = __mod2
local sections = import("./sections")
local WindowControls = __mod3
local UserInputService = game:GetService("UserInputService")

function Main.createMain()
    local player = game:GetService("Players").LocalPlayer
    if not player then return end
    local playerGui = player:WaitForChild("PlayerGui")
    if not playerGui then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MainGUI"
    gui.Parent = playerGui

    local window = Engine:CreateElement("Frame", gui, {
        bg = Color3.fromRGB(30, 30, 30),
        size = UDim2.new(0, 350, 0, 500),
        pos = UDim2.new(0, 50, 0, 50),
        corner = UDim.new(0, 8),
        shadow = true
    })

    local topBar = Engine:CreateElement("Frame", window, {
        bg = Color3.fromRGB(20, 20, 20),
        size = UDim2.new(1, 0, 0, 35),
        pos = UDim2.new(0, 0, 0, 0),
        corner = UDim.new(0, 8)
    })

    WindowControls.create(topBar, window, gui)

    local container = Engine:CreateElement("Frame", window, {
        bg = Color3.fromRGB(25, 25, 25),
        size = UDim2.new(1, -20, 1, -50),
        pos = UDim2.new(0, 10, 0, 45),
        corner = UDim.new(0, 6)
    })

    local scrolling = Instance.new("ScrollingFrame")
    scrolling.Size = UDim2.new(1, 0, 1, 0)
    scrolling.BackgroundTransparency = 1
    scrolling.ScrollBarThickness = 6
    scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrolling.Parent = container

    local tooltip = Engine:CreateElement("Label", gui, {
        bg = Color3.fromRGB(15, 15, 15),
        bgTransparency = 0.4,
        size = UDim2.new(0, 260, 0, 50),
        textColor = Color3.new(1, 1, 1),
        textSize = 16,
        corner = UDim.new(0, 8),
        align = Enum.TextXAlignment.Left
    })
    tooltip.Visible = false

    local yOffset = 10

    for sectionName, scriptsInSection in pairs(sections) do
        local sectionLabel = Engine:CreateElement("Label", scrolling, {
            text = sectionName,
            pos = UDim2.new(0, 10, 0, yOffset),
            size = UDim2.new(1, -20, 0, 30),
            textColor = Color3.new(1, 1, 1),
            textSize = 18,
            font = Enum.Font.GothamBold,
            align = Enum.TextXAlignment.Left,
            bgTransparency = 1
        })
        yOffset = yOffset + 40

        local idList = {}
        for idKey in pairs(scriptsInSection) do
            local n = tonumber(idKey:match("id:(%d+)")) or 0
            table.insert(idList, n)
        end
        table.sort(idList)

        for _, i in ipairs(idList) do
            local idKey = "id:" .. i
            local scriptData = scriptsInSection[idKey]
            if scriptData and type(scriptData.content) == "string" and #scriptData.content > 0 then
                local button = Engine:CreateElement("Button", scrolling, {
                    text = scriptData.name,
                    pos = UDim2.new(0, 10, 0, yOffset),
                    size = UDim2.new(1, -20, 0, 35),
                    bg = Color3.fromRGB(50, 50, 50),
                    textColor = Color3.new(1, 1, 1),
                    corner = UDim.new(0, 4)
                })

                button.MouseButton1Click:Connect(function()
                    Engine.Animate.Pulse(button, 1.05, 0.15)
                    local func, err = load(scriptData.content)
                    if type(func) == "function" then
                        local ok, res = pcall(func)
                        if not ok then warn("Failed to execute script:", scriptData.name, res) end
                    else
                        warn("Failed to load script:", scriptData.name, err)
                    end
                end)

                button.MouseEnter:Connect(function()
                    tooltip.Text = scriptData.description
                    tooltip.Visible = true
                end)

                button.MouseLeave:Connect(function()
                    tooltip.Visible = false
                end)

                button.MouseMoved:Connect(function(x, y)
                    tooltip.Position = UDim2.new(0, math.min(x + 10, workspace.CurrentCamera.ViewportSize.X - tooltip.Size.X.Offset - 10), 0, y)
                end)

                yOffset = yOffset + 40
            else
                warn("Script missing or invalid content:", idKey)
            end
        end

        yOffset = yOffset + 20
    end

    scrolling.CanvasSize = UDim2.new(0, 0, 0, yOffset)
end

return Main

end)()

local __mod5 = (function()
local function isGameReady()
	if typeof(game) ~= "Instance" or not game.GetService then
		return false
	end

	local ok, Players = pcall(function()
		return game:GetService("Players")
	end)
	if not ok or not Players then
		return false
	end

	if not Players.LocalPlayer then
		local okWait, _ = pcall(function()
			Players.PlayerAdded:Wait()
		end)
		if not okWait then
			return false
		end
	end

	return true
end

local function safeStart()
	if not isGameReady() then
		warn("[⚠️] Roblox environment not ready yet, waiting...")
		repeat
			task.wait(0.25)
		until isGameReady()
	end

	local Engine = __mod2
	local Intro = import("./modules/intro")
	local Main = __mod4

	Engine:Start()

	local ok, err = pcall(function()
		Intro.createIntro(function()
			Main.createMain()
		end)
	end)
	if not ok then
		warn("[Intro Error]", err)
		Main.createMain()
	end
end

task.spawn(safeStart)

end)()