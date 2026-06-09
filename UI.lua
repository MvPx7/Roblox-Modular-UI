-- UI.lua
-- Carregamento via loadstring + GitHub Raw. Suporte mobile + minimizar.

-- ──────────────────────────────────────────────
-- ⚙️  CONFIGURAÇÃO — edite apenas aqui
-- ──────────────────────────────────────────────
local GITHUB_RAW = "https://raw.githubusercontent.com/MvPx7/Roblox-Modular-UI/main/Modules/"

local Players     = game:GetService("Players")
local UIS         = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local IsMobile    = UIS.TouchEnabled and not UIS.KeyboardEnabled

local TABS = {
    { name = "Home",    module = "HomeTab"   },
    { name = "NPC",     module = "NPCTab"    },
    { name = "Player",  module = "PlayerTab" },
    { name = "Visual",  module = "VisualTab" },
    { name = "Config",  module = "ConfigTab" },
}

local THEME = {
    BG         = Color3.fromRGB(15,  15,  20),
    SURFACE    = Color3.fromRGB(22,  22,  30),
    ACCENT     = Color3.fromRGB(99,  102, 241),
    ACCENT_DIM = Color3.fromRGB(55,  57,  140),
    TEXT       = Color3.fromRGB(230, 230, 240),
    SUBTEXT    = Color3.fromRGB(130, 130, 150),
    TAB_H      = IsMobile and 44 or 36,
    HEADER_H   = IsMobile and 48 or 40,
    CORNER     = UDim.new(0, 8),
    FONT       = Enum.Font.GothamMedium,
    FONT_BOLD  = Enum.Font.GothamBold,
    MOBILE     = IsMobile,
}

-- ── Helpers ──────────────────────────────────────────────────────────────────
local function corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = r or THEME.CORNER
    c.Parent = p
end
local function newFrame(props)
    local f = Instance.new("Frame")
    for k,v in pairs(props) do f[k]=v end; return f
end
local function newLabel(props)
    local l = Instance.new("TextLabel")
    for k,v in pairs(props) do l[k]=v end; return l
end
local function newButton(props)
    local b = Instance.new("TextButton")
    for k,v in pairs(props) do b[k]=v end; return b
end

-- Carrega módulo remotamente
local function loadModule(name)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(GITHUB_RAW .. name .. ".lua", true))()
    end)
    if ok then return result end
    warn("[UI] Módulo '" .. name .. "' falhou: " .. tostring(result))
    return nil
end

-- ── GUI base ─────────────────────────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "MainGui"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = PlayerGui

local WIN_W = IsMobile and 420 or 520
local WIN_H = IsMobile and 480 or 420

local Window = newFrame({
    Name             = "Window",
    Size             = UDim2.fromOffset(WIN_W, WIN_H),
    Position         = UDim2.fromScale(0.5, 0.5),
    AnchorPoint      = Vector2.new(0.5, 0.5),
    BackgroundColor3 = THEME.BG,
    BorderSizePixel  = 0,
    Parent           = ScreenGui,
})
corner(Window)

-- Sombra
local Shadow = newFrame({
    Size                   = UDim2.new(1,12,1,12),
    Position               = UDim2.fromOffset(-6,-6),
    BackgroundColor3       = Color3.new(0,0,0),
    BackgroundTransparency = 0.6,
    BorderSizePixel        = 0,
    ZIndex                 = Window.ZIndex - 1,
    Parent                 = Window,
})
corner(Shadow, UDim.new(0,12))

-- Header
local Header = newFrame({
    Name             = "Header",
    Size             = UDim2.new(1, 0, 0, THEME.HEADER_H),
    BackgroundColor3 = THEME.SURFACE,
    BorderSizePixel  = 0,
    Parent           = Window,
})
corner(Header)
newFrame({ -- corrige cantos inferiores
    Size             = UDim2.new(1,0,0,THEME.CORNER.Offset),
    Position         = UDim2.new(0,0,1,-THEME.CORNER.Offset),
    BackgroundColor3 = THEME.SURFACE,
    BorderSizePixel  = 0,
    Parent           = Header,
})
newLabel({
    Size                   = UDim2.new(1,-90,1,0),
    Position               = UDim2.fromOffset(12,0),
    BackgroundTransparency = 1,
    Text                   = "✦  Menu Principal",
    TextColor3             = THEME.TEXT,
    Font                   = THEME.FONT_BOLD,
    TextSize               = IsMobile and 16 or 15,
    TextXAlignment         = Enum.TextXAlignment.Left,
    Parent                 = Header,
})

-- Botão minimizar  ▲ / ▼
local minimized = false
local MinBtn = newButton({
    Size             = UDim2.fromOffset(IsMobile and 44 or 36, IsMobile and 34 or 28),
    AnchorPoint      = Vector2.new(1, 0.5),
    Position         = UDim2.new(1,-8,0.5,0),
    BackgroundColor3 = THEME.ACCENT_DIM,
    Text             = "▼",
    TextColor3       = THEME.TEXT,
    Font             = THEME.FONT_BOLD,
    TextSize         = 14,
    BorderSizePixel  = 0,
    Parent           = Header,
})
corner(MinBtn, UDim.new(0,6))

