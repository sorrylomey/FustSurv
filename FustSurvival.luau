local Rayfield = loadstring(game:HttpGet(
    "https://github.com/UnknownDeveloper-sqd/UnknownSquad-RayField-Lib/raw/refs/heads/main/Rayfield/CustomRayfield.luau"
))()

local Window = Rayfield:CreateWindow({
    Name = "FustSurv | SomeCheats",
    LoadingTitle = "FustSurv | SomeCheats",
    LoadingSubtitle = "By: UnknownSquad",
    Theme = "Amethyst",
    Width = 460,
    Height = 360,
    Font = "Code",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local PvpTab = Window:CreateTab("PVP")
local PveTab = Window:CreateTab("PVE")
local VisualsTab = Window:CreateTab("Visuals")

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local WS = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local lp = Players.LocalPlayer

-- SETTINGS

local Settings = {
    SilentAim = false,
    AutoCross = false,

    SmoothAim = false,
    VisibilityCheck = true,
    AimPart = "Head",
    Smoothness = 5,
    FOV = 150,
    ShowFOV = true,

    NoRecoil = false,
    NoCameraShake = false,

    PlayerESP = false,
    PlayerBoxes = false,
    PlayerName = false,
    PlayerDistance = false,
    PlayerHealth = false,
    NPCESP = false,
    FullBright = false,
    FPSOptimizer = false,

}

-- PVP

PvpTab:CreateToggle({
    Name = "SilentAim",
    CurrentValue = false,
    Callback = function(v)
        Settings.SilentAim = v
    end
})

PvpTab:CreateToggle({
    Name = "SmoothAim",
    CurrentValue = false,
    Callback = function(v)
        Settings.SmoothAim = v
    end
})

PvpTab:CreateToggle({
    Name = "Visibility Check",
    CurrentValue = true,
    Callback = function(v)
        Settings.VisibilityCheck = v
    end
})

PvpTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "Torso", "Legs"},
    CurrentOption = {"Head"},
    MultipleOptions = false,
    Callback = function(v)
        Settings.AimPart = typeof(v) == "table" and v[1] or v
    end
})

PvpTab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = 5,
    Callback = function(v)
        Settings.Smoothness = v
    end
})

PvpTab:CreateSlider({
    Name = "FOV",
    Range = {10, 500},
    Increment = 5,
    CurrentValue = 150,
    Callback = function(v)
        Settings.FOV = v
    end
})

PvpTab:CreateToggle({
    Name = "Show FOV",
    CurrentValue = true,
    Callback = function(v)
        Settings.ShowFOV = v
    end
})

PvpTab:CreateToggle({
    Name = "NoRecoil",
    CurrentValue = false,
    Callback = function(v)
        Settings.NoRecoil = v
    end
})

PvpTab:CreateToggle({
    Name = "No Camera Shake",
    CurrentValue = false,
    Callback = function(v)
        Settings.NoCameraShake = v
    end
})

-- PVE

PveTab:CreateToggle({
    Name = "Auto Run",
    CurrentValue = false,
    Callback = function(v)
        Settings.AutoCross = v
    end
})

-- VISUALS

VisualsTab:CreateToggle({
    Name = "PlayerESP",
    CurrentValue = false,
    Callback = function(v)
        Settings.PlayerESP = v
    end
})

VisualsTab:CreateToggle({
    Name = "Player Boxes",
    CurrentValue = false,
    Callback = function(v)
        Settings.PlayerBoxes = v
    end
})

VisualsTab:CreateToggle({
    Name = "PlayerName",
    CurrentValue = false,
    Callback = function(v)
        Settings.PlayerName = v
    end
})

VisualsTab:CreateToggle({
    Name = "PlayerDistance",
    CurrentValue = false,
    Callback = function(v)
        Settings.PlayerDistance = v
    end
})

VisualsTab:CreateToggle({
    Name = "PlayerHealth",
    CurrentValue = false,
    Callback = function(v)
        Settings.PlayerHealth = v
    end
})

VisualsTab:CreateToggle({
    Name = "NPC ESP",
    CurrentValue = false,
    Callback = function(v)
        Settings.NPCESP = v
    end
})

