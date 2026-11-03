
local Rayfield = loadstring(game:HttpGet(
    "https://github.com/UnknownDeveloper-sqd/UnknownSquad-RayField-Lib/raw/refs/heads/main/Rayfield/CustomRayfield.luau"
))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

-- SETTINGS
local Settings = {
    PlayerESP = false,
    PlayerName = true,
    PlayerHealth = true,
    PlayerDistance = true,
    PlayerItem = true,

    NPCESP = false,
    NPCAim = false,

    SmoothAim = false,
    VisibilityCheck = true,
    AimPart = "Head",
    Smoothness = 5,
    FOV = 150,
    ShowFOV = true,

    FullBright = false
}

-- GUI
local Window = Rayfield:CreateWindow({
    Name = "FustSurv | SomeCheats",
    LoadingTitle = "FustSurv | SomeCheats",
    LoadingSubtitle = "By: UnknownSquad",
    Theme = "Amethyst",
    Width = 460,
    Height = 360,
    Font = "Code",
    ConfigurationSaving = {Enabled = false},
    KeySystem = false
})

local PvpTab = Window:CreateTab("PVP")
local PveTab = Window:CreateTab("PVE")
local VisualsTab = Window:CreateTab("Visuals")

-- PVP SETTINGS
PvpTab:CreateToggle({
    Name = "SmoothAim",
    CurrentValue = false,
    Callback = function(value)
        Settings.SmoothAim = value
    end
})

PvpTab:CreateToggle({
    Name = "Aim NPC",
    CurrentValue = false,
    Callback = function(value)
        Settings.NPCAim = value

        if value then
            startNPCScan()
        else
            stopNPCScan()
        end
    end
})

PvpTab:CreateToggle({
    Name = "Visibility Check",
    CurrentValue = true,
    Callback = function(value)
        Settings.VisibilityCheck = value
    end
})

PvpTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "Torso", "Legs"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Callback = function(value)
        Settings.AimPart = typeof(value) == "table" and value[1] or value
    end
})

PvpTab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(value)
        Settings.Smoothness = value
    end
})

PvpTab:CreateSlider({
    Name = "FOV",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = 150,
    Callback = function(value)
        Settings.FOV = value
    end
})

PvpTab:CreateToggle({
    Name = "Show FOV",
    CurrentValue = true,
    Callback = function(value)
        Settings.ShowFOV = value
    end
})

-- NPC SCAN
local NPCList = {}
local NPCScanEnabled = false
local NPCConnection

local function isPlayerCharacter(model)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then
            return true
        end
    end

    return false
end

local function registerNPC(model)
    if not model or not model:IsA("Model") then
        return
    end

    if isPlayerCharacter(model) then
        return
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")

    if humanoid and humanoid.Health > 0 then
        NPCList[model] = true
    end
end

local function startNPCScan()
    if NPCScanEnabled then
        return
    end

    NPCScanEnabled = true

    task.spawn(function()
        local descendants = Workspace:GetDescendants()

        for i, obj in ipairs(descendants) do
            if not NPCScanEnabled then
                break
            end

            if obj:IsA("Humanoid") then
                local model = obj.Parent

                if model and model:IsA("Model") then
                    registerNPC(model)
                end
            end

            if i % 250 == 0 then
                task.wait()
            end
        end

        descendants = nil
    end)

    NPCConnection = Workspace.DescendantAdded:Connect(function(obj)
        if not NPCScanEnabled then
            return
        end

        if obj:IsA("Humanoid") then
            local model = obj.Parent

            if model and model:IsA("Model") then
                registerNPC(model)
            end
        end
    end)
end

local function stopNPCScan()
    if Settings.NPCESP or Settings.NPCAim then
        return
    end

    NPCScanEnabled = false

    if NPCConnection then
        NPCConnection:Disconnect()
        NPCConnection = nil
    end
end

-- VISUAL SETTINGS
VisualsTab:CreateToggle({
    Name = "PlayerESP",
    CurrentValue = false,
    Callback = function(value)
        Settings.PlayerESP = value
    end
})

VisualsTab:CreateToggle({
    Name = "PlayerName",
    CurrentValue = true,
    Callback = function(value)
        Settings.PlayerName = value
    end
})

