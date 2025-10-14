local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 400, 0, 350)
Frame.Position = UDim2.new(0.5, -200, 0.15, 0)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.BorderSizePixel = 2

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Position = UDim2.new(0,0,0,0)
Title.Text = "Advanced Server Browser"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18

local ServerListFrame = Instance.new("ScrollingFrame", Frame)
ServerListFrame.Size = UDim2.new(1, -20, 0, 220)
ServerListFrame.Position = UDim2.new(0, 10, 0, 40)
ServerListFrame.BackgroundColor3 = Color3.fromRGB(35,35,35)
ServerListFrame.CanvasSize = UDim2.new(0,0,0,0)
ServerListFrame.ScrollBarThickness = 8

local UIListLayout = Instance.new("UIListLayout", ServerListFrame)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)

local serversData = {}
local SelectedServerId = nil
local RefreshInterval = 10

local function fetchServers(cursor)
    cursor = cursor or ""
    local success, response = pcall(function()
        return HttpService:JSONDecode(
            game:HttpGetAsync("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Asc&limit=100&cursor="..cursor)
        )
    end)
    if success and response and response.data then
        return response
    else
        return nil
    end
end

local function updateServerList()
    for _, child in pairs(ServerListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    serversData = {}
    local cursor = ""
    repeat
        local response = fetchServers(cursor)
        if response then
            for _, server in pairs(response.data) do
                table.insert(serversData, server)
            end
            cursor = response.nextPageCursor or ""
        else
            break
        end
    until cursor == ""
    for _, server in pairs(serversData) do
        local btn = Instance.new("TextButton", ServerListFrame)
        btn.Size = UDim2.new(1,0,0,30)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.BackgroundColor3 = Color3.fromRGB(70,70,70)
        btn.Text = "Server "..server.id.." ("..server.playing.."/"..server.maxPlayers..")"
        btn.MouseButton1Click:Connect(function()
            SelectedServerId = server.id
            for _, sibling in pairs(ServerListFrame:GetChildren()) do
                if sibling:IsA("TextButton") then
                    sibling.BackgroundColor3 = Color3.fromRGB(70,70,70)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(100,100,255)
        end)
    end
    ServerListFrame.CanvasSize = UDim2.new(0,0,0,UIListLayout.AbsoluteContentSize.Y)
end

local RejoinButton = Instance.new("TextButton", Frame)
RejoinButton.Size = UDim2.new(0.32, -10, 0, 40)
RejoinButton.Position = UDim2.new(0, 10, 1, -50)
RejoinButton.Text = "Rejoin Server"
RejoinButton.TextColor3 = Color3.fromRGB(255,255,255)
RejoinButton.BackgroundColor3 = Color3.fromRGB(50,50,50)

local JoinSelectedButton = Instance.new("TextButton", Frame)
JoinSelectedButton.Size = UDim2.new(0.32, -10, 0, 40)
JoinSelectedButton.Position = UDim2.new(0.34, 0, 1, -50)
JoinSelectedButton.Text = "Join Selected"
JoinSelectedButton.TextColor3 = Color3.fromRGB(255,255,255)
JoinSelectedButton.BackgroundColor3 = Color3.fromRGB(50,50,50)

local JoinEmptyButton = Instance.new("TextButton", Frame)
JoinEmptyButton.Size = UDim2.new(0.32, -10, 0, 40)
JoinEmptyButton.Position = UDim2.new(0.68, 0, 1, -50)
JoinEmptyButton.Text = "Join Low Pop"
JoinEmptyButton.TextColor3 = Color3.fromRGB(255,255,255)
JoinEmptyButton.BackgroundColor3 = Color3.fromRGB(50,50,50)

RejoinButton.MouseButton1Click:Connect(function()
    TeleportService:Teleport(PlaceId, LocalPlayer)
end)

JoinSelectedButton.MouseButton1Click:Connect(function()
    if SelectedServerId then
        TeleportService:TeleportToPlaceInstance(PlaceId, SelectedServerId, LocalPlayer)
    else
        warn("No server selected")
    end
end)

JoinEmptyButton.MouseButton1Click:Connect(function()
    local sortedServers = {}
    for _, s in pairs(serversData) do
        if s.playing < s.maxPlayers then
            table.insert(sortedServers, s)
        end
    end
    table.sort(sortedServers, function(a,b) return a.playing < b.playing end)
    if #sortedServers > 0 then
        TeleportService:TeleportToPlaceInstance(PlaceId, sortedServers[1].id, LocalPlayer)
    else
        warn("No low-pop servers available")
    end
end)

spawn(function()
    while true do
        updateServerList()
        wait(RefreshInterval)
    end
end)
