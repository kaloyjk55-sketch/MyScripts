-- THĐ HUD ULTRA UI (Visual Only)

local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- MAIN FRAME
local main = Instance.new("Frame")
main.Size = UDim2.new(0,500,0,300)
main.Position = UDim2.new(0.5,-250,0.5,-150)
main.BackgroundColor3 = Color3.fromRGB(255,255,255)
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner",main).CornerRadius = UDim.new(0,20)

local stroke = Instance.new("UIStroke",main)
stroke.Thickness = 1.5
stroke.Color = Color3.fromRGB(0,0,0)

-- SHADOW
local shadow = Instance.new("ImageLabel",main)
shadow.Size = UDim2.new(1,40,1,40)
shadow.Position = UDim2.new(0,-20,0,-20)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.7
shadow.ZIndex = 0

-- TITLE
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.BackgroundTransparency = 1
title.Text = "THĐ HUD"
title.Font = Enum.Font.GothamBlack
title.TextScaled = true
title.TextColor3 = Color3.fromRGB(0,0,0)
title.Parent = main

-- TAB HOLDER
local tabHolder = Instance.new("Frame",main)
tabHolder.Size = UDim2.new(1,0,0,40)
tabHolder.Position = UDim2.new(0,0,0,50)
tabHolder.BackgroundTransparency = 1

local content = Instance.new("Frame",main)
content.Size = UDim2.new(1,0,1,-90)
content.Position = UDim2.new(0,0,0,90)
content.BackgroundTransparency = 1

local tabs = {}
local pages = {}

local function createTab(name,pos)
    local btn = Instance.new("TextButton",tabHolder)
    btn.Size = UDim2.new(0,120,1,0)
    btn.Position = UDim2.new(0,pos,0,0)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextColor3 = Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = 1
    btn.TextScaled = true

    local page = Instance.new("Frame",content)
    page.Size = UDim2.new(1,0,1,0)
    page.Visible = false
    page.BackgroundTransparency = 1

    btn.MouseButton1Click:Connect(function()
        for _,p in pairs(pages) do p.Visible = false end
        page.Visible = true
    end)

    table.insert(pages,page)
    return page
end

-- CREATE TABS
local home = createTab("Home",20)
local playerTab = createTab("Player",160)
local settings = createTab("Settings",300)

home.Visible = true

-- HOME CONTENT
local homeText = Instance.new("TextLabel",home)
homeText.Size = UDim2.new(1,0,1,0)
homeText.BackgroundTransparency = 1
homeText.Text = "Welcome to THĐ HUD Ultra UI"
homeText.Font = Enum.Font.Gotham
homeText.TextScaled = true
homeText.TextColor3 = Color3.fromRGB(0,0,0)

-- MINI BUTTON
local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0,60,0,60)
mini.Position = UDim2.new(0,20,0.5,-30)
mini.Text = "THĐ"
mini.Font = Enum.Font.GothamBlack
mini.TextScaled = true
mini.BackgroundColor3 = Color3.fromRGB(255,255,255)
mini.TextColor3 = Color3.fromRGB(0,0,0)
mini.Visible = false
mini.Parent = gui
mini.Active = true
mini.Draggable = true
Instance.new("UICorner",mini).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke",mini).Color = Color3.fromRGB(0,0,0)

-- TOGGLE
local close = Instance.new("TextButton",main)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-40,0,10)
close.Text = "-"
close.BackgroundColor3 = Color3.fromRGB(0,0,0)
close.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner",close).CornerRadius = UDim.new(1,0)

close.MouseButton1Click:Connect(function()
    main.Visible = false
    mini.Visible = true
end)

mini.MouseButton1Click:Connect(function()
    main.Visible = true
    mini.Visible = false
end)
