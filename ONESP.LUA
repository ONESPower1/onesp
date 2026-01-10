--==================================================
--                ONESP
--==================================================
if getgenv().ONESP_LOADED then return end
getgenv().ONESP_LOADED = true

--================ SERVICES =================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local SoundService = game:GetService("SoundService")
local LP = Players.LocalPlayer

--================ CONFIG =================
local CONFIG = {
    COLORS = {
        MAIN = Color3.fromRGB(255,255,255), -- neon branco
        DARK = Color3.fromRGB(55,55,55),
        BG   = Color3.fromRGB(10,10,10),
        TEXT = Color3.fromRGB(255,255,255),
        HEAD = Color3.fromRGB(255,70,70)
    },

    FOV_MIN = 40,
    FOV_MAX = 260,

    AIM_STRENGTHS = {
        {value=0.25,name="LEGIT"},
        {value=0.55,name="SMOOTH"},
        {value=0.95,name="SOLID"}
    },

    BONES = {
        {name="HEAD",parts={"Head"}},
        {name="TORSO",parts={"UpperTorso","Torso","LowerTorso"}},
        {name="ROOT",parts={"HumanoidRootPart"}}
    }
}

--================ STATE =================
local STATE = {
    ENABLED=true,
    UI=true,
    MIN=false,

    ESP=true,
    AIM=false,
    RAINBOW=false,

    AIM_POWER=3,
    AIM_BONE=1,
    FOV=130
}

--================ SOUND =================
local snd = Instance.new("Sound")
snd.SoundId="rbxassetid://6026984224"
snd.Volume=1
snd.Parent=SoundService
local function Beep() snd:Play() end

--================ DRAW SYSTEM =================
local UIDrawings, ESPDrawings = {}, {}

local function D(t,p,esp)
    local o = Drawing.new(t)
    for k,v in pairs(p or {}) do o[k]=v end
    table.insert(esp and ESPDrawings or UIDrawings,o)
    return o
end

--================ UI =================
local UI={Pos=Vector2.new(90,220),Size=Vector2.new(240,340),MinSize=Vector2.new(240,32),Drag=false,Offset=Vector2.zero}

local Frame=D("Square",{Filled=true,Transparency=0.88,Color=CONFIG.COLORS.BG})
local Bar=D("Square",{Filled=true})
local Title=D("Text",{Text="ONESP",Size=18,Center=true,Outline=true})
local Arrow=D("Text",{Text="▼",Size=18,Center=true,Outline=true})

local Buttons={
    {key="ESP",label="ESP"},
    {key="AIM",label="AIMBOT"},
    {key="RAINBOW",label="RAINBOW"},
    {key="FORCE",label="FORCE"},
    {key="BONE",label="BONE"}
}

local Btn={}
for _,b in ipairs(Buttons) do
    Btn[b.key]={Bg=D("Square",{Filled=true,Transparency=0.85}),Txt=D("Text",{Size=14,Center=true,Outline=true})}
end

local SliderBG=D("Square",{Filled=true,Transparency=0.7})
local SliderFill=D("Square",{Filled=true})
local SliderTxt=D("Text",{Size=13,Center=true,Outline=true})
local draggingSlider=false

