local function isGameReady()
    if typeof(game) ~= "Instance" or not game.GetService then
        return false
    end

    local Players = game:GetService("Players")
    if not Players then
        return false
    end

    if not Players.LocalPlayer then
        Players.PlayerAdded:Wait()
    end

    return true
end

local function createPersistentScreenGui(name)
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local existingGui = playerGui:FindFirstChild(name)
    if existingGui then
        return existingGui
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = name
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    return screenGui
end

local function safeStart()
    if not isGameReady() then
        warn("[⚠️] Roblox environment not ready, waiting...")
        repeat
            task.wait(0.25)
        until isGameReady()
    end

    local gui = createPersistentScreenGui("MyMainUI")
    local Intro = import("./modules/intro") or {}

    if type(Intro.createIntro) == "function" then
        Intro.createIntro(function()
            local Main = import("./modules/main")
            if type(Main.create) == "function" then
                Main.create(gui)
            else
                warn("[⚠️] create() not found in Main module")
            end
        end, gui)
    else
        local Main = import("./modules/main")
        if type(Main.create) == "function" then
            Main.create(gui)
        else
            warn("[⚠️] create() not found in Main module!")
        end
    end
end

task.spawn(safeStart)
