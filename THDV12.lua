-- [[ THĐ NANO V12 - GENESIS FULL MODULES ]] --
-- [[ ENGINE: TD FLY V36 INTEGRATED ]] --

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- HỆ THỐNG QUẢN LÝ TÀI NGUYÊN (V12 CORE)
local V12 = { Conns = {}, Objs = {}, ESP_List = {} }
function V12:Clear()
    for _, c in pairs(self.Conns) do c:Disconnect() end
    for _, o in pairs(self.Objs) do if o and o.Parent then o:Destroy() end end
    for _, e in pairs(self.ESP_List) do if e then e:Remove() end end
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.PlatformStand = false
        player.Character.Humanoid.WalkSpeed = 16
        player.Character.Humanoid.JumpPower = 50
    end
end
if _G.V12_Active then _G.V12_Active:Clear() end
_G.V12_Active = V12

-- TRẠNG THÁI CHỨC NĂNG
local State = {
    Fly = false, FlySpeed = 2,
    Noclip = false,
    Speed = 16, Jump = 50,
    ESP = false,
    Aimbot = false
}

-- ===== HIỆU ỨNG RIPPLE VÀ RAINBOW =====
local function Ripple(obj)
    obj.ClipsDescendants = true
    obj.MouseButton1Click:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        local relPos = mousePos - obj.AbsolutePosition
        local circle = Instance.new("Frame", obj)
        circle.BackgroundColor3 = Color3.new(1, 1, 1)
        circle.BackgroundTransparency = 0.7
        circle.Position = UDim2.new(0, relPos.X, 0, relPos.Y - 36)
        Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
        TweenService:Create(circle, TweenInfo.new(0.5), {Size = UDim2.new(0,200,0,200), Position = UDim2.new(0, relPos.X-100, 0, relPos.Y-136), BackgroundTransparency = 1}):Play()
        task.delay(0.5, function() circle:Destroy() end)
    end)
end

-- ===== GIAO DIỆN CHÍNH =====
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "V12_Genesis"; gui.ResetOnSpawn = false
table.insert(V12.Objs, gui)

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 55, 0, 55)
toggleBtn.Position = UDim2.new(0.05, 0, 0.4, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
toggleBtn.Text = "V12"
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.ZIndex = 10
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", toggleBtn)
stroke.Thickness = 3
task.spawn(function() while task.wait() do stroke.Color = Color3.fromHSV(tick() % 5 / 5, 0.8, 1) end end)

local menu = Instance.new("Frame", gui)
menu.Size = UDim2.new(0, 0, 0, 0)
menu.Position = UDim2.new(0.05, 65, 0.4, 0)
menu.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
menu.Visible = false
menu.ClipsDescendants = true
Instance.new("UICorner", menu)
Instance.new("UIStroke", menu).Color = Color3.fromRGB(60, 60, 60)

local container = Instance.new("ScrollingFrame", menu)
container.Size = UDim2.new(1, -10, 1, -40)
container.Position = UDim2.new(0, 5, 0, 35)
container.BackgroundTransparency = 1
container.ScrollBarThickness = 0
Instance.new("UIListLayout", container).Padding = UDim.new(0, 5)

-- ===== HÀM THÊM CHỨC NĂNG =====
local function AddModule(name, cb)
    local b = Instance.new("TextButton", container)
    b.Size = UDim2.new(0.95, 0, 0, 35)
    b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    b.Text = name; b.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    b.Font = Enum.Font.GothamMedium; b.TextSize = 13
    Instance.new("UICorner", b)
    Ripple(b)
    b.MouseButton1Click:Connect(function()
        local active = cb()
        TweenService:Create(b, TweenInfo.new(0.3), {BackgroundColor3 = active and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(25, 25, 25)}):Play()
    end)
    return b
end

-- ===== DANH SÁCH CHỨC NĂNG FULL =====

-- 1. TD FLY V36
AddModule("TD FLY V36", function()
    State.Fly = not State.Fly
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        if State.Fly then
            Instance.new("BodyVelocity", root).Name = "V36_V"; Instance.new("BodyGyro", root).Name = "V36_G"
        else
            if root:FindFirstChild("V36_V") then root.V36_V:Destroy() end
            if root:FindFirstChild("V36_G") then root.V36_G:Destroy() end
        end
    end
    return State.Fly
end)

-- 2. ESP BOX
AddModule("ESP (Nhìn xuyên)", function()
    State.ESP = not State.ESP
    if not State.ESP then
        for _, v in pairs(V12.ESP_List) do v.Visible = false end
    end
    return State.ESP
end)

-- 3. SPEED & JUMP
local sBtn = AddModule("Speed: 16", function()
    State.Speed = (State.Speed == 16) and 100 or 16
    if player.Character then player.Character.Humanoid.Walk
