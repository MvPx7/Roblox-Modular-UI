-- UI.lua
-- Responsabilidade: Criar a janela base, barra de abas e delegar conteúdo aos módulos.
-- Carregamento via loadstring + GitHub Raw (sem require / ModuleScript).

-- ──────────────────────────────────────────────
-- ⚙️  CONFIGURAÇÃO — edite apenas aqui
-- ──────────────────────────────────────────────
local GITHUB_RAW = "https://raw.githubusercontent.com/MvP_x7/Roblox-Modular-UI/main/Modules/"

local Players       = game:GetService("Players")
local HttpService   = game:GetService("HttpService")
local LocalPlayer   = Players.LocalPlayer
local PlayerGui     = LocalPlayer:WaitForChild("PlayerGui")

-- Carrega um módulo remotamente e retorna a tabela exportada
local function loadModule(name)
    local url = GITHUB_RAW .. name .. ".lua"
    local ok, result = pcall(function()
        local src = game:HttpGet(url, true)
        return loadstring(src)()
    end)
    if ok then return result end
    warn("[UI] Falha ao carregar módulo '" .. name .. "': " .. tostring(result))
    return nil
end

-- ──────────────────────────────────────────────
-- Configuração central de abas
-- ──────────────────────────────────────────────
local TABS = {
    { name = "Home",    module = "HomeTab"   },
    { name = "NPC",     module = "NPCTab"    },
    { name = "Player",  module = "PlayerTab" },
    { name = "Visual",  module = "VisualTab" },
    { name = "Config",  module = "ConfigTab" },
}

-- ──────────────────────────────────────────────
-- Paleta & constantes visuais
-- ──────────────────────────────────────────────
local THEME = {
    BG          = Color3.fromRGB(15,  15,  20),
    SURFACE     = Color3.fromRGB(22,  22,  30),
    ACCENT      = Color3.fromRGB(99,  102, 241),   -- indigo-500
    ACCENT_DIM  = Color3.fromRGB(55,  57,  140),
    TEXT        = Color3.fromRGB(230, 230, 240),
    SUBTEXT     = Color3.fromRGB(130, 130, 150),
    TAB_H       = 36,
    HEADER_H    = 40,
    CORNER      = UDim.new(0, 8),
    FONT        = Enum.Font.GothamMedium,
    FONT_BOLD   = Enum.Font.GothamBold,
}

-- ──────────────────────────────────────────────
-- Helpers
-- ──────────────────────────────────────────────
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = radius or THEME.CORNER
    c.Parent = parent
end

local function newFrame(props)
    local f = Instance.new("Frame")
    for k, v in pairs(props) do f[k] = v end
    return f
end

local function newLabel(props)
    local l = Instance.new("TextLabel")
    for k, v in pairs(props) do l[k] = v end
    return l
end

local function newButton(props)
    local b = Instance.new("TextButton")
    for k, v in pairs(props) do b[k] = v end
    return b
end

-- ──────────────────────────────────────────────
-- Construção da GUI base
-- ──────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "MainGui"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = PlayerGui

-- Janela principal
local Window = newFrame({
    Name            = "Window",
    Size            = UDim2.fromOffset(520, 420),
    Position        = UDim2.fromScale(0.5, 0.5),
    AnchorPoint     = Vector2.new(0.5, 0.5),
    BackgroundColor3 = THEME.BG,
    BorderSizePixel = 0,
    Parent          = ScreenGui,
})
corner(Window)

-- Sombra
local Shadow = newFrame({
    Name            = "Shadow",
    Size            = UDim2.new(1, 12, 1, 12),
    Position        = UDim2.fromOffset(-6, -6),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.6,
    BorderSizePixel = 0,
    ZIndex          = Window.ZIndex - 1,
    Parent          = Window,
})
corner(Shadow, UDim.new(0, 12))

