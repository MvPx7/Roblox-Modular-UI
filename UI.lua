-- UI.lua  v4.1  ─ Sidebar vertical + lazy loading + drag otimizado
-- Layout: Header no topo | Sidebar esquerda (abas) | ContentArea direita
-- Correções v4.1:
--   • Proteção contra GUI duplicada
--   • Registry.closed para evitar callbacks perdidos
--   • loadModule com timeout (8s) e mensagem de erro detalhada
--   • Spinner animado no loading
--   • dragConn desconectado imediatamente no endDrag
--   • Drag bloqueado quando minimizado
--   • ActiveBar corrigida para considerar scroll
--   • Conexão ViewportSize desconectada ao fechar
--   • Loop de recuperação usa snapshot de WIN_W/WIN_H
--   • Módulo já destruído não recebe Init
-- ══════════════════════════════════════════════════════════════════════════════

local VERSION    = "4.1"
local TITLE      = "Menu"
local GITHUB_RAW = "https://raw.githubusercontent.com/MvPx7/Roblox-Modular-UI/main/Modules/"
local MODULE_TIMEOUT = 8   -- segundos antes de desistir do HTTP

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local LP           = Players.LocalPlayer
local PlayerGui    = LP:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════════════════════════════════════
--  PROTEÇÃO CONTRA GUI DUPLICADA
-- ══════════════════════════════════════════════════════════════════════════════
do
    local existing = PlayerGui:FindFirstChild("MainGui")
    if existing then existing:Destroy() end
end

-- ══════════════════════════════════════════════════════════════════════════════
--  CLEANUP REGISTRY
-- ══════════════════════════════════════════════════════════════════════════════
local Registry = { _fns = {}, closed = false }

function Registry.onClose(fn)
    if Registry.closed then
        -- UI já fechou: executa imediatamente para não perder o cleanup
        pcall(fn)
    else
        table.insert(Registry._fns, fn)
    end
end

function Registry.runAll()
    Registry.closed = true
    for _, fn in ipairs(Registry._fns) do pcall(fn) end
    Registry._fns = {}
end

-- Alias global retrocompatível (módulos que usam UI_REGISTRY continuam funcionando)
_G.UI_REGISTRY = Registry

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

--  WIN_W / WIN_H = janela completa
--  SIDE_W        = largura da sidebar
--  HDR_H         = altura do header
--  TAB_H         = altura de cada botão na sidebar
--  FONT_S        = tamanho de fonte nas abas
--  TITLE_S       = tamanho do título
--  BTN           = tamanho dos botões flutuantes
local PLATFORM_CFG = {
    PC     = { WIN_W=420, WIN_H=400, SIDE_W=90,  HDR_H=42, TAB_H=38, FONT_S=10, TITLE_S=13, BTN=28 },
    Tablet = { WIN_W=440, WIN_H=430, SIDE_W=95,  HDR_H=46, TAB_H=42, FONT_S=11, TITLE_S=14, BTN=32 },
    Mobile = { WIN_W=330, WIN_H=440, SIDE_W=80,  HDR_H=46, TAB_H=42, FONT_S=10, TITLE_S=13, BTN=36 },
}

