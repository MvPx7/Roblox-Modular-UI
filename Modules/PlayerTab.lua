-- Modules/PlayerTab.lua
-- Modificações no personagem local.

local PlayerTab = {}

local UIS = game:GetService("UserInputService")

function PlayerTab.Init(frame, THEME)
    local LP   = game.Players.LocalPlayer
    local BLUE = Color3.fromRGB(50, 110, 210)
    local TEAL = Color3.fromRGB(30, 150, 140)
    local PURPLE = Color3.fromRGB(120, 60, 200)

    -- ── helpers ──────────────────────────────────────────────────────────
    local function corner(p, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = r or THEME.CORNER
        c.Parent = p
    end

    local function makeBtn(parent, text, color, order)
        local b = Instance.new("TextButton")
        b.Size              = UDim2.new(1, 0, 0, 36)
        b.BackgroundColor3  = color
        b.Text              = text
        b.TextColor3        = THEME.TEXT
        b.Font              = THEME.FONT_BOLD
        b.TextSize          = 13
        b.BorderSizePixel   = 0
        b.AutoButtonColor   = false
        b.LayoutOrder       = order
        b.Parent            = parent
        corner(b)
        b.MouseEnter:Connect(function()
            b.BackgroundColor3 = Color3.new(
                math.min(color.R+0.08,1), math.min(color.G+0.08,1), math.min(color.B+0.08,1))
        end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = color end)
        return b
    end

    local function secLabel(parent, text, order)
        local l = Instance.new("TextLabel")
        l.Size                  = UDim2.new(1, 0, 0, 18)
        l.BackgroundTransparency = 1
        l.Text                  = text
        l.TextColor3            = THEME.SUBTEXT
        l.Font                  = THEME.FONT_BOLD
        l.TextSize              = 11
        l.TextXAlignment        = Enum.TextXAlignment.Left
        l.LayoutOrder           = order
        l.Parent                = parent
    end

    -- slider helper
    local function makeSlider(parent, labelText, order, minV, maxV, defaultV, onChange)
        local container = Instance.new("Frame")
        container.Size              = UDim2.new(1, 0, 0, 52)
        container.BackgroundTransparency = 1
        container.LayoutOrder       = order
        container.Parent            = parent

        local lbl = Instance.new("TextLabel", container)
        lbl.Size                = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Text                = labelText .. ": " .. defaultV
        lbl.TextColor3          = THEME.TEXT
        lbl.Font                = THEME.FONT
        lbl.TextSize            = 12
        lbl.TextXAlignment      = Enum.TextXAlignment.Left

        local track = Instance.new("Frame", container)
        track.Size              = UDim2.new(1, 0, 0, 6)
        track.Position          = UDim2.fromOffset(0, 28)
        track.BackgroundColor3  = Color3.fromRGB(45, 45, 60)
        track.BorderSizePixel   = 0
        corner(track, UDim.new(0, 3))

        local fill = Instance.new("Frame", track)
        fill.BackgroundColor3   = THEME.ACCENT
        fill.BorderSizePixel    = 0
        fill.Size               = UDim2.new((defaultV - minV)/(maxV - minV), 0, 1, 0)
        corner(fill, UDim.new(0, 3))

        local knob = Instance.new("TextButton", track)
        knob.Size               = UDim2.fromOffset(14, 14)
        knob.AnchorPoint        = Vector2.new(0.5, 0.5)
        knob.Position           = UDim2.new((defaultV - minV)/(maxV - minV), 0, 0.5, 0)
        knob.BackgroundColor3   = THEME.TEXT
        knob.Text               = ""
        knob.BorderSizePixel    = 0
        corner(knob, UDim.new(0, 7))

        local dragging = false
        knob.MouseButton1Down:Connect(function() dragging = true end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = (i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
                rel = math.clamp(rel, 0, 1)
                local val = math.floor(minV + (maxV - minV) * rel)
                knob.Position   = UDim2.new(rel, 0, 0.5, 0)
                fill.Size       = UDim2.new(rel, 0, 1, 0)
                lbl.Text        = labelText .. ": " .. val
                onChange(val)
            end
        end)
    end

    -- ── Scroll ───────────────────────────────────────────────────────────
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size                   = UDim2.fromScale(1, 1)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel        = 0
    scroll.ScrollBarThickness     = 3
    scroll.ScrollBarImageColor3   = THEME.ACCENT
    scroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    scroll.CanvasSize             = UDim2.new()
    scroll.Parent                 = frame

    Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 8)
    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingTop = UDim.new(0, 10); pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12); pad.PaddingBottom = UDim.new(0, 10)

    -- ── Seção: Movimento ─────────────────────────────────────────────────
    secLabel(scroll, "MOVIMENTO", 1)

    makeSlider(scroll, "WalkSpeed", 2, 16, 200, 16, function(v)
        local char = LP.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end)

    makeSlider(scroll, "JumpHeight", 3, 7, 120, 7, function(v)
        local char = LP.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpHeight = v end
    end)

    -- ── Seção: Habilidades ───────────────────────────────────────────────
    secLabel(scroll, "HABILIDADES", 10)

    local noclipActive = false
    local btnNoclip = makeBtn(scroll, "👻  Noclip  [ OFF ]", PURPLE, 11)
    local noclipConn
    btnNoclip.MouseButton1Click:Connect(function()
        noclipActive = not noclipActive
        btnNoclip.Text = "👻  Noclip  [ " .. (noclipActive and "ON" or "OFF") .. " ]"
        btnNoclip.BackgroundColor3 = noclipActive and Color3.fromRGB(80, 30, 160) or PURPLE
        if noclipActive then
            noclipConn = game:GetService("RunService").Stepped:Connect(function()
                local char = LP.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConn then noclipConn:Disconnect() end
        end
    end)

    local flightActive = false
    local flightConn
    local btnFlight = makeBtn(scroll, "🚀  Voar  [ OFF ]", TEAL, 12)
    btnFlight.MouseButton1Click:Connect(function()
        flightActive = not flightActive
        btnFlight.Text = "🚀  Voar  [ " .. (flightActive and "ON" or "OFF") .. " ]"
        btnFlight.BackgroundColor3 = flightActive and Color3.fromRGB(20, 100, 95) or TEAL
        local char = LP.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if flightActive and hrp then
            local bg = Instance.new("BodyGyro", hrp)
            bg.Name = "_flightGyro"; bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
            local bv = Instance.new("BodyVelocity", hrp)
            bv.Name = "_flightVel"; bv.MaxForce = Vector3.new(1e5,1e5,1e5)
            flightConn = game:GetService("RunService").Heartbeat:Connect(function()
                local cam   = workspace.CurrentCamera
                local speed = 40
                local move  = Vector3.new()
                if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
                if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
                if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
                if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
                bv.Velocity = move.Magnitude > 0 and move.Unit * speed or Vector3.zero
                bg.CFrame   = cam.CFrame
            end)
        else
            if flightConn then flightConn:Disconnect() end
            if hrp then
                local bg = hrp:FindFirstChild("_flightGyro")
                local bv = hrp:FindFirstChild("_flightVel")
                if bg then bg:Destroy() end
                if bv then bv:Destroy() end
            end
        end
    end)
end

return PlayerTab
