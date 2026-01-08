--===========================
--         ONESP
--===========================
if getgenv().ONESP_LOADED then return end
getgenv().ONESP_LOADED = true

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local Camera     = workspace.CurrentCamera
local LP         = Players.LocalPlayer

--================ CONFIG =================
local CONFIG = {
    FOV_RADIUS = 130,

    BASE_COLOR = Color3.fromRGB(155, 89, 255),
    DIM_COLOR  = Color3.fromRGB(80, 60, 120),
    HEAD_COLOR = Color3.fromRGB(255, 0, 0),

    -- TEXTO (ESCALA INVERSA)
    MIN_TEXT   = 13,
    MAX_TEXT   = 28,
    SCALE_DIST = 1200 -- quanto maior, mais suave
}

--================ STATE =================
getgenv().ONESP_STATE = {
    ESP=true,
    AIM=false,
    RAINBOW=false,
    UI=true,
    MIN=false
    WALLCHECK=true
}

--================ DRAWING =================
local Drawings={}
local function D(t,p)
    local o=Drawing.new(t)
    if p then for k,v in pairs(p) do o[k]=v end end
    table.insert(Drawings,o)
    return o
end

--================ UI =================
local UI={Pos=Vector2.new(80,220),Size=Vector2.new(210,170),MinSize=Vector2.new(210,32),Drag=false,Offset=Vector2.zero}

local Frame=D("Square",{Filled=true,Transparency=0.88,Color=Color3.fromRGB(20,15,35)})
local Bar  =D("Square",{Filled=true,Color=CONFIG.BASE_COLOR})
local Title=D("Text",{Text="ONESP",Size=18,Center=true,Outline=true,Color=CONFIG.BASE_COLOR})
local Arrow=D("Text",{Text="▼",Size=18,Center=true,Outline=true,Color=Color3.fromRGB(220,220,220)})

local Buttons={
    {name="ESP",key="ESP"},
    {name="AIMBOT",key="AIM"},
    {name="RAINBOW",key="RAINBOW"}
    {name="WALLCHECK", key="WALLCHECK"}
}

local Btn={}
for _,b in ipairs(Buttons) do
    Btn[b.key]={Bg=D("Square",{Filled=true,Transparency=0.85}),Txt=D("Text",{Size=14,Center=true,Outline=true})}
end

local function RefreshUI()
    if not getgenv().ONESP_STATE.UI then
        for _,d in ipairs(Drawings) do d.Visible=false end
        return
    end

    local min=getgenv().ONESP_STATE.MIN
    local size=min and UI.MinSize or UI.Size

    Frame.Visible=true Frame.Position=UI.Pos Frame.Size=size
    Bar.Visible=true   Bar.Position=UI.Pos   Bar.Size=Vector2.new(size.X,3)
    Title.Visible=true Title.Position=UI.Pos+Vector2.new(size.X/2,6)

    Arrow.Visible=true
    Arrow.Text=min and "▶" or "▼"
    Arrow.Position=UI.Pos+Vector2.new(size.X-14,6)

    for _,o in pairs(Btn) do o.Bg.Visible=false o.Txt.Visible=false end
    if min then return end

    for i,b in ipairs(Buttons) do
        local o=Btn[b.key]
        local y=35+(i-1)*40
        local on=getgenv().ONESP_STATE[b.key]
        o.Bg.Visible=true
        o.Bg.Position=UI.Pos+Vector2.new(25,y)
        o.Bg.Size=Vector2.new(160,30)
        o.Bg.Color=on and CONFIG.BASE_COLOR or CONFIG.DIM_COLOR
        o.Txt.Visible=true
        o.Txt.Text=b.name..(on and " ON" or " OFF")
        o.Txt.Position=o.Bg.Position+Vector2.new(80,7)
    end
end

--================ INPUT =================
local mouseStart
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        local p=UIS:GetMouseLocation()
        mouseStart=p
        if math.abs(p.X-Arrow.Position.X)<=10 and math.abs(p.Y-Arrow.Position.Y)<=10 then
            getgenv().ONESP_STATE.MIN=not getgenv().ONESP_STATE.MIN
            RefreshUI()
            return
        end
        if p.X>=UI.Pos.X and p.X<=UI.Pos.X+Frame.Size.X and p.Y>=UI.Pos.Y and p.Y<=UI.Pos.Y+28 then
            UI.Drag=true UI.Offset=p-UI.Pos
        end
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
    UI.Drag=false
    local p=UIS:GetMouseLocation()
    if (p-mouseStart).Magnitude>6 or getgenv().ONESP_STATE.MIN then return end
    for _,b in ipairs(Buttons) do
        local o=Btn[b.key]
        if p.X>=o.Bg.Position.X and p.X<=o.Bg.Position.X+160
        and p.Y>=o.Bg.Position.Y and p.Y<=o.Bg.Position.Y+30 then
            getgenv().ONESP_STATE[b.key]=not getgenv().ONESP_STATE[b.key]
            RefreshUI()
            return
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if UI.Drag then UI.Pos=UIS:GetMouseLocation()-UI.Offset RefreshUI() end
end)

