-- Modules/NPCTab.lua  v2.0
-- Highlight com nome + range ajustável + cleanup ao fechar UI
-- ══════════════════════════════════════════════════════════════════════════════

local NPCTab = {}

-- ── Constantes ────────────────────────────────────────────────────────────────
local HIGHLIGHT_TAG = "_uiNpcHL"   -- nome do Highlight dentro do model
local SCAN_INTERVAL = 2            -- segundos entre cada varredura de NPCs

-- Cores do Highlight
local HL_FILL    = Color3.fromRGB(99, 102, 241)   -- roxo (igual ao ACCENT)
local HL_OUTLINE = Color3.fromRGB(180, 180, 255)

-- ══════════════════════════════════════════════════════════════════════════════
--  HELPERS INTERNOS
-- ══════════════════════════════════════════════════════════════════════════════
local function isNPC(model)
    if not model:IsA("Model") then return false end
    if not model:FindFirstChildOfClass("Humanoid") then return false end
    -- ignora o personagem do jogador local
    local lp = game:GetService("Players").LocalPlayer
    if lp and model == lp.Character then return false end
    return true
end

local function getDistance(model)
    local lp   = game:GetService("Players").LocalPlayer
    local char = lp and lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local mhrp = model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("RootPart")
        or model.PrimaryPart
    if not hrp or not mhrp then return math.huge end
    return (mhrp.Position - hrp.Position).Magnitude
end

-- ── Helpers de UI ─────────────────────────────────────────────────────────────
local function mk(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(p, r)
    mk("UICorner", {CornerRadius = r or UDim.new(0, 8)}, p)
end

local function label(parent, text, order, theme)
    return mk("TextLabel", {
        Size                  = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text                  = text,
        TextColor3            = theme.MUTED,
        Font                  = theme.FONTB,
        TextSize              = 10,
        TextXAlignment        = Enum.TextXAlignment.Left,
        LayoutOrder           = order,
        Parent                = parent,
    })
end

local function makeBtn(parent, text, color, order, theme)
    local b = mk("TextButton", {
        Size             = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = color,
        Text             = text,
        TextColor3       = theme.TEXT,
        Font             = theme.FONTB,
        TextSize         = 13,
        BorderSizePixel  = 0,
        AutoButtonColor  = false,
        LayoutOrder      = order,
        Parent           = parent,
    })
    corner(b)
    -- hover sutil
    local base = color
    b.MouseEnter:Connect(function()
        b.BackgroundColor3 = Color3.new(
            math.min(base.R + 0.07, 1),
            math.min(base.G + 0.07, 1),
            math.min(base.B + 0.07, 1))
    end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = base end)
    return b
end

local function makeDivider(parent, order)
    local f = mk("Frame", {
        Size             = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Color3.fromRGB(40, 40, 60),
        BorderSizePixel  = 0,
        LayoutOrder      = order,
        Parent           = parent,
    })
end

-- ── Slider helper ─────────────────────────────────────────────────────────────
-- Retorna (frame, getter) onde getter() → valor atual
local function makeSlider(parent, labelTxt, minVal, maxVal, defaultVal, order, theme, onChange)
    local SLIDER_H = 46
    local container = mk("Frame", {
        Size             = UDim2.new(1, 0, 0, SLIDER_H),
        BackgroundColor3 = Color3.fromRGB(18, 18, 28),
        BorderSizePixel  = 0,
        LayoutOrder      = order,
        Parent           = parent,
    })
    corner(container)
    mk("UIStroke", {Color = Color3.fromRGB(40,40,60), Thickness=1, Parent=container})

    local titleLbl = mk("TextLabel", {
        Size               = UDim2.new(1,-50,0,16),
        Position           = UDim2.fromOffset(10, 6),
        BackgroundTransparency = 1,
        Text               = labelTxt,
        TextColor3         = theme.TEXT,
        Font               = theme.FONT,
        TextSize           = 11,
        TextXAlignment     = Enum.TextXAlignment.Left,
        Parent             = container,
    })

    local valLbl = mk("TextLabel", {
        Size               = UDim2.fromOffset(44, 16),
        Position           = UDim2.new(1, -50, 0, 6),
        BackgroundTransparency = 1,
        Text               = tostring(defaultVal),
        TextColor3         = theme.ACCENT,
        Font               = theme.FONTB,
        TextSize           = 11,
        TextXAlignment     = Enum.TextXAlignment.Right,
        Parent             = container,
    })

    -- track
    local track = mk("Frame", {
        Size             = UDim2.new(1,-20,0,6),
        Position         = UDim2.fromOffset(10, 30),
        BackgroundColor3 = Color3.fromRGB(35,35,55),
        BorderSizePixel  = 0,
        Parent           = container,
    })
    corner(track, UDim.new(0,3))

    -- fill
    local ratio0 = (defaultVal - minVal) / (maxVal - minVal)
    local fill = mk("Frame", {
        Size             = UDim2.new(ratio0, 0, 1, 0),
        BackgroundColor3 = theme.ACCENT,
        BorderSizePixel  = 0,
        Parent           = track,
    })
    corner(fill, UDim.new(0,3))

    -- thumb
    local thumb = mk("Frame", {
        Size             = UDim2.fromOffset(14,14),
        Position         = UDim2.new(ratio0,-7,0.5,-7),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel  = 0,
        ZIndex           = 2,
        Parent           = track,
    })
    corner(thumb, UDim.new(0,7))

    local currentVal = defaultVal
    local dragging   = false

    local function updateFromX(absX)
        local trackAbs = track.AbsolutePosition
        local trackW   = track.AbsoluteSize.X
        local r = math.clamp((absX - trackAbs.X) / trackW, 0, 1)
        local v = math.floor(minVal + r * (maxVal - minVal) + 0.5)
        currentVal = v
        fill.Size  = UDim2.new(r, 0, 1, 0)
        thumb.Position = UDim2.new(r, -7, 0.5, -7)
        valLbl.Text = tostring(v)
        if onChange then onChange(v) end
    end

    local UIS = game:GetService("UserInputService")
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(i.Position.X)
        end
    end)

    return container, function() return currentVal end