local TabBar     -- declarado antes do minimize para poder referenciar
local ContentArea

local function setMinimized(state)
    minimized = state
    MinBtn.Text = minimized and "▲" or "▼"
    if TabBar     then TabBar.Visible     = not minimized end
    if ContentArea then ContentArea.Visible = not minimized end
    Window.Size = minimized
        and UDim2.fromOffset(WIN_W, THEME.HEADER_H)
        or  UDim2.fromOffset(WIN_W, WIN_H)
end
MinBtn.MouseButton1Click:Connect(function() setMinimized(not minimized) end)
MinBtn.Activated:Connect(function()         setMinimized(not minimized) end)

-- Arrastar (mouse + touch)
do
    local dragging, startPos, startWin
    local function beginDrag(pos)
        dragging = true; startPos = pos; startWin = Window.Position
    end
    local function endDrag() dragging = false end
    local function moveDrag(pos)
        if not dragging then return end
        local d = pos - startPos
        Window.Position = UDim2.new(
            startWin.X.Scale, startWin.X.Offset + d.X,
            startWin.Y.Scale, startWin.Y.Offset + d.Y)
    end
    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then beginDrag(i.Position) end
        if i.UserInputType == Enum.UserInputType.Touch         then beginDrag(i.Position) end
    end)
    Header.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then endDrag() end
    end)
    UIS.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then moveDrag(i.Position) end
    end)
end

-- TabBar
TabBar = newFrame({
    Name             = "TabBar",
    Size             = UDim2.new(1,0,0,THEME.TAB_H),
    Position         = UDim2.fromOffset(0, THEME.HEADER_H),
    BackgroundColor3 = THEME.SURFACE,
    BorderSizePixel  = 0,
    Parent           = Window,
})
local tl = Instance.new("UIListLayout", TabBar)
tl.FillDirection = Enum.FillDirection.Horizontal
tl.SortOrder     = Enum.SortOrder.LayoutOrder

-- ContentArea
ContentArea = newFrame({
    Name                   = "ContentArea",
    Size                   = UDim2.new(1,0,1,-(THEME.HEADER_H+THEME.TAB_H)),
    Position               = UDim2.fromOffset(0, THEME.HEADER_H+THEME.TAB_H),
    BackgroundTransparency = 1,
    BorderSizePixel        = 0,
    Parent                 = Window,
})

-- ── Carregamento de abas ──────────────────────────────────────────────────────
local tabButtons = {}
local tabFrames  = {}
local activeTab  = nil

local function setActiveTab(name)
    if activeTab == name then return end
    activeTab = name
    for _, n in ipairs(TABS) do
        local btn = tabButtons[n.name]
        local frm = tabFrames[n.name]
        local on  = (n.name == name)
        btn.BackgroundColor3       = on and THEME.ACCENT or Color3.new(0,0,0)
        btn.BackgroundTransparency = on and 0 or 1
        btn.TextColor3             = on and THEME.TEXT or THEME.SUBTEXT
        if frm then frm.Visible = on end
    end
end

for i, tabInfo in ipairs(TABS) do
    local btn = newButton({
        Name                   = tabInfo.name.."Btn",
        Size                   = UDim2.new(1/#TABS, 0, 1, 0),
        BackgroundTransparency = 1,
        Text                   = tabInfo.name,
        TextColor3             = THEME.SUBTEXT,
        Font                   = THEME.FONT,
        TextSize               = IsMobile and 14 or 13,
        BorderSizePixel        = 0,
        LayoutOrder            = i,
        Parent                 = TabBar,
    })
    corner(btn, UDim.new(0,6))
    tabButtons[tabInfo.name] = btn

    local frame = newFrame({
        Name                   = tabInfo.name.."Frame",
        Size                   = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        Visible                = false,
        Parent                 = ContentArea,
    })
    tabFrames[tabInfo.name] = frame

    local mod = loadModule(tabInfo.module)
    if mod and mod.Init then
        mod.Init(frame, THEME)
    else
        newLabel({
            Size                   = UDim2.fromScale(1,1),
            BackgroundTransparency = 1,
            Text                   = "⚠ Módulo '"..tabInfo.module.."' não encontrado.",
            TextColor3             = Color3.fromRGB(220,80,80),
            Font                   = THEME.FONT,
            TextSize               = 14,
            Parent                 = frame,
        })
    end

    btn.MouseButton1Click:Connect(function() setActiveTab(tabInfo.name) end)
    btn.Activated:Connect(function()          setActiveTab(tabInfo.name) end)
end

setActiveTab(TABS[1].name)
