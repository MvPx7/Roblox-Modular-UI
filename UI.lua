-- UI.lua
local GITHUB_RAW = "https://raw.githubusercontent.com/MvPx7/Roblox-Modular-UI/main/Modules/"

local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local TweenService= game:GetService("TweenService")
local LP          = Players.LocalPlayer
local PlayerGui   = LP:WaitForChild("PlayerGui")
local IsMobile    = UIS.TouchEnabled and not UIS.KeyboardEnabled

local TABS = {
    { name = "Home",    module = "HomeTab"   },
    { name = "NPC",     module = "NPCTab"    },
    { name = "Player",  module = "PlayerTab" },
    { name = "Visual",  module = "VisualTab" },
    { name = "Config",  module = "ConfigTab" },
}

local T = {
    BG       = Color3.fromRGB(12, 12, 18),
    SURFACE  = Color3.fromRGB(20, 20, 28),
    BORDER   = Color3.fromRGB(35, 35, 50),
    ACCENT   = Color3.fromRGB(99, 102, 241),
    TEXT     = Color3.fromRGB(220, 220, 235),
    SUBTEXT  = Color3.fromRGB(100, 100, 120),
    FONT     = Enum.Font.GothamMedium,
    FONTB    = Enum.Font.GothamBold,
    MOBILE   = IsMobile,
    -- Tamanhos
    WIN_W    = IsMobile and 300 or 340,
    WIN_H    = IsMobile and 400 or 360,
    HDR_H    = IsMobile and 40  or 34,
    TAB_H    = IsMobile and 36  or 30,
    CORNER   = UDim.new(0, 10),
}

-- ── Helpers ──────────────────────────────────────────────────────────────────
local function mk(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props) do o[k]=v end
    if parent then o.Parent = parent end
    return o
end
local function corner(p, r)
    return mk("UICorner",{CornerRadius=r or T.CORNER},p)
end
local function stroke(p, color, thick)
    return mk("UIStroke",{Color=color or T.BORDER, Thickness=thick or 1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p)
end
local function tween(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad), props):Play()
end

local function loadModule(name)
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(GITHUB_RAW..name..".lua",true))()
    end)
    if ok then return res end
    warn("[UI] "..name.." falhou: "..tostring(res))
end

-- ── ScreenGui ────────────────────────────────────────────────────────────────
local SG = mk("ScreenGui",{
    Name="MainGui", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    Parent=PlayerGui
})

-- ── Janela ───────────────────────────────────────────────────────────────────
local WIN_W, WIN_H = T.WIN_W, T.WIN_H
local Window = mk("Frame",{
    Name="Window",
    Size=UDim2.fromOffset(WIN_W, WIN_H),
    Position=UDim2.fromScale(0.5,0.5),
    AnchorPoint=Vector2.new(0.5,0.5),
    BackgroundColor3=T.BG,
    BorderSizePixel=0,
    Parent=SG,
})
corner(Window)
stroke(Window, T.BORDER, 1)

-- ── Header ───────────────────────────────────────────────────────────────────
local Header = mk("Frame",{
    Size=UDim2.new(1,0,0,T.HDR_H),
    BackgroundColor3=T.SURFACE,
    BorderSizePixel=0,
    Parent=Window,
})
corner(Header)
-- tapa canto inferior do header
mk("Frame",{
    Size=UDim2.new(1,0,0,10),
    Position=UDim2.new(0,0,1,-10),
    BackgroundColor3=T.SURFACE,
    BorderSizePixel=0,
    Parent=Header,
})

mk("TextLabel",{
    Size=UDim2.new(1,-50,1,0),
    Position=UDim2.fromOffset(10,0),
    BackgroundTransparency=1,
    Text="✦ Menu",
    TextColor3=T.TEXT,
    Font=T.FONTB,
    TextSize=IsMobile and 14 or 13,
    TextXAlignment=Enum.TextXAlignment.Left,
    Parent=Header,
})

-- MinBtn
local minimized = false
local MinBtn = mk("TextButton",{
    Size=UDim2.fromOffset(IsMobile and 38 or 30, IsMobile and 26 or 22),
    AnchorPoint=Vector2.new(1,0.5),
    Position=UDim2.new(1,-8,0.5,0),
    BackgroundColor3=T.BORDER,
    Text="−",
    TextColor3=T.TEXT,
    Font=T.FONTB,
    TextSize=16,
    BorderSizePixel=0,
    AutoButtonColor=false,
    Parent=Header,
})
corner(MinBtn, UDim.new(0,6))

local TabBar, ContentArea