VisualsTab:CreateToggle({
    Name = "PlayerHealth",
    CurrentValue = true,
    Callback = function(value)
        Settings.PlayerHealth = value
    end
})

VisualsTab:CreateToggle({
    Name = "PlayerDistance",
    CurrentValue = true,
    Callback = function(value)
        Settings.PlayerDistance = value
    end
})

VisualsTab:CreateToggle({
    Name = "PlayerItem",
    CurrentValue = true,
    Callback = function(value)
        Settings.PlayerItem = value
    end
})

-- FULLBRIGHT
local OriginalLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

local function setFullBright(value)
    Settings.FullBright = value

    if value then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.FogEnd = OriginalLighting.FogEnd
        Lighting.GlobalShadows = OriginalLighting.GlobalShadows
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
    end
end

VisualsTab:CreateToggle({
    Name = "FullBright",
    CurrentValue = false,
    Callback = setFullBright
})

-- FOV CIRCLE
local FOVCircle

pcall(function()
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1.5
        FOVCircle.NumSides = 60
        FOVCircle.Filled = false
        FOVCircle.Color = Color3.fromRGB(180, 100, 255)
        FOVCircle.Transparency = 1
    end
end)

-- AIM
local RightMouseDown = false
local CachedTarget = nil
local LastAimUpdate = 0
local AIM_UPDATE_INTERVAL = 0.05

local RaycastParamsCache = RaycastParams.new()
RaycastParamsCache.FilterType = Enum.RaycastFilterType.Exclude
RaycastParamsCache.IgnoreWater = true

local function getAimPart(character)
    if not character then
        return nil
    end

    if Settings.AimPart == "Head" then
        return character:FindFirstChild("Head")

    elseif Settings.AimPart == "Torso" then
        return character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
            or character:FindFirstChild("HumanoidRootPart")

    elseif Settings.AimPart == "Legs" then
        return character:FindFirstChild("LeftLowerLeg")
            or character:FindFirstChild("Left Leg")
            or character:FindFirstChild("RightLowerLeg")
            or character:FindFirstChild("Right Leg")
    end

    return character:FindFirstChild("Head")
end

local function isVisible(character, targetPosition)
    if not Settings.VisibilityCheck then
        return true
    end

    local origin = Camera.CFrame.Position
    local direction = targetPosition - origin

    RaycastParamsCache.FilterDescendantsInstances = {
        LocalPlayer.Character
    }

    local result = Workspace:Raycast(
        origin,
        direction,
        RaycastParamsCache
    )

    return result == nil
        or result.Instance:IsDescendantOf(character)
end

local function checkTarget(character, shortestDistance, center)
    if not character then
        return nil, shortestDistance
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not humanoid or humanoid.Health <= 0 then
        return nil, shortestDistance
    end

    local targetPart = getAimPart(character)

    if not targetPart then
        return nil, shortestDistance
    end

    local screenPosition, onScreen =
        Camera:WorldToViewportPoint(targetPart.Position)

    if not onScreen or screenPosition.Z <= 0 then
        return nil, shortestDistance
    end

    local screenPoint = Vector2.new(
        screenPosition.X,
        screenPosition.Y
    )

    local distance = (screenPoint - center).Magnitude

    if distance < shortestDistance
        and isVisible(character, targetPart.Position) then

        return targetPart, distance
    end

    return nil, shortestDistance
end

local function getClosestTarget()
    if not Camera then
        return nil
    end

    local viewport = Camera.ViewportSize
    local center = Vector2.new(
        viewport.X / 2,
        viewport.Y / 2
    )

    local closestTarget = nil
    local shortestDistance = Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local target, distance = checkTarget(
                player.Character,
                shortestDistance,
                center
            )

            if target then
                closestTarget = target
                shortestDistance = distance
            end
        end
    end

    if Settings.NPCAim then
        for model in pairs(NPCList) do
            if model and model.Parent and not isPlayerCharacter(model) then
                local target, distance = checkTarget(
                    model,
                    shortestDistance,
                    center
                )

                if target then
                    closestTarget = target
                    shortestDistance = distance
                end
            else
                NPCList[model] = nil
            end
        end
    end

    return closestTarget
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightMouseDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightMouseDown = false
        CachedTarget = nil
    end
end)

-- ESP
local GuiParent

pcall(function()
    if gethui then
        GuiParent = gethui()
    end
end)

