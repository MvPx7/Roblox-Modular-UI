-- UI.lua  v2.5  ─ Sistema de Cleanup global para módulos
-- Correções: ícones dos botões flutuantes corrigidos para ASCII puro
-- ══════════════════════════════════════════════════════════════════════════════

local GITHUB_RAW = "https://raw.githubusercontent.com/MvPx7/Roblox-Modular-UI/main/Modules/"

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP           = Players.LocalPlayer
local PlayerGui    = LP:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════════════════════════════════════
--  SISTEMA DE CLEANUP GLOBAL
--  Cada módulo chama UI_REGISTRY.onClose(fn) para registrar sua limpeza.
--  Quando o usuário fecha a UI, todas as funções são chamadas automaticamente.
-- ══════════════════════════════════════════════════════════════════════════════
UI_REGISTRY = UI_REGISTRY or {}
UI_REGISTRY._cleanupFns = {}

function UI_REGISTRY.onClose(fn)
    table.insert(UI_REGISTRY._cleanupFns, fn)
end

local function runAllCleanups()
    for _, fn in ipairs(UI_REGISTRY._cleanupFns) do
        pcall(fn)
    end
    UI_REGISTRY._cleanupFns = {}
end

-- ══════════════════════════════════════════════════════════════════════════════
--  DETECÇÃO DE PLATAFORMA
-- ══════════════════════════════════════════════════════════════════════════════
local function getPlatform()
    local vp    = workspace.CurrentCamera.ViewportSize
    local touch = UIS.TouchEnabled
    local w, h  = vp.X, vp.Y
    if not touch and w >= 900 then return "PC"
    elseif touch and math.min(w,h) >= 600 and math.max(w,h) >= 900 then return "Tablet"
    else return "Mobile" end
end

-- ══════════════════════════════════════════════════════════════════════════════
--  TEMA
-- ══════════════════════════════════════════════════════════════════════════════
local PLATFORM_CFG = {
    PC     = { WIN_W=340, WIN_H=360, HDR_H=34, TAB_H=28, FONT_S=10, TITLE_S=12, BTN=32 },
    Tablet = { WIN_W=360, WIN_H=380, HDR_H=38, TAB_H=32, FONT_S=11, TITLE_S=13, BTN=36 },
    Mobile = { WIN_W=300, WIN_H=390, HDR_H=40, TAB_H=34, FONT_S=11, TITLE_S=13, BTN=40 },
}

local T = {
    BG      = Color3.fromRGB(12, 12, 18),
    SURFACE = Color3.fromRGB(20, 20, 30),
    BORDER  = Color3.fromRGB(35, 35, 55),
    ACCENT  = Color3.fromRGB(99, 102, 241),
    TEXT    = Color3.fromRGB(220, 220, 235),
    MUTED   = Color3.fromRGB(120, 120, 140),
    ERR     = Color3.fromRGB(220, 60, 60),
    CLOSE   = Color3.fromRGB(180, 40, 40),
    FONT    = Enum.Font.GothamMedium,
    FONTB   = Enum.Font.GothamBold,
    CORNER  = UDim.new(0, 10),
}
T.SUBTEXT   = T.MUTED
T.FONT_BOLD = T.FONTB
T.SUCCESS   = Color3.fromRGB(80, 220, 130)
T.WARN      = Color3.fromRGB(255, 190, 60)

