-- [ Darkteria ] FULL HACK: Noclip + True Stealth + ESP + Сворачивание GUI
-- Работает в Delta, Arceus X, Hydrogen, Fluxus, Krnl
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- === ПЕРЕМЕННЫЕ ===
local InfiniteHealth = false
local OneHitKill = false
local StealthMode = false
local SilentWalk = false
local MonsterESP = false
local Noclip = false

local espObjects = {}
local noclipConnection = nil

-- === БЕСКОНЕЧНОЕ ЗДОРОВЬЕ ===
task.spawn(function()
    while task.wait() do
        if InfiniteHealth and humanoid and humanoid.Parent then
            humanoid.Health = humanoid.MaxHealth
        end
    end
end)

-- === УБИЙСТВО С ОДНОГО УДАРА ===
local function applyOneHitKill()
    if not OneHitKill then return end
    local tools = {}
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then table.insert(tools, tool) end
        end
    end
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") then table.insert(tools, tool) end
    end

    for _, tool in ipairs(tools) do
        local handle = tool:FindFirstChild("Handle")
        if handle and not handle:FindFirstChild("OHK") then
            local conn = handle.Touched:Connect(function(hit)
                if OneHitKill then
                    local enemyHum = hit.Parent:FindFirstChildOfClass("Humanoid")
                    if enemyHum and enemyHum ~= humanoid then
                        enemyHum:TakeDamage(999999)
                    end
                end
            end)
            conn.Name = "OHK"
        end
    end
end

-- === НЕВИДИМОСТЬ (True Stealth) ===
local function applyStealth(enable)
    StealthMode = enable
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") and model ~= character then
            local hum = model:FindFirstChildOfClass("Humanoid")
            if hum then
                if enable then
                    pcall(function()
                        for _, script in ipairs(model:GetDescendants()) do
                            if (script:IsA("LocalScript") or script:IsA("Script")) and (string.find(script.Name, "AI") or string.find(script.Name, "Behavior") or string.find(script.Name, "Follow")) then
                                script.Disabled = true
                            end
                        end
                    end)
                    for _, part in ipairs(model:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                        if part:IsA("ProximityPrompt") then part.Enabled = false end
                    end
                else
                    pcall(function()
                        for _, script in ipairs(model:GetDescendants()) do
                            if (script:IsA("Script") or script:IsA("LocalScript")) and string.find(script.Name, "AI") then
                                script.Disabled = false
                            end
                        end
                    end)
                end
            end
        end
    end
end

-- === НЕСЛЫШИМОСТЬ ===
local function applySilentWalk(enable)
    SilentWalk = enable
    if not enable then return end
    for _, sound in ipairs(character:GetDescendants()) do
        if sound:IsA("Sound") and (string.find(string.lower(sound.Name), "foot") or string.find(string.lower(sound.Name), "step")) then
            sound.Volume = 0
            sound:Destroy()
        end
    end
    character.DescendantAdded:Connect(function(obj)
        if SilentWalk and obj:IsA("Sound") and (string.find(string.lower(obj.Name), "foot") or string.find(string.lower(obj.Name), "step")) then
            task.defer(function() if obj.Parent then obj:Destroy() end end)
        end
    end)
end

-- === NOCLIP ===
local function toggleNoclip(enable)
    Noclip = enable
    if noclipConnection then noclipConnection:Disconnect() end
    if not enable then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
        return
    end
    noclipConnection = RunService.Stepped:Connect(function()
        if Noclip and character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end)
end

-- === ESP МОНСТРОВ ===
local function addESP(model)
    if espObjects[model] or not model.PrimaryPart then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = model.PrimaryPart
    billboard.Size = UDim2.new(0, 100, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = model

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "MONSTER"
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = billboard

    espObjects[model] = billboard
end

local function updateESP()
    if not MonsterESP then
        for model, gui in pairs(espObjects) do
            if gui and gui.Parent then gui:Destroy() end
        end
        espObjects = {}
        return
    end
    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") and model ~= character then
            if not espObjects[model] then addESP(model) end
        end
    end
end

task.spawn(function()
    while task.wait(1) do
        if MonsterESP then updateESP() end
    end
end)

-- === РЕСПАВН ===
local function onCharacterAdded(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
    task.wait(1)
    if InfiniteHealth then humanoid.Health = humanoid.MaxHealth end
    if OneHitKill then applyOneHitKill() end
    if StealthMode then applyStealth(true) end
    if SilentWalk then applySilentWalk(true) end
    if Noclip then toggleNoclip(true) end
end

player.CharacterAdded:Connect(onCharacterAdded)
player.Backpack.ChildAdded:Connect(applyOneHitKill)

-- === GUI ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkteriaHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- === ОСНОВНАЯ РАМКА ===
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 580)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -290)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
title.Text = "Darkteria Hub"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = mainFrame

-- === КНОПКА СВОРАЧИВАНИЯ ===
local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 40, 0, 40)
collapseBtn.Position = UDim2.new(1, -45, 0, 5)
collapseBtn.Text = "−"
collapseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
collapseBtn.TextColor3 = Color3.new(1, 1, 1)
collapseBtn.Font = Enum.Font.GothamBold
collapseBtn.Parent = mainFrame

-- === КОНТЕНТ ===
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -70)
content.Position = UDim2.new(0, 10, 0, 60)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 6
content.Visible = true
content.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 10)
layout.Parent = content

-- === ТУМБЛЕР ===
local function createToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.Parent = content

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 60, 0, 30)
    toggle.Position = UDim2.new(1, -70, 0.5, -15)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = frame

    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
        toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return frame
end

local function createButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 50)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 18
    btn.Parent = content
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- === КНОПКИ ===
createToggle("Infinite Health", false, function(v) InfiniteHealth = v end)
createToggle("One Hit Kill", false, function(v) OneHitKill = v; if v then applyOneHitKill() end end)
createToggle("Stealth (Invisible)", false, function(v) applyStealth(v) end)
createToggle("Silent Walk", false, function(v) applySilentWalk(v) end)
createToggle("Monster ESP", false, function(v) MonsterESP = v; updateESP() end)
createToggle("Noclip", false, function(v) toggleNoclip(v) end)
createButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
end)

-- === СВОРАЧИВАНИЕ GUI ===
local collapsed = false
local fullSize = UDim2.new(0, 380, 0, 580)
local miniSize = UDim2.new(0, 60, 0, 60)

collapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    local targetSize = collapsed and miniSize or fullSize
    TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
    collapseBtn.Text = collapsed and "+" or "−"
    content.Visible = not collapsed
    title.Visible = not collapsed
end)

-- === ПЕРЕТАСКИВАНИЕ ===
local dragging = false
local dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("Darkteria Hub: Сворачивание + Noclip + Stealth — ГОТОВО!")