-- ══════════════════════════════════════════════════════════════════════════════
--  TEMA
-- ══════════════════════════════════════════════════════════════════════════════
local T = {
    BG        = Color3.fromRGB(10, 10, 16),
    SURFACE   = Color3.fromRGB(18, 18, 28),
    SURFACE2  = Color3.fromRGB(22, 22, 35),
    SIDEBAR   = Color3.fromRGB(14, 14, 22),
    BORDER    = Color3.fromRGB(38, 38, 62),
    BORDER2   = Color3.fromRGB(55, 55, 85),

    ACCENT    = Color3.fromRGB(110, 86, 255),
    ACCENT2   = Color3.fromRGB(80, 60, 200),

    TEXT      = Color3.fromRGB(230, 228, 245),
    SUBTEXT   = Color3.fromRGB(150, 148, 175),
    MUTED     = Color3.fromRGB(85, 83, 110),

    SUCCESS   = Color3.fromRGB(72, 212, 140),
    WARN      = Color3.fromRGB(255, 185, 50),
    ERR       = Color3.fromRGB(225, 65, 65),
    CLOSE     = Color3.fromRGB(190, 45, 45),

    FONT      = Enum.Font.GothamMedium,
    FONTB     = Enum.Font.GothamBold,
    CORNER    = UDim.new(0, 12),
    CORNER_SM = UDim.new(0, 7),
    CORNER_XS = UDim.new(0, 4),
}
T.FONT_BOLD = T.FONTB

-- ══════════════════════════════════════════════════════════════════════════════
--  TABS
-- ══════════════════════════════════════════════════════════════════════════════
local TABS = {
    { name = "Home",   icon = "⌂",  module = "HomeTab"   },
    { name = "NPC",    icon = "☻",  module = "NPCTab"    },
    { name = "Player", icon = "♟",  module = "PlayerTab" },
    { name = "Visual", icon = "◈",  module = "VisualTab" },
    { name = "Quest",  icon = "★",  module = "QuestTab"  },
    { name = "Config", icon = "⚙",  module = "ConfigTab" },
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
local function corner(p, r)    mk("UICorner",{CornerRadius=r or T.CORNER},p) end
local function stroke(p, c, t) mk("UIStroke",{Color=c or T.BORDER, Thickness=t or 1,
    ApplyStrokeMode=Enum.ApplyStrokeMode.Border},p) end
local function tw(obj, dur, props, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(dur, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props):Play()
end
local function getVP()
    local vp = workspace.CurrentCamera.ViewportSize
    return math.max(vp.X,100), math.max(vp.Y,100)
end
local function clampWin(x, y, w, h)
    local vpW, vpH = getVP()
    return math.clamp(x, 0, math.max(0,vpW-w)),
           math.clamp(y, 0, math.max(0,vpH-h))
end
-- Verifica se uma instância ainda existe e não foi destruída
local function alive(inst)
    return inst and inst.Parent ~= nil
end

-- ══════════════════════════════════════════════════════════════════════════════
--  SPINNER DE LOADING
-- ══════════════════════════════════════════════════════════════════════════════
local function makeSpinner(parent, tabName)
    local holder = mk("Frame",{
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,
        ZIndex=2, Parent=parent,
    })
    local dots = {"⠋","⠙","⠹","⠸","⠼","⠴","⠦","⠧","⠇","⠏"}
    local spinLbl = mk("TextLabel",{
        Size=UDim2.new(1,0,0,24),
        AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,-8),
        BackgroundTransparency=1,
        Text=dots[1],
        TextColor3=T.ACCENT, Font=T.FONTB, TextSize=22,
        ZIndex=3, Parent=holder,
    })
    mk("TextLabel",{
        Size=UDim2.new(1,-16,0,18),
        AnchorPoint=Vector2.new(0.5,0),
        Position=UDim2.new(0.5,0,0.5,20),
        BackgroundTransparency=1,
        Text="Carregando "..tabName.."...",
        TextColor3=T.MUTED, Font=T.FONT, TextSize=10,
        ZIndex=3, Parent=holder,
    })
    local frame = 1
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not alive(spinLbl) then conn:Disconnect() return end
        frame = frame % #dots + 1
        spinLbl.Text = dots[frame]
    end)
    -- retorna o holder e a conexão para que possam ser destruídos depois
    return holder, conn
end