end

-- ══════════════════════════════════════════════════════════════════════════════
--  STATUS BAR  (contador de NPCs destacados)
-- ══════════════════════════════════════════════════════════════════════════════
local function makeStatusBar(parent, order, theme)
    local bar = mk("Frame", {
        Size             = UDim2.new(1,0,0,28),
        BackgroundColor3 = Color3.fromRGB(16,16,26),
        BorderSizePixel  = 0,
        LayoutOrder      = order,
        Parent           = parent,
    })
    corner(bar)
    mk("UIStroke", {Color=Color3.fromRGB(40,40,60), Thickness=1, Parent=bar})
    local dot = mk("Frame", {
        Size=UDim2.fromOffset(8,8), Position=UDim2.fromOffset(10,10),
        BackgroundColor3=Color3.fromRGB(80,80,100), BorderSizePixel=0, Parent=bar,
    })
    corner(dot, UDim.new(0,4))
    local lbl = mk("TextLabel", {
        Size=UDim2.new(1,-30,1,0), Position=UDim2.fromOffset(26,0),
        BackgroundTransparency=1, Text="Highlight desativado",
        TextColor3=theme.MUTED, Font=theme.FONT, TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=bar,
    })
    local function set(active, count)
        dot.BackgroundColor3 = active
            and Color3.fromRGB(99,102,241)
            or  Color3.fromRGB(80,80,100)
        lbl.TextColor3 = active and theme.TEXT or theme.MUTED
        lbl.Text = active
            and ("✦ " .. count .. " NPC(s) destacado(s)")
            or  "Highlight desativado"
    end
    return bar, set
end

