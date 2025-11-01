-- [ Darkteria ] Infinite Health + Mobile GUI
-- Работает в Krnl, Delta, Arceus X, Fluxus

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- === БЕСКОНЕЧНОЕ ЗДОРОВЬЕ ===
local InfiniteHealth = true

spawn(function()
    while task.wait() do
        if InfiniteHealth and Humanoid and Humanoid.Parent then
            Humanoid.Health = Humanoid.MaxHealth
        end
    end
end)

-- === МОБИЛЬНОЕ GUI (Rayfield) ===
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/nAlwspa/rayfield/refs/heads/main/fef.lua'))()

local Window = Rayfield:CreateWindow({
    Name = "Darkteria Hub",
    LoadingTitle = "Infinite Health",
    LoadingSubtitle = "by Darkteria",
})

local Tab = Window:CreateTab("Main", 4483362458)

Tab:CreateToggle({
    Name = "Infinite Health",
    CurrentValue = true,
    Callback = function(Value)
        InfiniteHealth = Value
        if Value then
            Rayfield:Notify({ Title = "Enabled", Content = "Infinite Health ON" })
        else
            Rayfield:Notify({ Title = "Disabled", Content = "Infinite Health OFF" })
        end
    end,
})

Tab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end,
})

-- Авто-обновление персонажа
LocalPlayer.CharacterAdded:Connect(function(char)
    Humanoid = char:WaitForChild("Humanoid")
end)
