-- FlixHub using WindUI instead of Rayfield
-- Load WindUI library
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/Example.lua"))()

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Create the main window
local Window = WindUI:Window({
    Title = "FlixHub",
    Subtitle = "Garden Edition",
    Icon = "rbxassetid://4483362458",
    Size = UDim2.fromOffset(550, 350)
})

-- Create tabs
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "rbxassetid://4483362458"
})

local OtherTab = Window:Tab({
    Title = "Other",
    Icon = "rbxassetid://4483362458"
})

local FarmingTab = Window:Tab({
    Title = "Farming",
    Icon = "rbxassetid://4483362458"
})

local ChangelogTab = Window:Tab({
    Title = "Changelog",
    Icon = "rbxassetid://4483362458"
})

-- Variables for auto-farm features
local autoFarm = false
local autoSell = false
local autoPlant = false
local autoBuy = false
local autoHarvest = false
local noClip = false
local sellThreshold = 15

local selectedSeed = ""
local autoPlantRandom = false
local harvestIgnores = {
    Normal = false,
    Gold = false,
    Rainbow = false
}

-- MAIN TAB
-- Player Info
local userId = LocalPlayer.UserId
local username = LocalPlayer.Name
local avatarUrl = "https://www.roblox.com/headshot-thumbnail/image?userId="..userId.."&width=150&height=150&format=png"

MainTab:Label({
    Text = "Player Info"
})

MainTab:Label({
    Text = "Username: " .. username
})

MainTab:Label({
    Text = "UserId: " .. userId
})

-- WalkSpeed Slider
MainTab:Slider({
    Label = "WalkSpeed",
    Value = 16,
    Minimum = 8,
    Maximum = 100,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Value
        end
    end
})

-- JumpPower Slider
MainTab:Slider({
    Label = "JumpPower",
    Value = 50,
    Minimum = 20,
    Maximum = 200,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = Value
        end
    end
})

-- Fly Toggle
local flying = false
local flyConnection
MainTab:Checkbox({
    Value = false,
    Label = "Fly",
    Callback = function(Value)
        if Value and not flying then
            flying = true
            local humanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                flyConnection = RunService.RenderStepped:Connect(function()
                    humanoidRootPart.Velocity = Vector3.new(0, 50, 0)
                end)
            end
        elseif not Value and flying then
            flying = false
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
        end
    end
})

-- Reset WalkSpeed Button
MainTab:Button({
    Text = "Reset WalkSpeed",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16
        end
    end
})

-- Reset JumpPower Button
MainTab:Button({
    Text = "Reset JumpPower",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 50
        end
    end
})

-- WalkSpeed Presets
MainTab:Button({
    Text = "WalkSpeed: Fast (50)",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 50
        end
    end
})

MainTab:Button({
    Text = "WalkSpeed: Super Fast (100)",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 100
        end
    end
})

-- JumpPower Presets
MainTab:Button({
    Text = "JumpPower: High (100)",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 100
        end
    end
})

MainTab:Button({
    Text = "JumpPower: Super High (200)",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = 200
        end
    end
})

-- Rainbow Character Toggle
local rainbowActive = false
local rainbowConnection
MainTab:Checkbox({
    Value = false,
    Label = "Rainbow Character",
    Callback = function(Value)
        if Value and not rainbowActive then
            rainbowActive = true
            rainbowConnection = RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") then
                            part.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                        end
                    end
                end
            end)
        elseif not Value and rainbowActive then
            rainbowActive = false
            if rainbowConnection then
                rainbowConnection:Disconnect()
                rainbowConnection = nil
            end
        end
    end
})

-- OTHER TAB
-- Live location display
local playerLocationLabel = OtherTab:Label({
    Text = "Your Current Location: Fetching..."
})

-- Update location every 0.5s
task.spawn(function()
    while true do
        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            playerLocationLabel:Set({
                Text = string.format("Your Current Location: (%.2f, %.2f, %.2f)", pos.X, pos.Y, pos.Z)
            })
        else
            playerLocationLabel:Set({
                Text = "Your Current Location: Not found"
            })
        end
        task.wait(0.5)
    end
end)

-- Copy Location button
OtherTab:Button({
    Text = "Copy Location",
    Callback = function()
        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            if setclipboard then
                setclipboard(tostring(pos))
                WindUI:Notification({
                    Title = "Copied!",
                    Content = "Your current location has been copied to the clipboard.",
                    Duration = 3
                })
            end
        end
    end
})

