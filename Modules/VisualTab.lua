-- Modules/VisualTab.lua

local VisualTab = {}

function VisualTab.Init(frame, T)
    local LP      = game.Players.LocalPlayer
    local Players = game:GetService("Players")
    local RS      = game:GetService("RunService")
    local TS      = game:GetService("TweenService")

    local function corner(p, r)
        local c = Instance.new("UICorner"); c.CornerRadius = r or T.CORNER; c.Parent = p
    end
    local function tw(o, t, p) TS:Create(o, TweenInfo.new(t, Enum.EasingStyle.Quad), p):Play() end

    -- ── Scroll ────────────────────────────────────────────────────────────────
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.fromScale(1,1); scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = T.ACCENT
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(); scroll.Parent = frame
    local ll = Instance.new("UIListLayout", scroll); ll.Padding = UDim.new(0,6)
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingTop=UDim.new(0,8); pad.PaddingLeft=UDim.new(0,10)
    pad.PaddingRight=UDim.new(0,10); pad.PaddingBottom=UDim.new(0,8)

    local order = 0
    local function secLabel(text)
        order += 1
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,0,0,14); l.BackgroundTransparency = 1
        l.Text = string.upper(text); l.TextColor3 = T.SUBTEXT
        l.Font = T.FONTB; l.TextSize = 9
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.LayoutOrder = order; l.Parent = scroll
    end

    -- ── Switch (igual ao PlayerTab) ───────────────────────────────────────────
    local function makeSwitch(labelText, onEnable, onDisable)
        order += 1
        local active = false
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1,0,0, T.MOBILE and 42 or 34)
        row.BackgroundColor3 = T.SURFACE
        row.BorderSizePixel = 0
        row.LayoutOrder = order; row.Parent = scroll
        corner(row, UDim.new(0,8))

        local p2 = Instance.new("UIPadding", row)
        p2.PaddingLeft = UDim.new(0,10); p2.PaddingRight = UDim.new(0,10)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1,-52,1,0); lbl.BackgroundTransparency = 1
        lbl.Text = labelText; lbl.TextColor3 = T.TEXT
        lbl.Font = T.FONT; lbl.TextSize = T.MOBILE and 14 or 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local PW,PH = 44, T.MOBILE and 26 or 22
        local pill = Instance.new("Frame", row)
        pill.Size = UDim2.fromOffset(PW,PH)
        pill.AnchorPoint = Vector2.new(1,0.5)
        pill.Position = UDim2.new(1,0,0.5,0)
        pill.BackgroundColor3 = Color3.fromRGB(45,45,60)
        pill.BorderSizePixel = 0
        corner(pill, UDim.new(0,PH//2))

        local KS = PH-6
        local knob = Instance.new("Frame", pill)
        knob.Size = UDim2.fromOffset(KS,KS)
        knob.AnchorPoint = Vector2.new(0,0.5)
        knob.Position = UDim2.new(0,3,0.5,0)
        knob.BackgroundColor3 = Color3.fromRGB(120,120,140)
        knob.BorderSizePixel = 0
        corner(knob, UDim.new(0,KS//2))

        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.fromScale(1,1); btn.BackgroundTransparency = 1
        btn.Text = ""; btn.AutoButtonColor = false

        local function toggle()
            active = not active
            if active then
                tw(pill,0.15,{BackgroundColor3=T.ACCENT})
                tw(knob,0.15,{Position=UDim2.new(1,-(KS+3),0.5,0),BackgroundColor3=Color3.new(1,1,1)})
                onEnable()
            else
                tw(pill,0.15,{BackgroundColor3=Color3.fromRGB(45,45,60)})
                tw(knob,0.15,{Position=UDim2.new(0,3,0.5,0),BackgroundColor3=Color3.fromRGB(120,120,140)})
                onDisable()
            end
        end
        btn.Activated:Connect(toggle)
    end

    -- ════════════════════════════════════════════════════════════════════════
    -- ESP
    -- ════════════════════════════════════════════════════════════════════════
    secLabel("ESP")

    -- Cores por time/distância
    local ESP_COLOR   = Color3.fromRGB(255, 80,  80)   -- inimigo / padrão
    local ESP_OUTLINE = Color3.fromRGB(0,   0,   0)

    -- Cria o ESP num character confirmado como player real
    local function attachESP(plr, char)
        if char:FindFirstChild("_espHL") then return end

        -- Highlight — outline suave no contorno, sem caixa
        local hl = Instance.new("Highlight")
        hl.Name               = "_espHL"
        hl.Adornee            = char
        hl.FillTransparency   = 1          -- sem preenchimento colorido
        hl.OutlineTransparency= 0          -- outline totalmente visível
        hl.OutlineColor       = ESP_COLOR
        hl.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent             = char

        -- Billboard com nome + distância
        local bb = Instance.new("BillboardGui")
        bb.Name           = "_espBB"
        bb.Size           = UDim2.fromOffset(120, 36)
        bb.StudsOffset    = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop    = true
        bb.LightInfluence = 0
        bb.Adornee        = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
        bb.Parent         = char

        local nameLbl = Instance.new("TextLabel", bb)
        nameLbl.Size               = UDim2.new(1,0,0.55,0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text               = plr.DisplayName
        nameLbl.TextColor3         = ESP_COLOR
        nameLbl.Font               = Enum.Font.GothamBold
        nameLbl.TextSize           = 13
        nameLbl.TextStrokeTransparency = 0.4
        nameLbl.TextStrokeColor3   = Color3.new(0,0,0)

        local distLbl = Instance.new("TextLabel", bb)
        distLbl.Name               = "_espDist"
        distLbl.Size               = UDim2.new(1,0,0.45,0)
        distLbl.Position           = UDim2.new(0,0,0.55,0)
        distLbl.BackgroundTransparency = 1
        distLbl.Text               = ""
        distLbl.TextColor3         = Color3.fromRGB(200,200,200)
        distLbl.Font               = Enum.Font.Gotham
        distLbl.TextSize           = 11
        distLbl.TextStrokeTransparency = 0.5
        distLbl.TextStrokeColor3   = Color3.new(0,0,0)
    end

    local function removeESP(char)
        local hl = char:FindFirstChild("_espHL")
        local bb = char:FindFirstChild("_espBB")
        if hl then hl:Destroy() end
        if bb then bb:Destroy() end
    end

    local espConn, espDistConn
    makeSwitch("Player ESP",
        function()
            -- Aplica em quem já está no servidor
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.UserId > 0 and plr.Character then
                    attachESP(plr, plr.Character)
                end
            end
            -- Aplica quando um player faz respawn
            espConn = Players.PlayerAdded:Connect(function(plr)
                plr.CharacterAdded:Connect(function(char)
                    task.wait(0.5)
                    if plr.UserId > 0 then attachESP(plr, char) end
                end)
            end)
            -- Atualiza distância a cada frame
            espDistConn = RS.Heartbeat:Connect(function()
                local myHRP = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LP and plr.UserId > 0 and plr.Character then
                        local bb = plr.Character:FindFirstChild("_espBB")
                        if bb then
                            local dl = bb:FindFirstChild("_espDist")
                            if dl and myHRP then
                                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local dist = math.floor((hrp.Position - myHRP.Position).Magnitude)
                                    dl.Text = dist.."m"
                                end
                            end
                        end
                        -- Garante que recém-spawnados também ganhem ESP
                        attachESP(plr, plr.Character)
                    end
                end
            end)
        end,
        function()
            if espConn     then espConn:Disconnect();     espConn     = nil end
            if espDistConn then espDistConn:Disconnect(); espDistConn = nil end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr.Character then removeESP(plr.Character) end
            end
        end
    )

    -- ════════════════════════════════════════════════════════════════════════
    -- ILUMINAÇÃO
    -- ════════════════════════════════════════════════════════════════════════
    secLabel("Iluminação")

    local Lighting = game:GetService("Lighting")
    local origBright, origClock

    makeSwitch("Fullbright",
        function()
            origBright = Lighting.Brightness
            origClock  = Lighting.ClockTime
            Lighting.Brightness = 10
            Lighting.ClockTime  = 14
        end,
        function()
            Lighting.Brightness = origBright or 1
            Lighting.ClockTime  = origClock  or 14
        end
    )

    -- ════════════════════════════════════════════════════════════════════════
    -- CÂMERA
    -- ════════════════════════════════════════════════════════════════════════
    secLabel("Câmera")

    local origFOV
    makeSwitch("FOV Alargado",
        function()
            origFOV = workspace.CurrentCamera.FieldOfView
            workspace.CurrentCamera.FieldOfView = 110
        end,
        function()
            workspace.CurrentCamera.FieldOfView = origFOV or 70
        end
    )

    makeSwitch("Câmera Shoulder",
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
