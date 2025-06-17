-- FlixHub - Created with Wind UI
local Wind = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wind"))()

-- Creating the main window (force create our custom UI)
Wind.Unload() -- If there's any existing UI instance, unload it first
local MainWindow = Wind.New({
    Title = "FlixHub",
    Theme = "Dark",
    Sizeable = true,
    MinSize = UDim2.new(0, 450, 0, 300),
    Position = UDim2.new(0.5, -225, 0.5, -150)
})

-- Creating tabs
local MainTab = MainWindow:Tab("Main")
local PositionTab = MainWindow:Tab("Position")

-- Position Tab
local PlayerPosition = PositionTab:Section("Player Position")

-- Display current position
local PositionLabel = PlayerPosition:Label("Position: 0, 0, 0")

-- Function to update position
local function UpdatePosition()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local pos = player.Character.HumanoidRootPart.Position
        local roundedPos = Vector3.new(
            math.round(pos.X * 10) / 10,
            math.round(pos.Y * 10) / 10,
            math.round(pos.Z * 10) / 10
        )
        PositionLabel:Set("Position: " .. tostring(roundedPos))
    end
end

-- Copy position button
PlayerPosition:Button("Copy Position", function()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local pos = player.Character.HumanoidRootPart.Position
        local roundedPos = Vector3.new(
            math.round(pos.X * 10) / 10,
            math.round(pos.Y * 10) / 10,
            math.round(pos.Z * 10) / 10
        )
        setclipboard(tostring(roundedPos))
        Wind:Notification({
            Title = "Position Copied",
            Content = "Player position copied to clipboard",
            Duration = 3
        })
    end
end)

-- Create a ScreenGui for our GEAR button
local ScreenGui
if not game.Players.LocalPlayer.PlayerGui:FindFirstChild("FlixHubGui") then
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FlixHubGui"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
else
    ScreenGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("FlixHubGui")
end

-- Create GEAR button on screen (not in the UI)
local GearButton = Instance.new("TextButton")
GearButton.Name = "GearButton"
GearButton.Text = "GEAR"
GearButton.Size = UDim2.new(0, 80, 0, 40)
GearButton.Position = UDim2.new(0.9, -40, 0.5, -20)
GearButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
GearButton.BorderColor3 = Color3.fromRGB(255, 100, 100)
GearButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GearButton.Font = Enum.Font.SourceSansBold
GearButton.TextSize = 18
GearButton.Parent = ScreenGui

-- Teleport function for GEAR button
local teleportPosition = Vector3.new(0, 100, 0) -- Default teleport position, change as needed

GearButton.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(teleportPosition)
        Wind:Notification({
            Title = "Teleported",
            Content = "Teleported to preset location",
            Duration = 3
        })
    end
end)

-- Update position label continuously
game:GetService("RunService").RenderStepped:Connect(UpdatePosition)

-- Main Tab (Currently Empty as requested)
local MainSection = MainTab:Section("Welcome")
MainSection:Label("Welcome to FlixHub!")

-- Make sure UI is displayed
if MainWindow.Show then
    MainWindow:Show()
end

print("FlixHub UI has been loaded successfully!") 
