-- Modules/VisualTab.lua
-- Modificações visuais: ESP, iluminação, FOV, etc.

local VisualTab = {}

function VisualTab.Init(frame, THEME)
    local LP = game.Players.LocalPlayer

    local function corner(p, r)
        local c = Instance.new("UICorner"); c.CornerRadius = r or THEME.CORNER; c.Parent = p
    end

    local function secLabel(parent, text, order)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 18); l.BackgroundTransparency = 1
        l.Text = text; l.TextColor3 = THEME.SUBTEXT
        l.Font = THEME.FONT_BOLD; l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.LayoutOrder = order; l.Parent = parent
    end

    -- Toggle button que mantém estado ON/OFF
    local function makeToggle(parent, text, order, onEnable, onDisable)
        local OFF = Color3.fromRGB(45, 45, 60)
        local ON  = THEME.ACCENT
        local active = false

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 36)
        row.BackgroundColor3 = OFF
        row.BorderSizePixel = 0
        row.LayoutOrder = order
        row.Parent = parent
        corner(row)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -60, 1, 0)
        lbl.Position = UDim2.fromOffset(12, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.TextColor3 = THEME.TEXT
        lbl.Font = THEME.FONT
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local pill = Instance.new("Frame", row)
        pill.Size = UDim2.fromOffset(42, 22)
        pill.AnchorPoint = Vector2.new(1, 0.5)
        pill.Position = UDim2.new(1, -10, 0.5, 0)
        pill.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
        pill.BorderSizePixel = 0
        corner(pill, UDim.new(0, 11))

        local knob = Instance.new("Frame", pill)
        knob.Size = UDim2.fromOffset(16, 16)
        knob.Position = UDim2.fromOffset(3, 3)
        knob.BackgroundColor3 = THEME.TEXT
        knob.BorderSizePixel = 0
        corner(knob, UDim.new(0, 8))

        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.fromScale(1, 1)
        btn.BackgroundTransparency = 1
        btn.Text = ""

        btn.MouseButton1Click:Connect(function()
            active = not active
            if active then
                row.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
                pill.BackgroundColor3 = THEME.ACCENT
                knob.Position = UDim2.fromOffset(23, 3)
                if onEnable then onEnable() end
            else
                row.BackgroundColor3 = OFF
                pill.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
                knob.Position = UDim2.fromOffset(3, 3)
                if onDisable then onDisable() end
            end
        end)
        return btn
    end

    -- ── Scroll ───────────────────────────────────────────────────────────
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.fromScale(1, 1); scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = THEME.ACCENT
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(); scroll.Parent = frame
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 8)
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingTop = UDim.new(0,10); pad.PaddingLeft = UDim.new(0,12)
    pad.PaddingRight = UDim.new(0,12); pad.PaddingBottom = UDim.new(0,10)

    -- ── ESP de jogadores ─────────────────────────────────────────────────
    secLabel(scroll, "ESP", 1)
    local espConn
    makeToggle(scroll, "Player ESP  (caixas)", 2,
        function() -- enable
            espConn = game:GetService("RunService").Heartbeat:Connect(function()
                for _, plr in ipairs(game.Players:GetPlayers()) do
                    if plr ~= LP and plr.Character then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local tag = hrp:FindFirstChild("_espTag")
                            if not tag then
                                tag = Instance.new("SelectionBox")
                                tag.Name = "_espTag"
                                tag.Adornee = plr.Character
                                tag.Color3 = Color3.fromRGB(255, 50, 50)
                                tag.LineThickness = 0.05
                                tag.SurfaceTransparency = 0.8
                                tag.SurfaceColor3 = Color3.fromRGB(255, 50, 50)
                                tag.Parent = workspace
                            end
                        end
                    end
                end
            end)
        end,
        function() -- disable
            if espConn then espConn:Disconnect() end
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("SelectionBox") and obj.Name == "_espTag" then obj:Destroy() end
            end
        end
    )

    makeToggle(scroll, "Fullbright", 3,
        function()
            game:GetService("Lighting").Brightness = 10
            game:GetService("Lighting").ClockTime  = 14
        end,
        function()
            game:GetService("Lighting").Brightness = 1
            game:GetService("Lighting").ClockTime  = 14
        end
    )

    -- ── Câmera ───────────────────────────────────────────────────────────
    secLabel(scroll, "CÂMERA", 10)

    makeToggle(scroll, "FOV Alargado  (90→120)", 11,
        function() workspace.CurrentCamera.FieldOfView = 120 end,
        function() workspace.CurrentCamera.FieldOfView = 70  end
    )

    makeToggle(scroll, "Câmera Shoulder  (over-shoulder)", 12,
        function()
            workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
            LP.CameraMode = Enum.CameraMode.LockFirstPerson
        end,
        function()
            LP.CameraMode = Enum.CameraMode.Classic
        end
    )
end

return VisualTab