-- ══════════════════════════════════════════════════════════════════════════════
--  TELA DE ERRO DE MÓDULO
-- ══════════════════════════════════════════════════════════════════════════════
local function showModuleError(parent, name, url, errHTTP, errSyntax, errRuntime)
    -- Limpa filhos anteriores (ex: spinner)
    for _, c in ipairs(parent:GetChildren()) do c:Destroy() end

    local bg = mk("Frame",{
        Size=UDim2.new(1,-16,1,-16),
        Position=UDim2.fromOffset(8,8),
        BackgroundColor3=Color3.fromRGB(30,10,10),
        BackgroundTransparency=0.3,
        ZIndex=2, Parent=parent,
    })
    corner(bg, T.CORNER_XS)
    stroke(bg, T.ERR, 1)

    -- Ícone de erro
    mk("TextLabel",{
        Size=UDim2.new(1,0,0,28),
        Position=UDim2.fromOffset(0,10),
        BackgroundTransparency=1,
        Text="✖  Falha ao carregar módulo",
        TextColor3=T.ERR, Font=T.FONTB, TextSize=12,
        ZIndex=3, Parent=bg,
    })
    -- Separador
    mk("Frame",{
        Size=UDim2.new(1,-16,0,1),
        Position=UDim2.fromOffset(8,40),
        BackgroundColor3=T.ERR, BackgroundTransparency=0.6,
        BorderSizePixel=0, ZIndex=3, Parent=bg,
    })

    local lines = {}
    table.insert(lines, "Módulo : " .. name)
    table.insert(lines, "URL    : " .. url)
    if errHTTP    then table.insert(lines, "HTTP   : " .. tostring(errHTTP))    end
    if errSyntax  then table.insert(lines, "Sintaxe: " .. tostring(errSyntax))  end
    if errRuntime then table.insert(lines, "Runtime: " .. tostring(errRuntime)) end
    table.insert(lines, "")
    table.insert(lines, "→ Verifique se o arquivo existe no GitHub")
    table.insert(lines, "→ Confirme que HTTP Requests está habilitado")

    mk("TextLabel",{
        Size=UDim2.new(1,-16,1,-56),
        Position=UDim2.fromOffset(8,48),
        BackgroundTransparency=1,
        Text=table.concat(lines,"\n"),
        TextColor3=T.SUBTEXT, Font=T.FONT, TextSize=9,
        TextWrapped=true,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Top,
        ZIndex=3, Parent=bg,
    })
end

-- ══════════════════════════════════════════════════════════════════════════════
--  CARREGAR MÓDULO (lazy, com timeout)
-- ══════════════════════════════════════════════════════════════════════════════
local function loadModule(name, errorFrame)
    local url    = GITHUB_RAW .. name .. ".lua"
    local raw    = nil
    local errHTTP, errSyntax, errRuntime

    -- HTTP com timeout manual
    local httpDone  = false
    local httpOk    = false
    task.spawn(function()
        local ok, err = pcall(function() raw = game:HttpGet(url, true) end)
        httpOk   = ok
        errHTTP  = not ok and err or nil
        httpDone = true
    end)
    local t0 = tick()
    while not httpDone do
        if tick() - t0 > MODULE_TIMEOUT then
            errHTTP  = "Timeout após " .. MODULE_TIMEOUT .. "s (verifique HTTP Requests)"
            break
        end
        task.wait(0.05)
    end

    -- Verifica conteúdo vazio (pode acontecer sem erro HTTP)
    if httpOk and (not raw or raw == "") then
        errHTTP = "Resposta vazia — arquivo não encontrado ou URL incorreta"
        raw = nil
    end

    -- Compila
    local fn
    if raw then
        local ok2, res2 = pcall(loadstring, raw)
        if ok2 and type(res2) == "function" then
            fn = res2
        else
            errSyntax = res2
        end
    end

    -- Executa
    local result
    if fn then
        local ok3, res3 = pcall(fn)
        if ok3 then
            result = res3
        else
            errRuntime = res3
        end
    end

    if result then return result end

    -- Exibe erro se tiver frame disponível
    if errorFrame and alive(errorFrame) then
        showModuleError(errorFrame, name, url, errHTTP, errSyntax, errRuntime)
    end
    warn("[UI v"..VERSION.."] Módulo '"..name.."' falhou.")
    return nil
