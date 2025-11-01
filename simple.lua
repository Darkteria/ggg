-- [ Darkteria ] Infinite Health + One Hit Kill + Stealth + Mobile GUI
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
        if handle and not handle:FindFirstChild("OneHitConnection") then
            local conn
            conn = handle.Touched:Connect(function(hit)
                if OneHitKill and conn.Connected then
                    local enemyHum = hit.Parent:FindFirstChildOfClass("Humanoid")
                    if enemyHum and enemyHum ~= humanoid then
                        enemyHum:TakeDamage(999999)
                    end
                end
            end)
            conn.Name = "OneHitConnection"
        end
    end
end

-- === НЕВИДИМОСТЬ (Stealth Mode) ===
local function applyStealth()
    if not StealthMode then return end

    -- 1. Убираем ProximityPrompt (монстры не видят)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("ProximityPrompt") then
            part.Enabled = false
        end
    end

    -- 2. Отключаем коллизии с монстрами
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.Massless = true
        end
    end

    -- 3. Убираем имя над головой (если есть)
    local head = character:FindFirstChild("Head")
    if head then
        local nameTag = head:FindFirstChildWhichIsA("BillboardGui")
        if nameTag then nameTag:Destroy() end
    end

    -- 4. Отключаем AI Detection (если есть скрипты монстров)
    pcall(function()
        for _, monster in ipairs(Workspace:GetDescendants()) do
            if monster:IsA("Model") and monster:FindFirstChild("Humanoid") then
                local ai = monster:FindFirstChild("AI") or monster:FindFirstChild("Behavior")
                if ai then ai:Destroy() end
            end
        end
    end)
end

-- === НЕСЛЫШИМОСТЬ (Silent Walk) ===
local function applySilentWalk()
    if not SilentWalk then return end

    -- 1. Удаляем звуки шагов
    for _, sound in ipairs(character:GetDescendants()) do
        if sound:IsA("Sound") and (string.find(sound.Name, "Foot") or string.find(sound.Name, "Step")) then
            sound.Volume = 0
            sound.PlayOnRemove = false
            sound:Destroy()
        end
    end

    -- 2. Блокируем создание новых звуков
    character.DescendantAdded:Connect(function(obj)
        if SilentWalk and obj:IsA("Sound") and (string.find(obj.Name, "Foot") or string.find(obj.Name, "Step")) then
            task.defer(function() obj:Destroy() end)
        end
    end)

    -- 3. Отключаем анимацию шагов (если есть)
    if humanoid then
        humanoid:FindFirstChildOfClass("Animator"):Destroy()
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://0"
        humanoid:LoadAnimation(anim)
    end
end

-- === ПРИМЕНЕНИЕ ПРИ РЕСПАВНЕ ===
local function onCharacterAdded(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")

    task.wait(1)
    if InfiniteHealth then humanoid.Health = humanoid.MaxHealth end
    if OneHitKill then applyOneHitKill() end
    if StealthMode then applyStealth() end
    if SilentWalk then applySilentWalk() end
end

player.CharacterAdded:Connect(onCharacterAdded)
player.Backpack.ChildAdded:Connect(applyOneHitKill)

-- === GUI СОЗДАНИЕ ===
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DarkteriaHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 420)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -210)
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

-- Сворачивание
local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 40, 0, 40)
collapseBtn.Position = UDim2.new(1, -45, 0, 5)
collapseBtn.Text = "−"
collapseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
collapseBtn.TextColor3 = Color3.new(1, 1, 1)
collapseBtn.Parent = mainFrame

-- Контент
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -70)
content.Position = UDim2.new(0, 10, 0, 60)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 6
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

-- === КНОПКА ===
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

-- === КНОПКИ В GUI ===
createToggle("Infinite Health", false, function(v) InfiniteHealth = v end)
createToggle("One Hit Kill", false, function(v)
    OneHitKill = v
    if v then applyOneHitKill() end
end)
createToggle("Stealth (Invisible)", false, function(v)
    StealthMode = v
    if v then applyStealth() end
end)
createToggle("Silent Walk (No Sound)", false, function(v)
    SilentWalk = v
    if v then applySilentWalk() end
end)
createButton("Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
end)

-- === СВОРАЧИВАНИЕ ===
local collapsed = false
collapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    local targetSize = collapsed and UDim2.new(0, 60, 0, 60) or UDim2.new(0, 380, 0, 420)
    TweenService:Create(mainFrame, TweenInfo.new(0.3), {Size = targetSize}):Play()
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

print("Darkteria Hub загружен! Stealth + Silent Walk включены!")