-- FULLBRIGHT (client-side visual setting; restores original Lighting values)
local fullBrightOriginal = nil

local function setFullBright(enabled)
    Settings.FullBright = enabled

    if enabled then
        if not fullBrightOriginal then
            fullBrightOriginal = {
                Brightness = Lighting.Brightness,
                Ambient = Lighting.Ambient,
                OutdoorAmbient = Lighting.OutdoorAmbient,
                ColorShift_Top = Lighting.ColorShift_Top,
                ColorShift_Bottom = Lighting.ColorShift_Bottom,
                ExposureCompensation = Lighting.ExposureCompensation,
                GlobalShadows = Lighting.GlobalShadows
            }
        end

        Lighting.Brightness = 3
        Lighting.Ambient = Color3.fromRGB(190, 190, 190)
        Lighting.OutdoorAmbient = Color3.fromRGB(190, 190, 190)
        Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
        Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
        Lighting.ExposureCompensation = 0.5
        Lighting.GlobalShadows = false
    elseif fullBrightOriginal then
        for property, value in pairs(fullBrightOriginal) do
            pcall(function()
                Lighting[property] = value
            end)
        end
        fullBrightOriginal = nil
    end
end

VisualsTab:CreateToggle({
    Name = "FullBright",
    CurrentValue = false,
    Callback = setFullBright
})

-- FPS OPTIMIZER (disables costly local visual effects; does not alter gameplay scripts)
local optimizerOriginal = {}
local optimizerConnections = {}
local terrainOriginal = nil

local function optimizeInstance(instance)
    if not instance or not instance.Parent then return end

    local property
    if instance:IsA("ParticleEmitter") or instance:IsA("Trail")
        or instance:IsA("Beam") or instance:IsA("Smoke")
        or instance:IsA("Fire") or instance:IsA("Sparkles")
        or instance:IsA("PostEffect") then
        property = "Enabled"
    elseif instance:IsA("BasePart") then
        property = "CastShadow"
    end

    if property then
        local key = instance
        if not optimizerOriginal[key] then
            local ok, oldValue = pcall(function()
                return instance[property]
            end)
            if ok then
                optimizerOriginal[key] = {Property = property, Value = oldValue}
            end
        end
        pcall(function()
            instance[property] = false
        end)
    end
end

local function setFPSOptimizer(enabled)
    Settings.FPSOptimizer = enabled

    if enabled then
        if WS.Terrain and not terrainOriginal then
            terrainOriginal = {
                Decoration = WS.Terrain.Decoration,
                WaterWaveSize = WS.Terrain.WaterWaveSize,
                WaterWaveSpeed = WS.Terrain.WaterWaveSpeed,
                WaterReflectance = WS.Terrain.WaterReflectance
            }
            pcall(function() WS.Terrain.Decoration = false end)
            pcall(function() WS.Terrain.WaterWaveSize = 0 end)
            pcall(function() WS.Terrain.WaterWaveSpeed = 0 end)
            pcall(function() WS.Terrain.WaterReflectance = 0 end)
        end

        for _, instance in ipairs(game:GetDescendants()) do
            optimizeInstance(instance)
        end

        if not optimizerConnections.DescendantAdded then
            optimizerConnections.DescendantAdded = game.DescendantAdded:Connect(function(instance)
                if Settings.FPSOptimizer then
                    optimizeInstance(instance)
                end
            end)
        end
    else
        if optimizerConnections.DescendantAdded then
            optimizerConnections.DescendantAdded:Disconnect()
            optimizerConnections.DescendantAdded = nil
        end

        for instance, data in pairs(optimizerOriginal) do
            if instance and instance.Parent then
                pcall(function()
                    instance[data.Property] = data.Value
                end)
            end
        end
        table.clear(optimizerOriginal)

        if terrainOriginal and WS.Terrain then
            for property, value in pairs(terrainOriginal) do
                pcall(function() WS.Terrain[property] = value end)
            end
            terrainOriginal = nil
        end
    end
end

VisualsTab:CreateToggle({
    Name = "FPS Optimizer",
    CurrentValue = false,
    Callback = setFPSOptimizer
})