-- ══════════════════════════════════════════════════════════════════════════════
--  TABS
-- ══════════════════════════════════════════════════════════════════════════════
local TABS = {
    { name = "Home",   module = "HomeTab"   },
    { name = "NPC",    module = "NPCTab"    },
    { name = "Player", module = "PlayerTab" },
    { name = "Visual", module = "VisualTab" },
    { name = "Quest",  module = "QuestTab"  },
    { name = "Config", module = "ConfigTab" },
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
local function corner(p, r) mk("UICorner", {CornerRadius = r or T.CORNER}, p) end
local function tw(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad), props):Play()
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
--  CARREGAR MÓDULO EXTERNO
-- ══════════════════════════════════════════════════════════════════════════════
local function loadModule(name, errorFrame)
    local url = GITHUB_RAW .. name .. ".lua"
    local raw, fn

    local ok1, err1 = pcall(function() raw = game:HttpGet(url, true) end)
    local ok2, fn2  = pcall(loadstring, raw or "")
    local ok3, res
    if ok2 and type(fn2) == "function" then ok3, res = pcall(fn2) end

    if ok3 and res then return res end

    if errorFrame then
        local lines = { "!  Falha: " .. name, "", "URL: " .. url, "",
            not ok1 and ("HTTP: " .. tostring(err1)) or nil,
            not ok2 and ("Sintaxe: " .. tostring(fn2)) or nil,
            (ok2 and not ok3) and ("Runtime: " .. tostring(res)) or nil,
            "", "Verifique se o arquivo existe no GitHub." }
        local txt = ""
        for _, l in ipairs(lines) do if l then txt = txt .. l .. "\n" end end
        mk("TextLabel", {
            Size = UDim2.new(1,-20,1,-20), Position = UDim2.fromOffset(10,10),
            BackgroundTransparency = 1, Text = txt, TextColor3 = T.ERR,
            Font = T.FONT, TextSize = 11, TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top, Parent = errorFrame,
        })
    end
    warn("[UI] " .. name .. " falhou.")
    return nil
end

-- ══════════════════════════════════════════════════════════════════════════════
--  SCREENGUI + JANELA
-- ══════════════════════════════════════════════════════════════════════════════
local SG = mk("ScreenGui", {
    Name = "MainGui", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, Parent = PlayerGui,
})

local plat = getPlatform()
local cfg  = PLATFORM_CFG[plat]
local WIN_W, WIN_H = cfg.WIN_W, cfg.WIN_H
local BTN_SZ, BTN_PAD = cfg.BTN, 8

local Window = mk("Frame", {
    Size = UDim2.fromOffset(WIN_W, WIN_H),
    BackgroundColor3 = T.BG, BorderSizePixel = 0, Parent = SG,
})
corner(Window)
mk("UIStroke", {Color=T.BORDER, Thickness=1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Parent=Window})

do
    local vpW, vpH = getVP()
    Window.Position = UDim2.fromOffset(
        math.clamp((vpW-WIN_W)/2, 0, vpW-WIN_W),
        math.clamp((vpH-WIN_H)/2, 0, vpH-WIN_H))
end

local Header = mk("Frame", {
    Size=UDim2.new(1,0,0,cfg.HDR_H), BackgroundColor3=T.SURFACE,
    BorderSizePixel=0, Parent=Window,
})
corner(Header)
mk("Frame", {Size=UDim2.new(1,0,0,10), Position=UDim2.new(0,0,1,-10),
    BackgroundColor3=T.SURFACE, BorderSizePixel=0, Parent=Header})
mk("TextLabel", {
    Size=UDim2.new(1,-60,1,0), Position=UDim2.fromOffset(10,0),
    BackgroundTransparency=1, Text="* Menu", TextColor3=T.TEXT,
    Font=T.FONTB, TextSize=cfg.TITLE_S,
    TextXAlignment=Enum.TextXAlignment.Left, Parent=Header,
})

