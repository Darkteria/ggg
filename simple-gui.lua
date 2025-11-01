local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local texts = {}
local textVisible = false
local moneyTextVisible = false
local lightingChangeActive = false
local gefFolder = Workspace:FindFirstChild("GEFs")
local moneyFolder = Workspace:FindFirstChild("Pickups")
local miniGefTextColor = Color3.new(1, 1, 0)
local moneyTextColor = Color3.new(0, 1, 0)

local hurtboxRemovalStarted = false

-- === УТИЛИТЫ ===
local function startHurtboxRemoval()
    if hurtboxRemovalStarted then return end
    hurtboxRemovalStarted = true
    spawn(function()
        while true do
            if gefFolder then
                for _, gef in pairs(gefFolder:GetChildren()) do
                    if gef:IsA("Model") then
                        for _, child in pairs(gef:GetChildren()) do
                            if child.Name == "Hurtbox" then
                                child:Destroy()
                            end
                        end
                    end
                end
            end
            task.wait(1)
        end
    end)
end

local function setToolDamage(toolName, damage)
    for _, player in pairs(Players:GetPlayers()) do
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, item in pairs(backpack:GetChildren()) do
                if item.Name == toolName then
                    local damageValue = item:FindFirstChild("Damage")
                    if not damageValue then
                        damageValue = Instance.new("NumberValue")
                        damageValue.Name = "Damage"
                        damageValue.Parent = item
                    end
                    damageValue.Value = damage
                end
            end
        end
    end
end

local function addTextToObject(obj, labelText, color)
    local adorneePart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
    if adorneePart and not texts[obj] then
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = adorneePart
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = obj

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextColor3 = color
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.Parent = billboard

        texts[obj] = billboard
    end
end

local function removeTextFromObject(obj)
    if texts[obj] then
        texts[obj]:Destroy()
        texts[obj] = nil
    end
end

local function toggleTextGEFs()
    textVisible = not textVisible
    if textVisible then
        if gefFolder then
            for _, gef in pairs(gefFolder:GetChildren()) do
                if gef:IsA("Model") then
                    addTextToObject(gef, "Mini GEF", miniGefTextColor)
                end
            end
        end
        local gef = Workspace:FindFirstChild("GEF")
        if gef and gef:IsA("Model") then
            addTextToObject(gef, "GEF", Color3.new(1, 0, 0))
        end
    else
        for obj, gui in pairs(texts) do
            if gui:FindFirstChild("TextLabel") and (gui.TextLabel.Text == "Mini GEF" or gui.TextLabel.Text == "GEF") then
                removeTextFromObject(obj)
            end
        end
    end
end

local function toggleTextMoney()
    moneyTextVisible = not moneyTextVisible
    if moneyTextVisible and moneyFolder then
        for _, money in pairs(moneyFolder:GetChildren()) do
            if money.Name == "Money" then
                addTextToObject(money, "Money", moneyTextColor)
            end
        end
    else
        for obj, gui in pairs(texts) do
            if gui:FindFirstChild("TextLabel") and gui.TextLabel.Text == "Money" then
                removeTextFromObject(obj)
            end
        end
    end
end

local function autoAddTextToNewObjects()
    while true do
        task.wait(1)
        if textVisible and gefFolder then
            for _, gef in pairs(gefFolder:GetChildren()) do
                if gef:IsA("Model") and not texts[gef] then
                    addTextToObject(gef, "Mini GEF", miniGefTextColor)
                end
            end
            local gef = Workspace:FindFirstChild("GEF")
            if gef and gef:IsA("Model") and not texts[gef] then
                addTextToObject(gef, "GEF", Color3.new(1, 0, 0))
            end
        end
        if moneyTextVisible and moneyFolder then
            for _, money in pairs(moneyFolder:GetChildren()) do
                if money.Name == "Money" and not texts[money] then
                    addTextToObject(money, "Money", moneyTextColor)
                end
            end
        end
    end
end

spawn(autoAddTextToNewObjects)

local function toggleLightingChange()
    lightingChangeActive = not lightingChangeActive
    if lightingChangeActive then
        spawn(function()
            while lightingChangeActive do
                Lighting.Ambient = Color3.fromRGB(84, 84, 84)
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 1000
                Lighting.FogStart = 0
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                task.wait(3)
            end
        end)
    end
end

