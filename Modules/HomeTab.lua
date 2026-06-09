-- Modules/HomeTab.lua
-- Aba inicial: apresentação e atalhos rápidos.

local HomeTab = {}

function HomeTab.Init(frame, THEME)

    -- ── Helpers locais ───────────────────────────────────────────────────
    local function corner(parent, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = r or THEME.CORNER
        c.Parent = parent
    end

    local function label(props)
        local l = Instance.new("TextLabel")
        for k, v in pairs(props) do l[k] = v end
        return l
    end

    local function button(text, color, parent, pos)
        local b = Instance.new("TextButton")
        b.Size                  = UDim2.new(1, -24, 0, 38)
        b.Position              = pos
        b.BackgroundColor3      = color
        b.Text                  = text
        b.TextColor3            = THEME.TEXT
        b.Font                  = THEME.FONT_BOLD
        b.TextSize              = 13
        b.BorderSizePixel       = 0
        b.AutoButtonColor       = false
        b.Parent                = parent
        corner(b)
        -- hover
        b.MouseEnter:Connect(function()  b.BackgroundColor3 = Color3.fromRGB(
            color.R*255+20, color.G*255+20, color.B*255+20) end)
        b.MouseLeave:Connect(function()  b.BackgroundColor3 = color end)
        return b
    end

    -- ── Scroll container ─────────────────────────────────────────────────
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size                     = UDim2.fromScale(1, 1)
    scroll.BackgroundTransparency   = 1
    scroll.BorderSizePixel          = 0
    scroll.ScrollBarThickness       = 3
    scroll.ScrollBarImageColor3     = THEME.ACCENT
    scroll.CanvasSize               = UDim2.fromOffset(0, 0)
    scroll.AutomaticCanvasSize      = Enum.AutomaticSize.Y
    scroll.Parent                   = frame

    local list = Instance.new("UIListLayout")
    list.Padding    = UDim.new(0, 10)
    list.SortOrder  = Enum.SortOrder.LayoutOrder
    list.Parent     = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingTop      = UDim.new(0, 12)
    pad.PaddingLeft     = UDim.new(0, 12)
    pad.PaddingRight    = UDim.new(0, 12)
    pad.PaddingBottom   = UDim.new(0, 12)
    pad.Parent          = scroll

    -- ── Banner ───────────────────────────────────────────────────────────
    local banner = Instance.new("Frame")
    banner.Size                 = UDim2.new(1, 0, 0, 64)
    banner.BackgroundColor3     = THEME.ACCENT_DIM
    banner.BorderSizePixel      = 0
    banner.LayoutOrder          = 1
    banner.Parent               = scroll
    corner(banner)

    label({
        Size                    = UDim2.fromScale(1, 1),
        BackgroundTransparency  = 1,
        Text                    = "Bem-vindo ao Menu  ✦",
        TextColor3              = THEME.TEXT,
        Font                    = THEME.FONT_BOLD,
        TextSize                = 18,
        Parent                  = banner,
    })

    -- ── Separador de seção ───────────────────────────────────────────────
    local secLabel = label({
        Size                    = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency  = 1,
        Text                    = "ATALHOS RÁPIDOS",
        TextColor3              = THEME.SUBTEXT,
        Font                    = THEME.FONT_BOLD,
        TextSize                = 11,
        TextXAlignment          = Enum.TextXAlignment.Left,
        LayoutOrder             = 2,
        Parent                  = scroll,
    })

    -- ── Botões de atalho ─────────────────────────────────────────────────
    local QUICK = {
        { label = "🔄  Respawn", color = Color3.fromRGB(39, 110, 200) },
        { label = "🏠  Ir para Spawn", color = Color3.fromRGB(39, 150, 100) },
        { label = "📋  Copiar UserID", color = Color3.fromRGB(120, 60, 180) },
    }

    for idx, info in ipairs(QUICK) do
        local wrapper = Instance.new("Frame")
        wrapper.Size                = UDim2.new(1, 0, 0, 38)
        wrapper.BackgroundTransparency = 1
        wrapper.LayoutOrder         = 2 + idx
        wrapper.Parent              = scroll

        local btn = button(info.label, info.color, wrapper, UDim2.fromOffset(0, 0))

        btn.MouseButton1Click:Connect(function()
            if info.label:find("Respawn") then
                local char = game.Players.LocalPlayer.Character
                if char then char:BreakJoints() end
            elseif info.label:find("UserID") then
                local id = tostring(game.Players.LocalPlayer.UserId)
                game:GetService("GuiService"):SetGameplayPausedNotificationEnabled(false)
                -- Feedback visual
                btn.Text = "✓  Copiado: " .. id
                task.delay(2, function() btn.Text = info.label end)
            end
        end)
    end

    -- ── Rodapé ───────────────────────────────────────────────────────────
    label({
        Size                    = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency  = 1,
        Text                    = "v1.0.0  •  Use as abas acima para navegar",
        TextColor3              = THEME.SUBTEXT,
        Font                    = THEME.FONT,
        TextSize                = 11,
        LayoutOrder             = 99,
        Parent                  = scroll,
    })
end

return HomeTab