-- ══════════════════════════════════════════════════════════════════════════════
--  BOTÕES FLUTUANTES
--  CORRIGIDO: ícones trocados por texto ASCII puro que o Roblox renderiza
--  corretamente em qualquer fonte.
--    X  = Fechar   (era "×" — aparecia bugado)
--    [ ] = Minimizar (era "▣" — aparecia como quadrado bugado)
--    O  = Recentrar  (era "⌖" — aparecia como "0" bugado)
-- ══════════════════════════════════════════════════════════════════════════════
local function makeBtn(label, row, color)
    local b = mk("TextButton", {
        Size=UDim2.fromOffset(BTN_SZ,BTN_SZ),
        Position=UDim2.fromOffset(BTN_PAD, BTN_PAD+(BTN_SZ+6)*row),
        BackgroundColor3=color, Text=label, TextColor3=T.TEXT,
        Font=T.FONTB, TextSize=BTN_SZ>38 and 17 or 14,
        BorderSizePixel=0, AutoButtonColor=false, ZIndex=20, Parent=SG,
    })
    corner(b, UDim.new(0, BTN_SZ>38 and 11 or 7))
    mk("UIStroke", {Color=T.BORDER, Thickness=1, Parent=b})
    -- Hover sutil
    b.MouseEnter:Connect(function() tw(b, 0.1, {BackgroundTransparency=0.2}) end)
    b.MouseLeave:Connect(function() tw(b, 0.1, {BackgroundTransparency=0})   end)
    return b
end

-- Texto ASCII puro: sem caracteres Unicode especiais que causam bug
local CloseBtn  = makeBtn("X",   0, T.CLOSE)   -- Fechar
local ToggleBtn = makeBtn("[ ]", 1, T.ACCENT)  -- Minimizar/Restaurar
local ResetBtn  = makeBtn("O",   2, T.SURFACE) -- Recentrar janela

-- Tooltip pequeno ao lado dos botões (opcional, ajuda a entender)
local function addTooltip(btn, text)
    local tip = mk("TextLabel", {
        Size = UDim2.fromOffset(70, 20),
        Position = UDim2.new(1, 4, 0, (BTN_SZ-20)/2),
        BackgroundColor3 = Color3.fromRGB(8, 8, 14),
        BackgroundTransparency = 0.2,
        Text = text,
        TextColor3 = T.TEXT,
        Font = T.FONT,
        TextSize = 9,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 25,
        Parent = btn,
    })
    corner(tip, UDim.new(0, 4))
    btn.MouseEnter:Connect(function() tip.Visible = true  end)
    btn.MouseLeave:Connect(function() tip.Visible = false end)
end
addTooltip(CloseBtn,  "Fechar")
addTooltip(ToggleBtn, "Minimizar")
addTooltip(ResetBtn,  "Recentrar")

-- TabBar + ContentArea
local TabBar = mk("Frame", {
    Size=UDim2.new(1,-16,0,cfg.TAB_H), Position=UDim2.new(0,8,0,cfg.HDR_H+4),
    BackgroundTransparency=1, Parent=Window,
})
mk("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal,
    SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,3), Parent=TabBar})

local TAB_OFFSET = cfg.HDR_H + cfg.TAB_H + 8
local ContentArea = mk("Frame", {
    Size=UDim2.new(1,0,1,-TAB_OFFSET), Position=UDim2.fromOffset(0,TAB_OFFSET),
    BackgroundTransparency=1, ClipsDescendants=true, Parent=Window,
})

-- ══════════════════════════════════════════════════════════════════════════════
--  TABS
-- ══════════════════════════════════════════════════════════════════════════════
local tabBtns, tabFrames, activeTab = {}, {}, nil

local function setActive(name)
    if activeTab == name then return end
    activeTab = name
    for _, td in ipairs(TABS) do
        local btn = tabBtns[td.name]
        local frm = tabFrames[td.name]
        local on  = (td.name == name)
        tw(btn, 0.12, {BackgroundTransparency = on and 0 or 1})
        btn.TextColor3 = on and T.TEXT or T.MUTED
        if frm then frm.Visible = on end
    end
end