end

-- ══════════════════════════════════════════════════════════════════════════════
--  SCREENGUI
-- ══════════════════════════════════════════════════════════════════════════════
local SG = mk("ScreenGui",{
    Name="MainGui", ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling, Parent=PlayerGui,
})

local plat = getPlatform()
local cfg  = PLATFORM_CFG[plat]
local WIN_W, WIN_H    = cfg.WIN_W, cfg.WIN_H
local SIDE_W          = cfg.SIDE_W
local BTN_SZ, BTN_PAD = cfg.BTN, 8

-- ── SOMBRA ───────────────────────────────────────────────────────────────────
local Shadow = mk("Frame",{
    Size=UDim2.fromOffset(WIN_W+24, WIN_H+24),
    BackgroundColor3=Color3.fromRGB(0,0,0),
    BackgroundTransparency=0.55, BorderSizePixel=0, ZIndex=0, Parent=SG,
})
corner(Shadow, UDim.new(0,16))

-- ── JANELA ───────────────────────────────────────────────────────────────────
local Window = mk("Frame",{
    Size=UDim2.fromOffset(WIN_W, WIN_H),
    BackgroundColor3=T.BG, BorderSizePixel=0, ZIndex=1, Parent=SG,
})
corner(Window)
stroke(Window, T.BORDER, 1)

local function syncShadow()
    Shadow.Position = UDim2.fromOffset(
        Window.Position.X.Offset - 12,
        Window.Position.Y.Offset - 12)
end
local function positionWindow()
    local vpW, vpH = getVP()
    local nx = math.clamp((vpW-WIN_W)/2, 0, math.max(0, vpW-WIN_W))
    local ny = math.clamp((vpH-WIN_H)/2, 0, math.max(0, vpH-WIN_H))
    Window.Position = UDim2.fromOffset(nx, ny)
    syncShadow()
end
positionWindow()

-- ══════════════════════════════════════════════════════════════════════════════
--  HEADER  (topo da janela, largura total)
-- ══════════════════════════════════════════════════════════════════════════════
local Header = mk("Frame",{
    Size=UDim2.new(1,0,0,cfg.HDR_H),
    BackgroundColor3=T.SURFACE, BorderSizePixel=0, ZIndex=2, Parent=Window,
})
corner(Header)
-- cobre cantos inferiores do header
mk("Frame",{
    Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,1,-14),
    BackgroundColor3=T.SURFACE, BorderSizePixel=0, ZIndex=2, Parent=Header,
})
-- linha acento
mk("Frame",{
    Size=UDim2.new(0.5,0,0,2), Position=UDim2.new(0,12,0,0),
    BackgroundColor3=T.ACCENT, BorderSizePixel=0, ZIndex=3, Parent=Header,
})
-- título
mk("TextLabel",{
    Size=UDim2.new(1,-60,1,0), Position=UDim2.fromOffset(14,0),
    BackgroundTransparency=1, Text="  "..TITLE,
    TextColor3=T.TEXT, Font=T.FONTB, TextSize=cfg.TITLE_S,
    TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3, Parent=Header,
})
-- versão
mk("TextLabel",{
    Size=UDim2.fromOffset(52,20), Position=UDim2.new(1,-58,0.5,-10),
    BackgroundTransparency=1, Text="v"..VERSION,
    TextColor3=T.MUTED, Font=T.FONT, TextSize=9,
    TextXAlignment=Enum.TextXAlignment.Right, ZIndex=3, Parent=Header,
})
-- separador header / corpo
mk("Frame",{
    Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,0),
    BackgroundColor3=T.BORDER, BorderSizePixel=0, ZIndex=3, Parent=Header,
})

