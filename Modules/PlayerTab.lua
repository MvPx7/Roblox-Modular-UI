-- Modules/PlayerTab.lua  — Mobile + Desktop

local PlayerTab = {}

function PlayerTab.Init(frame, THEME)
    local LP      = game.Players.LocalPlayer
    local UIS     = game:GetService("UserInputService")
    local RS      = game:GetService("RunService")
    local IsMobile = THEME.MOBILE

    local function corner(p, r)
        local c = Instance.new("UICorner"); c.CornerRadius = r or THEME.CORNER; c.Parent = p
    end
    local function secLabel(parent, text, order)
        local l = Instance.new("TextLabel")
        l.Size=UDim2.new(1,0,0,18); l.BackgroundTransparency=1
        l.Text=text; l.TextColor3=THEME.SUBTEXT
        l.Font=THEME.FONT_BOLD; l.TextSize=11
        l.TextXAlignment=Enum.TextXAlignment.Left
        l.LayoutOrder=order; l.Parent=parent
    end
    local function makeBtn(parent, text, color, order)
        local b = Instance.new("TextButton")
        b.Size=UDim2.new(1,0,0, IsMobile and 44 or 36)
        b.BackgroundColor3=color; b.Text=text
        b.TextColor3=THEME.TEXT; b.Font=THEME.FONT_BOLD
        b.TextSize=IsMobile and 14 or 13
        b.BorderSizePixel=0; b.AutoButtonColor=false
        b.LayoutOrder=order; b.Parent=parent
        corner(b)
        local function hl() b.BackgroundColor3=Color3.new(
            math.min(color.R+.08,1),math.min(color.G+.08,1),math.min(color.B+.08,1)) end
        local function un() b.BackgroundColor3=color end
        b.MouseEnter:Connect(hl); b.MouseLeave:Connect(un)
        return b
    end

    -- ── Slider touch+mouse ────────────────────────────────────────────────
    local function makeSlider(parent, labelText, order, minV, maxV, defV, onChange)
        local h = IsMobile and 64 or 52
        local container = Instance.new("Frame")
        container.Size=UDim2.new(1,0,0,h)
        container.BackgroundTransparency=1
        container.LayoutOrder=order; container.Parent=parent

        local lbl = Instance.new("TextLabel", container)
        lbl.Size=UDim2.new(1,0,0,20); lbl.BackgroundTransparency=1
        lbl.Text=labelText..": "..defV; lbl.TextColor3=THEME.TEXT
        lbl.Font=THEME.FONT; lbl.TextSize=IsMobile and 14 or 12
        lbl.TextXAlignment=Enum.TextXAlignment.Left

        local track = Instance.new("Frame", container)
        track.Size=UDim2.new(1,0,0, IsMobile and 10 or 6)
        track.Position=UDim2.fromOffset(0, IsMobile and 34 or 28)
        track.BackgroundColor3=Color3.fromRGB(45,45,60)
        track.BorderSizePixel=0
        corner(track, UDim.new(0,5))

        local fill = Instance.new("Frame", track)
        fill.BackgroundColor3=THEME.ACCENT; fill.BorderSizePixel=0
        fill.Size=UDim2.new((defV-minV)/(maxV-minV),0,1,0)
        corner(fill, UDim.new(0,5))

        local KS = IsMobile and 22 or 14
        local knob = Instance.new("TextButton", track)
        knob.Size=UDim2.fromOffset(KS,KS)
        knob.AnchorPoint=Vector2.new(.5,.5)
        knob.Position=UDim2.new((defV-minV)/(maxV-minV),0,.5,0)
        knob.BackgroundColor3=THEME.TEXT; knob.Text=""
        knob.BorderSizePixel=0
        corner(knob, UDim.new(0,KS//2))

        local function applyPos(absX)
            local rel = math.clamp((absX - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
            local val = math.floor(minV + (maxV-minV)*rel)
            knob.Position = UDim2.new(rel,0,.5,0)
            fill.Size     = UDim2.new(rel,0,1,0)
            lbl.Text      = labelText..": "..val
            onChange(val)
        end

        local dragging = false
        knob.MouseButton1Down:Connect(function() dragging=true end)
        knob.TouchLongPress:Connect(function()   dragging=true end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
            or i.UserInputType==Enum.UserInputType.Touch) then
                applyPos(i.Position.X)
            end
        end)
        -- tap direto na track
        track.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1
            or i.UserInputType==Enum.UserInputType.Touch then
                dragging=true; applyPos(i.Position.X)
            end
        end)
    end

    -- ── Scroll ────────────────────────────────────────────────────────────
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size=UDim2.fromScale(1,1); scroll.BackgroundTransparency=1
    scroll.BorderSizePixel=0; scroll.ScrollBarThickness=3
    scroll.ScrollBarImageColor3=THEME.ACCENT
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    scroll.CanvasSize=UDim2.new(); scroll.Parent=frame
    Instance.new("UIListLayout",scroll).Padding=UDim.new(0,8)
    local pad=Instance.new("UIPadding",scroll)
    pad.PaddingTop=UDim.new(0,10); pad.PaddingLeft=UDim.new(0,12)
    pad.PaddingRight=UDim.new(0,12); pad.PaddingBottom=UDim.new(0,10)

    secLabel(scroll,"MOVIMENTO",1)

    makeSlider(scroll,"WalkSpeed",2,16,200,16,function(v)
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=v end
    end)
    makeSlider(scroll,"JumpHeight",3,7,120,7,function(v)
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpHeight=v end
    end)

    secLabel(scroll,"HABILIDADES",10)

    -- Noclip
    local noclipOn = false; local noclipConn
    local PURPLE = Color3.fromRGB(120,60,200)
    local btnNoclip = makeBtn(scroll,"👻  Noclip  [ OFF ]",PURPLE,11)
    local function toggleNoclip()
        noclipOn = not noclipOn
        btnNoclip.Text="👻  Noclip  [ "..(noclipOn and "ON" or "OFF").." ]"
        btnNoclip.BackgroundColor3=noclipOn and Color3.fromRGB(80,30,160) or PURPLE
        if noclipOn then
            noclipConn=RS.Stepped:Connect(function()
                local char=LP.Character; if not char then return end
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide=false end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() end
        end
    end
    btnNoclip.MouseButton1Click:Connect(toggleNoclip)
    btnNoclip.TouchTap:Connect(toggleNoclip)

    -- Voo — mobile usa botões na tela, desktop usa WASD
    local TEAL = Color3.fromRGB(30,150,140)
    local flightOn=false; local flightConn
    local btnFlight=makeBtn(scroll,"🚀  Voar  [ OFF ]",TEAL,12)

    -- Pad de voo (mobile)
    local flightPad
    if IsMobile then
        flightPad = Instance.new("Frame")
        flightPad.Size=UDim2.fromOffset(200,200)
        flightPad.Position=UDim2.new(1,-210,1,-210)
        flightPad.BackgroundTransparency=1
        flightPad.Visible=false
        flightPad.ZIndex=10
        flightPad.Parent=frame

        local dirs = {
            {sym="▲", ax= 0, ay= 1, gx=1, gy=0},
            {sym="▼", ax= 0, ay=-1, gx=1, gy=2},
            {sym="◄", ax=-1, ay= 0, gx=0, gy=1},
            {sym="►", ax= 1, ay= 0, gx=2, gy=1},
            {sym="↑", ax= 0, ay= 0, az= 1, gx=1, gy=3}, -- subir
            {sym="↓", ax= 0, ay= 0, az=-1, gx=1, gy=4}, -- descer (off-screen mas ok)
        }
        -- simplificado: apenas 4 direções + subir/descer
        local padBtns = {}
        local positions = {
            {sym="▲",x=70, y=0 },
            {sym="▼",x=70, y=140},
            {sym="◄",x=0,  y=70 },
            {sym="►",x=140,y=70 },
            {sym="↑",x=70, y=70, up=true},
        }
        local held = {}
        for _, d in ipairs(positions) do
            local b = Instance.new("TextButton", flightPad)
            b.Size=UDim2.fromOffset(56,56)
            b.Position=UDim2.fromOffset(d.x,d.y)
            b.BackgroundColor3=Color3.fromRGB(40,40,60)
            b.BackgroundTransparency=0.3
            b.Text=d.sym; b.TextColor3=THEME.TEXT
            b.Font=THEME.FONT_BOLD; b.TextSize=18
            b.BorderSizePixel=0; b.ZIndex=11
            Instance.new("UICorner",b).CornerRadius=UDim.new(0,10)
            b.MouseButton1Down:Connect(function() held[d.sym]=true  end)
            b.MouseButton1Up:Connect(function()   held[d.sym]=false end)
            b.TouchLongPress:Connect(function()   held[d.sym]=true  end)
            b.TouchTap:Connect(function()         held[d.sym]=false end)
            padBtns[d.sym] = {btn=b, held=false}
        end

        flightConn = RS.Heartbeat:Connect(function()
            local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local bg = hrp:FindFirstChild("_fGyro")
            local bv = hrp:FindFirstChild("_fVel")
            if not bg or not bv then return end
            local cam = workspace.CurrentCamera
            local spd = 40
            local move = Vector3.zero
            if held["▲"] then move += cam.CFrame.LookVector end
            if held["▼"] then move -= cam.CFrame.LookVector end
            if held["◄"] then move -= cam.CFrame.RightVector end
            if held["►"] then move += cam.CFrame.RightVector end
            if held["↑"] then move += Vector3.new(0,1,0) end
            bv.Velocity = move.Magnitude>0 and move.Unit*spd or Vector3.zero
            bg.CFrame   = cam.CFrame
        end)
    end

    local function toggleFlight()
        flightOn = not flightOn
        btnFlight.Text="🚀  Voar  [ "..(flightOn and "ON" or "OFF").." ]"
        btnFlight.BackgroundColor3=flightOn and Color3.fromRGB(20,100,95) or TEAL
        local char=LP.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if flightOn and hrp then
            local bg=Instance.new("BodyGyro",hrp); bg.Name="_fGyro"
            bg.MaxTorque=Vector3.new(1e5,1e5,1e5)
            local bv=Instance.new("BodyVelocity",hrp); bv.Name="_fVel"
            bv.MaxForce=Vector3.new(1e5,1e5,1e5)
            if IsMobile and flightPad then
                flightPad.Visible=true
            else
                -- desktop: WASD via RunService
                flightConn=RS.Heartbeat:Connect(function()
                    local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                    if not h then return end
                    local bv2=h:FindFirstChild("_fVel")
                    local bg2=h:FindFirstChild("_fGyro")
                    if not bv2 or not bg2 then return end
                    local cam=workspace.CurrentCamera; local spd=40
                    local mv=Vector3.zero
                    if UIS:IsKeyDown(Enum.KeyCode.W)         then mv+=cam.CFrame.LookVector  end
                    if UIS:IsKeyDown(Enum.KeyCode.S)         then mv-=cam.CFrame.LookVector  end
                    if UIS:IsKeyDown(Enum.KeyCode.A)         then mv-=cam.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.D)         then mv+=cam.CFrame.RightVector end
                    if UIS:IsKeyDown(Enum.KeyCode.Space)     then mv+=Vector3.new(0,1,0)     end
                    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then mv-=Vector3.new(0,1,0)     end
                    bv2.Velocity=mv.Magnitude>0 and mv.Unit*spd or Vector3.zero
                    bg2.CFrame=cam.CFrame
                end)
            end
        else
            if flightConn and not IsMobile then flightConn:Disconnect() end
            if IsMobile and flightPad then flightPad.Visible=false end
            if hrp then
                local bg=hrp:FindFirstChild("_fGyro"); local bv=hrp:FindFirstChild("_fVel")
                if bg then bg:Destroy() end; if bv then bv:Destroy() end
            end
        end
    end
    btnFlight.MouseButton1Click:Connect(toggleFlight)
    btnFlight.TouchTap:Connect(toggleFlight)
end

return PlayerTab