local function getNearestMiniGEF(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil, nil end
    local root = character.HumanoidRootPart
    local closest, minDist = nil, math.huge
    if gefFolder then
        for _, gef in pairs(gefFolder:GetChildren()) do
            if gef:IsA("Model") and gef.PrimaryPart then
                local dist = (gef.PrimaryPart.Position - root.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = gef
                end
            end
        end
    end
    return closest, minDist
end

-- === СОЗДАНИЕ GUI ДЛЯ ИГРОКА ===
local function createGUIForPlayer(player)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GEFGUI_Collapsible"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    -- Главный контейнер
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 500, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -300)
    mainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    mainFrame.BorderSizePixel = 2
    mainFrame.BorderColor3 = Color3.new(0.3, 0.3, 0.3)
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui

    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 0, 50)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.Text = "Simple GEF GUI"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.BackgroundTransparency = 1
    title.Parent = mainFrame

    local author = Instance.new("TextLabel")
    author.Size = UDim2.new(0, 150, 0, 30)
    author.Position = UDim2.new(0, 20, 0, 50)
    author.Text = "by Gabriel"
    author.TextColor3 = Color3.new(0.7, 0.7, 0.7)
    author.Font = Enum.Font.Gotham
    author.BackgroundTransparency = 1
    author.Parent = mainFrame

    -- Кнопка сворачивания
    local collapseBtn = Instance.new("TextButton")
    collapseBtn.Size = UDim2.new(0, 40, 0, 40)
    collapseBtn.Position = UDim2.new(1, -50, 0, 5)
    collapseBtn.Text = "−"
    collapseBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    collapseBtn.TextColor3 = Color3.new(1, 1, 1)
    collapseBtn.Font = Enum.Font.GothamBold
    collapseBtn.Parent = mainFrame

    -- Свернутая кнопка
    local collapsedBtn = Instance.new("TextButton")
    collapsedBtn.Size = UDim2.new(0, 60, 0, 60)
    collapsedBtn.Position = UDim2.new(0.5, -30, 0.1, 0)
    collapsedBtn.Text = "☰\nMenu"
    collapsedBtn.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    collapsedBtn.TextColor3 = Color3.new(1, 1, 1)
    collapsedBtn.Font = Enum.Font.GothamBold
    collapsedBtn.Visible = false
    collapsedBtn.Parent = screenGui

    -- Контент
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -90)
    contentFrame.Position = UDim2.new(0, 10, 0, 80)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame

    local uiList = Instance.new("UIListLayout")
    uiList.Padding = UDim.new(0, 8)
    uiList.Parent = contentFrame

    -- === КНОПКИ ===
    local function createBtn(text, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = text
        btn.Font = Enum.Font.Gotham
        btn.Parent = contentFrame
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0, 30)
    distanceLabel.BackgroundColor3 = Color3.new(0.15, 0.15, 0.15)
    distanceLabel.Text = "Distance: ..."
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.Parent = contentFrame

    createBtn("Teleport to Nearest GEF", function()
        local gef, _ = getNearestMiniGEF(player)
        if gef and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = gef.PrimaryPart.CFrame
        end
    end)

    local noDmgBtn = createBtn("No Damage", function()
        startHurtboxRemoval()
        noDmgBtn.Text = "No Damage (ON)"
        noDmgBtn.TextColor3 = Color3.new(0, 1, 0)
    end)

    createBtn("Infinity Crowbar Damage", function() spawn(function() setToolDamage("Crowbar", 1000) end) end)
    createBtn("Infinity Bat Damage", function() spawn(function() setToolDamage("Bat", 1000) end) end)

    local gefEspBtn = createBtn("GEFs ESP", function()
        toggleTextGEFs()
        gefEspBtn.Text = textVisible and "GEFs ESP (ON)" or "GEFs ESP"
    end)

    local moneyEspBtn = createBtn("Money ESP", function()
        toggleTextMoney()
        moneyEspBtn.Text = moneyTextVisible and "Money ESP (ON)" or "Money ESP"
    end)

    local lightBtn = createBtn("Day Light", function()
        toggleLightingChange()
        lightBtn.Text = lightingChangeActive and "Day Light (ON)" or "Day Light"
    end)

    -- Телепорт к предметам
    local items = {
        "Shotgun", "Handgun", "Hammer", "Lantern", "Shells",
        "Soda", "Money", "Crowbar", "Food", "Bat", "Medkit", "GPS", "Bullets"
    }
    for _, itemName in ipairs(items) do
        createBtn("Teleport to " .. itemName, function()
            local folder = itemName == "Money" and moneyFolder or Workspace:FindFirstChild("Pickups")
            local item = folder and folder:FindFirstChild(itemName)
            if item and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = item.CFrame
            end
        end)
    end

    -- === СВОРАЧИВАНИЕ ===
    local isCollapsed = false
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local function collapse()
        isCollapsed = true
        collapseBtn.Text = "+"
        local tween = TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 60, 0, 60)})
        tween:Play()
        tween.Completed:Connect(function()
            mainFrame.Visible = false
            collapsedBtn.Visible = true
        end)
    end

    local function expand()
        isCollapsed = false
        mainFrame.Visible = true
        collapsedBtn.Visible = false
        local tween = TweenService:Create(mainFrame, tweenInfo, {Size = UDim2.new(0, 500, 0, 600)})
        tween:Play()
        collapseBtn.Text = "−"
    end

    collapseBtn.MouseButton1Click:Connect(function()
        if isCollapsed then expand() else collapse() end
    end)

    collapsedBtn.MouseButton1Click:Connect(expand)

    -- === ОБНОВЛЕНИЕ РАССТОЯНИЯ ===
    spawn(function()
        while screenGui.Parent do
            local _, dist = getNearestMiniGEF(player)
            distanceLabel.Text = dist and string.format("Nearest GEF: %.1f m", dist) or "Nearest GEF: Not found"
            task.wait(1)
        end
    end)
end

-- Подключение игроков
Players.PlayerAdded:Connect(createGUIForPlayer)
for _, player in pairs(Players:GetPlayers()) do
    task.spawn(createGUIForPlayer, player)
end