-- ══════════════════════════════════════════════════════════════════════════════
--  SIDEBAR  (coluna esquerda abaixo do header)
-- ══════════════════════════════════════════════════════════════════════════════
local Sidebar = mk("Frame",{
    Size=UDim2.new(0,SIDE_W,1,-cfg.HDR_H),
    Position=UDim2.new(0,0,0,cfg.HDR_H),
    BackgroundColor3=T.SIDEBAR, BorderSizePixel=0, ZIndex=2, Parent=Window,
})
-- cantos esquerdos arredondados (parte de baixo)
corner(Sidebar, T.CORNER)
-- cobre cantos direitos da sidebar
mk("Frame",{
    Size=UDim2.new(0,14,1,0), Position=UDim2.new(1,-14,0,0),
    BackgroundColor3=T.SIDEBAR, BorderSizePixel=0, ZIndex=2, Parent=Sidebar,
})
-- separador sidebar | conteúdo
mk("Frame",{
    Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,0,0,0),
    BackgroundColor3=T.BORDER, BorderSizePixel=0, ZIndex=3, Parent=Sidebar,
})

-- ScrollingFrame dentro da sidebar (suporta muitas abas)
local SideScroll = mk("ScrollingFrame",{
    Size=UDim2.new(1,0,1,-8),
    Position=UDim2.fromOffset(0,4),
    BackgroundTransparency=1,
    BorderSizePixel=0,
    ScrollBarThickness=2,
    ScrollBarImageColor3=T.ACCENT,
    CanvasSize=UDim2.new(0,0,0,0),
    ZIndex=3, Parent=Sidebar,
})
mk("UIListLayout",{
    SortOrder=Enum.SortOrder.LayoutOrder,
    Padding=UDim.new(0,2),
    Parent=SideScroll,
})
mk("UIPadding",{
    PaddingLeft=UDim.new(0,6), PaddingRight=UDim.new(0,6),
    PaddingTop=UDim.new(0,4),  Parent=SideScroll,
})

-- ══════════════════════════════════════════════════════════════════════════════
--  ÁREA DE CONTEÚDO  (coluna direita)
-- ══════════════════════════════════════════════════════════════════════════════
local ContentArea = mk("Frame",{
    Size=UDim2.new(1,-SIDE_W,1,-cfg.HDR_H),
    Position=UDim2.new(0,SIDE_W,0,cfg.HDR_H),
    BackgroundTransparency=1,
    ClipsDescendants=true,
    ZIndex=1, Parent=Window,
})

-- ══════════════════════════════════════════════════════════════════════════════
--  BOTÕES FLUTUANTES
-- ══════════════════════════════════════════════════════════════════════════════
local function makeBtn(label, row, bgColor)
    local b = mk("TextButton",{
        Size=UDim2.fromOffset(BTN_SZ,BTN_SZ),
        Position=UDim2.fromOffset(BTN_PAD, BTN_PAD+(BTN_SZ+6)*row),
        BackgroundColor3=bgColor, Text=label, TextColor3=T.TEXT,
        Font=T.FONTB, TextSize=BTN_SZ>34 and 15 or 12,
        BorderSizePixel=0, AutoButtonColor=false, ZIndex=20, Parent=SG,
    })
    corner(b, T.CORNER_SM)
    stroke(b, T.BORDER2, 1)
    b.MouseEnter:Connect(function() tw(b,0.1,{BackgroundTransparency=0.25}) end)
    b.MouseLeave:Connect(function() tw(b,0.1,{BackgroundTransparency=0})    end)
    return b
end
local function addTooltip(btn, text)
    local tip = mk("TextLabel",{
        Size=UDim2.fromOffset(68,20),
        Position=UDim2.new(1,6,0.5,-10),
        BackgroundColor3=T.SURFACE2, BackgroundTransparency=0.1,
        Text=text, TextColor3=T.SUBTEXT, Font=T.FONT, TextSize=10,
        BorderSizePixel=0, Visible=false, ZIndex=25, Parent=btn,
    })
    corner(tip, T.CORNER_XS)
    stroke(tip, T.BORDER, 1)
    btn.MouseEnter:Connect(function() tip.Visible=true  end)
    btn.MouseLeave:Connect(function() tip.Visible=false end)