-- SMOOTH AIM + PLAYER ESP
-- Intended for development/testing in your own Roblox experience.
-- Aim assist is active only while the right mouse button is held.

local aimConnection
local espObjects = {}

local function findNamedBodyPart(character, names)
    if not character then return nil end
    local wanted = {}
    for _, name in ipairs(names) do
        wanted[string.lower(name)] = true
    end
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart") and wanted[string.lower(descendant.Name)] then
            return descendant
        end
    end
    return nil
end

local function isAimTargetAllowed(player, character)
    if not player or player == lp or player.Parent ~= Players then return false end
    if not character or not character.Parent or player.Character ~= character then return false end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and (humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead) then
        return false
    end

    -- Ignore sleepers/dead/corpse states whether the game stores them as
    -- attributes or BoolValues on the Player, character, or nested rig models.
    local blockedFlags = {
        "Sleeping", "IsSleeping", "Sleeper", "IsSleeper",
        "Dead", "IsDead", "IsCorpse", "Corpse"
    }
    for _, flagName in ipairs(blockedFlags) do
        if player:GetAttribute(flagName) == true or character:GetAttribute(flagName) == true then
            return false
        end
        local playerFlag = player:FindFirstChild(flagName, true)
        local characterFlag = character:FindFirstChild(flagName, true)
        if (playerFlag and playerFlag:IsA("BoolValue") and playerFlag.Value)
            or (characterFlag and characterFlag:IsA("BoolValue") and characterFlag.Value) then
            return false
        end
    end
    for _, descendant in ipairs(character:GetDescendants()) do
        for _, flagName in ipairs(blockedFlags) do
            if descendant:GetAttribute(flagName) == true then return false end
            if descendant:IsA("BoolValue") and descendant.Name == flagName and descendant.Value then
                return false
            end
        end
    end

    return findNamedBodyPart(character, {
        "Head", "head", "HeadPart", "Skull", "HumanoidRootPart", "RootPart", "Root"
    }) ~= nil or #character:GetDescendants() > 0
end

local function getAimPart(character)
    if not character then return nil end

    if Settings.AimPart == "Head" then
        local head = findNamedBodyPart(character, {"Head", "head", "HeadPart", "Skull"})
        if head then return head end
        -- Custom rigs sometimes use an arbitrary name for the head. Use the
        -- highest body BasePart as a best-effort head point.
        local highestPart, highestY = nil, -math.huge
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("BasePart")
                and not descendant:FindFirstAncestorOfClass("Accessory")
                and not descendant:FindFirstAncestorOfClass("Tool")
                and descendant.Position.Y > highestY then
                highestPart, highestY = descendant, descendant.Position.Y
            end
        end
        return highestPart or findNamedBodyPart(character, {"HumanoidRootPart", "RootPart", "Root"})
    elseif Settings.AimPart == "Torso" then
        return findNamedBodyPart(character, {
            "UpperTorso", "Torso", "LowerTorso", "Chest", "Body", "HumanoidRootPart", "RootPart"
        })
    else -- Legs
        local left = findNamedBodyPart(character, {"LeftUpperLeg", "Left Leg", "LeftLeg", "LeftLowerLeg"})
        local right = findNamedBodyPart(character, {"RightUpperLeg", "Right Leg", "RightLeg", "RightLowerLeg"})
        if left and right then return (left.Position + right.Position) / 2 end
        return left or right or findNamedBodyPart(character, {"HumanoidRootPart", "RootPart", "Root"})
    end
end

local function isTargetVisible(character, targetPosition)
    if not Settings.VisibilityCheck then
        return true
    end

    local camera = WS.CurrentCamera
    if not camera or not character then
        return false
    end

    local origin = camera.CFrame.Position
    local direction = targetPosition - origin
    if direction.Magnitude <= 0 then
        return true
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {lp.Character}
    -- Ignore non-collidable decorative parts; solid map geometry still blocks the ray.
    params.RespectCanCollide = true

    local result = WS:Raycast(origin, direction, params)
    if not result then
        return true
    end

    return result.Instance:IsDescendantOf(character)