for i, td in ipairs(TABS) do
    local btn = mk("TextButton", {
        Size=UDim2.new(1/#TABS,-3,1,0), BackgroundColor3=T.ACCENT,
        BackgroundTransparency=1, Text=td.name, TextColor3=T.MUTED,
        Font=T.FONT, TextSize=cfg.FONT_S, BorderSizePixel=0,
        AutoButtonColor=false, LayoutOrder=i, Parent=TabBar,
    })
    corner(btn, UDim.new(0,5))
    tabBtns[td.name] = btn

    local frm = mk("Frame", {
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
        Visible=false, Parent=ContentArea,
    })
    tabFrames[td.name] = frm

    if td.module then
        local mod = loadModule(td.module, frm)
        if mod and mod.Init then pcall(mod.Init, frm, T) end
    end

    btn.Activated:Connect(function() setActive(td.name) end)
end

setActive(TABS[1].name)

-- ══════════════════════════════════════════════════════════════════════════════
--  AÇÕES DOS BOTÕES
-- ══════════════════════════════════════════════════════════════════════════════

-- FECHAR: roda cleanup de todos os módulos (inclui desconectar F1/F2), depois destrói
CloseBtn.Activated:Connect(function()
    runAllCleanups()
    SG:Destroy()
end)

local minimized = false
local function setMin(s)
    minimized = s
    Window.Visible = not s
    ToggleBtn.BackgroundColor3 = s and T.MUTED or T.ACCENT
    ToggleBtn.Text = s and ">  <" or "[ ]"
end
ToggleBtn.Activated:Connect(function() setMin(not minimized) end)

ResetBtn.Activated:Connect(function()
    local vpW, vpH = getVP()
    local nx = math.clamp((vpW-WIN_W)/2, 0, vpW-WIN_W)
    local ny = math.clamp((vpH-WIN_H)/2, 0, vpH-WIN_H)
    tw(Window, 0.25, {Position = UDim2.fromOffset(nx, ny)})
    if minimized then setMin(false) end
end)

-- ══════════════════════════════════════════════════════════════════════════════
--  DRAG
-- ══════════════════════════════════════════════════════════════════════════════
do
    local drag, sPos, sWin = false, Vector2.zero, Vector2.zero
    local function begin(pos)
        drag=true; sPos=Vector2.new(pos.X,pos.Y)
        sWin=Vector2.new(Window.Position.X.Offset, Window.Position.Y.Offset)
    end
    local function stop() drag=false end
    local function move(pos)
        if not drag then return end
        local nx,ny = clampWin(sWin.X+pos.X-sPos.X, sWin.Y+pos.Y-sPos.Y, WIN_W, WIN_H)
        Window.Position = UDim2.fromOffset(nx, ny)
    end
    Header.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then begin(i.Position) end end)
    Header.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then stop() end end)
    UIS.InputChanged:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then move(i.Position) end end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then stop() end end)
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
        Window.Size = UDim2.fromOffset(WIN_W, WIN_H)
        Header.Size = UDim2.new(1,0,0,nc.HDR_H)
        TabBar.Size = UDim2.new(1,-16,0,nc.TAB_H)
        TabBar.Position = UDim2.new(0,8,0,nc.HDR_H+4)
        local off = nc.HDR_H+nc.TAB_H+8
        ContentArea.Size = UDim2.new(1,0,1,-off)
        ContentArea.Position = UDim2.fromOffset(0, off)
        for row, btn in ipairs({CloseBtn, ToggleBtn, ResetBtn}) do
            btn.Size = UDim2.fromOffset(BTN_SZ, BTN_SZ)
            btn.Position = UDim2.fromOffset(BTN_PAD, BTN_PAD+(BTN_SZ+6)*(row-1))
        end
    end
    local px, py = Window.Position.X.Offset, Window.Position.Y.Offset
    local nx, ny = clampWin(px, py, WIN_W, WIN_H)
    Window.Position = UDim2.fromOffset(nx, ny)
end)

-- ══════════════════════════════════════════════════════════════════════════════
--  RECUPERAÇÃO AUTOMÁTICA
-- ══════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while SG.Parent do
        task.wait(5)
        if not minimized then
            local vpW, vpH = getVP()
            local px, py = Window.Position.X.Offset, Window.Position.Y.Offset
            if px>vpW-30 or px+WIN_W<30 or py>vpH-30 or py+WIN_H<30 then
                local nx, ny = clampWin(px, py, WIN_W, WIN_H)
                tw(Window, 0.4, {Position = UDim2.fromOffset(nx, ny)})
            end
        end
    end
end)