end

local CloseBtn  = makeBtn("X",   0, T.CLOSE)
local ToggleBtn = makeBtn("[ ]", 1, T.ACCENT)
local ResetBtn  = makeBtn("O",   2, T.SURFACE2)
addTooltip(CloseBtn,  "Fechar")
addTooltip(ToggleBtn, "Minimizar")
addTooltip(ResetBtn,  "Recentrar")

-- ══════════════════════════════════════════════════════════════════════════════
--  CONSTRUÇÃO DAS ABAS NA SIDEBAR
-- ══════════════════════════════════════════════════════════════════════════════
local tabBtns, tabFrames, tabLoaded = {}, {}, {}
local activeTab = nil

-- Indicador lateral (barra roxa à esquerda do item ativo)
local ActiveBar = mk("Frame",{
    Size=UDim2.fromOffset(3, cfg.TAB_H - 8),
    BackgroundColor3=T.ACCENT,
    BorderSizePixel=0, ZIndex=5, Parent=SideScroll,
})
corner(ActiveBar, UDim.new(0,2))
ActiveBar.Visible = false

local function setActive(name, index)
    if activeTab == name then return end
    activeTab = name

    for _, td in ipairs(TABS) do
        local btn = tabBtns[td.name]
        local frm = tabFrames[td.name]
        local on  = (td.name == name)

        tw(btn, 0.14, {BackgroundColor3 = on and T.ACCENT2 or T.SIDEBAR,
                        BackgroundTransparency = on and 0 or 1})
        tw(btn, 0.14, {TextColor3 = on and T.TEXT or T.MUTED})
        if frm then frm.Visible = on end
    end

    -- Posição corrigida: desconta o scroll atual do CanvasPosition
    if tabBtns[name] then
        local btn      = tabBtns[name]
        local scrollY  = SideScroll.CanvasPosition.Y
        local targetY  = btn.Position.Y.Offset - scrollY + 4
        ActiveBar.Visible  = true
        ActiveBar.Position = UDim2.fromOffset(0, targetY)
        tw(ActiveBar, 0.15, { Position = UDim2.fromOffset(0, targetY) })
    end
end

-- Atualiza a barra quando o usuário scrolla a sidebar
SideScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
    if activeTab and tabBtns[activeTab] then
        local btn     = tabBtns[activeTab]
        local scrollY = SideScroll.CanvasPosition.Y
        ActiveBar.Position = UDim2.fromOffset(0, btn.Position.Y.Offset - scrollY + 4)
    end
end)

for i, td in ipairs(TABS) do
    -- Botão da sidebar
    local btn = mk("TextButton",{
        Size=UDim2.new(1,0,0,cfg.TAB_H),
        BackgroundColor3=T.SIDEBAR,
        BackgroundTransparency=1,
        Text=td.name,
        TextColor3=T.MUTED,
        Font=T.FONT,
        TextSize=cfg.FONT_S,
        BorderSizePixel=0,
        AutoButtonColor=false,
        LayoutOrder=i,
        ZIndex=4,
        Parent=SideScroll,
    })
    corner(btn, T.CORNER_XS)
    tabBtns[td.name] = btn

    -- Frame de conteúdo — tamanho explícito para garantir que o módulo renderize
    local frm = mk("Frame",{
        Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,
        ClipsDescendants=true,
        Visible=false, ZIndex=1, Parent=ContentArea,
    })
    tabFrames[td.name] = frm

    -- Hover
    btn.MouseEnter:Connect(function()
        if activeTab ~= td.name then
            tw(btn, 0.1, {BackgroundTransparency=0.75})
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= td.name then
            tw(btn, 0.1, {BackgroundTransparency=1})
        end
    end)

    -- Clique: lazy load + ativar
    btn.Activated:Connect(function()
        if td.module and not tabLoaded[td.name] then
            tabLoaded[td.name] = true

            -- Spinner enquanto carrega
            local spinHolder, spinConn = makeSpinner(frm, td.name)

            task.spawn(function()
                local mod = loadModule(td.module, frm)

                -- Para o spinner
                spinConn:Disconnect()
                if alive(spinHolder) then spinHolder:Destroy() end

                -- Só inicializa se o frame ainda existir e a UI não foi fechada
                if mod and mod.Init and alive(frm) and not Registry.closed then
                    pcall(mod.Init, frm, T, Registry)
                end
            end)
        end
        setActive(td.name, i)
    end)