if not GuiParent then
    GuiParent = LocalPlayer:WaitForChild("PlayerGui")
end

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESPFolder"
ESPFolder.Parent = GuiParent

local HighlightCache = {}
local InfoCache = {}
local NPCHighlightCache = {}
local NPCInfoCache = {}

local function createHighlight(color)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.OutlineColor = color
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = ESPFolder

    return highlight
end

local function createInfoGui(name, offset)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = name
    billboard.Size = UDim2.fromOffset(160, 48)
    billboard.StudsOffset = Vector3.new(0, offset, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextSize = 10
    label.Font = Enum.Font.Code
    label.TextWrapped = true
    label.Parent = billboard

    return billboard
end

local function removeESP(player)
    if HighlightCache[player] then
        HighlightCache[player]:Destroy()
        HighlightCache[player] = nil
    end

    if InfoCache[player] then
        InfoCache[player]:Destroy()
        InfoCache[player] = nil
    end
end

local function removeNPCESP(model)
    if NPCHighlightCache[model] then
        NPCHighlightCache[model]:Destroy()
        NPCHighlightCache[model] = nil
    end

    if NPCInfoCache[model] then
        NPCInfoCache[model]:Destroy()
        NPCInfoCache[model] = nil
    end
end

-- NPC ESP TOGGLE
-- Размещён после removeNPCESP, чтобы функция удаления уже существовала.
PveTab:CreateToggle({
    Name = "NPC ESP",
    CurrentValue = false,
    Callback = function(value)
        Settings.NPCESP = value

        if value then
            startNPCScan()
        else
            -- Сразу удаляем ESP у всех NPC
            for model in pairs(NPCList) do
                removeNPCESP(model)
            end

            stopNPCScan()
        end
    end
})

local function updatePlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then
            continue
        end

        local character = player.Character
        local humanoid = character
            and character:FindFirstChildOfClass("Humanoid")

        local root = character
            and (character:FindFirstChild("HumanoidRootPart")
            or character:FindFirstChild("Head"))

        if not Settings.PlayerESP then
            if HighlightCache[player] then
                HighlightCache[player].Enabled = false
            end

            if InfoCache[player] then
                InfoCache[player].Enabled = false
            end

            continue
        end

        if not character or not humanoid
            or humanoid.Health <= 0 or not root then

            if HighlightCache[player] then
                HighlightCache[player].Adornee = nil
            end

            if InfoCache[player] then
                InfoCache[player].Adornee = nil
                InfoCache[player].Enabled = false
            end

            continue
        end

        local highlight = HighlightCache[player]

        if not highlight then
            highlight = createHighlight(Color3.fromRGB(255, 255, 255))
            HighlightCache[player] = highlight
        end

        highlight.Adornee = character
        highlight.Enabled = true

        local billboard = InfoCache[player]

        if not billboard then
            billboard = createInfoGui("PlayerInfo", -3)
            InfoCache[player] = billboard
        end

        billboard.Adornee = root

        local lines = {}

        if Settings.PlayerName then
            table.insert(lines, player.Name)
        end

        if Settings.PlayerHealth then
            table.insert(lines, string.format(
                "HP: %d / %d",
                math.floor(humanoid.Health),
                math.floor(humanoid.MaxHealth)
            ))
        end

        if Settings.PlayerDistance then
            local localCharacter = LocalPlayer.Character
            local localRoot = localCharacter
                and localCharacter:FindFirstChild("HumanoidRootPart")

            if localRoot then
                local distance =
                    (localRoot.Position - root.Position).Magnitude

                table.insert(lines, string.format(
                    "DIST: %d m",
                    math.floor(distance)
                ))
            end
        end

        if Settings.PlayerItem then
            local tool = character:FindFirstChildOfClass("Tool")

            if tool then
                table.insert(lines, tool.Name)
            end
        end

        local label = billboard:FindFirstChild("Info")

        if label then
            local newText = table.concat(lines, "\n")

            if label.Text ~= newText then
                label.Text = newText
            end
        end

        billboard.Enabled = #lines > 0
    end
end

local function updateNPCESP()
    for model in pairs(NPCList) do
        if not model or not model.Parent then
            removeNPCESP(model)
            NPCList[model] = nil
            continue
        end

        local humanoid = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("Head")

        if not Settings.NPCESP then
            removeNPCESP(model)
            continue
        end

        if not humanoid or humanoid.Health <= 0 or not root then
            if NPCHighlightCache[model] then
                NPCHighlightCache[model].Adornee = nil
            end

            if NPCInfoCache[model] then
                NPCInfoCache[model].Adornee = nil
                NPCInfoCache[model].Enabled = false
            end

            continue
        end

        local highlight = NPCHighlightCache[model]

        if not highlight then
            highlight = createHighlight(Color3.fromRGB(255, 140, 50))
            NPCHighlightCache[model] = highlight
        end

        highlight.Adornee = model
        highlight.Enabled = true

        local billboard = NPCInfoCache[model]

        if not billboard then
            billboard = createInfoGui("NPCInfo", -3)
            NPCInfoCache[model] = billboard
        end

        billboard.Adornee = root

        local lines = {
            model.Name,
            string.format(
                "HP: %d / %d",
                math.floor(humanoid.Health),
                math.floor(humanoid.MaxHealth)
            )
        }

        local localCharacter = LocalPlayer.Character
        local localRoot = localCharacter
            and localCharacter:FindFirstChild("HumanoidRootPart")

        if localRoot then
            local distance =
                (localRoot.Position - root.Position).Magnitude

            table.insert(lines, string.format(
                "DIST: %d m",
                math.floor(distance)
            ))
        end

        local label = billboard:FindFirstChild("Info")

        if label then
            local newText = table.concat(lines, "\n")

            if label.Text ~= newText then
                label.Text = newText
            end
        end

        billboard.Enabled = true
    end
end

Players.PlayerRemoving:Connect(removeESP)

Workspace.DescendantRemoving:Connect(function(obj)
    if obj:IsA("Model") and NPCList[obj] then
        removeNPCESP(obj)
        NPCList[obj] = nil
    end
end)

-- MAIN LOOP
local ESP_UPDATE_INTERVAL = 0.35
local lastESPUpdate = 0

RunService.RenderStepped:Connect(function()
    if not Camera then
        return
    end

    if FOVCircle then
        local viewport = Camera.ViewportSize

        FOVCircle.Position = Vector2.new(
            viewport.X / 2,
            viewport.Y / 2
        )

        FOVCircle.Radius = Settings.FOV
        FOVCircle.Visible = Settings.ShowFOV
            and Settings.SmoothAim
    end

    if Settings.SmoothAim and RightMouseDown then
        local now = os.clock()

        if now - LastAimUpdate >= AIM_UPDATE_INTERVAL then
            LastAimUpdate = now
            CachedTarget = getClosestTarget()
        end

        local target = CachedTarget

        if target and target.Parent then
            local smoothness = math.clamp(Settings.Smoothness, 1, 10)
            local alpha = 1 / smoothness

            local targetCFrame = CFrame.lookAt(
                Camera.CFrame.Position,
                target.Position
            )

            Camera.CFrame = Camera.CFrame:Lerp(
                targetCFrame,
                alpha
            )
        else
            CachedTarget = nil
        end
    else
        CachedTarget = nil
    end

    local now = os.clock()

    if now - lastESPUpdate >= ESP_UPDATE_INTERVAL then
        lastESPUpdate = now

        updatePlayerESP()

        if Settings.NPCESP then
            updateNPCESP()
        end
    end
end)

-- MOBILE UI
if UserInputService.TouchEnabled then
    local toggleGui = Instance.new("ScreenGui")
    toggleGui.Name = "MobileToggleGui"
    toggleGui.ResetOnSpawn = false
    toggleGui.Parent = GuiParent

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleUI"
    toggleBtn.Size = UDim2.fromOffset(45, 45)
    toggleBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Text = "UI"
    toggleBtn.TextSize = 16
    toggleBtn.Font = Enum.Font.Code
    toggleBtn.Parent = toggleGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toggleBtn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(150, 90, 220)
    stroke.Thickness = 1.5
    stroke.Parent = toggleBtn

    toggleBtn.Activated:Connect(function()
        for _, gui in ipairs(GuiParent:GetChildren()) do
            if gui:IsA("ScreenGui") and gui ~= toggleGui then
                gui.Enabled = not gui.Enabled
            end
        end
    end)
end