-- ══════════════════════════════════════════════════════════════════════════════
--  INIT
-- ══════════════════════════════════════════════════════════════════════════════
function NPCTab.Init(frame, THEME)
    -- Normaliza chaves (compatível com todas as versões do UI.lua)
    THEME.FONTB    = THEME.FONTB    or Enum.Font.GothamBold
    THEME.FONT     = THEME.FONT     or Enum.Font.GothamMedium
    THEME.MUTED    = THEME.MUTED    or THEME.SUBTEXT or Color3.fromRGB(120,120,140)
    THEME.CORNER   = THEME.CORNER   or UDim.new(0,8)
    THEME.ACCENT   = THEME.ACCENT   or Color3.fromRGB(99,102,241)
    THEME.TEXT     = THEME.TEXT     or Color3.new(1,1,1)

    local RED    = Color3.fromRGB(190, 50, 50)
    local ORANGE = Color3.fromRGB(200, 115, 30)
    local GREEN  = Color3.fromRGB(35, 155, 85)
    local INDIGO = Color3.fromRGB(75, 78, 200)

    -- ── ScrollingFrame ────────────────────────────────────────────────────────
    local scroll = mk("ScrollingFrame", {
        Size                  = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        BorderSizePixel       = 0,
        ScrollBarThickness    = 3,
        ScrollBarImageColor3  = THEME.ACCENT,
        AutomaticCanvasSize   = Enum.AutomaticSize.Y,
        CanvasSize            = UDim2.new(),
        Parent                = frame,
    })
    mk("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 6),
        Parent    = scroll,
    })
    local pad = mk("UIPadding", {
        PaddingTop    = UDim.new(0,10),
        PaddingLeft   = UDim.new(0,10),
        PaddingRight  = UDim.new(0,10),
        PaddingBottom = UDim.new(0,10),
        Parent        = scroll,
    })

    -- ── Estado do highlight ───────────────────────────────────────────────────
    local highlightActive = false
    local highlightRange  = 100   -- valor inicial do slider
    local scanThread      = nil   -- thread de varredura
    local taggedModels    = {}    -- { [model] = true }

    -- ── Status bar ───────────────────────────────────────────────────────────
    local statusBar, setStatus = makeStatusBar(scroll, 1, THEME)

    -- ── Seção: Highlight ─────────────────────────────────────────────────────
    label(scroll, "  HIGHLIGHT", 2, THEME)

    -- Slider de range
    local _, getRange = makeSlider(
        scroll, "Range de detecção (studs)", 20, 500, highlightRange, 3, THEME,
        function(v)
            highlightRange = v
        end
    )

    -- Botão Toggle Highlight
    local btnHL = makeBtn(scroll, "👁  Ativar Highlight", INDIGO, 4, THEME)

    -- ── Seção: Ações ─────────────────────────────────────────────────────────
    makeDivider(scroll, 9)
    label(scroll, "  AÇÕES", 10, THEME)

    local btnKill   = makeBtn(scroll, "💀  Eliminar NPCs Próximos", RED,    11, THEME)
    local btnFreeze = makeBtn(scroll, "🧊  Congelar NPCs",          GREEN,  12, THEME)
    local btnUnfreeze = makeBtn(scroll, "🔥  Descongelar NPCs",     ORANGE, 13, THEME)

    -- ════════════════════════════════════════════════════════════════════════
    --  HIGHLIGHT: adiciona/remove Highlight + BillboardGui com nome do NPC
    -- ════════════════════════════════════════════════════════════════════════
    local function addHighlight(model)
        if model:FindFirstChild(HIGHLIGHT_TAG) then return end

        -- Highlight nativo do Roblox (sem BillboardGui vermelho feio)
        local hl = Instance.new("Highlight", model)
        hl.Name            = HIGHLIGHT_TAG
        hl.FillColor       = HL_FILL
        hl.OutlineColor    = HL_OUTLINE
        hl.FillTransparency    = 0.55
        hl.OutlineTransparency = 0
        hl.DepthMode       = Enum.HighlightDepthMode.AlwaysOnTop

        -- Nome do NPC acima da cabeça
        local root = model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("RootPart")
            or model.PrimaryPart
        if root then
            local bb = Instance.new("BillboardGui", root)
            bb.Name         = HIGHLIGHT_TAG .. "_name"
            bb.Size         = UDim2.fromOffset(120, 22)
            bb.StudsOffset  = Vector3.new(0, 3.2, 0)
            bb.AlwaysOnTop  = true
            bb.LightInfluence = 0
            local lbl = Instance.new("TextLabel", bb)
            lbl.Size               = UDim2.fromScale(1,1)
            lbl.BackgroundTransparency = 1
            lbl.Text               = model.Name
            lbl.TextColor3         = Color3.new(1,1,1)
            lbl.Font               = Enum.Font.GothamBold
            lbl.TextSize           = 12
            lbl.TextStrokeTransparency = 0.4
            lbl.TextStrokeColor3   = Color3.new(0,0,0)
        end

        taggedModels[model] = true
    end

    local function removeHighlight(model)
        local hl = model:FindFirstChild(HIGHLIGHT_TAG)
        if hl then hl:Destroy() end
        local root = model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("RootPart")
            or model.PrimaryPart
        if root then
            local bb = root:FindFirstChild(HIGHLIGHT_TAG .. "_name")
            if bb then bb:Destroy() end
        end
        taggedModels[model] = nil
    end

    local function clearAllHighlights()
        for model in pairs(taggedModels) do
            pcall(removeHighlight, model)
        end
        taggedModels = {}
    end

    -- Varredura periódica (adiciona NPCs dentro do range, remove os de fora)
    local function startScan()
        if scanThread then return end
        scanThread = task.spawn(function()
            while highlightActive do
                local range = getRange()
                -- adiciona novos dentro do range
                for _, model in ipairs(workspace:GetDescendants()) do
                    if isNPC(model) and getDistance(model) <= range then
                        pcall(addHighlight, model)
                    end
                end
                -- remove os que saíram do range ou foram destruídos
                for model in pairs(taggedModels) do
                    if not model.Parent or getDistance(model) > range then
                        pcall(removeHighlight, model)
                    end
                end
                -- atualiza status
                local count = 0
                for _ in pairs(taggedModels) do count += 1 end
                setStatus(true, count)
                task.wait(SCAN_INTERVAL)
            end
            clearAllHighlights()
            setStatus(false, 0)
            scanThread = nil
        end)
    end

    local function stopScan()
        highlightActive = false  -- o loop do scanThread vai detectar e sair
    end

    -- Botão toggle highlight
    btnHL.MouseButton1Click:Connect(function()
        highlightActive = not highlightActive
        if highlightActive then
            btnHL.Text = "👁  Desativar Highlight"
            btnHL.BackgroundColor3 = Color3.fromRGB(50,50,50)
            startScan()
        else
            btnHL.Text = "👁  Ativar Highlight"
            btnHL.BackgroundColor3 = INDIGO
            stopScan()
        end
    end)

    -- ── Eliminar NPCs próximos ────────────────────────────────────────────────
    btnKill.MouseButton1Click:Connect(function()
        local lp   = game:GetService("Players").LocalPlayer
        local char = lp and lp.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local killed = 0
        for _, model in ipairs(workspace:GetDescendants()) do
            if isNPC(model) then
                local mhrp = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                if mhrp and (mhrp.Position - hrp.Position).Magnitude < 50 then
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0; killed += 1 end
                end
            end
        end
        btnKill.Text = "✓  " .. killed .. " eliminado(s)"
        task.delay(2, function() btnKill.Text = "💀  Eliminar NPCs Próximos" end)
    end)

    -- ── Congelar ──────────────────────────────────────────────────────────────
    btnFreeze.MouseButton1Click:Connect(function()
        local count = 0
        for _, model in ipairs(workspace:GetDescendants()) do
            if isNPC(model) then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:SetAttribute("_prevWalk",  hum.WalkSpeed)
                    hum:SetAttribute("_prevJump",  hum.JumpHeight)
                    hum.WalkSpeed  = 0
                    hum.JumpHeight = 0
                    count += 1
                end
            end
        end
        btnFreeze.Text = "✓  " .. count .. " congelado(s)"
        task.delay(2, function() btnFreeze.Text = "🧊  Congelar NPCs" end)
    end)

    -- ── Descongelar ───────────────────────────────────────────────────────────
    btnUnfreeze.MouseButton1Click:Connect(function()
        local count = 0
        for _, model in ipairs(workspace:GetDescendants()) do
            if isNPC(model) then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed  = hum:GetAttribute("_prevWalk")  or 16
                    hum.JumpHeight = hum:GetAttribute("_prevJump")  or 7.2
                    count += 1
                end
            end
        end
        btnUnfreeze.Text = "✓  " .. count .. " descongelado(s)"
        task.delay(2, function() btnUnfreeze.Text = "🔥  Descongelar NPCs" end)
    end)

    -- ════════════════════════════════════════════════════════════════════════
    --  CLEANUP ao fechar a UI
    -- ════════════════════════════════════════════════════════════════════════
    if UI_REGISTRY then
        UI_REGISTRY.onClose(function()
            highlightActive = false   -- para o scanThread
            task.wait(0.05)           -- dá tempo pro loop encerrar
            clearAllHighlights()      -- remove tudo do workspace
        end)
    end
end

return NPCTab
