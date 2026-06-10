-- UI.lua  v3.0  ─ Redesign visual + melhorias estruturais
-- Mudanças: lazy loading, drag otimizado, sombra, animação de entrada,
--           tabs com indicador animado, gradiente no header, sem globals expostas
-- ══════════════════════════════════════════════════════════════════════════════

local GITHUB_RAW = "https://raw.githubusercontent.com/MvPx7/Roblox-Modular-UI/main/Modules/"

local Players       = game:GetService("Players")
local UIS           = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local RunService    = game:GetService("RunService")
local LP            = Players.LocalPlayer
local PlayerGui     = LP:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE CLEANUP  (local — não expõe global)
-- ══════════════════════════════════════════════════════════════════════════════
local Registry = { _fns = {} }
function Registry.onClose(fn)  table.insert(Registry._fns, fn) end
function Registry.runAll()
    for _, fn in ipairs(Registry._fns) do pcall(fn) end
    Registry._fns = {}
end
-- Mantém compatibilidade com módulos antigos que usem UI_REGISTRY
UI_REGISTRY = Registry

-- ══════════════════════════════════════════════════════════════════════════════
--  PLATAFORMA
-- ══════════════════════════════════════════════════════════════════════════════
local function getPlatform()
    local vp    = workspace.CurrentCamera.ViewportSize
    local touch = UIS.TouchEnabled
    local w, h  = vp.X, vp.Y
    if not touch and w >= 900 then return "PC"
    elseif touch and math.min(w,h) >= 600 and math.max(w,h) >= 900 then return "Tablet"
    else return "Mobile" end
end

local PLATFORM_CFG = {
    PC     = { WIN_W=360, WIN_H=400, HDR_H=44, TAB_H=32, FONT_S=11, TITLE_S=13, BTN=30 },
    Tablet = { WIN_W=380, WIN_H=420, HDR_H=48, TAB_H=36, FONT_S=12, TITLE_S=14, BTN=34 },
    Mobile = { WIN_W=310, WIN_H=430, HDR_H=50, TAB_H=38, FONT_S=12, TITLE_S=14, BTN=38 },
}

-- ══════════════════════════════════════════════════════════════════════════════
--  TEMA  v3 — paleta refinada com suporte a gradiente
-- ══════════════════════════════════════════════════════════════════════════════
local T = {
    -- Fundos
    BG        = Color3.fromRGB(10, 10, 16),
    SURFACE   = Color3.fromRGB(18, 18, 28),
    SURFACE2  = Color3.fromRGB(24, 24, 38),
    BORDER    = Color3.fromRGB(40, 40, 65),
    BORDER2   = Color3.fromRGB(60, 60, 90),

    -- Acento principal — violeta-índigo
    ACCENT    = Color3.fromRGB(110, 86, 255),
    ACCENT2   = Color3.fromRGB(80, 60, 200),
    ACCENT_DIM= Color3.fromRGB(110, 86, 255),

    -- Textos
    TEXT      = Color3.fromRGB(230, 228, 245),
    SUBTEXT   = Color3.fromRGB(150, 148, 175),
    MUTED     = Color3.fromRGB(90, 88, 115),

    -- Estado
    SUCCESS   = Color3.fromRGB(72, 212, 140),
    WARN      = Color3.fromRGB(255, 185, 50),
    ERR       = Color3.fromRGB(225, 65, 65),
    CLOSE     = Color3.fromRGB(190, 45, 45),
    CLOSE2    = Color3.fromRGB(140, 30, 30),

    -- Fontes
    FONT      = Enum.Font.GothamMedium,
    FONTB     = Enum.Font.GothamBold,
    CORNER    = UDim.new(0, 12),
    CORNER_SM = UDim.new(0, 7),
    CORNER_XS = UDim.new(0, 4),

    -- Aliases retrocompatíveis
    FONT_BOLD = nil,
}
T.FONT_BOLD = T.FONTB

-- ══════════════════════════════════════════════════════════════════════════════
--  TABS
-- ══════════════════════════════════════════════════════════════════════════════
local TABS = {
    { name = "Home",   icon = "H", module = "HomeTab"   },
    { name = "NPC",    icon = "N", module = "NPCTab"    },
    { name = "Player", icon = "P", module = "PlayerTab" },
    { name = "Visual", icon = "V", module = "VisualTab" },
    { name = "Quest",  icon = "Q", module = "QuestTab"  },
    { name = "Config", icon = "C", module = "ConfigTab" },
}