--================ UI RENDER =================
local function RefreshUI()
    for _,d in ipairs(UIDrawings) do d.Visible=false end
    if not STATE.UI or not STATE.ENABLED then return end

    local size=STATE.MIN and UI.MinSize or UI.Size

    Frame.Visible=true Frame.Position=UI.Pos Frame.Size=size
    Bar.Visible=true Bar.Position=UI.Pos Bar.Size=Vector2.new(size.X,3)
    Bar.Color=CONFIG.COLORS.MAIN

    Title.Visible=true
    Title.Position=UI.Pos+Vector2.new(size.X/2,6)
    Title.Color=CONFIG.COLORS.TEXT

    Arrow.Visible=true
    Arrow.Text=STATE.MIN and "▶" or "▼"
    Arrow.Position=UI.Pos+Vector2.new(size.X-14,6)
    Arrow.Color=CONFIG.COLORS.TEXT

    if STATE.MIN then return end

    for i,b in ipairs(Buttons) do
        local o=Btn[b.key]
        local y=40+(i-1)*38
        o.Bg.Visible=true
        o.Bg.Position=UI.Pos+Vector2.new(30,y)
        o.Bg.Size=Vector2.new(180,30)

        if b.key=="FORCE" then
            o.Bg.Color=CONFIG.COLORS.DARK
            o.Txt.Text="FORCE: "..CONFIG.AIM_STRENGTHS[STATE.AIM_POWER].name
        elseif b.key=="BONE" then
            o.Bg.Color=CONFIG.COLORS.DARK
            o.Txt.Text="BONE: "..CONFIG.BONES[STATE.AIM_BONE].name
        else
            o.Bg.Color=STATE[b.key] and Color3.fromRGB(255,255,255) or CONFIG.COLORS.DARK
            o.Txt.Color=STATE[b.key] and Color3.fromRGB(0,0,0) or CONFIG.COLORS.TEXT
            o.Txt.Text=b.label.." "..(STATE[b.key] and "ON" or "OFF")
        end

        o.Txt.Visible=true
        o.Txt.Position=o.Bg.Position+Vector2.new(90,6)
    end

    local sy=40+#Buttons*38+14
    SliderBG.Visible=true
    SliderBG.Position=UI.Pos+Vector2.new(30,sy)
    SliderBG.Size=Vector2.new(180,18)
    SliderBG.Color=CONFIG.COLORS.DARK

    local pct=(STATE.FOV-CONFIG.FOV_MIN)/(CONFIG.FOV_MAX-CONFIG.FOV_MIN)
    SliderFill.Visible=true
    SliderFill.Position=SliderBG.Position
    SliderFill.Size=Vector2.new(180*pct,18)
    SliderFill.Color=CONFIG.COLORS.MAIN

    SliderTxt.Visible=true
    SliderTxt.Text="FOV "..STATE.FOV
    SliderTxt.Position=SliderBG.Position+Vector2.new(90,2)
    SliderTxt.Color=CONFIG.COLORS.TEXT
end

--================ INPUT =================
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode==Enum.KeyCode.F4 then
        STATE.ENABLED=not STATE.ENABLED
        STATE.UI=STATE.ENABLED
        Beep() RefreshUI() return
    end

    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        local p=UIS:GetMouseLocation()
        if (p-Arrow.Position).Magnitude<=12 then STATE.MIN=not STATE.MIN RefreshUI() return end

        for _,b in ipairs(Buttons) do
            local o=Btn[b.key]
            if o.Bg.Visible and p.X>=o.Bg.Position.X and p.X<=o.Bg.Position.X+o.Bg.Size.X
            and p.Y>=o.Bg.Position.Y and p.Y<=o.Bg.Position.Y+o.Bg.Size.Y then
                if b.key=="FORCE" then
                    STATE.AIM_POWER=STATE.AIM_POWER%#CONFIG.AIM_STRENGTHS+1
                elseif b.key=="BONE" then
                    STATE.AIM_BONE=STATE.AIM_BONE%#CONFIG.BONES+1
                else
                    STATE[b.key]=not STATE[b.key]
                end
                Beep() RefreshUI() return
            end
        end

        if p.X>=SliderBG.Position.X and p.X<=SliderBG.Position.X+SliderBG.Size.X
        and p.Y>=SliderBG.Position.Y and p.Y<=SliderBG.Position.Y+SliderBG.Size.Y then
            draggingSlider=true return
        end

        if p.X>=UI.Pos.X and p.X<=UI.Pos.X+Frame.Size.X and p.Y>=UI.Pos.Y and p.Y<=UI.Pos.Y+28 then
            UI.Drag=true UI.Offset=p-UI.Pos
        end
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then draggingSlider=false UI.Drag=false end
end)

RunService.RenderStepped:Connect(function()
    if draggingSlider then
        local p=UIS:GetMouseLocation()
        local x=math.clamp((p.X-SliderBG.Position.X)/SliderBG.Size.X,0,1)
        STATE.FOV=math.floor(CONFIG.FOV_MIN+x*(CONFIG.FOV_MAX-CONFIG.FOV_MIN))
        RefreshUI()
    end
    if UI.Drag then UI.Pos=UIS:GetMouseLocation()-UI.Offset RefreshUI() end
end)

--================ ESP =================
local ESP={}
local function AddESP(p)
    if p==LP then return end
    ESP[p]={
        Box=D("Square",{Filled=false,Thickness=1},true),
        Head=D("Square",{Filled=true,Size=Vector2.new(8,8)},true),
        Name=D("Text",{Size=13,Center=true,Outline=true},true),

        HP_BG=D("Square",{Filled=true,Transparency=0.6},true),
        HP_BAR=D("Square",{Filled=true},true)
    }
