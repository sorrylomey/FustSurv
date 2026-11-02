local Rayfield = loadstring(game:HttpGet(
    "https://github.com/UnknownDeveloper-sqd/UnknownSquad-RayField-Lib/raw/refs/heads/main/Rayfield/CustomRayfield.luau"
))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local CollectionService = game:GetService("CollectionService")

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

-- PVE SETTINGS
PveTab:CreateToggle({
    Name = "NPC ESP",
    CurrentValue = false,
    Callback = function(value)
        Settings.NPCESP = value
    end
})

-- VISUAL SETTINGS
VisualsTab:CreateToggle({
    Name = "PlayerESP",
    CurrentValue = false,
    Callback = function(value)
        Settings.PlayerESP = value
    end
})

VisualsTab:CreateToggle({
    Name = "Username",
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
    Name = "Player Item",
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

local function setFullBright(enabled)
    Settings.FullBright = enabled

    if enabled then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        for property, value in pairs(OriginalLighting) do
            Lighting[property] = value
        end
    end
end

VisualsTab:CreateToggle({
    Name = "FullBright (Night to Day)",
    CurrentValue = false,
    Callback = setFullBright
})

-- FOV CIRCLE
local FOVCircle

pcall(function()
    if Drawing then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Thickness = 1.5
        FOVCircle.NumSides = 80
        FOVCircle.Filled = false
        FOVCircle.Color = Color3.fromRGB(180, 100, 255)
        FOVCircle.Transparency = 1
    end
end)

-- AIM PART
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

-- VISIBILITY CHECK
local RaycastParamsCache = RaycastParams.new()
RaycastParamsCache.FilterType = Enum.RaycastFilterType.Exclude
RaycastParamsCache.IgnoreWater = true

local function isVisible(character, targetPosition)
    if not Settings.VisibilityCheck then
        return true
    end

    RaycastParamsCache.FilterDescendantsInstances = {
        LocalPlayer.Character
    }

    local origin = Camera.CFrame.Position
    local direction = targetPosition - origin

    local result = Workspace:Raycast(
        origin,
        direction,
        RaycastParamsCache
    )

    return result == nil or result.Instance:IsDescendantOf(character)
end

-- NPC CACHE
local NPCList = {}

local function getNPCs()
    local npcList = {}
    local added = {}

    local function addNPC(model)
        if not model or not model:IsA("Model") then
            return
        end

        if added[model] then
            return
        end

        if Players:GetPlayerFromCharacter(model) then
            return
        end

        local humanoid = model:FindFirstChildOfClass("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("Head")

        if humanoid and root and humanoid.Health > 0 then
            added[model] = true
            table.insert(npcList, model)
        end
    end

    for _, folderName in ipairs({
        "Npcs", "NPCs", "NPC", "Enemies"
    }) do
        local folder = Workspace:FindFirstChild(folderName)

        if folder then
            for _, object in ipairs(folder:GetDescendants()) do
                if object:IsA("Model") then
                    addNPC(object)
                end
            end
        end
    end

    for _, tag in ipairs({
        "FustNpc", "FustDino", "NPC"
    }) do
        for _, object in ipairs(CollectionService:GetTagged(tag)) do
            if object:IsA("Model") then
                addNPC(object)
            end
        end
    end

    for _, object in ipairs(Workspace:GetDescendants()) do
        if object:IsA("Model") then
            addNPC(object)
        end
    end

    return npcList
end

-- NPC CACHE UPDATE
task.spawn(function()
    while task.wait(1) do
        NPCList = getNPCs()
    end
end)

-- CLOSEST TARGET
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

    -- PLAYER TARGETS
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character
                and character:FindFirstChildOfClass("Humanoid")

            local targetPart = getAimPart(character)

            if humanoid and humanoid.Health > 0 and targetPart then
                local screenPosition, onScreen =
                    Camera:WorldToViewportPoint(targetPart.Position)

                if onScreen and screenPosition.Z > 0 then
                    local screenPoint = Vector2.new(
                        screenPosition.X,
                        screenPosition.Y
                    )

                    local distance = (screenPoint - center).Magnitude

                    if distance < shortestDistance
                        and isVisible(character, targetPart.Position) then

                        shortestDistance = distance
                        closestTarget = targetPart
                    end
                end
            end
        end
    end

    -- NPC TARGETS
    if Settings.NPCAim then
        for _, npc in ipairs(NPCList) do
            if npc.Parent then
                local humanoid = npc:FindFirstChildOfClass("Humanoid")
                local targetPart = getAimPart(npc)

                if humanoid and humanoid.Health > 0 and targetPart then
                    local screenPosition, onScreen =
                        Camera:WorldToViewportPoint(targetPart.Position)

                    if onScreen and screenPosition.Z > 0 then
                        local screenPoint = Vector2.new(
                            screenPosition.X,
                            screenPosition.Y
                        )

                        local distance = (screenPoint - center).Magnitude

                        if distance < shortestDistance
                            and isVisible(npc, targetPart.Position) then

                            shortestDistance = distance
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end
    end

    return closestTarget
end

-- RIGHT MOUSE BUTTON
local RightMouseDown = false

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightMouseDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        RightMouseDown = false
    end
end)

-- ESP PARENT
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

-- PLAYER ESP CACHE
local HighlightCache = {}
local InfoCache = {}

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

-- PLAYER INFO GUI
local function createInfoGui(player)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerInfo"

    billboard.Size = UDim2.fromOffset(160, 42)

    -- Text below player
    billboard.StudsOffset = Vector3.new(0, -3, 0)

    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Name = "Info"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.35

    -- Smaller text
    label.TextSize = 10

    label.Font = Enum.Font.Gotham
    label.TextWrapped = true
    label.Parent = billboard

    InfoCache[player] = billboard

    return billboard
end

-- PLAYER ESP UPDATE
local function updatePlayerESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local character = player.Character

            local humanoid = character
                and character:FindFirstChildOfClass("Humanoid")

            local root = character
                and (
                    character:FindFirstChild("HumanoidRootPart")
                    or character:FindFirstChild("Head")
                )

            if Settings.PlayerESP and character
                and humanoid and humanoid.Health > 0 and root then

                local highlight = HighlightCache[player]

                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "PlayerHighlight"
                    highlight.FillTransparency = 1
                    highlight.OutlineTransparency = 0
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = ESPFolder

                    HighlightCache[player] = highlight
                end

                highlight.Adornee = character
                highlight.Enabled = true

                local billboard = InfoCache[player]

                if not billboard then
                    billboard = createInfoGui(player)
                end

                local label = billboard:FindFirstChild("Info")
                billboard.Adornee = root

                local lines = {}

                -- REAL USERNAME
                if Settings.PlayerName then
                    table.insert(lines, player.Name)
                end

                -- SMALL HP
                if Settings.PlayerHealth then
                    table.insert(lines, string.format(
                        "HP: %d/%d",
                        math.floor(humanoid.Health),
                        math.floor(humanoid.MaxHealth)
                    ))
                end

                -- SMALL DISTANCE
                if Settings.PlayerDistance then
                    local localCharacter = LocalPlayer.Character

                    local localRoot = localCharacter
                        and localCharacter:FindFirstChild("HumanoidRootPart")

                    if localRoot then
                        local distance =
                            (localRoot.Position - root.Position).Magnitude

                        table.insert(lines, string.format(
                            "%dm",
                            math.floor(distance)
                        ))
                    end
                end

                -- PLAYER ITEM
                if Settings.PlayerItem then
                    local tool = character:FindFirstChildOfClass("Tool")

                    if tool then
                        table.insert(lines, tool.Name)
                    end
                end

                if label then
                    label.Text = table.concat(lines, " | ")
                end

                billboard.Enabled = #lines > 0

            else
                removeESP(player)
            end
        end
    end
end

Players.PlayerRemoving:Connect(removeESP)

-- NPC ESP CACHE
local NPCHighlightCache = {}

-- SEPARATE NPC ESP FUNCTION
local function updateNPCESP()
    local foundNPCs = {}

    for _, npc in ipairs(NPCList) do
        if npc.Parent then
            foundNPCs[npc] = true

            local humanoid = npc:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 then
                local highlight = NPCHighlightCache[npc]

                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "NPC_Highlight"
                    highlight.FillTransparency = 1
                    highlight.OutlineTransparency = 0
                    highlight.OutlineColor = Color3.fromRGB(255, 140, 0)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = ESPFolder

                    NPCHighlightCache[npc] = highlight
                end

                highlight.Adornee = npc
                highlight.Enabled = Settings.NPCESP
            end
        end
    end

    for npc, highlight in pairs(NPCHighlightCache) do
        if not foundNPCs[npc] or not npc.Parent then
            highlight:Destroy()
            NPCHighlightCache[npc] = nil
        end
    end
end

-- ESP UPDATE LOOP
task.spawn(function()
    while task.wait(0.2) do
        updatePlayerESP()
        updateNPCESP()
    end
end)

-- MAIN RENDER LOOP
RunService.RenderStepped:Connect(function()
    if not Camera then
        return
    end

    -- FOV CIRCLE
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

    -- SMOOTH AIM
    if not Settings.SmoothAim or not RightMouseDown then
        return
    end

    local target = getClosestTarget()

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
    end
end)

-- MOBILE UI BUTTON
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

Rayfield:Notify({
    Title = "FustSurv",
    Content = "Script loaded successfully!",
    Duration = 4
})