-- GEAR teleport button toggle
local gearShopPosition = Vector3.new(-281.18951416015625, 2.999999761581421, -32.618160247802734)
local teleportButtonGui = nil

local function createTeleportButton()
    if teleportButtonGui then return end
    teleportButtonGui = Instance.new("ScreenGui")
    teleportButtonGui.Name = "FlixHubTeleportButton"
    teleportButtonGui.ResetOnSpawn = false
    teleportButtonGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local button = Instance.new("TextButton")
    button.Name = "GearTeleportButton"
    button.Size = UDim2.new(0, 120, 0, 40)
    button.Position = UDim2.new(0.5, -60, 0.8, 0)
    button.Text = "GEAR"
    button.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
    button.TextColor3 = Color3.new(1,1,1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 24
    button.Parent = teleportButtonGui
    button.Active = true
    button.Draggable = true
    button.MouseButton1Click:Connect(function()
        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(gearShopPosition)
        end
    end)
end

local function removeTeleportButton()
    if teleportButtonGui then
        teleportButtonGui:Destroy()
        teleportButtonGui = nil
    end
end

OtherTab:Checkbox({
    Value = false,
    Label = "Enable GEAR Teleport Button",
    Callback = function(Value)
        if Value then
            createTeleportButton()
        else
            removeTeleportButton()
        end
    end
})

-- Teleport to Spawn Button
local spawnPosition = Vector3.new(0, 3, 0) -- Replace with actual spawn if known
OtherTab:Button({
    Text = "Teleport to Spawn",
    Callback = function()
        if LocalPlayer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(spawnPosition)
        end
    end
})

-- Anti-AFK Toggle
local antiAfkConnection
OtherTab:Checkbox({
    Value = false,
    Label = "Anti-AFK",
    Callback = function(Value)
        if Value then
            antiAfkConnection = LocalPlayer.Idled:Connect(function()
                game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
                wait(1)
                game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
            end)
        else
            if antiAfkConnection then
                antiAfkConnection:Disconnect()
                antiAfkConnection = nil
            end
        end
    end
})

-- Teleport to Random Player
OtherTab:Button({
    Text = "Teleport to Random Player",
    Callback = function()
        local players = Players:GetPlayers()
        if #players > 1 then
            local others = {}
            for _, p in ipairs(players) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    table.insert(others, p)
                end
            end
            if #others > 0 then
                local target = others[math.random(1, #others)]
                LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
})

-- Server Hop Button
OtherTab:Button({
    Text = "Server Hop",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        TeleportService:Teleport(placeId)
    end
})

-- Rejoin Server Button
OtherTab:Button({
    Text = "Rejoin Server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

-- Copy Username Button
OtherTab:Button({
    Text = "Copy Username",
    Callback = function()
        if setclipboard then
            setclipboard(LocalPlayer.Name)
            WindUI:Notification({
                Title = "Copied!",
                Content = "Your username has been copied to the clipboard.",
                Duration = 3
            })
        end
    end
})

-- FARMING TAB (Auto-Farm Features from depso's script)
-- Functions from depso's script
local function GetFarm(PlayerName)
    local Farms = workspace.Farm:GetChildren()
    for _, Farm in next, Farms do
        local Important = Farm.Important
        local Data = Important.Data
        local Owner = Data.Owner

        if Owner.Value == PlayerName then
            return Farm
        end
    end
    return nil
end

local MyFarm = GetFarm(LocalPlayer.Name)
if not MyFarm then
    FarmingTab:Label({
        Text = "No farm found for your player!"
    })
else
    local MyImportant = MyFarm.Important
    local PlantLocations = MyImportant.Plant_Locations
    local PlantsPhysical = MyImportant.Plants_Physical
    
    local Dirt = PlantLocations:FindFirstChildOfClass("Part")
    local X1, Z1, X2, Z2
    
    if Dirt then
        local Center = Dirt:GetPivot()
        local Size = Dirt.Size
        
        X1 = math.ceil(Center.X - (Size.X/2))
        Z1 = math.ceil(Center.Z - (Size.Z/2))
        X2 = math.floor(Center.X + (Size.X/2))
        Z2 = math.floor(Center.Z + (Size.Z/2))
    end

    -- Seed Stock and Owned Seeds
    local SeedStock = {}
    local OwnedSeeds = {}

    local function GetSeedInfo(Seed)
        local PlantName = Seed:FindFirstChild("Plant_Name")
        local Count = Seed:FindFirstChild("Numbers")
        if not PlantName then return nil end

        return PlantName.Value, Count.Value
    end

    local function CollectSeedsFromParent(Parent, Seeds)
        for _, Tool in next, Parent:GetChildren() do
            local Name, Count = GetSeedInfo(Tool)
            if not Name then continue end

            Seeds[Name] = {
                Count = Count,
                Tool = Tool
            }
        end
    end

    local function GetOwnedSeeds()
        OwnedSeeds = {}
        CollectSeedsFromParent(LocalPlayer.Backpack, OwnedSeeds)
        if LocalPlayer.Character then
            CollectSeedsFromParent(LocalPlayer.Character, OwnedSeeds)
        end
        return OwnedSeeds
    end

    local function GetSeedStock(IgnoreNoStock)
        local SeedShop = LocalPlayer.PlayerGui.Seed_Shop
        if not SeedShop then return {} end
        
        local Items = SeedShop:FindFirstChild("Blueberry", true)
        if not Items then return {} end
        
        Items = Items.Parent
        local NewList = {}

        for _, Item in next, Items:GetChildren() do
            local MainFrame = Item:FindFirstChild("Main_Frame")
            if not MainFrame then continue end

            local StockText = MainFrame.Stock_Text.Text
            local StockCount = tonumber(StockText:match("%d+"))

            if IgnoreNoStock then
                if StockCount and StockCount > 0 then
                    NewList[Item.Name] = StockCount
                end
            else
                if StockCount then
                    SeedStock[Item.Name] = StockCount
                end
            end
        end

        return IgnoreNoStock and NewList or SeedStock
    end

    local function GetRandomFarmPoint()
        local FarmLands = PlantLocations:GetChildren()
        local FarmLand = FarmLands[math.random(1, #FarmLands)]

        local X1, Z1, X2, Z2
        local Center = FarmLand:GetPivot()
        local Size = FarmLand.Size
        
        X1 = math.ceil(Center.X - (Size.X/2))
        Z1 = math.ceil(Center.Z - (Size.Z/2))
        X2 = math.floor(Center.X + (Size.X/2))
        Z2 = math.floor(Center.Z + (Size.Z/2))
        
        local X = math.random(X1, X2)
        local Z = math.random(Z1, Z2)

        return Vector3.new(X, 4, Z)
    end

    local function Plant(Position, Seed)
        local GameEvents = ReplicatedStorage.GameEvents
        GameEvents.Plant_RE:FireServer(Position, Seed)
        wait(.3)
    end

    local function EquipCheck(Tool)
        local Character = LocalPlayer.Character
        if not Character then return end
        
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if not Humanoid then return end

        if Tool.Parent ~= LocalPlayer.Backpack then return end
        Humanoid:EquipTool(Tool)
    end

    local function AutoPlantLoop()
        if not selectedSeed or selectedSeed == "" then return end

        local seeds = GetOwnedSeeds()
        local SeedData = seeds[selectedSeed]
        if not SeedData then return end

        local Count = SeedData.Count
        local Tool = SeedData.Tool

        if Count <= 0 then return end

        local Planted = 0
        local Step = 1

        EquipCheck(Tool)

        if autoPlantRandom then
            for i = 1, Count do
                local Point = GetRandomFarmPoint()
                Plant(Point, selectedSeed)
            end
        elseif X1 and Z1 and X2 and Z2 then
            for X = X1, X2, Step do
                for Z = Z1, Z2, Step do
                    if Planted >= Count then break end
                    local Point = Vector3.new(X, 0.13, Z)

                    Planted = Planted + 1
                    Plant(Point, selectedSeed)
                end
            end
        end
    end

    local function CanHarvest(Plant)
        local Prompt = Plant:FindFirstChild("ProximityPrompt", true)
        if not Prompt then return end
        if not Prompt.Enabled then return end

        return true
    end

    local function CollectHarvestable(Parent, Plants, IgnoreDistance)
        local Character = LocalPlayer.Character
        if not Character then return Plants end
        
        local PlayerPosition = Character:GetPivot().Position

        for _, Plant in next, Parent:GetChildren() do
            local Fruits = Plant:FindFirstChild("Fruits")
            if Fruits then
                CollectHarvestable(Fruits, Plants, IgnoreDistance)
            end

            local PlantPosition = Plant:GetPivot().Position
            local Distance = (PlayerPosition-PlantPosition).Magnitude
            if not IgnoreDistance and Distance > 15 then continue end

            local Variant = Plant:FindFirstChild("Variant")
            if Variant and harvestIgnores[Variant.Value] then continue end

            if CanHarvest(Plant) then
                table.insert(Plants, Plant)
            end
        end
        return Plants
    end

    local function GetHarvestablePlants(IgnoreDistance)
        local Plants = {}
        return CollectHarvestable(PlantsPhysical, Plants, IgnoreDistance)
    end

    local function HarvestPlant(Plant)
        local Prompt = Plant:FindFirstChild("ProximityPrompt", true)
        if not Prompt then return end
        fireproximityprompt(Prompt)
    end

    local function HarvestPlants()
        local Plants = GetHarvestablePlants()
        for _, Plant in next, Plants do
            HarvestPlant(Plant)
        end
    end

    local function CollectCropsFromParent(Parent, Crops)
        for _, Tool in next, Parent:GetChildren() do
            local Name = Tool:FindFirstChild("Item_String")
            if not Name then continue end

            table.insert(Crops, Tool)
        end
    end

    local function GetInvCrops()
        local Crops = {}
        CollectCropsFromParent(LocalPlayer.Backpack, Crops)
        if LocalPlayer.Character then
            CollectCropsFromParent(LocalPlayer.Character, Crops)
        end
        return Crops
    end

    local IsSelling = false
    local function SellInventory()
        local Character = LocalPlayer.Character
        if not Character then return end
        
        local Previous = Character:GetPivot()
        local PreviousSheckles = LocalPlayer.leaderstats.Sheckles.Value

        if IsSelling then return end
        IsSelling = true

        Character:PivotTo(CFrame.new(62, 4, -26))
        local GameEvents = ReplicatedStorage.GameEvents
        
        local sellAttempts = 0
        local maxAttempts = 10
        
        while sellAttempts < maxAttempts do
            if LocalPlayer.leaderstats.Sheckles.Value ~= PreviousSheckles then break end
            GameEvents.Sell_Inventory:FireServer()
            sellAttempts = sellAttempts + 1
            wait(0.5)
        end
        
        Character:PivotTo(Previous)

        wait(0.2)
        IsSelling = false
    end

    local function AutoSellCheck()
        local CropCount = #GetInvCrops()

        if not autoSell then return end
        if CropCount < sellThreshold then return end

        SellInventory()
    end

    local function BuySeed(Seed)
        local GameEvents = ReplicatedStorage.GameEvents
        GameEvents.BuySeedStock:FireServer(Seed)
    end

    local function BuyAllSelectedSeeds()
        if not selectedSeed or selectedSeed == "" then return end
        
        local stock = GetSeedStock()[selectedSeed]
        if not stock or stock <= 0 then return end

        for i = 1, stock do
            BuySeed(selectedSeed)
        end
    end

    local function NoclipLoop()
        local Character = LocalPlayer.Character
        if not noClip then return end
        if not Character then return end

        for _, Part in Character:GetDescendants() do
            if Part:IsA("BasePart") then
                Part.CanCollide = false
            end
        end
    end

    -- Auto-Plant Section
    FarmingTab:Label({
        Text = "Auto-Plant 🥕"
    })

    -- Get seed options
    local seedOptions = {}
    for seedName, _ in pairs(GetOwnedSeeds()) do
        table.insert(seedOptions, seedName)
    end
    
    if #seedOptions == 0 then
        table.insert(seedOptions, "No seeds found")
    end

    FarmingTab:Dropdown({
        Label = "Seed",
        Options = seedOptions,
        Default = seedOptions[1],
        Callback = function(Value)
            selectedSeed = Value
        end
    })

    FarmingTab:Checkbox({
        Value = false,
        Label = "Auto Plant",
        Callback = function(Value)
            autoPlant = Value
            if autoPlant then
                -- Start auto plant loop
                task.spawn(function()
                    while autoPlant do
                        AutoPlantLoop()
                        task.wait(1)
                    end
                end)
            end
        end
    })

    FarmingTab:Checkbox({
        Value = false,
        Label = "Plant at random points",
        Callback = function(Value)
            autoPlantRandom = Value
        end
    })

    FarmingTab:Button({
        Text = "Plant all",
        Callback = AutoPlantLoop
    })

    -- Auto-Harvest Section
    FarmingTab:Label({
        Text = "Auto-Harvest 🚜"
    })

    FarmingTab:Checkbox({
        Value = false,
        Label = "Auto Harvest",
        Callback = function(Value)
            autoHarvest = Value
            if autoHarvest then
                -- Start auto harvest loop
                task.spawn(function()
                    while autoHarvest do
                        HarvestPlants()
                        task.wait(1)
                    end
                end)
            end
        end
    })

    FarmingTab:Label({
        Text = "Harvest Ignores:"
    })

    FarmingTab:Checkbox({
        Value = false,
        Label = "Normal",
        Callback = function(Value)
            harvestIgnores.Normal = Value
        end
    })

    FarmingTab:Checkbox({
        Value = false,
        Label = "Gold",
        Callback = function(Value)
            harvestIgnores.Gold = Value
        end
    })

    FarmingTab:Checkbox({
        Value = false,
        Label = "Rainbow",
        Callback = function(Value)
            harvestIgnores.Rainbow = Value
        end
    })

    -- Auto-Buy Section
    FarmingTab:Label({
        Text = "Auto-Buy 🥕"
    })

    -- Get seed stock options
    local stockOptions = {}
    for seedName, stock in pairs(GetSeedStock()) do
        if stock > 0 then
            table.insert(stockOptions, seedName)
        end
    end
    
    if #stockOptions == 0 then
        table.insert(stockOptions, "No seeds in stock")
    end

    FarmingTab:Dropdown({
        Label = "Seed to Buy",
        Options = stockOptions,
        Default = stockOptions[1],
        Callback = function(Value)
            selectedSeed = Value
        end
    })

    FarmingTab:Checkbox({
        Value = false,
        Label = "Auto Buy",
        Callback = function(Value)
            autoBuy = Value
            if autoBuy then
                -- Start auto buy loop
                task.spawn(function()
                    while autoBuy do
                        BuyAllSelectedSeeds()
                        task.wait(5)
                    end
                end)
            end
        end
    })

    FarmingTab:Button({
        Text = "Buy all",
        Callback = BuyAllSelectedSeeds
    })

    -- Auto-Sell Section
    FarmingTab:Label({
        Text = "Auto-Sell 💰"
    })

    FarmingTab:Button({
        Text = "Sell inventory",
        Callback = SellInventory
    })

    FarmingTab:Checkbox({
        Value = false,
        Label = "Auto Sell",
        Callback = function(Value)
            autoSell = Value
            -- Auto sell is checked in the AutoSellCheck function
            -- which is called when crops are added to backpack
        end
    })

    FarmingTab:Slider({
        Label = "Crops threshold",
        Value = 15,
        Minimum = 1,
        Maximum = 199,
        Callback = function(Value)
            sellThreshold = Value
        end
    })

    -- NoClip
    FarmingTab:Checkbox({
        Value = false,
        Label = "NoClip",
        Callback = function(Value)
            noClip = Value
        end
    })

    -- Connect events
    RunService.Stepped:Connect(NoclipLoop)
    LocalPlayer.Backpack.ChildAdded:Connect(AutoSellCheck)
    
    -- Refresh seed lists periodically
    task.spawn(function()
        while true do
            GetSeedStock()
            GetOwnedSeeds()
            task.wait(5)
        end
    end)
end

-- CHANGELOG TAB
ChangelogTab:Label({
    Text = "Changelog"
})

ChangelogTab:Label({
    Text = "- Initial release"
})

ChangelogTab:Label({
    Text = "- UI, Main tab, Other tab, Farming tab, Changelog tab created"
})

ChangelogTab:Label({
    Text = "- WalkSpeed, JumpPower, Fly, and GEAR teleport"
})

ChangelogTab:Label({
    Text = "- Player avatar and username"
})

ChangelogTab:Label({
    Text = "- Copy location, live location"
})

ChangelogTab:Label({
    Text = "- Reset WalkSpeed/JumpPower, Teleport to Spawn, Anti-AFK"
})

ChangelogTab:Label({
    Text = "- WalkSpeed/JumpPower presets, Rainbow Character, Teleport to Random Player, Server Hop, Rejoin, Copy Username"
})

ChangelogTab:Label({
    Text = "- Auto Farm features in Farming tab"
})

ChangelogTab:Label({
    Text = "- Bug fixes and improvements"
})

ChangelogTab:Label({
    Text = "Version: v1.0.0 - Initial Release"
})

ChangelogTab:Label({
    Text = "Update Notes: This is the first version of FlixHub for Grow a Garden using WindUI. More features will be added in future updates."
})

ChangelogTab:Label({
    Text = "Credits: Created by YourName\nSpecial thanks to: depso (depthso) for the autofarm script"
})

-- Initialize the UI
WindUI:Init() 
