--===========================
--         ONESP
--===========================
if getgenv().ONESP_LOADED then return end
getgenv().ONESP_LOADED = true

--================ SERVICES =================
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local Camera=workspace.CurrentCamera
local SoundService=game:GetService("SoundService")
local LP=Players.LocalPlayer

--================ CONFIG =================
local CONFIG={
    FOV_MIN=40,
    FOV_MAX=260,

    BASE_COLOR=Color3.fromRGB(160,90,255),
    DIM_COLOR=Color3.fromRGB(70,60,100),

    AIM_STRENGTHS={
        {value=0.18,name="LEGIT"},
        {value=0.40,name="SMOOTH"},
        {value=0.85,name="SOLID"}
    },

    BONES={
        {name="HEAD",parts={"Head"}},
        {name="TORSO",parts={"UpperTorso","Torso","LowerTorso"}},
        {name="ROOT",parts={"HumanoidRootPart"}}
    }
}

--================ STATE =================
getgenv().ONESP_STATE={
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
local snd=Instance.new("Sound")
snd.SoundId="rbxassetid://6026984224"
snd.Volume=1
snd.Parent=SoundService
local function Play() snd:Play() end

--================ DRAWING =================
local Drawings={}
local function D(t,p)
    local o=Drawing.new(t)
    if p then for k,v in pairs(p) do o[k]=v end end
    table.insert(Drawings,o)
    return o
end

--================ UI =================
local UI={Pos=Vector2.new(80,200),Size=Vector2.new(220,330),MinSize=Vector2.new(220,32),Drag=false,Offset=Vector2.zero}

local Frame=D("Square",{Filled=true,Transparency=0.88,Color=Color3.fromRGB(20,15,30)})
local Bar=D("Square",{Filled=true})
local Title=D("Text",{Text="ONESP",Size=18,Center=true,Outline=true})
local Arrow=D("Text",{Text="▼",Size=18,Center=true,Outline=true})

local SliderBG=D("Square",{Filled=true,Transparency=0.7})
local SliderFill=D("Square",{Filled=true})
local SliderText=D("Text",{Size=13,Center=true,Outline=true})

local draggingSlider=false

local Buttons={
    {key="ESP",label="ESP"},
    {key="AIM",label="AIMBOT"},
    {key="RAINBOW",label="RAINBOW"},
    {key="FORCE",label="FORCE"},
    {key="BONE",label="BONE"}
}

local Btn={}
for _,b in ipairs(Buttons) do
    Btn[b.key]={Bg=D("Square",{Filled=true,Transparency=0.9}),Txt=D("Text",{Size=14,Center=true,Outline=true})}
end

--================ UI DRAW =================
local function RefreshUI()
    local s=getgenv().ONESP_STATE
    for _,d in ipairs(Drawings) do d.Visible=false end
    if not s.UI or not s.ENABLED then return end

    local size=s.MIN and UI.MinSize or UI.Size

    Frame.Visible=true Frame.Position=UI.Pos Frame.Size=size
    Bar.Visible=true Bar.Position=UI.Pos Bar.Size=Vector2.new(size.X,3) Bar.Color=CONFIG.BASE_COLOR
    Title.Visible=true Title.Position=UI.Pos+Vector2.new(size.X/2,6) Title.Color=CONFIG.BASE_COLOR
    Arrow.Visible=true Arrow.Text=s.MIN and "▶" or "▼"
    Arrow.Position=UI.Pos+Vector2.new(size.X-14,6)

    if s.MIN then return end

    for i,b in ipairs(Buttons) do
        local o=Btn[b.key]
        local y=35+(i-1)*35

        o.Bg.Visible=true
        o.Bg.Position=UI.Pos+Vector2.new(30,y)
        o.Bg.Size=Vector2.new(160,28)

        if b.key=="FORCE" then
            o.Bg.Color=CONFIG.BASE_COLOR
            o.Txt.Text="FORCE: "..CONFIG.AIM_STRENGTHS[s.AIM_POWER].name
        elseif b.key=="BONE" then
            o.Bg.Color=CONFIG.BASE_COLOR
            o.Txt.Text="BONE: "..CONFIG.BONES[s.AIM_BONE].name
        else
            o.Bg.Color=s[b.key] and CONFIG.BASE_COLOR or CONFIG.DIM_COLOR
            o.Txt.Text=b.label.." "..(s[b.key] and "ON" or "OFF")
        end

        o.Txt.Visible=true
        o.Txt.Position=o.Bg.Position+Vector2.new(80,6)
    end

    local sy=35+#Buttons*35+10
    SliderBG.Visible=true
    SliderBG.Position=UI.Pos+Vector2.new(30,sy)
    SliderBG.Size=Vector2.new(160,18)
    SliderBG.Color=CONFIG.DIM_COLOR

    local pct=(s.FOV-CONFIG.FOV_MIN)/(CONFIG.FOV_MAX-CONFIG.FOV_MIN)
    pct=math.clamp(pct,0,1)

    SliderFill.Visible=true
    SliderFill.Position=SliderBG.Position
    SliderFill.Size=Vector2.new(160*pct,18)
    SliderFill.Color=CONFIG.BASE_COLOR

    SliderText.Visible=true
    SliderText.Text="FOV: "..s.FOV
    SliderText.Position=SliderBG.Position+Vector2.new(80,2)
end

--================ INPUT =================
UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    local s=getgenv().ONESP_STATE

    if i.KeyCode==Enum.KeyCode.F4 then
        s.ENABLED=not s.ENABLED
        s.UI=s.ENABLED
        Play()
        RefreshUI()
        return
    end

    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        local p=UIS:GetMouseLocation()

        if (p-Arrow.Position).Magnitude<=12 then
            s.MIN=not s.MIN
            RefreshUI()
            return
        end

        for _,b in ipairs(Buttons) do
            local o=Btn[b.key]
            if o.Bg.Visible and p.X>=o.Bg.Position.X and p.X<=o.Bg.Position.X+o.Bg.Size.X
            and p.Y>=o.Bg.Position.Y and p.Y<=o.Bg.Position.Y+o.Bg.Size.Y then

                if b.key=="FORCE" then
                    s.AIM_POWER=s.AIM_POWER%#CONFIG.AIM_STRENGTHS+1
                elseif b.key=="BONE" then
                    s.AIM_BONE=s.AIM_BONE%#CONFIG.BONES+1
                else
                    s[b.key]=not s[b.key]
                end

                Play()
                RefreshUI()
                return
            end
        end

        if p.X>=SliderBG.Position.X and p.X<=SliderBG.Position.X+SliderBG.Size.X
        and p.Y>=SliderBG.Position.Y and p.Y<=SliderBG.Position.Y+SliderBG.Size.Y then
            draggingSlider=true
            return
        end

        if p.X>=UI.Pos.X and p.X<=UI.Pos.X+Frame.Size.X and p.Y>=UI.Pos.Y and p.Y<=UI.Pos.Y+28 then
            UI.Drag=true UI.Offset=p-UI.Pos
        end
    end
end)

