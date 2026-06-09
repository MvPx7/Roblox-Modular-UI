-- Modules/PlayerTab.lua
local PlayerTab = {}

function PlayerTab.Init(frame, T)
    local LP  = game.Players.LocalPlayer
    local RS  = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local TS  = game:GetService("TweenService")

    local function corner(p,r)
        local c=Instance.new("UICorner"); c.CornerRadius=r or T.CORNER; c.Parent=p
    end
    local function tween(o,t,p) TS:Create(o,TweenInfo.new(t,Enum.EasingStyle.Quad),p):Play() end

    -- ── Scroll ────────────────────────────────────────────────────────────────
    local scroll=Instance.new("ScrollingFrame")
    scroll.Size=UDim2.fromScale(1,1)
    scroll.BackgroundTransparency=1
    scroll.BorderSizePixel=0
    scroll.ScrollBarThickness=2
    scroll.ScrollBarImageColor3=T.ACCENT
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    scroll.CanvasSize=UDim2.new()
    scroll.Parent=frame
    local ll=Instance.new("UIListLayout",scroll)
    ll.Padding=UDim.new(0,6)
    local pad=Instance.new("UIPadding",scroll)
    pad.PaddingTop=UDim.new(0,8)
    pad.PaddingLeft=UDim.new(0,10)
    pad.PaddingRight=UDim.new(0,10)
    pad.PaddingBottom=UDim.new(0,8)

    -- ── Seção label ───────────────────────────────────────────────────────────
    local order=0
    local function secLabel(text)
        order+=1
        local l=Instance.new("TextLabel")
        l.Size=UDim2.new(1,0,0,14)
        l.BackgroundTransparency=1
        l.Text=string.upper(text)
        l.TextColor3=T.SUBTEXT
        l.Font=T.FONTB
        l.TextSize=9
        l.TextXAlignment=Enum.TextXAlignment.Left
        l.LayoutOrder=order
        l.Parent=scroll
    end

    -- ── Switch (toggle bonito) ────────────────────────────────────────────────
    -- Layout: [ label ]  [ pill switch ]
    -- Retorna { toggle = function(state) } para sync externo (ex: hotkeys)
    local function makeSwitch(labelText, onEnable, onDisable)
        order+=1
        local active=false
        local row=Instance.new("Frame")
        row.Size=UDim2.new(1,0,0,T.MOBILE and 42 or 34)
        row.BackgroundColor3=T.SURFACE
        row.BorderSizePixel=0
        row.LayoutOrder=order
        row.Parent=scroll
        corner(row, UDim.new(0,8))

        local pad2=Instance.new("UIPadding",row)
        pad2.PaddingLeft=UDim.new(0,10)
        pad2.PaddingRight=UDim.new(0,10)

        local lbl=Instance.new("TextLabel",row)
        lbl.Size=UDim2.new(1,-52,1,0)
        lbl.BackgroundTransparency=1
        lbl.Text=labelText
        lbl.TextColor3=T.TEXT
        lbl.Font=T.FONT
        lbl.TextSize=T.MOBILE and 14 or 12
        lbl.TextXAlignment=Enum.TextXAlignment.Left

        -- Pill
        local PW,PH=44,T.MOBILE and 26 or 22
        local pill=Instance.new("Frame",row)
        pill.Size=UDim2.fromOffset(PW,PH)
        pill.AnchorPoint=Vector2.new(1,0.5)
        pill.Position=UDim2.new(1,0,0.5,0)
        pill.BackgroundColor3=Color3.fromRGB(45,45,60)
        pill.BorderSizePixel=0
        corner(pill,UDim.new(0,PH//2))

        local KS=PH-6
        local knob=Instance.new("Frame",pill)
        knob.Size=UDim2.fromOffset(KS,KS)
        knob.AnchorPoint=Vector2.new(0,0.5)
        knob.Position=UDim2.new(0,3,0.5,0)
        knob.BackgroundColor3=Color3.fromRGB(120,120,140)
        knob.BorderSizePixel=0
        corner(knob,UDim.new(0,KS//2))

        -- Área clicável invisível cobre a linha toda
        local btn=Instance.new("TextButton",row)
        btn.Size=UDim2.fromScale(1,1)
        btn.BackgroundTransparency=1
        btn.Text=""
        btn.AutoButtonColor=false

        local function setVisual(state)
            if state then
                tween(pill,0.15,{BackgroundColor3=T.ACCENT})
                tween(knob,0.15,{Position=UDim2.new(1,-(KS+3),0.5,0),BackgroundColor3=Color3.new(1,1,1)})
            else
                tween(pill,0.15,{BackgroundColor3=Color3.fromRGB(45,45,60)})
                tween(knob,0.15,{Position=UDim2.new(0,3,0.5,0),BackgroundColor3=Color3.fromRGB(120,120,140)})
            end
        end

        local function toggle(forceState)
            if forceState ~= nil then
                if forceState == active then return end -- já está no estado certo
                active = forceState
            else
                active = not active
            end
            setVisual(active)
            if active then onEnable() else onDisable() end
        end

        btn.Activated:Connect(function() toggle() end)

        return { toggle = toggle }
    end

    -- ── Slider ────────────────────────────────────────────────────────────────
    local function makeSlider(labelText, minV, maxV, defV, onChange)
        order+=1
        local container=Instance.new("Frame")
        container.Size=UDim2.new(1,0,0,T.MOBILE and 54 or 46)
        container.BackgroundColor3=T.SURFACE
        container.BorderSizePixel=0
        container.LayoutOrder=order
        container.Parent=scroll
        corner(container, UDim.new(0,8))

        local pad2=Instance.new("UIPadding",container)
        pad2.PaddingLeft=UDim.new(0,10)
        pad2.PaddingRight=UDim.new(0,10)
        pad2.PaddingTop=UDim.new(0,6)

        local lbl=Instance.new("TextLabel",container)
        lbl.Size=UDim2.new(1,0,0,16)
        lbl.BackgroundTransparency=1
        lbl.Text=labelText..":  "..defV
        lbl.TextColor3=T.TEXT
        lbl.Font=T.FONT
        lbl.TextSize=T.MOBILE and 13 or 11
        lbl.TextXAlignment=Enum.TextXAlignment.Left

        local TH=T.MOBILE and 8 or 5
        local track=Instance.new("Frame",container)
        track.Size=UDim2.new(1,0,0,TH)
        track.Position=UDim2.new(0,0,0, T.MOBILE and 32 or 26)
        track.BackgroundColor3=Color3.fromRGB(35,35,50)
        track.BorderSizePixel=0
        corner(track,UDim.new(0,4))

        local fill=Instance.new("Frame",track)
        fill.BackgroundColor3=T.ACCENT
        fill.BorderSizePixel=0
        fill.Size=UDim2.new((defV-minV)/(maxV-minV),0,1,0)
        corner(fill,UDim.new(0,4))

        local KS=T.MOBILE and 20 or 12
        local knob=Instance.new("TextButton",track)
        knob.Size=UDim2.fromOffset(KS,KS)
        knob.AnchorPoint=Vector2.new(0.5,0.5)
        knob.Position=UDim2.new((defV-minV)/(maxV-minV),0,0.5,0)
        knob.BackgroundColor3=Color3.fromRGB(200,200,220)
        knob.Text=""
        knob.BorderSizePixel=0
        knob.AutoButtonColor=false
        corner(knob,UDim.new(0,KS//2))

        local dragging=false
        local function apply(absX)
            local rel=math.clamp((absX-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            local val=math.floor(minV+(maxV-minV)*rel)
            knob.Position=UDim2.new(rel,0,0.5,0)
            fill.Size=UDim2.new(rel,0,1,0)
            lbl.Text=labelText..":  "..val
            onChange(val)
        end

        knob.MouseButton1Down:Connect(function() dragging=true end)
        knob.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.Touch then dragging=true end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
        end)
        UIS.InputChanged:Connect(function(i)
            if not dragging then return end
            if i.UserInputType==Enum.UserInputType.MouseMovement
            or i.UserInputType==Enum.UserInputType.Touch then apply(i.Position.X) end
        end)
        track.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true; apply(i.Position.X)
            end
        end)
    end

    -- ════════════════════════════════════════════════════════════════════════
    -- CONTEÚDO
    -- ════════════════════════════════════════════════════════════════════════

    secLabel("Movimento")

    makeSlider("WalkSpeed", 16, 200, 16, function(v)
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=v end
    end)
    makeSlider("JumpHeight", 7, 120, 7, function(v)
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpHeight=v end
    end)

    secLabel("Habilidades")

    -- ══════════════════════════════════════════════════════════════════════════
    --  ESTADO COMPARTILHADO  (fly + noclip precisam se ver)
    -- ══════════════════════════════════════════════════════════════════════════
    local flyActive    = false
    local noclipActive = false
    local flySpeed     = 40   -- velocidade inicial; + / - mudam isso
    local flyConn      = nil
    local noclipConn   = nil

    -- ── Label de velocidade de voo (atualizada pelos atalhos) ─────────────────
    order += 1
    local flySpeedRow = Instance.new("Frame")
    flySpeedRow.Size = UDim2.new(1,0,0,24)
    flySpeedRow.BackgroundTransparency = 1
    flySpeedRow.LayoutOrder = order
    flySpeedRow.Parent = scroll

    local flySpeedLbl = Instance.new("TextLabel", flySpeedRow)
    flySpeedLbl.Size = UDim2.fromScale(1,1)
    flySpeedLbl.BackgroundTransparency = 1
    flySpeedLbl.Text = "Velocidade de Voo:  " .. flySpeed .. "  (+ / -)"
    flySpeedLbl.TextColor3 = T.SUBTEXT
    flySpeedLbl.Font = T.FONT
    flySpeedLbl.TextSize = 10
    flySpeedLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- ── helpers internos ──────────────────────────────────────────────────────
    local function stopFly()
        flyActive = false
        if flyConn then flyConn:Disconnect(); flyConn = nil end
        local char = LP.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local bv = hrp:FindFirstChild("_fVel")
                local bg = hrp:FindFirstChild("_fGyro")
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
            end
        end
    end

    local function startFly()
        local char = LP.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        flyActive = true

        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = true end

        -- Remove instâncias antigas se existirem
        if hrp:FindFirstChild("_fVel") then hrp:FindFirstChild("_fVel"):Destroy() end
        if hrp:FindFirstChild("_fGyro") then hrp:FindFirstChild("_fGyro"):Destroy() end

        local bv = Instance.new("BodyVelocity", hrp)
        bv.Name = "_fVel"
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bv.Velocity = Vector3.zero

        local bg = Instance.new("BodyGyro", hrp)
        bg.Name = "_fGyro"
        bg.MaxTorque = Vector3.new(4e5, 4e5, 4e5)
        bg.D = 500
        bg.P = 1e5

        flyConn = RS.Heartbeat:Connect(function()
            local h  = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not h then return end
            local bv2 = h:FindFirstChild("_fVel")
            local bg2 = h:FindFirstChild("_fGyro")
            if not bv2 or not bg2 then return end

            local cam   = workspace.CurrentCamera
            local cf    = cam.CFrame
            local look  = cf.LookVector   -- direção que a câmera aponta (inclui Y)
            local right = cf.RightVector
            -- Vetor "para cima" puro, independente da câmera
            local up    = Vector3.new(0, 1, 0)

            local mv = Vector3.zero

            if T.MOBILE then
                local hum2 = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                local md   = hum2 and hum2.MoveDirection or Vector3.zero
                if md.Magnitude > 0.05 then
                    local camFlat = Vector3.new(look.X, 0, look.Z)
                    local rt      = Vector3.new(right.X, 0, right.Z)
                    if camFlat.Magnitude > 0 then camFlat = camFlat.Unit end
                    if rt.Magnitude > 0      then rt      = rt.Unit      end
                    local mdFlat = Vector3.new(md.X, 0, md.Z)
                    mv = camFlat * mdFlat:Dot(camFlat) + rt * mdFlat:Dot(rt)
                end
            else
                -- WASD: movimento horizontal relativo à câmera (SEM inclinação Y)
                local fwd   = Vector3.new(look.X, 0, look.Z)
                local strafe = Vector3.new(right.X, 0, right.Z)
                if fwd.Magnitude    > 0 then fwd    = fwd.Unit    end
                if strafe.Magnitude > 0 then strafe = strafe.Unit end

                if UIS:IsKeyDown(Enum.KeyCode.W) then mv += fwd    end
                if UIS:IsKeyDown(Enum.KeyCode.S) then mv -= fwd    end
                if UIS:IsKeyDown(Enum.KeyCode.A) then mv -= strafe end
                if UIS:IsKeyDown(Enum.KeyCode.D) then mv += strafe end
                -- Vertical puro: Space sobe, Shift desce
                if UIS:IsKeyDown(Enum.KeyCode.Space)     then mv += up end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then mv -= up end
            end

            bv2.Velocity = mv.Magnitude > 0.01 and mv.Unit * flySpeed or Vector3.zero

            -- Gyro: personagem sempre de frente para onde a câmera aponta (só eixo Y)
            local flatLook = Vector3.new(look.X, 0, look.Z)
            local dir = flatLook.Magnitude > 0 and flatLook.Unit or Vector3.new(0, 0, -1)
            bg2.CFrame = CFrame.new(Vector3.zero, dir)
        end)
    end

    local function stopNoclip()
        noclipActive = false
        if noclipConn then noclipConn:Disconnect(); noclipConn = nil end
        local char = LP.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end

    local function startNoclip()
        noclipActive = true
        noclipConn = RS.Stepped:Connect(function()
            local char = LP.Character; if not char then return end
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end)
    end

    -- ── Noclip switch (F2) ────────────────────────────────────────────────────
    local noclipSwitch -- referência ao toggle visual
    noclipSwitch = makeSwitch("Noclip  [F2]", startNoclip, stopNoclip)

    -- ── Fly switch (F1) ───────────────────────────────────────────────────────
    local flySwitch
    flySwitch = makeSwitch("Voar  [F1]  |  WASD + Space/Shift", startFly, stopFly)

    -- ── Hotkeys globais F1 / F2 / + / - ──────────────────────────────────────
    UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end

        -- F1 → toggle voo
        if input.KeyCode == Enum.KeyCode.F1 then
            if flyActive then
                stopFly()
                -- atualiza visual do switch
                if flySwitch and flySwitch.toggle then flySwitch.toggle(false) end
            else
                startFly()
                if flySwitch and flySwitch.toggle then flySwitch.toggle(true) end
            end

        -- F2 → toggle noclip
        elseif input.KeyCode == Enum.KeyCode.F2 then
            if noclipActive then
                stopNoclip()
                if noclipSwitch and noclipSwitch.toggle then noclipSwitch.toggle(false) end
            else
                startNoclip()
                if noclipSwitch and noclipSwitch.toggle then noclipSwitch.toggle(true) end
            end

        -- + / = → aumenta velocidade de voo
        elseif input.KeyCode == Enum.KeyCode.Equals
            or input.KeyCode == Enum.KeyCode.KeypadPlus then
            flySpeed = math.min(flySpeed + 10, 300)
            flySpeedLbl.Text = "Velocidade de Voo:  " .. flySpeed .. "  (+ / -)"

        -- - → diminui velocidade de voo
        elseif input.KeyCode == Enum.KeyCode.Minus
            or input.KeyCode == Enum.KeyCode.KeypadMinus then
            flySpeed = math.max(flySpeed - 10, 10)
            flySpeedLbl.Text = "Velocidade de Voo:  " .. flySpeed .. "  (+ / -)"
        end
    end)

end

return PlayerTab