end

local function getClosestAimTarget()
    local camera = WS.CurrentCamera
    if not camera then return nil end

    local center = camera.ViewportSize / 2
    local bestPosition, bestDistance = nil, Settings.FOV

    for _, player in ipairs(Players:GetPlayers()) do
        local character = player.Character
        if isAimTargetAllowed(player, character) then
            local part = getAimPart(character)
            if part then
                local targetPosition = typeof(part) == "Vector3" and part or part.Position
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPosition)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if distance <= bestDistance and isTargetVisible(character, targetPosition) then
                        bestDistance = distance
                        bestPosition = targetPosition
                    end
                end
            end
        end
    end

    return bestPosition
end

local function updateSmoothAim()
    if not Settings.SmoothAim or not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        return
    end

    local camera = WS.CurrentCamera
    local target = getClosestAimTarget()
    if not camera or not target then return end

    local targetPosition = target
    local goal = CFrame.lookAt(camera.CFrame.Position, targetPosition)
    -- 1 = instant; 10 = slower/smoother.
    local alpha = 1 / math.clamp(Settings.Smoothness, 1, 10)
    camera.CFrame = camera.CFrame:Lerp(goal, alpha)
end

local function clearPlayerESP(player)
    local objects = espObjects[player]
    if not objects then return end
    if objects.highlight then objects.highlight:Destroy() end
    if objects.box then objects.box:Destroy() end
    if objects.nameBillboard then objects.nameBillboard:Destroy() end
    if objects.infoBillboard then objects.infoBillboard:Destroy() end
    espObjects[player] = nil
end

-- Supports standard R6/R15 and custom rigs with arbitrary body-part names.
-- The anchor is selected from the actual model bounds, not from skin/body colors.
local function getCharacterAnchor(character)
    if not character or not character:IsA("Model") then return nil end

    local preferredNames = {
        "HumanoidRootPart", "Root", "RootPart", "UpperTorso", "Torso",
        "LowerTorso", "Head"
    }

    for _, name in ipairs(preferredNames) do
        local part = character:FindFirstChild(name, true)
        if part and part:IsA("BasePart") then
            return part
        end
    end

    if character.PrimaryPart and character.PrimaryPart:IsA("BasePart") then
        return character.PrimaryPart
    end

    local parts = {}
    for _, descendant in ipairs(character:GetDescendants()) do
        if descendant:IsA("BasePart")
            and not descendant:FindFirstAncestorOfClass("Accessory")
            and not descendant:FindFirstAncestorOfClass("Tool") then
            table.insert(parts, descendant)
        end
    end

    if #parts == 0 then
        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                table.insert(parts, descendant)
            end
        end
    end
    if #parts == 0 then return nil end

    -- Pick the body part closest to the model's center. This works for custom
    -- rigs whose parts have names unrelated to R6/R15 and ignores skin color.
    local ok, boxCFrame = pcall(function()
        local cf = character:GetBoundingBox()
        return cf
    end)
    if ok and boxCFrame then
        local center = boxCFrame.Position
        local bestPart, bestDistance = nil, math.huge
        for _, part in ipairs(parts) do
            local distance = (part.Position - center).Magnitude
            if distance < bestDistance then
                bestDistance = distance
                bestPart = part
            end
        end
        if bestPart then return bestPart end
    end

    return parts[1]
end

