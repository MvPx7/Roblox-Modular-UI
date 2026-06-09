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

        local function toggle()
            active=not active
            if active then
                tween(pill,0.15,{BackgroundColor3=T.ACCENT})
                tween(knob,0.15,{Position=UDim2.new(1,-(KS+3),0.5,0),BackgroundColor3=Color3.new(1,1,1)})
                onEnable()
            else
                tween(pill,0.15,{BackgroundColor3=Color3.fromRGB(45,45,60)})
                tween(knob,0.15,{Position=UDim2.new(0,3,0.5,0),BackgroundColor3=Color3.fromRGB(120,120,140)})
                onDisable()
            end
        end
        btn.Activated:Connect(toggle)
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

    -- ── Noclip ───────────────────────────────────────────────────────────────
    local noclipConn
    makeSwitch("Noclip",
        function()
            noclipConn=RS.Stepped:Connect(function()
                local char=LP.Character; if not char then return end
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=false end
                end
            end)
        end,
        function()
            if noclipConn then noclipConn:Disconnect(); noclipConn=nil end
            local char=LP.Character
            if char then
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=true end
                end
            end
        end
    )

    -- ── Fly ──────────────────────────────────────────────────────────────────
    -- PC:     WASD = horizontal  |  Space = subir  |  Shift = descer
    -- Mobile: joystick = horizontal  |  câmera inclinada = vertical
    --         (sem botões extras na tela)
    local flyConn
    makeSwitch("Voar",
        function()
            local char=LP.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end

            local hum=char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand=true end

            local bv=Instance.new("BodyVelocity",hrp)
            bv.Name="_fVel"; bv.MaxForce=Vector3.new(1e5,1e5,1e5); bv.Velocity=Vector3.zero

            local bg=Instance.new("BodyGyro",hrp)
            bg.Name="_fGyro"; bg.MaxTorque=Vector3.new(0,4e5,0); bg.D=100; bg.P=1e4

            local SPD=40

            flyConn=RS.Heartbeat:Connect(function()
                local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if not h then return end
                local v2=h:FindFirstChild("_fVel")
                local g2=h:FindFirstChild("_fGyro")
                if not v2 or not g2 then return end

                local cam=workspace.CurrentCamera
                local cf=cam.CFrame
                -- look com Y incluído → voa na direção que a câmera aponta
                local look=cf.LookVector
                local right=cf.RightVector

                local mv=Vector3.zero

                if T.MOBILE then
                    -- Horizontal: MoveDirection (joystick nativo)
                    local hum2=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                    local md=hum2 and hum2.MoveDirection or Vector3.zero
                    if md.Magnitude>0.05 then
                        -- Projeta a direção do joystick no plano da câmera (com Y)
                        local fwd=Vector3.new(look.X,look.Y,look.Z)
                        local rt =Vector3.new(right.X,0,right.Z)
                        if rt.Magnitude>0 then rt=rt.Unit end
                        -- md já está em world space, usa só X/Z para pegar frente/direita
                        local mdFlat=Vector3.new(md.X,0,md.Z)
                        -- componente frente e lado
                        local camFlat=Vector3.new(look.X,0,look.Z)
                        if camFlat.Magnitude>0 then camFlat=camFlat.Unit end
                        local dotF=mdFlat:Dot(camFlat)
                        local dotR=mdFlat:Dot(rt)
                        -- voa na direção da câmera (incluindo Y) proporcional ao joystick
                        mv = look*dotF + rt*dotR
                    end
                else
                    -- PC: WASD na direção da câmera (com Y incluso)
                    if UIS:IsKeyDown(Enum.KeyCode.W) then mv+=look end
                    if UIS:IsKeyDown(Enum.KeyCode.S) then mv-=look end
                    if UIS:IsKeyDown(Enum.KeyCode.A) then mv-=right end
                    if UIS:IsKeyDown(Enum.KeyCode.D) then mv+=right end
                    -- Space/Shift: vertical puro
                    if UIS:IsKeyDown(Enum.KeyCode.Space)     then mv+=Vector3.new(0,1,0) end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then mv-=Vector3.new(0,1,0) end
                end

                v2.Velocity=mv.Magnitude>0.01 and mv.Unit*SPD or Vector3.zero
                local flatLook=Vector3.new(look.X,0,look.Z)
                g2.CFrame=CFrame.new(Vector3.zero, flatLook.Magnitude>0 and flatLook or Vector3.new(0,0,-1))
            end)
        end,
        function()
            if flyConn then flyConn:Disconnect(); flyConn=nil end
            local char=LP.Character
            if char then
                local hum=char:FindFirstChildOfClass("Humanoid")
                if hum then hum.PlatformStand=false end
                local hrp=char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local v=hrp:FindFirstChild("_fVel")
                    local g=hrp:FindFirstChild("_fGyro")
                    if v then v:Destroy() end
                    if g then g:Destroy() end
                end
            end
        end
    )

    -- ── God Mode ─────────────────────────────────────────────────────────────
    local godConn
    makeSwitch("God Mode",
        function()
            godConn=RS.Heartbeat:Connect(function()
                local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health=hum.MaxHealth end
            end)
        end,
        function()
            if godConn then godConn:Disconnect(); godConn=nil end
        end
    )
end

return PlayerTab