end

-- Ajusta canvas da sidebar para caber todos os botões
do
    local layout = SideScroll:FindFirstChildOfClass("UIListLayout")
    local function updateCanvas()
        SideScroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 10)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
    updateCanvas()
end

-- Ativa primeira tab + carrega módulo
do
    local first = TABS[1]
    tabLoaded[first.name] = true

    local spinHolder, spinConn = makeSpinner(tabFrames[first.name], first.name)

    task.spawn(function()
        local frm = tabFrames[first.name]
        local mod = loadModule(first.module, frm)

        spinConn:Disconnect()
        if alive(spinHolder) then spinHolder:Destroy() end

        if mod and mod.Init and alive(frm) and not Registry.closed then
            pcall(mod.Init, frm, T, Registry)
        end
    end)
    setActive(first.name, 1)
end

-- ══════════════════════════════════════════════════════════════════════════════
--  AÇÕES DOS BOTÕES FLUTUANTES
-- ══════════════════════════════════════════════════════════════════════════════
CloseBtn.Activated:Connect(function()
    tw(Window, 0.18, {Size=UDim2.fromOffset(WIN_W,0), BackgroundTransparency=1})
    tw(Shadow, 0.18, {BackgroundTransparency=1})
    task.delay(0.2, function()
        Registry.runAll()
        SG:Destroy()
    end)
end)

local minimized = false
local function setMin(s)
    minimized = s
    local targetH = s and cfg.HDR_H or WIN_H
    if s then
        tw(Window, 0.2, {Size=UDim2.fromOffset(WIN_W, cfg.HDR_H)})
    else
        tw(Window, 0.22, {Size=UDim2.fromOffset(WIN_W, WIN_H)})
    end
    ToggleBtn.BackgroundColor3 = s and T.SURFACE2 or T.ACCENT
    ToggleBtn.Text             = s and ">  <" or "[ ]"
end
ToggleBtn.Activated:Connect(function() setMin(not minimized) end)

ResetBtn.Activated:Connect(function()
    local vpW, vpH = getVP()
    local nx = math.clamp((vpW-WIN_W)/2, 0, math.max(0, vpW-WIN_W))
    local ny = math.clamp((vpH-WIN_H)/2, 0, math.max(0, vpH-WIN_H))
    tw(Window, 0.3, {Position=UDim2.fromOffset(nx, ny)})
    task.delay(0.01, function()
        local c; c = RunService.RenderStepped:Connect(function()
            syncShadow()
        end)
        task.delay(0.35, function() c:Disconnect() end)
    end)
    if minimized then setMin(false) end
end)

