-- Modules/ConfigTab.lua
-- Configurações gerais: tema, keybinds, info do menu.

local ConfigTab = {}

function ConfigTab.Init(frame, THEME)
    local UIS = game:GetService("UserInputService")

    local function corner(p, r)
        local c = Instance.new("UICorner"); c.CornerRadius = r or THEME.CORNER; c.Parent = p
    end

    local function label(props)
        local l = Instance.new("TextLabel")
        for k, v in pairs(props) do l[k] = v end
        return l
    end

    local function secLabel(parent, text, order)
        label({
            Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1,
            Text = text, TextColor3 = THEME.SUBTEXT,
            Font = THEME.FONT_BOLD, TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = order, Parent = parent,
        })
    end

    -- ── Scroll ───────────────────────────────────────────────────────────
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.fromScale(1,1); scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = THEME.ACCENT
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(); scroll.Parent = frame
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 8)
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingTop = UDim.new(0,10); pad.PaddingLeft = UDim.new(0,12)
    pad.PaddingRight = UDim.new(0,12); pad.PaddingBottom = UDim.new(0,10)

    -- ── Keybind ──────────────────────────────────────────────────────────
    secLabel(scroll, "KEYBIND  (ocultar / mostrar menu)", 1)

    local currentKey = Enum.KeyCode.RightControl
    local listening  = false

    local keybindRow = Instance.new("Frame")
    keybindRow.Size              = UDim2.new(1, 0, 0, 40)
    keybindRow.BackgroundColor3  = Color3.fromRGB(30, 30, 42)
    keybindRow.BorderSizePixel   = 0
    keybindRow.LayoutOrder       = 2
    keybindRow.Parent            = scroll
    corner(keybindRow)

    label({
        Size = UDim2.new(0.6, 0, 1, 0), Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1, Text = "Tecla atual:",
        TextColor3 = THEME.TEXT, Font = THEME.FONT, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, Parent = keybindRow,
    })

    local keyBtn = Instance.new("TextButton", keybindRow)
    keyBtn.Size             = UDim2.fromOffset(120, 28)
    keyBtn.AnchorPoint      = Vector2.new(1, 0.5)
    keyBtn.Position         = UDim2.new(1, -10, 0.5, 0)
    keyBtn.BackgroundColor3 = THEME.ACCENT_DIM
    keyBtn.Text             = currentKey.Name
    keyBtn.TextColor3       = THEME.TEXT
    keyBtn.Font             = THEME.FONT_BOLD
    keyBtn.TextSize         = 12
    keyBtn.BorderSizePixel  = 0
    corner(keyBtn)

    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "[ pressione ]"
        keyBtn.BackgroundColor3 = Color3.fromRGB(180, 100, 20)
        local conn
        conn = UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keyBtn.Text = currentKey.Name
                keyBtn.BackgroundColor3 = THEME.ACCENT_DIM
                listening = false
                conn:Disconnect()
            end
        end)
    end)

    -- ── Info do menu ─────────────────────────────────────────────────────
    secLabel(scroll, "INFORMAÇÕES", 10)

    local LP   = game.Players.LocalPlayer
    local info = {
        { "Jogador",  LP.Name },
        { "UserId",   tostring(LP.UserId) },
        { "Plataforma", UIS:GetPlatform().Name },
    }

    for idx, row in ipairs(info) do
        local card = Instance.new("Frame")
        card.Size               = UDim2.new(1, 0, 0, 34)
        card.BackgroundColor3   = Color3.fromRGB(30, 30, 42)
        card.BorderSizePixel    = 0
        card.LayoutOrder        = 10 + idx
        card.Parent             = scroll
        corner(card)

        label({
            Size = UDim2.new(0.45, 0, 1, 0), Position = UDim2.fromOffset(12, 0),
            BackgroundTransparency = 1, Text = row[1],
            TextColor3 = THEME.SUBTEXT, Font = THEME.FONT, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left, Parent = card,
        })
        label({
            Size = UDim2.new(0.55, -12, 1, 0), Position = UDim2.new(0.45, 0, 0, 0),
            BackgroundTransparency = 1, Text = row[2],
            TextColor3 = THEME.TEXT, Font = THEME.FONT_BOLD, TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right, Parent = card,
        })
    end

    -- ── Botão fechar / destruir GUI ──────────────────────────────────────
    secLabel(scroll, "PERIGO", 20)

    local btnClose = Instance.new("TextButton")
    btnClose.Size               = UDim2.new(1, 0, 0, 36)
    btnClose.BackgroundColor3   = Color3.fromRGB(160, 40, 40)
    btnClose.Text               = "✕  Fechar e destruir menu"
    btnClose.TextColor3         = THEME.TEXT
    btnClose.Font               = THEME.FONT_BOLD
    btnClose.TextSize           = 13
    btnClose.BorderSizePixel    = 0
    btnClose.LayoutOrder        = 21
    btnClose.Parent             = scroll
    corner(btnClose)
    btnClose.MouseButton1Click:Connect(function()
        local gui = frame:FindFirstAncestorOfClass("ScreenGui")
        if gui then gui:Destroy() end
    end)
end

return ConfigTab
