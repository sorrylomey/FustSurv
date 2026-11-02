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

local lp = Players.LocalPlayer

-- SETTINGS

local Settings = {
    SilentAim = false,
    AutoCross = false,

    SmoothAim = false,
    AimPart = "Head",
    Smoothness = 25,
    FOV = 150,
    ShowFOV = true,

    NoRecoil = false,
    NoCameraShake = false,

    PlayerESP = false,
    PlayerName = false,
    PlayerDistance = false,
    PlayerHealth = false,
    NPCESP = false,

    Noclip = false
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
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 25,
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
    Name = "AutoCross",
    CurrentValue = false,
    Callback = function(v)
        Settings.AutoCross = v
    end
})

-- NOCLIP

local noclipConnection
local originalCollision = {}

local function restoreCollision()
    for part, value in pairs(originalCollision) do
        if part and part.Parent then
            part.CanCollide = value
        end
    end

    table.clear(originalCollision)
end

local function setNoclip(enabled)
    Settings.Noclip = enabled

    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    if not enabled then
        restoreCollision()
        return
    end

    noclipConnection = RS.Stepped:Connect(function()
        local character = lp.Character
        if not character then return end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if originalCollision[part] == nil then
                    originalCollision[part] = part.CanCollide
                end

                part.CanCollide = false
            end
        end
    end)
end

PveTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Callback = setNoclip
})

lp.CharacterAdded:Connect(function()
    if Settings.Noclip then
        task.wait(0.5)
        setNoclip(true)
    else
        restoreCollision()
    end
end)

-- VISUALS

VisualsTab:CreateToggle({
    Name = "PlayerESP",
    CurrentValue = false,
    Callback = function(v)
        Settings.PlayerESP = v
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