-- ══════════════════════════════════════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════════════════════════════════════
local function mk(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(p, r)  mk("UICorner", {CornerRadius = r or T.CORNER}, p) end
local function stroke(p, c, t) mk("UIStroke", {Color = c or T.BORDER, Thickness = t or 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, p) end
local function tw(obj, dur, props, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(dur, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props):Play()
end
local function getVP()
    local vp = workspace.CurrentCamera.ViewportSize
    return math.max(vp.X, 100), math.max(vp.Y, 100)
end
local function clampWin(x, y, w, h)
    local vpW, vpH = getVP()
    return math.clamp(x, 0, math.max(0, vpW-w)),
           math.clamp(y, 0, math.max(0, vpH-h))
end

-- ══════════════════════════════════════════════════════════════════════════════
--  CARREGAR MÓDULO  (lazy: só executa quando a aba é aberta)
-- ══════════════════════════════════════════════════════════════════════════════
local function loadModule(name, errorFrame)
    local url = GITHUB_RAW .. name .. ".lua"
    local raw

    local ok1, err1 = pcall(function() raw = game:HttpGet(url, true) end)
    local ok2, fn2  = pcall(loadstring, raw or "")
    local ok3, res
    if ok2 and type(fn2) == "function" then ok3, res = pcall(fn2) end

    if ok3 and res then return res end

    if errorFrame then
        local lines = {
            "Falha ao carregar: " .. name, "",
            "URL: " .. url, "",
            not ok1 and ("HTTP: "    .. tostring(err1)) or nil,
            not ok2 and ("Sintaxe: " .. tostring(fn2))  or nil,
            (ok2 and not ok3) and ("Runtime: " .. tostring(res)) or nil,
            "", "Verifique se o arquivo existe no GitHub.",
        }
        local txt = ""
        for _, l in ipairs(lines) do if l then txt = txt .. l .. "\n" end end
        mk("TextLabel", {
            Size = UDim2.new(1,-24,1,-24),
            Position = UDim2.fromOffset(12, 12),
            BackgroundTransparency = 1,
            Text = txt,
            TextColor3 = T.ERR,
            Font = T.FONT,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            Parent = errorFrame,
        })
    end
    warn("[UI] " .. name .. " falhou.")
    return nil
end

-- ══════════════════════════════════════════════════════════════════════════════
--  SCREENGUI
-- ══════════════════════════════════════════════════════════════════════════════
local SG = mk("ScreenGui", {
    Name = "MainGui",
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = PlayerGui,
})

local plat = getPlatform()
local cfg  = PLATFORM_CFG[plat]
local WIN_W, WIN_H = cfg.WIN_W, cfg.WIN_H
local BTN_SZ, BTN_PAD = cfg.BTN, 8

-- ══════════════════════════════════════════════════════════════════════════════
--  SOMBRA  (frame preto levemente maior atrás da janela)
-- ══════════════════════════════════════════════════════════════════════════════
local Shadow = mk("Frame", {
    Size = UDim2.fromOffset(WIN_W + 24, WIN_H + 24),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.55,
    BorderSizePixel = 0,
    ZIndex = 0,
    Parent = SG,
})
corner(Shadow, UDim.new(0, 16))

-- ══════════════════════════════════════════════════════════════════════════════
--  JANELA PRINCIPAL
-- ══════════════════════════════════════════════════════════════════════════════
local Window = mk("Frame", {
    Size = UDim2.fromOffset(WIN_W, WIN_H),
    BackgroundColor3 = T.BG,
    BorderSizePixel = 0,
    ZIndex = 1,
    Parent = SG,
})
corner(Window)
stroke(Window, T.BORDER, 1)

-- Posiciona janela e sombra centradas
local function positionWindow()
    local vpW, vpH = getVP()
    local nx = math.clamp((vpW - WIN_W) / 2, 0, vpW - WIN_W)
    local ny = math.clamp((vpH - WIN_H) / 2, 0, vpH - WIN_H)
    Window.Position = UDim2.fromOffset(nx, ny)
    Shadow.Position = UDim2.fromOffset(nx - 12, ny - 12)
end
positionWindow()

-- Mantém sombra sincronizada com a janela durante drag
local function syncShadow()
    Shadow.Position = UDim2.fromOffset(
        Window.Position.X.Offset - 12,
        Window.Position.Y.Offset - 12)
end

-- ══════════════════════════════════════════════════════════════════════════════
--  HEADER com gradiente sutil
-- ══════════════════════════════════════════════════════════════════════════════
local Header = mk("Frame", {
    Size = UDim2.new(1, 0, 0, cfg.HDR_H),
    BackgroundColor3 = T.SURFACE,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = Window,
})
corner(Header)
-- Cobre os cantos inferiores arredondados do header
mk("Frame", {
    Size = UDim2.new(1, 0, 0, 14),
    Position = UDim2.new(0, 0, 1, -14),
    BackgroundColor3 = T.SURFACE,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = Header,
})

-- Linha de acento no topo do header
mk("Frame", {
    Size = UDim2.new(0.55, 0, 0, 2),
    Position = UDim2.new(0, 12, 0, 0),
    BackgroundColor3 = T.ACCENT,
    BorderSizePixel = 0,
    ZIndex = 3,
    Parent = Header,
})

-- Título
mk("TextLabel", {
    Size = UDim2.new(1, -70, 1, 0),
    Position = UDim2.fromOffset(14, 0),
    BackgroundTransparency = 1,
    Text = "  Menu",
    TextColor3 = T.TEXT,
    Font = T.FONTB,
    TextSize = cfg.TITLE_S,
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
    Parent = Header,
})

-- Subtítulo / versão
mk("TextLabel", {
    Size = UDim2.new(0, 60, 1, 0),
    Position = UDim2.new(1, -72, 0, 0),
    BackgroundTransparency = 1,
    Text = "v3.0",
    TextColor3 = T.MUTED,
    Font = T.FONT,
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Right,
    ZIndex = 3,
    Parent = Header,
})

-- Separador header / conteúdo
mk("Frame", {
    Size = UDim2.new(1, -24, 0, 1),
    Position = UDim2.new(0, 12, 0, cfg.HDR_H),
    BackgroundColor3 = T.BORDER,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = Window,
})

-- ══════════════════════════════════════════════════════════════════════════════
--  BOTÕES FLUTUANTES  (fora da janela, lado esquerdo)
-- ══════════════════════════════════════════════════════════════════════════════
local function makeBtn(label, row, bgColor)
    local b = mk("TextButton", {
        Size     = UDim2.fromOffset(BTN_SZ, BTN_SZ),
        Position = UDim2.fromOffset(BTN_PAD, BTN_PAD + (BTN_SZ + 6) * row),
        BackgroundColor3 = bgColor,
        Text     = label,
        TextColor3 = T.TEXT,
        Font     = T.FONTB,
        TextSize = BTN_SZ > 36 and 16 or 13,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex  = 20,
        Parent  = SG,
    })
    corner(b, T.CORNER_SM)
    stroke(b, T.BORDER2, 1)
    b.MouseEnter:Connect(function() tw(b, 0.12, {BackgroundTransparency = 0.25}) end)
    b.MouseLeave:Connect(function() tw(b, 0.12, {BackgroundTransparency = 0})    end)
    return b
end

local CloseBtn  = makeBtn("X",   0, T.CLOSE)
local ToggleBtn = makeBtn("[ ]", 1, T.ACCENT)
local ResetBtn  = makeBtn("O",   2, T.SURFACE2)

-- Tooltips
local function addTooltip(btn, text)
    local tip = mk("TextLabel", {
        Size = UDim2.fromOffset(68, 22),
        Position = UDim2.new(1, 6, 0.5, -11),
        BackgroundColor3 = T.SURFACE2,
        BackgroundTransparency = 0.1,
        Text = text,
        TextColor3 = T.SUBTEXT,
        Font = T.FONT,
        TextSize = 10,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 25,
        Parent = btn,
    })
    corner(tip, T.CORNER_XS)
    stroke(tip, T.BORDER, 1)
    btn.MouseEnter:Connect(function() tip.Visible = true  end)
    btn.MouseLeave:Connect(function() tip.Visible = false end)
end
addTooltip(CloseBtn,  "Fechar")
addTooltip(ToggleBtn, "Minimizar")
addTooltip(ResetBtn,  "Recentrar")

-- ══════════════════════════════════════════════════════════════════════════════
--  TAB BAR  com indicador deslizante animado
-- ══════════════════════════════════════════════════════════════════════════════
local TAB_TOP = cfg.HDR_H + 6
local TabBar = mk("Frame", {
    Size = UDim2.new(1, -16, 0, cfg.TAB_H),
    Position = UDim2.new(0, 8, 0, TAB_TOP),
    BackgroundColor3 = T.SURFACE2,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = Window,
})
corner(TabBar, T.CORNER_SM)
stroke(TabBar, T.BORDER, 1)
mk("UIPadding", {PaddingLeft=UDim.new(0,3), PaddingRight=UDim.new(0,3),
    PaddingTop=UDim.new(0,3), PaddingBottom=UDim.new(0,3), Parent=TabBar})

-- Indicador deslizante (pill que se move sob o tab ativo)
local TAB_COUNT = #TABS
local PILL_W = (WIN_W - 16 - 6) / TAB_COUNT  -- largura aproximada de cada tab menos padding
local Pill = mk("Frame", {
    Size = UDim2.new(1/TAB_COUNT, -2, 1, -6),
    Position = UDim2.new(0, 1, 0, 3),
    BackgroundColor3 = T.ACCENT,
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = TabBar,
})
corner(Pill, UDim.new(0, 5))

local TabLayout = mk("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 1),
    Parent = TabBar,
})

local TAB_OFFSET = TAB_TOP + cfg.TAB_H + 6
local ContentArea = mk("Frame", {
    Size = UDim2.new(1, 0, 1, -TAB_OFFSET),
    Position = UDim2.fromOffset(0, TAB_OFFSET),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    ZIndex = 1,
    Parent = Window,
})

-- ══════════════════════════════════════════════════════════════════════════════
--  TABS  (lazy loading: módulo carrega ao primeiro clique)
-- ══════════════════════════════════════════════════════════════════════════════
local tabBtns, tabFrames, tabLoaded = {}, {}, {}
local activeTab = nil

local function setActive(name, index)
    if activeTab == name then return end
    activeTab = name

    -- Move o indicador pill
    local destX = (index - 1) / TAB_COUNT
    tw(Pill, 0.18, {Position = UDim2.new(destX, 1, 0, 3)},
        Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    for i, td in ipairs(TABS) do
        local btn = tabBtns[td.name]
        local frm = tabFrames[td.name]
        local on  = (td.name == name)
        tw(btn, 0.15, {TextColor3 = on and T.TEXT or T.MUTED})
        if frm then frm.Visible = on end
    end
end

for i, td in ipairs(TABS) do
    -- Botão da tab
    local btn = mk("TextButton", {
        Size = UDim2.new(1/TAB_COUNT, -1, 1, 0),
        BackgroundTransparency = 1,
        Text = td.name,
        TextColor3 = T.MUTED,
        Font = T.FONT,
        TextSize = cfg.FONT_S,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        LayoutOrder = i,
        ZIndex = 3,
        Parent = TabBar,
    })
    tabBtns[td.name] = btn

    -- Frame de conteúdo da tab
    local frm = mk("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 1,
        Parent = ContentArea,
    })
    tabFrames[td.name] = frm

    -- LAZY LOADING: carrega o módulo só no primeiro clique
    btn.Activated:Connect(function()
        if td.module and not tabLoaded[td.name] then
            tabLoaded[td.name] = true
            -- Indicador de carregamento
            local loading = mk("TextLabel", {
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = "Carregando " .. td.name .. "...",
                TextColor3 = T.MUTED,
                Font = T.FONT,
                TextSize = 11,
                ZIndex = 2,
                Parent = frm,
            })
            task.spawn(function()
                local mod = loadModule(td.module, frm)
                loading:Destroy()
                if mod and mod.Init then
                    pcall(mod.Init, frm, T, Registry)
                end
            end)
        end
        setActive(td.name, i)
    end)
end

-- Ativa a primeira tab imediatamente (com carregamento)
do
    local first = TABS[1]
    tabLoaded[first.name] = true
    task.spawn(function()
        local mod = loadModule(first.module, tabFrames[first.name])
        if mod and mod.Init then
            pcall(mod.Init, tabFrames[first.name], T, Registry)
        end
    end)
    setActive(first.name, 1)
end

-- ══════════════════════════════════════════════════════════════════════════════
--  AÇÕES DOS BOTÕES FLUTUANTES
-- ══════════════════════════════════════════════════════════════════════════════
CloseBtn.Activated:Connect(function()
    -- Animação de saída
    tw(Window, 0.18, {Size = UDim2.fromOffset(WIN_W, 0), BackgroundTransparency = 1})
    tw(Shadow, 0.18, {BackgroundTransparency = 1})
    task.delay(0.2, function()
        Registry.runAll()
        SG:Destroy()
    end)
end)

local minimized = false
local function setMin(s)
    minimized = s
    if s then
        tw(Window, 0.2, {Size = UDim2.fromOffset(WIN_W, cfg.HDR_H)})
    else
        tw(Window, 0.22, {Size = UDim2.fromOffset(WIN_W, WIN_H)})
    end
    ToggleBtn.BackgroundColor3 = s and T.SURFACE2 or T.ACCENT
    ToggleBtn.Text             = s and ">  <" or "[ ]"
end
ToggleBtn.Activated:Connect(function() setMin(not minimized) end)

ResetBtn.Activated:Connect(function()
    local vpW, vpH = getVP()
    local nx = math.clamp((vpW - WIN_W) / 2, 0, vpW - WIN_W)
    local ny = math.clamp((vpH - WIN_H) / 2, 0, vpH - WIN_H)
    tw(Window, 0.3, {Position = UDim2.fromOffset(nx, ny)})
    -- Sombra acompanha com pequeno delay
    task.delay(0.01, function()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            syncShadow()
        end)
        task.delay(0.35, function() conn:Disconnect() end)
    end)
    if minimized then setMin(false) end
end)

-- ══════════════════════════════════════════════════════════════════════════════
--  DRAG  (RenderStepped só enquanto arrasta — sem listener global sempre ativo)
-- ══════════════════════════════════════════════════════════════════════════════
do
    local dragging  = false
    local startPos  = Vector2.zero
    local startWin  = Vector2.zero
    local dragConn  = nil

    local function beginDrag(pos)
        dragging = true
        startPos = Vector2.new(pos.X, pos.Y)
        startWin = Vector2.new(Window.Position.X.Offset, Window.Position.Y.Offset)

        dragConn = RunService.RenderStepped:Connect(function()
            if not dragging then
                dragConn:Disconnect()
                dragConn = nil
                return
            end
            local mp = UIS:GetMouseLocation()
            local nx, ny = clampWin(
                startWin.X + mp.X - startPos.X,
                startWin.Y + mp.Y - startPos.Y,
                WIN_W, WIN_H)
            Window.Position = UDim2.fromOffset(nx, ny)
            syncShadow()
        end)
    end

    local function endDrag()
        dragging = false
    end

    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            beginDrag(i.Position)
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            endDrag()
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
--  ANIMAÇÃO DE ENTRADA
-- ══════════════════════════════════════════════════════════════════════════════
do
    Window.Size = UDim2.fromOffset(WIN_W, 0)
    Window.BackgroundTransparency = 1
    Shadow.BackgroundTransparency = 1
    task.defer(function()
        tw(Window, 0.3, {
            Size = UDim2.fromOffset(WIN_W, WIN_H),
            BackgroundTransparency = 0,
        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tw(Shadow, 0.3, {BackgroundTransparency = 0.55})
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
--  RESPONSIVIDADE
-- ══════════════════════════════════════════════════════════════════════════════
local lastPlat = plat
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local newPlat = getPlatform()
    if newPlat ~= lastPlat then
        lastPlat = newPlat
        local nc = PLATFORM_CFG[newPlat]
        WIN_W, WIN_H, BTN_SZ = nc.WIN_W, nc.WIN_H, nc.BTN
        Window.Size   = UDim2.fromOffset(WIN_W, WIN_H)
        Shadow.Size   = UDim2.fromOffset(WIN_W + 24, WIN_H + 24)
        Header.Size   = UDim2.new(1, 0, 0, nc.HDR_H)
        TabBar.Size   = UDim2.new(1, -16, 0, nc.TAB_H)
        TabBar.Position = UDim2.new(0, 8, 0, nc.HDR_H + 6)
        local off = nc.HDR_H + nc.TAB_H + 6
        ContentArea.Size     = UDim2.new(1, 0, 1, -off)
        ContentArea.Position = UDim2.fromOffset(0, off)
        for row, btn in ipairs({CloseBtn, ToggleBtn, ResetBtn}) do
            btn.Size     = UDim2.fromOffset(BTN_SZ, BTN_SZ)
            btn.Position = UDim2.fromOffset(BTN_PAD, BTN_PAD + (BTN_SZ + 6) * (row - 1))
        end
    end
    local px, py = Window.Position.X.Offset, Window.Position.Y.Offset
    local nx, ny = clampWin(px, py, WIN_W, WIN_H)
    Window.Position = UDim2.fromOffset(nx, ny)
    syncShadow()
end)

-- ══════════════════════════════════════════════════════════════════════════════
--  RECUPERAÇÃO AUTOMÁTICA  (reposiciona só se realmente saiu da tela)
-- ══════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while SG.Parent do
        task.wait(5)
        if not minimized then
            local vpW, vpH = getVP()
            local px, py = Window.Position.X.Offset, Window.Position.Y.Offset
            if px > vpW-30 or px+WIN_W < 30 or py > vpH-30 or py+WIN_H < 30 then
                local nx, ny = clampWin(px, py, WIN_W, WIN_H)
                tw(Window, 0.4, {Position = UDim2.fromOffset(nx, ny)})
                syncShadow()
            end
        end
    end
end)
