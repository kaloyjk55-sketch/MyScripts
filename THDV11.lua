-- [[ THĐ NANO V11 - DEPLOYMENT BUILD ]] --
-- Fix: Physics, Noclip, Invis, Mobile Joystick Support --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer

-- [1] QUẢN LÝ TÀI NGUYÊN (JANITOR)
local Janitor = { _conns = {}, _objs = {} }
function Janitor:Add(obj) table.insert(self._objs, obj); return obj end
function Janitor:Connect(conn) table.insert(self._conns, conn); return conn end
function Janitor:Clean()
    for _, c in pairs(self._conns) do if c.Disconnect then c:Disconnect() end end
    for _, o in pairs(self._objs) do if o and o.Parent then o:Destroy() end end
    self._conns = {}; self._objs = {}
end

if _G.ThdNanoProduction then _G.ThdNanoProduction:Clean() end
_G.ThdNanoProduction = Janitor

-- [2] TRẠNG THÁI (STATE)
local State = {
    Fly = false, Noclip = false, Invis = false, Bright = false,
    Speed = 16, FlySpeed = 60, Up = false, Down = false,
    ColCache = setmetatable({}, {__mode = "k"}),
    TransCache = setmetatable({}, {__mode = "k"}),
    LightOrig = { Amb = Lighting.Ambient, Out = Lighting.OutdoorAmbient, Exp = Lighting.ExposureCompensation }
}

-- [3] CÁC HÀM XỬ LÝ CHÍNH
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
        if root:FindFirstChild("V11_Att") then root.V11_Att:Destroy() end
    end
end

local function ToggleNoclip()
    State.Noclip = not State.Noclip
    if not State.Noclip then
        for part, canCollide in pairs(State.ColCache) do
            if part and part.Parent then part.CanCollide = canCollide end
        end
        State.ColCache = setmetatable({}, {__mode = "k"})
    end
end

local function ApplyInvis(v)
    if (v:IsA("BasePart") or v:IsA("Decal")) and v.Name ~= "HumanoidRootPart" then
        if State.Invis then
            if State.TransCache[v] == nil then State.TransCache[v] = v.Transparency end
            v.Transparency = 1
        else
            v.Transparency = State.TransCache[v] or 0
        end
    end
end

-- [4] VÒNG LẶP HỆ THỐNG
Janitor:Connect(RunService.Stepped:Connect(function(_, dt)
    local char = player.Character
    if not char then return end

    if State.Fly then
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if root and root:FindFirstChild("V11_Att") and hum then
            local att = root.V11_Att
            local lv, ao = att.V11_LV, att.V11_AO
            local cam = workspace.CurrentCamera
            local moveDir = hum.MoveDirection
            local targetVel = Vector3.new(0,0,0)
            
            if moveDir.Magnitude > 0 then targetVel = moveDir.Unit * State.FlySpeed end
            if State.Up then targetVel += Vector3.new(0, State.FlySpeed, 0) end
            if State.Down then targetVel += Vector3.new(0, -State.FlySpeed, 0) end
            
            lv.VectorVelocity = lv.VectorVelocity:Lerp(targetVel, 15 * dt)
            ao.CFrame = cam.CFrame
        end
    end

    if State.Noclip then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") then
                if State.ColCache[part] == nil then State.ColCache[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    end
end))

-- [5] GIAO DIỆN (UI)
local gui = Janitor:Add(Instance.new("ScreenGui", player.PlayerGui))
gui.Name = "THD_V11_PRO"; gui.ResetOnSpawn = false

local Main = Janitor:Add(Instance.new("Frame", gui))
Main.Size = UDim2.new(0, 220, 0, 380); Main.Position = UDim2.new(0.05, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "THĐ NANO V11"; Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold; Title.BackgroundTransparency = 1

local function Btn(txt, pos, cb)
    local b = Instance.new("TextButton", Main)
    b.Size = UDim2.new(0.9, 0, 0, 35); b.Position = pos; b.Text = txt
    b.BackgroundColor3 = Color3.fromRGB(30,30,30); b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamMedium; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        local s = cb()
        if s ~= nil then b.BackgroundColor3 = s and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(30,30,30) end
    end)
    return b
end

Btn("FLY: ON/OFF", UDim2.new(0.05, 0, 0.15, 0), function() ToggleFly(); return State.Fly end)
local up = Btn("UP", UDim2.new(0.05, 0, 0.27, 0), function() end); up.Size = UDim2.new(0.42, 0, 0, 35)
local dw = Btn("DOWN", UDim2.new(0.53, 0, 0.27, 0), function() end); dw.Size = UDim2.new(0.42, 0, 0, 35)
up.MouseButton1Down:Connect(function() State.Up = true end); up.MouseButton1Up:Connect(function() State.Up = false end)
dw.MouseButton1Down:Connect(function() State.Down = true end); dw.MouseButton1Up:Connect(function() State.Down = false end)

Btn("NOCLIP (WALL)", UDim2.new(0.05, 0, 0.4, 0), function() ToggleNoclip(); return State.Noclip end)
Btn("SPEED (150)", UDim2.new(0.05, 0, 0.53, 0), function() 
    State.Speed = (State.Speed == 16) and 150 or 16
    if player.Character then player.Character.Humanoid.WalkSpeed = State.Speed end
    return State.Speed > 16
end)
Btn("FULL BRIGHT", UDim2.new(0.05, 0, 0.66, 0), function()
    State.Bright = not State.Bright
    if State.Bright then
        Lighting.Ambient = Color3.new(1,1,1); Lighting.ExposureCompensation = 1
    else
        Lighting.Ambient = State.LightOrig.Amb; Lighting.ExposureCompensation = State.LightOrig.Exp
    end
    return State.Bright
end)
Btn("KILL SCRIPT", UDim2.new(0.05, 0, 0.85, 0), function() 
    if State.Fly then ToggleFly() end
    if State.Noclip then ToggleNoclip() end
    Janitor:Clean() 
end).BackgroundColor3 = Color3.fromRGB(120, 0, 0)

-- Auto-Run khi respawn
player.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    if State.Speed > 16 then c:WaitForChild("Humanoid").WalkSpeed = State.Speed end
end)
