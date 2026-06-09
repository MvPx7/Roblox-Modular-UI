-- Modules/PlayerTab.lua

local PlayerTab = {}

function PlayerTab.Init(frame, THEME)
    local LP  = game.Players.LocalPlayer
    local RS  = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")

    local function corner(p, r)
        local c = Instance.new("UICorner"); c.CornerRadius = r or THEME.CORNER; c.Parent = p
    end

    local function secLabel(parent, text, order)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1,0,0,18); l.BackgroundTransparency = 1
        l.Text = text; l.TextColor3 = THEME.SUBTEXT
        l.Font = THEME.FONT_BOLD; l.TextSize = 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.LayoutOrder = order; l.Parent = parent
    end

    local function makeToggle(parent, text, colorOn, order, onEnable, onDisable)
        local colorOff = Color3.fromRGB(50, 50, 70)
        local active = false
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1,0,0, THEME.MOBILE and 48 or 40)
        b.BackgroundColor3 = colorOff
        b.Text = text .. "  [ OFF ]"
        b.TextColor3 = THEME.TEXT
        b.Font = THEME.FONT_BOLD
        b.TextSize = THEME.MOBILE and 15 or 13
        b.BorderSizePixel = 0
        b.AutoButtonColor = false
        b.LayoutOrder = order
        b.Parent = parent
        corner(b)

        local function toggle()
            active = not active
            b.Text = text .. "  [ " .. (active and "ON" or "OFF") .. " ]"
            b.BackgroundColor3 = active and colorOn or colorOff
            if active then onEnable() else onDisable() end
        end
        b.MouseButton1Click:Connect(toggle)
        b.TouchTap:Connect(toggle)
        return b
    end

    local function makeSlider(parent, labelText, order, minV, maxV, defV, onChange)
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1,0,0, THEME.MOBILE and 62 or 52)
        container.BackgroundTransparency = 1
        container.LayoutOrder = order; container.Parent = parent

        local lbl = Instance.new("TextLabel", container)
        lbl.Size = UDim2.new(1,0,0,20); lbl.BackgroundTransparency = 1
        lbl.Text = labelText..": "..defV; lbl.TextColor3 = THEME.TEXT
        lbl.Font = THEME.FONT; lbl.TextSize = THEME.MOBILE and 14 or 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local TH = THEME.MOBILE and 10 or 6
        local track = Instance.new("Frame", container)
        track.Size = UDim2.new(1,0,0,TH)
        track.Position = UDim2.fromOffset(0, THEME.MOBILE and 32 or 26)
        track.BackgroundColor3 = Color3.fromRGB(45,45,60)
        track.BorderSizePixel = 0
        corner(track, UDim.new(0,5))

        local fill = Instance.new("Frame", track)
        fill.BackgroundColor3 = THEME.ACCENT; fill.BorderSizePixel = 0
        fill.Size = UDim2.new((defV-minV)/(maxV-minV),0,1,0)
        corner(fill, UDim.new(0,5))

        local KS = THEME.MOBILE and 24 or 14
        local knob = Instance.new("TextButton", track)
        knob.Size = UDim2.fromOffset(KS,KS)
        knob.AnchorPoint = Vector2.new(.5,.5)
        knob.Position = UDim2.new((defV-minV)/(maxV-minV),0,.5,0)
        knob.BackgroundColor3 = THEME.TEXT; knob.Text = ""
        knob.BorderSizePixel = 0; knob.AutoButtonColor = false
        corner(knob, UDim.new(0,KS//2))

        local dragging = false
        local function apply(absX)
            local rel = math.clamp((absX - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
            local val = math.floor(minV + (maxV-minV)*rel)
            knob.Position = UDim2.new(rel,0,.5,0)
            fill.Size     = UDim2.new(rel,0,1,0)
            lbl.Text      = labelText..": "..val
            onChange(val)
        end

        knob.MouseButton1Down:Connect(function() dragging = true end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)
        UIS.InputChanged:Connect(function(i)
            if not dragging then return end
            if i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch then apply(i.Position.X) end
        end)
        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true; apply(i.Position.X)
            end
        end)
    end

    -- ── Scroll ────────────────────────────────────────────────────────────
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.fromScale(1,1); scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0; scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = THEME.ACCENT
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.CanvasSize = UDim2.new(); scroll.Parent = frame
    Instance.new("UIListLayout", scroll).Padding = UDim.new(0,10)
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingTop = UDim.new(0,10); pad.PaddingLeft = UDim.new(0,12)
    pad.PaddingRight = UDim.new(0,12); pad.PaddingBottom = UDim.new(0,10)

    -- ── MOVIMENTO ─────────────────────────────────────────────────────────
    secLabel(scroll, "MOVIMENTO", 1)

    makeSlider(scroll, "WalkSpeed", 2, 16, 200, 16, function(v)
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end)
    makeSlider(scroll, "JumpHeight", 3, 7, 120, 7, function(v)
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpHeight = v end
    end)

    -- ── HABILIDADES ───────────────────────────────────────────────────────
    secLabel(scroll, "HABILIDADES", 10)

    -- Noclip
    local noclipConn
    makeToggle(scroll, "👻  Noclip", Color3.fromRGB(100, 40, 180), 11,
        function()
            noclipConn = RS.Stepped:Connect(function()
                local char = LP.Character; if not char then return end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CanCollide = false end
            end)
        end,
        function()
            if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        end
    )

    -- Voo simples: câmera define direção, personagem flutua
    local flightConn
    makeToggle(scroll, "🚀  Voar", Color3.fromRGB(20, 140, 120), 12,
        function()
            local char = LP.Character
            local hrp  = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            -- Remove gravidade do personagem
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = true end

            local bg = Instance.new("BodyGyro", hrp)
            bg.Name = "_fGyro"; bg.MaxTorque = Vector3.new(0,4e5,0)
            bg.D = 100; bg.P = 1e4

            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "_fVel"; bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            bv.Velocity = Vector3.zero

            flightConn = RS.Heartbeat:Connect(function()
                local h = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if not h then return end
                local bv2 = h:FindFirstChild("_fVel")
                local bg2 = h:FindFirstChild("_fGyro")
                if not bv2 or not bg2 then return end

                local cam  = workspace.CurrentCamera
                local spd  = 40
                local look = Vector3.new(cam.CFrame.LookVector.X, 0, cam.CFrame.LookVector.Z)
                local mv   = Vector3.zero

                if THEME.MOBILE then
                    -- Mobile: joystick nativo do Roblox via thumbstick
                    -- Usa a posição do polegar (já tratada pelo Roblox)
                    -- Movimenta para frente enquanto voa, UP/DOWN via aceleração
                    local ts = UIS:GetConnectedGamepads()
                    mv = look.Magnitude > 0 and look.Unit * spd or Vector3.zero
                else
                    if UIS:IsKeyDown(Enum.KeyCode.W) then mv += look.Unit end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then mv -= look.Unit end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then mv -= cam.CFrame.RightVector * Vector3.new(1,0,1) end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then mv += cam.CFrame.RightVector * Vector3.new(1,0,1) end
                    if UIS:IsKeyDown(Enum.KeyCode.Space)     then mv += Vector3.new(0,1,0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then mv -= Vector3.new(0,1,0) end
                end

                bv2.Velocity = mv.Magnitude > 0 and mv.Unit * spd or Vector3.zero
                bg2.CFrame   = CFrame.new(Vector3.zero, look.Magnitude > 0 and look or Vector3.new(0,0,-1))
            end)
        end,
        function()
            if flightConn then flightConn:Disconnect(); flightConn = nil end
            local char = LP.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand = false end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bg = hrp:FindFirstChild("_fGyro")
                    local bv = hrp:FindFirstChild("_fVel")
                    if bg then bg:Destroy() end
                    if bv then bv:Destroy() end
                end
            end
        end
    )

    -- Infinito de vida
    local godConn
    makeToggle(scroll, "❤️  God Mode", Color3.fromRGB(180, 40, 40), 13,
        function()
            godConn = RS.Heartbeat:Connect(function()
                local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = hum.MaxHealth end
            end)
        end,
        function()
            if godConn then godConn:Disconnect(); godConn = nil end
        end
    )
end

return PlayerTab