-- Header / barra de arrastar
local Header = newFrame({
    Name            = "Header",
    Size            = UDim2.new(1, 0, 0, THEME.HEADER_H),
    BackgroundColor3 = THEME.SURFACE,
    BorderSizePixel = 0,
    Parent          = Window,
})
corner(Header)
-- corrige cantos inferiores do header
newFrame({
    Size            = UDim2.new(1, 0, 0, THEME.CORNER.Offset),
    Position        = UDim2.new(0, 0, 1, -THEME.CORNER.Offset),
    BackgroundColor3 = THEME.SURFACE,
    BorderSizePixel = 0,
    Parent          = Header,
})

newLabel({
    Size            = UDim2.new(1, -16, 1, 0),
    Position        = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1,
    Text            = "✦  Menu Principal",
    TextColor3      = THEME.TEXT,
    Font            = THEME.FONT_BOLD,
    TextSize        = 15,
    TextXAlignment  = Enum.TextXAlignment.Left,
    Parent          = Header,
})

-- Arrastar janela
do
    local dragging, startPos, startWin
    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = i.Position
            startWin = Window.Position
        end
    end)
    Header.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - startPos
            Window.Position = UDim2.new(
                startWin.X.Scale, startWin.X.Offset + delta.X,
                startWin.Y.Scale, startWin.Y.Offset + delta.Y
            )
        end
    end)
end

-- Barra de abas
local TabBar = newFrame({
    Name            = "TabBar",
    Size            = UDim2.new(1, 0, 0, THEME.TAB_H),
    Position        = UDim2.fromOffset(0, THEME.HEADER_H),
    BackgroundColor3 = THEME.SURFACE,
    BorderSizePixel = 0,
    Parent          = Window,
})

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection   = Enum.FillDirection.Horizontal
TabLayout.SortOrder       = Enum.SortOrder.LayoutOrder
TabLayout.Parent          = TabBar

-- Área de conteúdo
local ContentArea = newFrame({
    Name            = "ContentArea",
    Size            = UDim2.new(1, 0, 1, -(THEME.HEADER_H + THEME.TAB_H)),
    Position        = UDim2.fromOffset(0, THEME.HEADER_H + THEME.TAB_H),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Parent          = Window,
})

-- ──────────────────────────────────────────────
-- Carregamento de abas
-- ──────────────────────────────────────────────
local tabButtons = {}
local tabFrames  = {}
local activeTab  = nil

local function setActiveTab(name)
    if activeTab == name then return end
    activeTab = name
    for _, n in ipairs(TABS) do
        local btn = tabButtons[n.name]
        local frm = tabFrames[n.name]
        local isActive = (n.name == name)
        btn.BackgroundColor3 = isActive and THEME.ACCENT or Color3.fromRGB(0,0,0)
        btn.BackgroundTransparency = isActive and 0 or 1
        btn.TextColor3 = isActive and THEME.TEXT or THEME.SUBTEXT
        if frm then frm.Visible = isActive end
    end
end

for i, tabInfo in ipairs(TABS) do
    -- Botão da aba
    local btn = newButton({
        Name                    = tabInfo.name .. "Btn",
        Size                    = UDim2.new(1 / #TABS, 0, 1, 0),
        BackgroundTransparency  = 1,
        Text                    = tabInfo.name,
        TextColor3              = THEME.SUBTEXT,
        Font                    = THEME.FONT,
        TextSize                = 13,
        BorderSizePixel         = 0,
        LayoutOrder             = i,
        Parent                  = TabBar,
    })
    corner(btn, UDim.new(0, 6))
    tabButtons[tabInfo.name] = btn

    -- Frame de conteúdo
    local frame = newFrame({
        Name            = tabInfo.name .. "Frame",
        Size            = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible         = false,
        Parent          = ContentArea,
    })
    tabFrames[tabInfo.name] = frame

    -- Carrega módulo via GitHub
    local mod = loadModule(tabInfo.module)
    if mod and mod.Init then
        mod.Init(frame, THEME)
    else
        -- Fallback visual se módulo falhar
        newLabel({
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Text = "⚠ Módulo '" .. tabInfo.module .. "' não encontrado.",
            TextColor3 = Color3.fromRGB(220, 80, 80),
            Font = THEME.FONT,
            TextSize = 14,
            Parent = frame,
        })
    end

    btn.MouseButton1Click:Connect(function() setActiveTab(tabInfo.name) end)
end

setActiveTab(TABS[1].name)
