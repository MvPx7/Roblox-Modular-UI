-- UI.lua
local GITHUB_RAW = "https://raw.githubusercontent.com/MvPx7/Roblox-Modular-UI/main/Modules/"

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP           = Players.LocalPlayer
local PlayerGui    = LP:WaitForChild("PlayerGui")

-- Detecção mobile mais robusta: TouchEnabled OU tela pequena (executors mobile)
local vp         = workspace.CurrentCamera.ViewportSize
local IsMobile   = UIS.TouchEnabled or (vp.X < 900 and vp.Y < 900)

local TABS = {
    { name = "Home",    module = "HomeTab"   },
    { name = "NPC",     module = "NPCTab"    },
    { name = "Player",  module = "PlayerTab" },
    { name = "Visual",  module = "VisualTab" },
    { name = "Config",  module = "ConfigTab" },
}

local T = {
    BG      = Color3.fromRGB(12, 12, 18),
    SURFACE = Color3.fromRGB(20, 20, 28),
    BORDER  = Color3.fromRGB(35, 35, 50),
    ACCENT  = Color3.fromRGB(99, 102, 241),
    TEXT    = Color3.fromRGB(220, 220, 235),
    SUBTEXT = Color3.fromRGB(100, 100, 120),
    ERR     = Color3.fromRGB(220, 60, 60),
    FONT    = Enum.Font.GothamMedium,
    FONTB   = Enum.Font.GothamBold,
    MOBILE  = IsMobile,
    WIN_W   = IsMobile and 300 or 340,
    WIN_H   = IsMobile and 390 or 360,
    HDR_H   = IsMobile and 40  or 34,
    TAB_H   = IsMobile and 34  or 28,
    CORNER  = UDim.new(0, 10),
}

-- ── Helpers ───────────────────────────────────────────────────────────────────
local function mk(cls, props, parent)
    local o = Instance.new(cls)
    for k,v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(p, r)
    mk("UICorner", {CornerRadius = r or T.CORNER}, p)
end
local function tw(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad), props):Play()
end

