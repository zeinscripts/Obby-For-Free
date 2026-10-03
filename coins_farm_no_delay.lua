-- Coin Farm - NO DELAY + Auto Rejoin on Kick (your exact code + hop)
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local queueteleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)
if queueteleport then
    queueteleport('loadstring(game:HttpGet("https://github.com/zeinscripts/Obby-For-Free/raw/refs/heads/main/coins_farm_no_delay.lua"))()')
end

local function getSmallestServer()
    local success, result = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
    end)
    if success then
        local ok, data = pcall(function() return HttpService:JSONDecode(result) end)
        if ok and data and data.data then
            local smallest, minPlayers = nil, 999
            for _, srv in ipairs(data.data) do
                if srv.playing < minPlayers and srv.id ~= game.JobId and srv.maxPlayers > srv.playing then
                    minPlayers = srv.playing
                    smallest = srv
                end
            end
            return smallest
        end
    end
    return nil
end

local function serverHop()
    local smallest = getSmallestServer()
    if smallest then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, smallest.id, player)
    else
        TeleportService:Teleport(game.PlaceId, player)
    end
end

pcall(function()
    game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" then
            task.wait(2)
            local txt = ""
            pcall(function() txt = child:FindFirstChild("MessageArea").ErrorFrame.MessageLabel.Text end)
            if string.find(string.lower(txt), "banned") then return end
            serverHop()
        end
    end)
end)

TeleportService.TeleportInitFailed:Connect(function(p, result, err)
    if p == player then task.wait(2) serverHop() end
end)

-- YOUR ORIGINAL CODE - NO DELAY
game.RunService.RenderStepped:Connect(function()
    game.ReplicatedStorage.IncrementCoins:FireServer()
end)