-- Player-only ESP. A Humanoid is optional for custom rigs; when present,
-- its health/state are still used to filter dead characters.
local function isLivePlayerCharacter(player, character)
    if not player or player == lp or player.Parent ~= Players then
        return false
    end
    if not character or not character.Parent or player.Character ~= character then
        return false
    end
    if not getCharacterAnchor(character) then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and (humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead) then
        return false
    end

    local blockedFlags = {
        "Sleeping", "IsSleeping", "Sleeper", "IsSleeper",
        "Dead", "IsDead", "IsCorpse", "Corpse"
    }

    for _, flagName in ipairs(blockedFlags) do
        if character:GetAttribute(flagName) == true
            or player:GetAttribute(flagName) == true then
            return false
        end

        local characterFlag = character:FindFirstChild(flagName, true)
        local playerFlag = player:FindFirstChild(flagName, true)
        if (characterFlag and characterFlag:IsA("BoolValue") and characterFlag.Value)
            or (playerFlag and playerFlag:IsA("BoolValue") and playerFlag.Value) then
            return false
        end
    end

    -- Some custom rigs store state flags on a nested body/model object.
    for _, descendant in ipairs(character:GetDescendants()) do
        for _, flagName in ipairs(blockedFlags) do
            if descendant:GetAttribute(flagName) == true then
                return false
            end
        end
        if descendant:IsA("BoolValue") then
            for _, flagName in ipairs(blockedFlags) do
                if descendant.Name == flagName and descendant.Value then
                    return false
                end
            end
        end
    end

    return true
end

local function createBillboard(name, size, offset, parent)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = name
    billboard.Size = size
    billboard.StudsOffset = offset
    billboard.AlwaysOnTop = true
    billboard.Enabled = false
    billboard.Parent = parent
    return billboard
end

local function createTextLabel(name, parent, position, size, textSize)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Position = position
    label.Size = size
    label.Font = Enum.Font.Code
    label.TextSize = textSize or 13
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextStrokeTransparency = 0.2
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.TextWrapped = false
    label.Parent = parent
    return label
end

local function createOrUpdatePlayerESP(player)
    if player == lp then return end
    local character = player.Character
    if not isLivePlayerCharacter(player, character) then
        clearPlayerESP(player)
        return
    end

    local anchor = getCharacterAnchor(character)
    if not anchor then
        clearPlayerESP(player)
        return
    end

    local objects = espObjects[player]
    if not objects or objects.character ~= character then
        clearPlayerESP(player)
        objects = {character = character}
        espObjects[player] = objects

        local highlight = Instance.new("Highlight")
        highlight.Name = "FustSurv_PlayerHighlight"
        highlight.Adornee = character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = Color3.fromRGB(170, 90, 255)
        highlight.OutlineColor = Color3.fromRGB(230, 210, 255)
        highlight.FillTransparency = 0.55
        highlight.OutlineTransparency = 0
        highlight.Parent = character
        objects.highlight = highlight

        -- A 3D bounding box follows the full model, regardless of rig or skin color.
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "FustSurv_PlayerBox"
        box.Adornee = anchor
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Color3 = Color3.fromRGB(210, 170, 255)
        box.Transparency = 0.25
        box.Visible = false
        box.Parent = anchor
        objects.box = box

        -- Name is kept separately above the character.
        local nameBillboard = createBillboard(
            "FustSurv_PlayerName", UDim2.fromOffset(150, 20),
            Vector3.new(0, 3, 0), lp:WaitForChild("PlayerGui")
        )
        nameBillboard.Adornee = anchor
        objects.nameBillboard = nameBillboard
        objects.nameLabel = createTextLabel(
            "Name", nameBillboard, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 12
        )
        objects.nameLabel.TextXAlignment = Enum.TextXAlignment.Center

        -- HP and distance are stacked in a separate label beside the player.
        local infoBillboard = createBillboard(
            "FustSurv_PlayerSideInfo", UDim2.fromOffset(88, 30),
            Vector3.new(1.9, 0.1, 0), lp:WaitForChild("PlayerGui")
        )
        infoBillboard.Adornee = anchor
        objects.infoBillboard = infoBillboard
        objects.infoLabel = createTextLabel(
            "HPAndDistance", infoBillboard, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 10
        )
        objects.infoLabel.TextYAlignment = Enum.TextYAlignment.Center
    end

    -- Rebind adornments when a custom rig streams/replaces its body parts.
    objects.highlight.Adornee = character
    objects.nameBillboard.Adornee = anchor
    objects.infoBillboard.Adornee = anchor
    objects.box.Adornee = anchor
    objects.box.Parent = anchor
    objects.highlight.Enabled = Settings.PlayerESP

    local boundsOK, boundsCFrame, boundsSize = pcall(function()
        return character:GetBoundingBox()
    end)
    if boundsOK and boundsCFrame and boundsSize then
        objects.box.CFrame = anchor.CFrame:ToObjectSpace(boundsCFrame)
        objects.box.Size = boundsSize + Vector3.new(0.08, 0.08, 0.08)
        objects.box.Visible = Settings.PlayerESP and Settings.PlayerBoxes
    else
        objects.box.Visible = false
    end

    local hasName = Settings.PlayerESP and Settings.PlayerName
    objects.nameBillboard.Enabled = hasName
    if hasName then
        objects.nameLabel.Text = player.DisplayName or player.Name
        local ok, _, size = pcall(function()
            return character:GetBoundingBox()
        end)
        if ok and size then
            objects.nameBillboard.StudsOffset = Vector3.new(0, math.max(2, size.Y * 0.5 + 0.6), 0)
        else
            objects.nameBillboard.StudsOffset = Vector3.new(0, 3, 0)
        end
    end

    local infoLines = {}
    if Settings.PlayerHealth then
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            table.insert(infoLines, string.format(
                "HP: %d/%d", math.floor(humanoid.Health + 0.5), math.floor(humanoid.MaxHealth + 0.5)
            ))
        else
            table.insert(infoLines, "HP: N/A")
        end
    end

    if Settings.PlayerDistance then
        local localCharacter = lp.Character
        local localAnchor = localCharacter and getCharacterAnchor(localCharacter)
        if localAnchor then
            local distance = (anchor.Position - localAnchor.Position).Magnitude
            table.insert(infoLines, string.format("DIST: %dm", math.floor(distance + 0.5)))
        end
    end

    objects.infoBillboard.Enabled = Settings.PlayerESP and #infoLines > 0
    objects.infoLabel.Text = table.concat(infoLines, "\n")
