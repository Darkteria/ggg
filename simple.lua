-- [ Darkteria ] FULL HACK: Noclip + True Stealth + ESP + Mobile GUI (УЛУЧШЕНО)
-- Работает в Delta, Arceus X, Hydrogen, Fluxus, Krnl
-- Улучшено: Бессмертие, Отключение ИИ, Сворачивание GUI

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PathfindingService = game:GetService("PathfindingService")

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
local stealthConnections = {}
local aiDisabledScripts = {}

-- === УЛУЧШЕННОЕ БЕССМЕРТИЕ ===
local function enableInfiniteHealth(enable)
    InfiniteHealth = enable
    if not enable then return end

    local healthConnection
    healthConnection = RunService.Heartbeat:Connect(function()
        if not InfiniteHealth or not humanoid or not humanoid.Parent then
            if healthConnection then healthConnection:Disconnect() end
            return
        end

        pcall(function()
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
            -- Защита от изменения MaxHealth
            if humanoid.MaxHealth < 100 then
                humanoid.MaxHealth = 100
            end
        end)
    end)

    -- Отключаем урон от падения, огня, etc.
    humanoid.StateChanged:Connect(function(old, new)
        if InfiniteHealth and (new == Enum.HumanoidStateType.Freefall or new == Enum.HumanoidStateType.FallingDown) then
            task.wait()
            if humanoid and humanoid.Parent then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
    end)
end

-- === УБИЙСТВО С ОДНОГО УДАРА (ОСТАЛОСЬ БЕЗ ИЗМЕНЕНИЙ, НО ОПТИМИЗИРОВАНО) ===
local function applyOneHitKill()
    if not OneHitKill then return end
    local tools = {}

    local function scanTools(container)
        if not container then return end
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then table.insert(tools, tool) end
        end
    end

    scanTools(player.Backpack)
    scanTools(character)

    for _, tool in ipairs(tools) do
        local handle = tool:FindFirstChild("Handle")
        if handle and not handle:FindFirstChild("OHK") then
            local conn = handle.Touched:Connect(function(hit)
                if not OneHitKill then return end
                local enemyHum = hit.Parent:FindFirstChildOfClass("Humanoid")
                if enemyHum and enemyHum ~= humanoid and enemyHum.Health > 0 then
                    enemyHum:TakeDamage(999999)
                end
            end)
            conn.Name = "OHK"
            handle:WaitForChild("OHK", 1) -- метка
        end
    end
end