-- ══════════════════════════════════════════════════════════════════════════════
--  DRAG  (RenderStepped só durante o arraste)
-- ══════════════════════════════════════════════════════════════════════════════
do
    local dragging, startPos, startWin = false, Vector2.zero, Vector2.zero
    local dragConn = nil

    local function endDrag()
        dragging = false
        if dragConn then
            dragConn:Disconnect()
            dragConn = nil
        end
    end

    local function beginDrag(pos)
        if minimized then return end   -- não arrastar quando minimizado
        if dragConn then dragConn:Disconnect(); dragConn = nil end
        dragging = true
        startPos = Vector2.new(pos.X, pos.Y)
        startWin = Vector2.new(Window.Position.X.Offset, Window.Position.Y.Offset)
        dragConn = RunService.RenderStepped:Connect(function()
            if not dragging then endDrag() return end
            local mp = UIS:GetMouseLocation()
            local curH = minimized and cfg.HDR_H or WIN_H
            local nx, ny = clampWin(
                startWin.X + mp.X - startPos.X,
                startWin.Y + mp.Y - startPos.Y,
                WIN_W, curH)
            Window.Position = UDim2.fromOffset(nx, ny)
            syncShadow()
        end)
    end

    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then beginDrag(i.Position) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then endDrag() end
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
        tw(Window, 0.3, {Size=UDim2.fromOffset(WIN_W,WIN_H), BackgroundTransparency=0},
            Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        tw(Shadow, 0.3, {BackgroundTransparency=0.55})
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
--  RESPONSIVIDADE  (conexão desconectada no close via Registry)
-- ══════════════════════════════════════════════════════════════════════════════
local lastPlat = plat
local vpConn = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    if not alive(SG) then return end

    local newPlat = getPlatform()
    if newPlat ~= lastPlat then
        lastPlat = newPlat
        local nc = PLATFORM_CFG[newPlat]
        WIN_W, WIN_H, SIDE_W, BTN_SZ = nc.WIN_W, nc.WIN_H, nc.SIDE_W, nc.BTN
        cfg = nc
        if not minimized then
            Window.Size = UDim2.fromOffset(WIN_W, WIN_H)
        else
            Window.Size = UDim2.fromOffset(WIN_W, nc.HDR_H)
        end
        Shadow.Size          = UDim2.fromOffset(WIN_W+24, WIN_H+24)
        Header.Size          = UDim2.new(1,0,0,nc.HDR_H)
        Sidebar.Size         = UDim2.new(0,SIDE_W,1,-nc.HDR_H)
        Sidebar.Position     = UDim2.new(0,0,0,nc.HDR_H)
        ContentArea.Size     = UDim2.new(1,-SIDE_W,1,-nc.HDR_H)
        ContentArea.Position = UDim2.new(0,SIDE_W,0,nc.HDR_H)
        for row, btn in ipairs({CloseBtn,ToggleBtn,ResetBtn}) do
            btn.Size     = UDim2.fromOffset(BTN_SZ, BTN_SZ)
            btn.Position = UDim2.fromOffset(BTN_PAD, BTN_PAD+(BTN_SZ+6)*(row-1))
        end
    end
    local curH = minimized and cfg.HDR_H or WIN_H
    local px, py = Window.Position.X.Offset, Window.Position.Y.Offset
    local nx, ny = clampWin(px, py, WIN_W, curH)
    Window.Position = UDim2.fromOffset(nx, ny)
    syncShadow()
end)

-- Garante desconexão da ViewportSize ao fechar
Registry.onClose(function()
    vpConn:Disconnect()
end)

-- ══════════════════════════════════════════════════════════════════════════════
--  RECUPERAÇÃO AUTOMÁTICA (usa snapshot local das dimensões)
-- ══════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while alive(SG) do
        task.wait(5)
        if not alive(SG) then break end
        if not minimized then
            local snapW, snapH = WIN_W, WIN_H   -- snapshot thread-safe
            local vpW, vpH = getVP()
            local px, py = Window.Position.X.Offset, Window.Position.Y.Offset
            if px > vpW-30 or px+snapW < 30 or py > vpH-30 or py+snapH < 30 then
                local nx, ny = clampWin(px, py, snapW, snapH)
                tw(Window, 0.4, {Position=UDim2.fromOffset(nx, ny)})
                syncShadow()
            end
        end
    end
end)
