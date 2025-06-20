-- FlixHub - Created with Wind UI
local success, Wind
success, Wind = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wind"))()
end)

if not success then
    warn("Failed to load Wind UI library: " .. tostring(Wind))
    return
end

-- Creating the main window with proper error handling
local MainWindow
success, MainWindow = pcall(function()
    return Wind:Window({
        Title = "FlixHub",
        Theme = "Dark",
        Sizeable = true,
        MinSize = UDim2.new(0, 450, 0, 300),
        Position = UDim2.new(0.5, -225, 0.5, -150)
    })
end)

if not success then
    warn("Failed to create window: " .. tostring(MainWindow))
    return
end

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
        pcall(function()
            PositionLabel:Set("Position: " .. tostring(roundedPos))
        end)
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
        pcall(function()
            setclipboard(tostring(roundedPos))
            Wind:Notification({
                Title = "Position Copied",
                Content = "Player position copied to clipboard",
                Duration = 3
            })
        end)
    end
end)

-- Create a ScreenGui for our GEAR button
local ScreenGui
pcall(function()
    if not game.Players.LocalPlayer:FindFirstChild("PlayerGui") then
        return
    end
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "FlixHubGear"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 100 -- Make sure it's visible above other GUIs
    ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
end)

if not ScreenGui then
    warn("Failed to create ScreenGui for GEAR button")
    return
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

-- Add corner radius to make it look better
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = GearButton

-- Teleport function for GEAR button
local teleportPosition = Vector3.new(0, 100, 0) -- Default teleport position, change as needed

GearButton.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            player.Character.HumanoidRootPart.CFrame = CFrame.new(teleportPosition)
            Wind:Notification({
                Title = "Teleported",
                Content = "Teleported to preset location",
                Duration = 3
            })
        end)
    end
end)

-- Update position label continuously
pcall(function()
    game:GetService("RunService").RenderStepped:Connect(UpdatePosition)
end)

-- Main Tab
local MainSection = MainTab:Section("Welcome")
MainSection:Label("Welcome to FlixHub!")

-- Make the UI visible
MainWindow:Show()

print("FlixHub has been loaded successfully!") 