local function clampWindow()
    local vp = workspace.CurrentCamera.ViewportSize
    local ap = Window.AbsolutePosition
    local as = Window.AbsoluteSize
    local nx = math.clamp(ap.X, 0, vp.X - as.X)
    local ny = math.clamp(ap.Y, 0, vp.Y - as.Y)
    Window.Position = UDim2.fromOffset(nx, ny)
end

local function setMinimized(s)
    minimized = s
    MinBtn.Text = s and "+" or "−"
    if TabBar     then TabBar.Visible     = not s end
    if ContentArea then ContentArea.Visible= not s end
    local h = s and T.HDR_H or WIN_H
    tween(Window, 0.15, {Size=UDim2.fromOffset(WIN_W, h)})
    task.delay(0.16, clampWindow)
end

MinBtn.Activated:Connect(function() setMinimized(not minimized) end)

-- ── Drag ─────────────────────────────────────────────────────────────────────
do
    local drag, sp, sw
    local function startDrag(pos)
        -- Não iniciar se clicar no MinBtn
        local bp, bs = MinBtn.AbsolutePosition, MinBtn.AbsoluteSize
        if pos.X>=bp.X and pos.X<=bp.X+bs.X and pos.Y>=bp.Y and pos.Y<=bp.Y+bs.Y then return end
        drag=true; sp=pos; sw=Window.Position
    end
    local function stopDrag() drag=false end
    local function moveDrag(pos)
        if not drag then return end
        local d=pos-sp
        local vp=workspace.CurrentCamera.ViewportSize
        local nx=math.clamp(sw.X.Offset+d.X, 0, vp.X-WIN_W)
        local ny=math.clamp(sw.Y.Offset+d.Y, 0, vp.Y-(minimized and T.HDR_H or WIN_H))
        Window.Position=UDim2.fromOffset(nx,ny)
    end
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then startDrag(i.Position) end
    end)
    Header.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then stopDrag() end
    end)
    UIS.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch then moveDrag(i.Position) end
    end)
end

-- ── TabBar ───────────────────────────────────────────────────────────────────
TabBar = mk("Frame",{
    Size=UDim2.new(1,-16,0,T.TAB_H),
    Position=UDim2.new(0,8,0,T.HDR_H+4),
    BackgroundTransparency=1,
    Parent=Window,
})
local tll=mk("UIListLayout",{
    FillDirection=Enum.FillDirection.Horizontal,
    SortOrder=Enum.SortOrder.LayoutOrder,
    Padding=UDim.new(0,4),
},TabBar)

-- ── ContentArea ──────────────────────────────────────────────────────────────
local TAB_OFFSET = T.HDR_H + T.TAB_H + 8
ContentArea = mk("Frame",{
    Size=UDim2.new(1,0,1,-TAB_OFFSET),
    Position=UDim2.fromOffset(0,TAB_OFFSET),
    BackgroundTransparency=1,
    Parent=Window,
})

-- ── Tabs ─────────────────────────────────────────────────────────────────────
local tabButtons, tabFrames, activeTab = {},{},nil

local function setActive(name)
    if activeTab==name then return end
    activeTab=name
    for _,td in ipairs(TABS) do
        local btn=tabButtons[td.name]
        local frm=tabFrames[td.name]
        local on=(td.name==name)
        tween(btn,0.1,{BackgroundTransparency=on and 0 or 1})
        btn.TextColor3=on and T.TEXT or T.SUBTEXT
        if frm then frm.Visible=on end
    end
end

for i,td in ipairs(TABS) do
    local btn=mk("TextButton",{
        Size=UDim2.new(1/#TABS,-4,1,0),
        BackgroundColor3=T.ACCENT,
        BackgroundTransparency=1,
        Text=td.name,
        TextColor3=T.SUBTEXT,
        Font=T.FONT,
        TextSize=IsMobile and 12 or 11,
        BorderSizePixel=0,
        AutoButtonColor=false,
        LayoutOrder=i,
        Parent=TabBar,
    })
    corner(btn,UDim.new(0,6))
    tabButtons[td.name]=btn

    local frm=mk("Frame",{
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,
        Visible=false,
        Parent=ContentArea,
    })
    tabFrames[td.name]=frm

    local mod=loadModule(td.module)
    if mod and mod.Init then
        mod.Init(frm,T)
    else
        mk("TextLabel",{
            Size=UDim2.fromScale(1,1),
            BackgroundTransparency=1,
            Text="⚠ "..td.module.." não encontrado",
            TextColor3=Color3.fromRGB(200,60,60),
            Font=T.FONT, TextSize=13,
            Parent=frm,
        })
    end
    btn.Activated:Connect(function() setActive(td.name) end)
end

setActive(TABS[1].name)
