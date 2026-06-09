-- Modules/NPCTab.lua
-- Ferramentas relacionadas a NPCs do jogo.

local NPCTab = {}

-- ── Shared button factory (cada módulo tem o seu para não criar dependência) ──
local function makeButton(parent, text, color, layoutOrder, theme)
    local b = Instance.new("TextButton")
    b.Size              = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3  = color
    b.Text              = text
    b.TextColor3        = theme.TEXT
    b.Font              = theme.FONT_BOLD
    b.TextSize          = 13
    b.BorderSizePixel   = 0
    b.AutoButtonColor   = false
    b.LayoutOrder       = layoutOrder
    b.Parent            = parent
    local c = Instance.new("UICorner")
    c.CornerRadius      = theme.CORNER
    c.Parent            = b
    b.MouseEnter:Connect(function()
        b.BackgroundColor3 = Color3.new(
            math.min(color.R + 0.08, 1),
            math.min(color.G + 0.08, 1),
            math.min(color.B + 0.08, 1))
    end)
    b.MouseLeave:Connect(function() b.BackgroundColor3 = color end)
    return b
end

local function sectionLabel(parent, text, order, theme)
    local l = Instance.new("TextLabel")
    l.Size                  = UDim2.new(1, 0, 0, 18)
    l.BackgroundTransparency = 1
    l.Text                  = text
    l.TextColor3            = theme.SUBTEXT
    l.Font                  = theme.FONT_BOLD
    l.TextSize              = 11
    l.TextXAlignment        = Enum.TextXAlignment.Left
    l.LayoutOrder           = order
    l.Parent                = parent
    return l
end

function NPCTab.Init(frame, THEME)
    -- Normaliza chaves do tema (compatível com UI.lua v2.2 e v2.3)
    THEME.FONT_BOLD = THEME.FONT_BOLD or THEME.FONTB or Enum.Font.GothamBold
    THEME.SUBTEXT   = THEME.SUBTEXT   or THEME.MUTED or Color3.fromRGB(120,120,140)
    THEME.CORNER    = THEME.CORNER    or UDim.new(0, 8)

    local RED    = Color3.fromRGB(200, 55, 55)
    local ORANGE = Color3.fromRGB(200, 120, 30)
    local GREEN  = Color3.fromRGB(40,  160, 90)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size                   = UDim2.fromScale(1, 1)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel        = 0
    scroll.ScrollBarThickness     = 3
    scroll.ScrollBarImageColor3   = THEME.ACCENT
    scroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    scroll.CanvasSize             = UDim2.new()
    scroll.Parent                 = frame

    Instance.new("UIListLayout", scroll).Padding  = UDim.new(0, 8)
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingTop    = UDim.new(0, 10)
    pad.PaddingLeft   = UDim.new(0, 12)
    pad.PaddingRight  = UDim.new(0, 12)
    pad.PaddingBottom = UDim.new(0, 10)

    -- ── Seção: Detecção ──────────────────────────────────────────────────
    sectionLabel(scroll, "DETECÇÃO", 1, THEME)

    local btnHighlight = makeButton(scroll, "👁  Destacar NPCs", ORANGE, 2, THEME)
    btnHighlight.MouseButton1Click:Connect(function()
        -- lógica: contorna NPCs com BillboardGui
        local count = 0
        for _, model in ipairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model:FindFirstChild("Humanoid")
                and model ~= game.Players.LocalPlayer.Character then
                local root = model:FindFirstChild("HumanoidRootPart")
                if root and not root:FindFirstChild("_npcTag") then
                    local bb = Instance.new("BillboardGui", root)
                    bb.Name          = "_npcTag"
                    bb.Size          = UDim2.fromOffset(60, 20)
                    bb.StudsOffset   = Vector3.new(0, 3, 0)
                    bb.AlwaysOnTop   = true
                    local lbl = Instance.new("TextLabel", bb)
                    lbl.Size             = UDim2.fromScale(1, 1)
                    lbl.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
                    lbl.TextColor3       = Color3.new(1, 1, 1)
                    lbl.Text             = "NPC"
                    lbl.Font             = Enum.Font.GothamBold
                    lbl.TextSize         = 11
                    Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 4)
                    count += 1
                end
            end
        end
        btnHighlight.Text = "✓  " .. count .. " NPC(s) marcados"
        task.delay(2.5, function() btnHighlight.Text = "👁  Destacar NPCs" end)
    end)

    -- ── Seção: Ações ────────────────────────────────────────────────────
    sectionLabel(scroll, "AÇÕES", 10, THEME)

    local btnKill = makeButton(scroll, "💀  Eliminar NPCs Próximos", RED, 11, THEME)
    btnKill.MouseButton1Click:Connect(function()
        local char   = game.Players.LocalPlayer.Character
        local hrp    = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local killed = 0
        for _, model in ipairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model ~= char then
                local hum  = model:FindFirstChildOfClass("Humanoid")
                local mhrp = model:FindFirstChild("HumanoidRootPart")
                if hum and mhrp and (mhrp.Position - hrp.Position).Magnitude < 50 then
                    hum.Health = 0
                    killed += 1
                end
            end
        end
        btnKill.Text = "✓  " .. killed .. " eliminado(s)"
        task.delay(2, function() btnKill.Text = "💀  Eliminar NPCs Próximos" end)
    end)

    local btnFreeze = makeButton(scroll, "🧊  Congelar NPCs", GREEN, 12, THEME)
    btnFreeze.MouseButton1Click:Connect(function()
        local count = 0
        for _, model in ipairs(workspace:GetDescendants()) do
            if model:IsA("Model") and model:FindFirstChildOfClass("Humanoid")
                and model ~= game.Players.LocalPlayer.Character then
                local hum = model:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed  = 0
                    hum.JumpHeight = 0
                    count += 1
                end
            end
        end
        btnFreeze.Text = "✓  " .. count .. " congelado(s)"
        task.delay(2, function() btnFreeze.Text = "🧊  Congelar NPCs" end)
    end)
end

return NPCTab