-- Carrega módulo — mostra erro visível na aba se falhar
local function loadModule(name, errorFrame)
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(GITHUB_RAW .. name .. ".lua", true))()
    end)
    if ok and res then return res end
    -- Mostra o erro dentro do frame da aba
    if errorFrame then
        mk("TextLabel", {
            Size = UDim2.new(1,-20,0,0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.fromOffset(10,10),
            BackgroundTransparency = 1,
            Text = "⚠ " .. name .. " falhou:\n" .. tostring(res),
            TextColor3 = T.ERR,
            Font = T.FONT,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = errorFrame,
        })
    end
    warn("[UI] " .. name .. ": " .. tostring(res))
    return nil
end

-- ── ScreenGui ─────────────────────────────────────────────────────────────────
local SG = mk("ScreenGui", {
    Name = "MainGui", ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = PlayerGui,
})

local WIN_W, WIN_H = T.WIN_W, T.WIN_H

-- ── Janela ────────────────────────────────────────────────────────────────────
local Window = mk("Frame", {
    Name = "Window",
    Size = UDim2.fromOffset(WIN_W, WIN_H),
    Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = T.BG,
    BorderSizePixel = 0,
    Parent = SG,
})
corner(Window)
mk("UIStroke", {
    Color = T.BORDER, Thickness = 1,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Parent = Window,
})

-- ── Header ────────────────────────────────────────────────────────────────────
local Header = mk("Frame", {
    Size = UDim2.new(1, 0, 0, T.HDR_H),
    BackgroundColor3 = T.SURFACE,
    BorderSizePixel = 0,
    Parent = Window,
})
corner(Header)
mk("Frame", { -- tapa canto inferior
    Size = UDim2.new(1, 0, 0, 10),
    Position = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = T.SURFACE,
    BorderSizePixel = 0,
    Parent = Header,
})
mk("TextLabel", {
    Size = UDim2.new(1, -50, 1, 0),
    Position = UDim2.fromOffset(10, 0),
    BackgroundTransparency = 1,
    Text = "✦ Menu",
    TextColor3 = T.TEXT,
    Font = T.FONTB,
    TextSize = IsMobile and 13 or 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = Header,
})

-- Botão flutuante fixo no canto — sempre visível, nunca sai da tela
local ToggleBtn = mk("TextButton", {
    Size        = UDim2.fromOffset(IsMobile and 44 or 36, IsMobile and 44 or 36),
    Position    = UDim2.new(0, 8, 0, 8),   -- canto superior esquerdo fixo
    BackgroundColor3 = T.ACCENT,
    Text        = "✦",
    TextColor3  = T.TEXT,
    Font        = T.FONTB,
    TextSize    = IsMobile and 18 or 15,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    ZIndex      = 10,
    Parent      = SG,   -- filho do ScreenGui, não da janela
})
corner(ToggleBtn, UDim.new(0, IsMobile and 12 or 8))

-- Remove o "−" do header, já que o toggle é externo
mk("TextLabel", {   -- placeholder vazio no lugar do MinBtn
    Size = UDim2.fromOffset(1, 1),
    BackgroundTransparency = 1,
    Text = "",
    Parent = Header,
})

local TabBar, ContentArea
local minimized = false

local function setMin(s)
    minimized = s
    Window.Visible = not s
    ToggleBtn.Text      = s and "✦" or "×"
    ToggleBtn.BackgroundColor3 = s and T.ACCENT or Color3.fromRGB(80, 30, 30)
end
ToggleBtn.Activated:Connect(function() setMin(not minimized) end)

-- ── Drag com clamp ────────────────────────────────────────────────────────────
do
    local drag, sp, sw
    local function startDrag(pos)
        drag=true; sp=pos; sw=Window.Position
    end
    local function stopDrag() drag=false end
    local function moveDrag(pos)
        if not drag then return end
        local d   = pos - sp
        local cvp = workspace.CurrentCamera.ViewportSize
        Window.Position = UDim2.fromOffset(
            math.clamp(sw.X.Offset + d.X, 0, cvp.X - WIN_W),
            math.clamp(sw.Y.Offset + d.Y, 0, cvp.Y - WIN_H)
        )
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

-- ── TabBar ────────────────────────────────────────────────────────────────────
TabBar = mk("Frame", {
    Size = UDim2.new(1, -16, 0, T.TAB_H),
    Position = UDim2.new(0, 8, 0, T.HDR_H + 4),
    BackgroundTransparency = 1,
    Parent = Window,
})
mk("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 3),
    Parent = TabBar,
})

-- ── ContentArea ───────────────────────────────────────────────────────────────
local TAB_OFFSET = T.HDR_H + T.TAB_H + 8
ContentArea = mk("Frame", {
    Size = UDim2.new(1, 0, 1, -TAB_OFFSET),
    Position = UDim2.fromOffset(0, TAB_OFFSET),
    BackgroundTransparency = 1,
    Parent = Window,
})

-- ── Tabs ──────────────────────────────────────────────────────────────────────
local tabBtns, tabFrames, activeTab = {}, {}, nil

local function setActive(name)
    if activeTab == name then return end
    activeTab = name
    for _, td in ipairs(TABS) do
        local btn = tabBtns[td.name]
        local frm = tabFrames[td.name]
        local on  = (td.name == name)
        tw(btn, 0.1, {BackgroundTransparency = on and 0 or 1})
        btn.TextColor3 = on and T.TEXT or T.SUBTEXT
        if frm then frm.Visible = on end
    end
end

for i, td in ipairs(TABS) do
    local btn = mk("TextButton", {
        Size = UDim2.new(1/#TABS, -3, 1, 0),
        BackgroundColor3 = T.ACCENT,
        BackgroundTransparency = 1,
        Text = td.name,
        TextColor3 = T.SUBTEXT,
        Font = T.FONT,
        TextSize = IsMobile and 11 or 10,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        LayoutOrder = i,
        Parent = TabBar,
    })
    corner(btn, UDim.new(0, 5))
    tabBtns[td.name] = btn

    local frm = mk("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = ContentArea,
    })
    tabFrames[td.name] = frm

    local mod = loadModule(td.module, frm)
    if mod and mod.Init then
        pcall(mod.Init, frm, T)
    end

    btn.Activated:Connect(function() setActive(td.name) end)
end

setActive(TABS[1].name)
