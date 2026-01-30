-- 🔐 ONESP KEY SYSTEM v2 (MINIMAL + OLHO)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- ===== CONFIG =====
local ADMIN_KEY = "KEYGABRIELPAINEL"

local VALID_KEYS = {
    ["ONESP-7DIAS-ABC123"] = 7,
    ["ONESP-30DIAS-XYZ999"] = 30,
}

local SAVE_FILE = "onesp_key.json"

-- ===== FUNÇÕES =====
local function Save(data)
    writefile(SAVE_FILE, HttpService:JSONEncode(data))
end

local function Load()
    if isfile(SAVE_FILE) then
        return HttpService:JSONDecode(readfile(SAVE_FILE))
    end
    return nil
end

local function IsValid(data)
    if not data then return false end
    if data.admin then return true end
    return data.expire and os.time() < data.expire
end

-- ===== AUTO LOGIN =====
local saved = Load()
if IsValid(saved) then
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/ONESPower1/onesp/refs/heads/main/ONESP.LUA"
    ))()
    return
end

-- ===== LIMPA UI ANTIGA =====
pcall(function()
    CoreGui.ONESP_KEY_UI:Destroy()
end)

-- ===== UI =====
local gui = Instance.new("ScreenGui")
gui.Name = "ONESP_KEY_UI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 360, 0, 220)
frame.Position = UDim2.new(0.5, -180, 0.5, -110)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

-- 👁️ OLHO DIREITA
local eye = Instance.new("ImageLabel", frame)
eye.Size = UDim2.new(0,40,0,40)
eye.Position = UDim2.new(1,-48,0,12)
eye.BackgroundTransparency = 1
eye.Image = "rbxassetid://112075600568307"
eye.ScaleType = Enum.ScaleType.Fit
eye.ZIndex = 10

-- TÍTULO
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,-70,0,50)
title.Position = UDim2.new(0,16,0,8)
title.Text = "ONESP KEY SYSTEM"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left

-- INPUT
local box = Instance.new("TextBox", frame)
box.Size = UDim2.new(1,-32,0,40)
box.Position = UDim2.new(0,16,0,70)
box.PlaceholderText = "Digite sua key"
box.Font = Enum.Font.Gotham
box.TextSize = 16
box.TextColor3 = Color3.fromRGB(230,230,230)
box.BackgroundColor3 = Color3.fromRGB(35,35,35)
box.ClearTextOnFocus = false
Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

-- STATUS
local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,-32,0,24)
status.Position = UDim2.new(0,16,0,116)
status.Text = ""
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextColor3 = Color3.fromRGB(255,80,80)
status.BackgroundTransparency = 1

-- BOTÃO
local button = Instance.new("TextButton", frame)
button.Size = UDim2.new(1,-32,0,42)
button.Position = UDim2.new(0,16,0,150)
button.Text = "VALIDAR"
button.Font = Enum.Font.GothamBold
button.TextSize = 16
button.TextColor3 = Color3.new(1,1,1)
button.BackgroundColor3 = Color3.fromRGB(0,160,0)
Instance.new("UICorner", button).CornerRadius = UDim.new(0,8)

-- ===== CLICK (KEY FUNCIONA) =====
button.MouseButton1Click:Connect(function()
    local key = box.Text

    -- ADMIN
    if key == ADMIN_KEY then
        Save({ admin = true })
        gui:Destroy()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/ONESPower1/onesp/refs/heads/main/ONESP.LUA"
        ))()
        return
    end

    local days = VALID_KEYS[key]
    if days then
        Save({
            key = key,
            expire = os.time() + (days * 86400)
        })
        gui:Destroy()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/ONESPower1/onesp/refs/heads/main/ONESP.LUA"
        ))()
    else
        status.Text = "KEY INVÁLIDA"
        button.BackgroundColor3 = Color3.fromRGB(170,0,0)
    end
end)
