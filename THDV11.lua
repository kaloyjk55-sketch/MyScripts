-- [[ THĐ NANO V11 - DEPLOYMENT BUILD ]] --
-- Trạng thái khép kín | Không rác vật lý | Tối ưu Mobile --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- [1] HỆ THỐNG QUẢN LÝ TÀI NGUYÊN (JANITOR V11)
local Janitor = { _conns = {}, _objs = {} }
function Janitor:Add(obj, name) 
    if name then self._objs[name] = obj else table.insert(self._objs, obj) end 
    return obj 
end
function Janitor:Connect(conn, name) 
    if name then self._conns[name] = conn else table.insert(self._conns, conn) end 
    return conn 
end
function Janitor:Clean()
    for _, c in pairs(self._conns) do if c.Disconnect then c:Disconnect() end end
    for _, o in pairs(self._objs) do if o and o.Parent then o:Destroy() end end
    self._conns = {}; self._objs = {}
end

if _G.ThdNanoProduction then _G.ThdNanoProduction:Clean() end
_G.ThdNanoProduction = Janitor

-- [2] TRẠNG THÁI TOÀN CỤC (STATE MACHINE)
local State = {
    Fly = false, Noclip = false, Invis = false, Bright = false,
    Speed = 16, Jump = 50, FlySpeed = 60, Up = false, Down = false,
    ColCache = setmetatable({}, {__mode = "k"}),
    TransCache = setmetatable({}, {__mode = "k"}),
    LightOrig = {}
}

-- [3] HÀM CHUYỂN ĐỔI TRẠNG THÁI (STATE TRANSITIONS - FIX ALL BUGS)

-- Xử lý Fly (Dọn dẹp triệt để khi tắt)
local function ToggleFly()
    State.Fly = not State.Fly
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not root or not hum then return end

    if State.Fly then
        hum:ChangeState(Enum.HumanoidStateType.Physics)
        local att = Instance.new("Attachment", root); att.Name = "V11_Att"
        local lv = Instance.new("LinearVelocity", att); lv.Name = "V11_LV"
        lv.MaxForce = 9e6; lv.Attachment0 = att; lv.RelativeTo = Enum.ActuatorRelativeTo.World
        local ao = Instance.new("AlignOrientation", att); ao.Name = "V11_AO"
        ao.MaxTorque = 9e6; ao.Attachment0 = att; ao.Responsiveness = 80
    else
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        local att = root:FindFirstChild("V11_Att")
        if att then att:Destroy() end -- Sạch bóng vật lý thừa
    end
end

-- Xử lý Noclip (Khôi phục lập tức khi tắt)
local function ToggleNoclip()
    State.Noclip = not State.Noclip
    if not State.Noclip then
        for part, canCollide in pairs(State.ColCache) do
            if part and part.Parent then part.CanCollide = canCollide end
        end
        State.ColCache = setmetatable({}, {__mode = "k"}) -- Reset cache
    end
end

-- Xử lý Tàng Hình (Quét lại toàn bộ khi bật/tắt)
local function ApplyInvisToPart(v)
    if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name ~= "HumanoidRootPart" then
        if State.Invis then
            if State.TransCache[v] == nil then State.TransCache[v] = v.Transparency end
            v.Transparency = 1
        else
            v.Transparency = State.TransCache[v] or 0
        end
    end
end

local function ToggleInvis()
    State.Invis = not State.Invis
    local char = player.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do ApplyInvisToPart(v) end
    end
end

-- [4] VÒNG LẶP CORE (CHỈ CHẠY LOGIC KHI STATE = TRUE)
Janitor:Connect(RunService.Stepped:Connect(function(time, dt)
    local char = player.Character
    if not char then return end

    -- Duy trì Fly (Hỗ trợ Mobile Joystick)
    if State.Fly then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        local att = root and root:FindFirstChild("V11_Att")
        
        if att and hum then
            local lv, ao = att:FindFirstChild("V11_LV"), att:FindFirstChild("V11_AO")
            local cam = workspace.CurrentCamera
            
            -- Tính toán Vector vận tốc (Joystick + Nút Up/Down)
            local moveDir = hum.MoveDirection
            local targetVel = Vector3.new(0,0,0)
            
            if moveDir.Magnitude > 0 then
                targetVel = moveDir.Unit * State.FlySpeed
            end
            if State.Up then targetVel += Vector3.new(0, State.FlySpeed, 0) end
            if State.Down then targetVel += Vector3.new(0, -State.FlySpeed, 0) end
            
            -- Nội suy mượt mà
            lv.VectorVelocity = lv.VectorVelocity:Lerp(targetVel, 15 * dt)
            ao.CFrame = cam.CFrame
        end
    end

    -- Duy trì Noclip
    if State.Noclip then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                if State.ColCache[part] == nil then State.ColCache[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    end
end))

-- [5] BẢO VỆ VÀ QUẢN LÝ CHARACTER MỚI
local function OnCharacterAdded(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end

    -- Khóa Speed
    Janitor:Connect(hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hum.WalkSpeed ~= State.Speed and State.Speed ~= 16 then hum.WalkSpeed = State.Speed end
    end), "SpeedGuard")

    -- Lắng nghe đồ vật mới
    Janitor:Connect(char.DescendantAdded:Connect(function(obj)
        if State.Invis then ApplyInvisToPart(obj) end
        if State.Noclip and obj:IsA("BasePart") then obj.CanCollide = false end
    end), "CharAddedDesc")
end

if player.Character then task.spawn(OnCharacterAdded, player.Character) end
Janitor:Connect(player.CharacterAdded:Connect(OnCharacterAdded))

-- [6] GIAO DIỆN MOBILE CHUYÊN NGHIỆP
local gui = Janitor:Add(Instance.new("ScreenGui", player.PlayerGui), "MainGui")
gui.Name = "THD_PRODUCTION"; gui.ResetOnSpawn = false

local Main = Janitor:Add(Instance.new("Frame", gui))
Main.Size = UDim2.new(0, 220, 0, 410); Main.Position = UDim2.new(0.05, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", Main); Stroke.Thickness = 1.5; Stroke.Color = Color3.fromRGB(80,80,80)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35); Title.Text = "THD FLIGHT V11"; Title.Font = Enum.Font.GothamBold; Title.TextColor3 = Color3.new(1,1,1); Title.BackgroundTransparency = 1

local function MakeBtn(txt, pos, size, cb)
    local b = Instance.new("TextButton", Main)
    b.Size = size; b.Position = pos; b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(25,25,25); b.TextColor3 = Color3.new(1,1,1); b.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    Instance.new("UIStroke", b).Color = Color3.fromRGB(50,50,50)
    
    b.MouseButton1Click:Connect(function()
        local state = cb()
        if state ~= nil then b.BackgroundColor3 = state and Color3.fromRGB(0,140,255) or Color3.fromRGB(25,25,25) end
    end)
    return b
end

-- Layout Buttons
MakeBtn("FLY: ON/OFF", UDim2.new(0.05, 0, 0.1, 0), UDim2.new(0.9, 0, 0, 32), function() ToggleFly(); return State.Fly end)

local btnUp = MakeBtn("UP", UDim2.new(0.05, 0, 0.2, 0), UDim2.new(0.42, 0, 0,