UIS.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then
        UI.Drag=false
        draggingSlider=false
    end
end)

RunService.RenderStepped:Connect(function()
    if draggingSlider then
        local p=UIS:GetMouseLocation()
        local x=math.clamp((p.X-SliderBG.Position.X)/SliderBG.Size.X,0,1)
        getgenv().ONESP_STATE.FOV=math.floor(CONFIG.FOV_MIN+x*(CONFIG.FOV_MAX-CONFIG.FOV_MIN))
        RefreshUI()
    end
    if UI.Drag then UI.Pos=UIS:GetMouseLocation()-UI.Offset RefreshUI() end
end)

--================ FOV =================
local FOV=D("Circle",{Thickness=2,Filled=false})

--================ AIM LOOP =================
local function GetTarget()
    local s=getgenv().ONESP_STATE
    local mouse=UIS:GetMouseLocation()
    local best,dist=nil,s.FOV

    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and plr.Character then
            local hum=plr.Character:FindFirstChild("Humanoid")
            if hum and hum.Health>0 then
                for _,part in ipairs(CONFIG.BONES[s.AIM_BONE].parts) do
                    local p=plr.Character:FindFirstChild(part)
                    if p then
                        local v,ons=Camera:WorldToViewportPoint(p.Position)
                        if ons then
                            local d=(Vector2.new(v.X,v.Y)-mouse).Magnitude
                            if d<dist then best=p dist=d end
                        end
                    end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    local s=getgenv().ONESP_STATE
    if not s.ENABLED then return end

    FOV.Visible=s.AIM
    FOV.Position=UIS:GetMouseLocation()
    FOV.Radius=s.FOV
    FOV.Color=s.RAINBOW and Color3.fromHSV(tick()%5/5,1,1) or CONFIG.BASE_COLOR

    if s.AIM and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local t=GetTarget()
        if t then
            local strength=CONFIG.AIM_STRENGTHS[s.AIM_POWER].value
            Camera.CFrame=Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position,t.Position),strength)
        end
    end
end)

RefreshUI()