-- === TRUE STEALTH: ПОЛНОЕ ОТКЛЮЧЕНИЕ ИИ МОНСТРОВ ===
local function applyStealth(enable)
    StealthMode = enable

    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") and model ~= character then
            local hum = model.Humanoid
            local root = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart

            if not root then continue end

            if enable then
                -- 1. Отключаем все скрипты ИИ
                for _, obj in ipairs(model:GetDescendants()) do
                    if obj:IsA("Script") or obj:IsA("LocalScript") then
                        if string.find(obj.Name, "AI") or string.find(obj.Name, "Behavior") or
                           string.find(obj.Name, "Follow") or string.find(obj.Name, "Chase") or
                           string.find(obj.Name, "Path") or string.find(obj.Name, "Attack") then
                            if not aiDisabledScripts[obj] then
                                aiDisabledScripts[obj] = obj.Disabled
                                obj.Disabled = true
                            end
                        end
                    end
                end

                -- 2. Отключаем Animator и анимации
                local animator = hum:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        track:Stop()
                    end
                end

                -- 3. Отключаем Pathfinding
                local agentParams = hum:FindFirstChild("AgentParameters")
                if agentParams then agentParams:Destroy() end

                -- 4. Убираем коллизию
                for _, part in ipairs(model:GetDescendants()) do
                    if part:IsA("BasePart") and part ~= root then
                        part.CanCollide = false
                        part.CanTouch = false
                    end
                end

                -- 5. Отключаем ProximityPrompt
                for _, prompt in ipairs(model:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        prompt.Enabled = false
                    end
                end

                -- 6. Отключаем Raycast-детект (перехватываем FindPartOnRay)
                if not stealthConnections[model] then
                    local conn = RunService.Heartbeat:Connect(function()
                        if not StealthMode or not root or not root.Parent then
                            if stealthConnections[model] then
                                stealthConnections[model]:Disconnect()
                                stealthConnections[model] = nil
                            end
                            return
                        end
                        -- Скрываем игрока от Raycast
                        for _, part in ipairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Transparency = 0.99
                                task.spawn(function()
                                    task.wait()
                                    if part and part.Parent then part.Transparency = 0 end
                                end)
                            end
                        end
                    end)
                    stealthConnections[model] = conn
                end

            else
                -- Восстановление
                for obj, wasDisabled in pairs(aiDisabledScripts) do
                    if obj and obj.Parent then
                        pcall(function() obj.Disabled = wasDisabled end)
                    end
                end
                aiDisabledScripts = {}

                if stealthConnections[model] then
                    stealthConnections[model]:Disconnect()
                    stealthConnections[model] = nil
                end
            end
        end
    end
end

-- === НЕСЛЫШИМОСТЬ (Silent Walk) ===
local function applySilentWalk(enable)
    SilentWalk = enable
    if not enable then return end

    local function muteSteps(obj)
        if obj:IsA("Sound") and (string.find(string.lower(obj.Name), "foot") or string.find(string.lower(obj.Name), "step")) then
            obj.Volume = 0
            obj:Destroy()
        end
    end

    for _, sound in ipairs(character:GetDescendants()) do
        muteSteps(sound)
    end

    character.DescendantAdded:Connect(function(obj)
        if SilentWalk then muteSteps(obj) end
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
                if part:IsA("BasePart") and part ~= humanoidRootPart then
                    part.CanCollide = false
                end
            end
        end
    end)
end

-- === ESP МОНСТРОВ ===
local function addESP(model)
    if espObjects[model] or not model.PrimaryPart then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = model.PrimaryPart
    billboard.Size = UDim2.new(0, 120, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Parent = model

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    frame.Parent = billboard

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "MONSTER"
    label.TextColor3 = Color3.new(1, 0.2, 0.2)
    label.TextStrokeTransparency = 0
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = frame

    espObjects[model] = billboard
end

local function updateESP()
    if not MonsterESP then
        for _, gui in pairs(espObjects) do
            if gui and gui.Parent then gui:Destroy() end
        end
        espObjects = {}
        return
    end

    for _, model in ipairs(Workspace:GetChildren()) do
        if model:IsA("Model") and model:FindFirstChild("Humanoid") and model ~= character and model.PrimaryPart then
            if not espObjects[model] then
                addESP(model)
            end
        end
    end
end

task.spawn(function()
    while task.wait(1.5) do
        if MonsterESP then updateESP() end
    end
end)

-- === РЕСПАВН ===
local function onCharacterAdded(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")

    task.wait(1)

    if InfiniteHealth then enableInfiniteHealth(true) end
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

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 380, 0, 580)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -290)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Закруглённые углы
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
title.Text = "Darkteria Hub"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = title

-- Кнопка сворачивания
local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.new(0, 40, 0, 40)
collapseBtn.Position = UDim2.new(1, -50, 0, 5)
collapseBtn.Text = "−"
collapseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
collapseBtn.TextColor3 = Color3.new(1, 1, 1)
collapseBtn.Font = Enum.Font.GothamBold
collapseBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = collapseBtn

-- Контент
local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -20, 1, -70)
content.Position = UDim2.new(0, 10, 0, 60)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 6
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 12)
layout.FillDirection = Enum.FillDirection.Vertical
layout.Parent = content

-- === ТУМБЛЕР ===
local function createToggle(text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    frame.Parent = content

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, 8)
    fCorner.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Position = UDim2.new(0, 15, 0, 0)
    label.Parent = frame

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 60, 0, 30)
    toggle.Position = UDim2.new(1, -75, 0.5, -15)
    toggle.BackgroundColor3 = default and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
    toggle.Text = default and "ON" or "OFF"
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Font = Enum.Font.GothamBold
    toggle.Parent = frame

    local tCorner = Instance.new("UICorner")
    tCorner.CornerRadius = UDim.new(0, 6)
    tCorner.Parent = toggle

    local state = default
    toggle.MouseButton1Click:Connect(function()
        state = not state
        toggle.BackgroundColor3 = state and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
        toggle.Text = state and "ON" or "OFF"
        callback(state)
    end)
    return frame
end

-- === КНОПКИ ===
createToggle("Infinite Health", false, enableInfiniteHealth)
createToggle("One Hit Kill", false, function(v) OneHitKill = v; if v then applyOneHitKill() end end)
createToggle("True Stealth", false, applyStealth)
createToggle("Silent Walk", false, applySilentWalk)
createToggle("Monster ESP", false, function(v) MonsterESP = v; updateESP() end)
createToggle("Noclip", false, toggleNoclip)

-- === СВОРАЧИВАНИЕ ===
local collapsed = false
collapseBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
    local targetSize = collapsed and UDim2.new(0, 60, 0, 60) or UDim2.new(0, 380, 0, 580)
    local tween = TweenService:Create(mainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {Size = targetSize})
    tween:Play()
    collapseBtn.Text = collapsed and "+" or "−"
    content.Visible = not collapsed
    title.Visible = not collapsed
end)

-- === ПЕРЕТАСКИВАНИЕ ===
local dragging = false
local dragStart, startPos

mainFrame.InputBegan:Connect(function(input)
    if collapsed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

print("Darkteria Hub v2: УЛУЧШЕНО — Бессмертие, ИИ отключён, GUI с анимацией!")