--================ RAINBOW =================
local function Color()
    if not getgenv().ONESP_STATE.RAINBOW then return CONFIG.BASE_COLOR end
    return Color3.fromHSV(tick()%5/5,1,1)
end

--================ FOV =================
local FOV=D("Circle",{Radius=CONFIG.FOV_RADIUS,Thickness=2,Filled=false})

--================ ESP =================
local ESP={}
local function Add(p)
    if p==LP then return end
    ESP[p]={
        Box=D("Square",{Filled=false}),
        Head=D("Square",{Filled=true,Size=Vector2.new(10,10)}),
        Name=D("Text",{Center=true,Outline=true})
    }
end
for _,p in ipairs(Players:GetPlayers()) do Add(p) end
Players.PlayerAdded:Connect(Add)
Players.PlayerRemoving:Connect(function(p)
    if ESP[p] then for _,d in pairs(ESP[p]) do d:Remove() end ESP[p]=nil end
end)

--================ AIMBOT =================
local hold=false
UIS.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton2 then hold=true end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton2 then hold=false end end)

local function Closest()
    local best,dist=nil,CONFIG.FOV_RADIUS
    for p,_ in pairs(ESP) do
        local c=p.Character
        local h=c and c:FindFirstChild("Head")
        local hum=c and c:FindFirstChildOfClass("Humanoid")
        if h and hum and hum.Health>0 then
            local sp,on=Camera:WorldToViewportPoint(h.Position)
            if on then
                local d=(Vector2.new(sp.X,sp.Y)-UIS:GetMouseLocation()).Magnitude
                if d<dist then dist=d best=h end
            end
        end
    end
    return best
end

--================ MAIN LOOP =================
RunService.RenderStepped:Connect(function()
    local col=Color()
    Bar.Color=col Title.Color=col FOV.Color=col

    FOV.Position=UIS:GetMouseLocation()
    FOV.Visible=getgenv().ONESP_STATE.AIM

    if getgenv().ONESP_STATE.AIM and hold then
        local t=Closest()
        if t then Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,t.Position),0.30) end
    end

    local myRoot=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    for p,e in pairs(ESP) do
        local c=p.Character
        local r=c and c:FindFirstChild("HumanoidRootPart")
        local h=c and c:FindFirstChild("Head")
        local hum=c and c:FindFirstChildOfClass("Humanoid")

        if getgenv().ONESP_STATE.ESP and r and h and hum and hum.Health>0 then
            local rs,on=Camera:WorldToViewportPoint(r.Position)
            if not on then for _,d in pairs(e) do d.Visible=false end continue end

            local dist=(myRoot.Position-r.Position).Magnitude

            -- TAMANHO INVERSO 🔥
            local size=math.clamp(
                CONFIG.MIN_TEXT + (dist/CONFIG.SCALE_DIST)*(CONFIG.MAX_TEXT-CONFIG.MIN_TEXT),
                CONFIG.MIN_TEXT, CONFIG.MAX_TEXT
            )

            local top=Camera:WorldToViewportPoint(r.Position+Vector3.new(0,3,0))
            local bot=Camera:WorldToViewportPoint(r.Position-Vector3.new(0,3,0))
            local hgt=math.abs(top.Y-bot.Y)
            local w=hgt/2

            e.Box.Size=Vector2.new(w,hgt)
            e.Box.Position=Vector2.new(rs.X-w/2,rs.Y-hgt/2)
            e.Box.Color=col

            local hs=Camera:WorldToViewportPoint(h.Position)
            e.Head.Position=Vector2.new(hs.X-5,hs.Y-5)
            e.Head.Color=CONFIG.HEAD_COLOR

            e.Name.Size=size
            e.Name.Text=p.Name.." ["..math.floor(dist).."m]"
            e.Name.Position=Vector2.new(rs.X,rs.Y-hgt/2-18)
            e.Name.Color=col

            for _,d in pairs(e) do d.Visible=true end
        else
            for _,d in pairs(e) do d.Visible=false end
        end
    end
end)

RefreshUI()
