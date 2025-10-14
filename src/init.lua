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

local function safeStart()
    if not isGameReady() then
        warn("[⚠️] Roblox environment not ready, waiting...")
        repeat
            task.wait(0.25)
        until isGameReady()
    end

    local Intro = import("./modules/intro") or {}

    if type(Intro.createIntro) == "function" then
        Intro.createIntro(function()
            local Main = import("./modules/main")
            if type(Main.create) == "function" then
                Main.create()
            else
                warn("[⚠️] create() not found in Main module")
            end
        end)
    else
        local Main = import("./modules/main")
        if type(Main.create) == "function" then
            Main.create()
        else
            warn("[⚠️] create() not found in Main module")
        end
    end
end

task.spawn(safeStart)
