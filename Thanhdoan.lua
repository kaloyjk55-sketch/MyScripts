local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- 1. TẠO GIAO DIỆN CHÍNH (GUI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ThanhDoanVipMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 2. DÒNG CHỮ CẦU VỒNG (ĐÃ DI CHUYỂN LÊN ĐẦU MÀN HÌNH)
local textLabel = Instance.new("TextLabel")
textLabel.Size = UDim2.new(0, 250, 0, 45)
-- Vị trí: Căn giữa ngang (0.5), Sát mép trên (0.01)
textLabel.Position = UDim2.new(0.5, -125, 0.01, 0) 
textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
textLabel.BackgroundTransparency = 0.6
textLabel.Text = "THÀNH ĐOÀN ĐẸP TRAI"
textLabel.TextScaled = true
textLabel.Font = Enum.Font.SourceSansBold
textLabel.Parent = screenGui
Instance.new("UICorner", textLabel).CornerRadius = UDim.new(0, 10)

-- 3. KHUNG MENU ĐIỀU KHIỂN (CÓ THỂ KÉO THẢ TRÊN MOBILE)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 280)
frame.Position = UDim2.new(0, 10, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true -- Bạn có thể đè tay vào để kéo menu đi chỗ khác
frame.Parent = screenGui
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "MENU ĐIỀU KHIỂN"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SourceSansBold
title.Parent = frame

-- Hàm tạo nút bấm nhanh
local function createBtn(name, pos, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.Position = pos
    btn.BackgroundColor3 = color
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = frame
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(callback)
    return btn
end

-- 4. CÁC TÍNH NĂNG TÙY CHỈNH

-- Tốc độ chạy (Speed)
local walkSpeed = 16
createBtn("Speed: +10", UDim2.new(0.05, 0, 0.15, 0), Color3.fromRGB(0, 120, 255), function()
    walkSpeed = walkSpeed + 10
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = walkSpeed
    end
end)

-- Độ nhảy cao (Jump)
local jumpPower = 50
createBtn("Jump: +20", UDim2.new(0.05, 0, 0.30, 0), Color3.fromRGB(150, 0, 255), function()
    jumpPower = jumpPower + 20
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.JumpPower = jumpPower
    end
end)

-- Bay (Fly)
local flying = false
local flySpeed = 60
local bv, bg
local flyBtn = createBtn("BAY: TẮT", UDim2.new(0.05, 0, 0.45, 0), Color3.fromRGB(200, 0, 0), function()
    flying = not flying
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if flying then
        flyBtn.Text = "BAY: BẬT"
        flyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
        bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(4e5, 4e5, 4e5)
        bg.P = 9e4
        bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(4e5, 4e5, 4e5)
        char.Humanoid.PlatformStand = true
    else
        flyBtn.Text = "BAY: TẮT"
        flyBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        if bg then bg:Destroy() end
        if bv then bv:Destroy() end
        char.Humanoid.PlatformStand = false
    end
end)

-- Tàng hình (Invisibility)
local isInvis = false
createBtn("TÀNG HÌNH", UDim2.new(0.05, 0, 0.60, 0), Color3.fromRGB(100, 100, 100), function()
    isInvis = not isInvis
    if player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                part.Transparency = isInvis and 1 or (part.Name == "HumanoidRootPart" and 1 or 0)
            end
        end
    end
end)

-- Độ sáng (Full Bright)
local isBright = false
createBtn("SÁNG/TỐI", UDim2.new(0.05, 0, 0.75, 0), Color3.fromRGB(255, 180, 0), function()
    isBright = not isBright
    if isBright then
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
    else
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
    end
end)

-- Reset All
createBtn("RESET ALL", UDim2.new(0.05, 0, 0.90, 0), Color3.fromRGB(50, 50, 50), function()
    walkSpeed = 16
    jumpPower = 50
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
        player.Character.Humanoid.JumpPower = 50
    end
end)

-- VÒNG LẶP CẬP NHẬT HIỆU ỨNG
RunService.RenderStepped:Connect(function()
    -- Chữ cầu vồng đổi màu mượt mà
    textLabel.TextColor3 = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    
    -- Xử lý hướng bay theo hướng nhìn Camera
    if flying and bv and bg then
        local cam = workspace.CurrentCamera
        bg.CFrame = cam.CFrame
        bv.Velocity = cam.CFrame.LookVector * flySpeed
    end
    
    -- Đảm bảo chỉ số không bị mất khi hồi sinh
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = walkSpeed
        player.Character.Humanoid.JumpPower = jumpPower
    end
end)