end

for _,p in ipairs(Players:GetPlayers()) do AddESP(p) end
Players.PlayerAdded:Connect(AddESP)
Players.PlayerRemoving:Connect(function(p)
    if ESP[p] then for _,d in pairs(ESP[p]) do d:Remove() end ESP[p]=nil end
end)

--================ AIM + ESP LOOP =================
local FOV=D("Circle",{Thickness=2,Filled=false})
local hue=0

local function GetTarget()
    local mouse=UIS:GetMouseLocation()
    local best,dist=nil,STATE.FOV
    for p,_ in pairs(ESP) do
        local c=p.Character
        local hum=c and c:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health>0 then
            for _,part in ipairs(CONFIG.BONES[STATE.AIM_BONE].parts) do
                local h=c:FindFirstChild(part)
                if h then
                    local v,on=Camera:WorldToViewportPoint(h.Position)
                    if on then
                        local d=(Vector2.new(v.X,v.Y)-mouse).Magnitude
                        if d<dist then best=h dist=d end
                    end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not STATE.ENABLED then return end

    -- Rainbow
    if STATE.RAINBOW then
        hue=(hue+1)%360
        FOV.Color=Color3.fromHSV(hue/360,1,1)
    else
        FOV.Color=CONFIG.COLORS.MAIN
    end

    FOV.Visible=STATE.AIM
    FOV.Position=UIS:GetMouseLocation()
    FOV.Radius=STATE.FOV

    if STATE.AIM and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=GetTarget()
        if t then
            Camera.CFrame=Camera.CFrame:Lerp(
                CFrame.new(Camera.CFrame.Position,t.Position),
                CONFIG.AIM_STRENGTHS[STATE.AIM_POWER].value
            )
        end
    end

    local myRoot=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    for p,e in pairs(ESP) do
        local c=p.Character
        local r=c and c:FindFirstChild("HumanoidRootPart")
        local h=c and c:FindFirstChild("Head")
        local hum=c and c:FindFirstChildOfClass("Humanoid")

        if STATE.ESP and r and h and hum and hum.Health>0 then
            local rs,on=Camera:WorldToViewportPoint(r.Position)
            if not on then for _,d in pairs(e) do d.Visible=false end continue end

            local top=Camera:WorldToViewportPoint(r.Position+Vector3.new(0,3,0))
            local bot=Camera:WorldToViewportPoint(r.Position-Vector3.new(0,3,0))
            local hgt=math.abs(top.Y-bot.Y)
            local w=hgt/2

            e.Box.Size=Vector2.new(w,hgt)
            e.Box.Position=Vector2.new(rs.X-w/2,rs.Y-hgt/2)
            e.Box.Color=STATE.RAINBOW and Color3.fromHSV(hue/360,1,1) or CONFIG.COLORS.MAIN

            local hs=Camera:WorldToViewportPoint(h.Position)
            e.Head.Position=Vector2.new(hs.X-4,hs.Y-4)
            e.Head.Color=CONFIG.COLORS.HEAD

            local dist=(myRoot.Position-r.Position).Magnitude
            e.Name.Text=p.Name.." ["..math.floor(dist).."m]"
            e.Name.Position=Vector2.new(rs.X,rs.Y-hgt/2-16)
            e.Name.Color=CONFIG.COLORS.TEXT

            -- Health bar
            local hp=math.clamp(hum.Health/hum.MaxHealth,0,1)
            local barX=e.Box.Position.X-6
            e.HP_BG.Position=Vector2.new(barX,e.Box.Position.Y)
            e.HP_BG.Size=Vector2.new(4,hgt)
            e.HP_BG.Color=Color3.fromRGB(20,20,20)

            e.HP_BAR.Position=Vector2.new(barX,e.Box.Position.Y+hgt-(hgt*hp))
            e.HP_BAR.Size=Vector2.new(4,hgt*hp)
            e.HP_BAR.Color=Color3.fromRGB(255*(1-hp),255*hp,0)

            for _,d in pairs(e) do d.Visible=true end
        else
            for _,d in pairs(e) do d.Visible=false end
        end
    end
end)

RefreshUI()