end

local function refreshPlayerESP()
    if not Settings.PlayerESP then
        for player in pairs(espObjects) do
            clearPlayerESP(player)
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        createOrUpdatePlayerESP(player)
    end
end

Players.PlayerRemoving:Connect(clearPlayerESP)
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.25)
        if Settings.PlayerESP then createOrUpdatePlayerESP(player) end
    end)
end)

RS.RenderStepped:Connect(function()
    updateSmoothAim()
    refreshPlayerESP()
end)

-- FOV CIRCLE

local FOVCircle

if Drawing and Drawing.new then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 80
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(180, 100, 255)
    FOVCircle.Visible = false
end

RS.RenderStepped:Connect(function()
    if not FOVCircle then return end

    local Camera = WS.CurrentCamera
    if not Camera then
        FOVCircle.Visible = false
        return
    end

    local Viewport = Camera.ViewportSize

    FOVCircle.Position = Vector2.new(
        Viewport.X / 2,
        Viewport.Y / 2
    )

    FOVCircle.Radius = Settings.FOV
    FOVCircle.Visible = Settings.SmoothAim and Settings.ShowFOV
end)

-- MOBILE UI BUTTON

if UIS.TouchEnabled then
    local GuiParent = (gethui and gethui())
        or lp:WaitForChild("PlayerGui")

    local ToggleGui = Instance.new("ScreenGui")
    ToggleGui.Name = "MobileToggleGui"
    ToggleGui.ResetOnSpawn = false
    ToggleGui.Parent = GuiParent

    local Button = Instance.new("TextButton")
    Button.Name = "ToggleUI"
    Button.Size = UDim2.fromOffset(45, 45)
    Button.Position = UDim2.new(0.02, 0, 0.25, 0)
    Button.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = "UI"
    Button.TextSize = 16
    Button.Font = Enum.Font.Code
    Button.Parent = ToggleGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(150, 90, 220)
    Stroke.Thickness = 1.5
    Stroke.Parent = Button

    Button.Activated:Connect(function()
        for _, Gui in ipairs(GuiParent:GetChildren()) do
            if Gui:IsA("ScreenGui") and Gui ~= ToggleGui then
                Gui.Enabled = not Gui.Enabled
            end
        end
    end)
end

-- NOTIFICATION

Rayfield:Notify({
    Title = "FustSurv | SomeCheats",
    Content = "Interface loaded successfully!",
    Duration = 4
})
