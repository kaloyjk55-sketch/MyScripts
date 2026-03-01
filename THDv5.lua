local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- 1. KHỞI TẠO GUI (CHỐNG RESET)
local gui = Instance.new("ScreenGui")
gui.Name = "THD_NANO_FIXED"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- 2. DÒNG CHỮ THƯƠNG HIỆU (RGB)
local topLabel = Instance.new("TextLabel", gui)
topLabel.Size = UDim2.new(0, 300, 0, 40)
topLabel.Position = UDim2.new(0.5, -150, 0, 5)
topLabel.BackgroundTransparency = 1
topLabel.Text = "THÀNH ĐOÀN ĐẸP TRAI - NANO V3"
topLabel.TextScaled = true
topLabel.Font = Enum.Font.GothamBold

-- 3. KHUNG MENU CHÍNH
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 200, 0, 340)
main.Position = UDim2.new(0.05, 0, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.Active = true
main.Draggable = true -- Kéo thả mượt trên Mobile
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 3

-- NÚT THU GỌN (DỄ TIẾP CẬN)
local isMinimized = false
local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 30, 0, 30)
minBtn.Position = UDim2.new(1, -35, 0, 5)
minBtn.Text = "-"
minBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
minBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", minBtn)

minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        main:TweenSize(UDim2.new(0, 200, 0, 40), "Out", "Quad", 0.3, true)
        minBtn.Text = "+"
    else
        main:TweenSize(UDim2.new(0, 200, 0, 340), "Out", "Quad", 0.3, true)
        minBtn.Text = "-"
    end
end)

---------------------------------------------------------
-- 4. HỆ THỐNG CHỨC NĂNG HACK BÁ ĐẠO
---------------------------------------------------------
local vars = { speed = 16, jump = 50, fly = false, noclip = false, bright = false, invis = false }

local function createBtn(text, pos, color, callback)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- TẠO CÁC NÚT TÍNH NĂNG
local sBtn = createBtn("SPEED: 16", UDim2.new(0.05, 0, 0.15, 0), Color3.fromRGB(30, 50, 150), function()
    vars.speed = (vars.speed >= 200) and 16 or vars.speed + 30
end)

local jBtn = createBtn("JUMP: 50", UDim2.new(0.05, 0, 0.28, 0), Color3.fromRGB(100, 30, 150), function()
    vars.jump = (vars.jump >= 400) and 50 or vars.jump + 50
end)

local fBtn = createBtn("FLY: OFF", UDim2.new(0.05, 0, 0.41, 0), Color3.fromRGB(150, 30, 30), function()
    vars.fly = not vars.fly
    fBtn.Text = vars.fly and "FLY: ON" or "FLY: OFF"
    fBtn.BackgroundColor3 = vars.fly and Color3.fromRGB(30, 150, 30) or Color3.fromRGB(150, 30, 30)
end)

local nBtn = createBtn("NOCLIP: OFF", UDim2.new(0.05, 0, 0.54, 0), Color3.fromRGB(120, 80, 0), function()
    vars.noclip = not vars.noclip
    nBtn.Text = vars.noclip and "NOCLIP: ON" or "NOCLIP: OFF"
end)

createBtn("TÀNG HÌNH", UDim2.new(0.05, 0, 0.67, 0), Color3.fromRGB(60, 60, 60), function()
    vars.invis = not vars.invis
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = vars.invis and 1 or (part.Name == "HumanoidRootPart" and 1 or 0)
            end
        end
    end
end)

createBtn("SÁNG TRỜI", UDim2.new(0.05, 0, 0.80, 0), Color3.fromRGB(200, 200, 50), function()
    vars.bright = not vars.bright
    Lighting.Brightness = vars.bright and 4 or 1
    Lighting.GlobalShadows = not vars.bright
    Lighting.ClockTime = 14
end)

---------------------------------------------------------
-- 5. CƠ CHẾ VẬN HÀNH (VÒNG LẶP FIX BUG)
---------------------------------------------------------
RunService.RenderStepped:Connect(function()
    -- RGB Hiệu ứng
    local rainbow = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    stroke.Color = rainbow
    topLabel.TextColor3 = rainbow
    
    -- Cập nhật Text nút
    sBtn.Text = "SPEED: " .. vars.speed
    jBtn.Text = "JUMP: " .. vars.jump

    local char = player.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if hum and root then
            -- Áp dụng Speed/Jump
            hum.WalkSpeed = vars.speed
            hum.JumpPower = vars.jump
            
            -- HỆ THỐNG BAY SIÊU MƯỢT
            if vars.fly then
                hum.PlatformStand = true
                root.Velocity = workspace.CurrentCamera.CFrame.LookVector * 100
                if not root:FindFirstChild("NanoGyro") then
                    local g = Instance.new("BodyGyro", root)
                    g.Name = "NanoGyro"
                    g.MaxTorque = Vector3.new(4e5, 4e5, 4e5)
                end
                root.NanoGyro.CFrame = workspace.CurrentCamera.CFrame
            else
                hum.PlatformStand = false
                if root:FindFirstChild("NanoGyro") then root.NanoGyro:Destroy() end
            end
            
            -- XUYÊN TƯỜNG (NOCLIP)
            if vars.noclip then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end
end)
