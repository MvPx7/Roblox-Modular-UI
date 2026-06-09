-- UI.lua  v2.1  ─ Responsivo + Drag-safe + Quest Tab
-- ══════════════════════════════════════════════════════════════════════════════

local GITHUB_RAW = "https://raw.githubusercontent.com/MvPx7/Roblox-Modular-UI/main/Modules/"

local Players      = game:GetService("Players")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService   = game:GetService("RunService")
local LP           = Players.LocalPlayer
local PlayerGui    = LP:WaitForChild("PlayerGui")

-- ══════════════════════════════════════════════════════════════════════════════
--  DETECÇÃO DE PLATAFORMA  (re-detectada sempre que a viewport mudar)
-- ══════════════════════════════════════════════════════════════════════════════
local function getPlatform()
    local vp = workspace.CurrentCamera.ViewportSize
    local touch = UIS.TouchEnabled
    local w, h  = vp.X, vp.Y
    local short = math.min(w, h)
    local long  = math.max(w, h)

    if not touch and w >= 900 then
        return "PC"
    elseif touch and short >= 600 and long >= 900 then
        return "Tablet"
    else
        -- mobile nativo OU executor mobile (tela pequena com ou sem touch)
        return "Mobile"
    end
end

-- ══════════════════════════════════════════════════════════════════════════════
--  TEMA  (valores por plataforma)
-- ══════════════════════════════════════════════════════════════════════════════
local PLATFORM_CFG = {
    PC     = { WIN_W=340, WIN_H=360, HDR_H=34, TAB_H=28, FONT_S=10, TITLE_S=12, BTN=36 },
    Tablet = { WIN_W=360, WIN_H=380, HDR_H=38, TAB_H=32, FONT_S=11, TITLE_S=13, BTN=40 },
    Mobile = { WIN_W=300, WIN_H=390, HDR_H=40, TAB_H=34, FONT_S=11, TITLE_S=13, BTN=44 },
}

local T = {
    BG      = Color3.fromRGB(12, 12, 18),
    SURFACE = Color3.fromRGB(20, 20, 28),
    BORDER  = Color3.fromRGB(35, 35, 50),
    ACCENT  = Color3.fromRGB(99, 102, 241),
    TEXT    = Color3.fromRGB(220, 220, 235),
    SUBTEXT = Color3.fromRGB(100, 100, 120),
    ERR     = Color3.fromRGB(220, 60, 60),
    SUCCESS = Color3.fromRGB(80, 220, 130),
    WARN    = Color3.fromRGB(255, 190, 60),
    FONT    = Enum.Font.GothamMedium,
    FONTB   = Enum.Font.GothamBold,
    CORNER  = UDim.new(0, 10),
}

local TABS = {
    { name = "Home",    module = "HomeTab"   },
    { name = "NPC",     module = "NPCTab"    },
    { name = "Player",  module = "PlayerTab" },
    { name = "Visual",  module = "VisualTab" },
    { name = "Quest",   module = nil         },  -- built-in, sem módulo externo
    { name = "Config",  module = "ConfigTab" },
}

-- ══════════════════════════════════════════════════════════════════════════════
--  HELPERS
-- ══════════════════════════════════════════════════════════════════════════════
local function mk(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(p, r) mk("UICorner", {CornerRadius = r or T.CORNER}, p) end
local function tw(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad), props):Play()
end

-- Viewport segura (nunca zero)
local function getVP()
    local vp = workspace.CurrentCamera.ViewportSize
    return math.max(vp.X, 100), math.max(vp.Y, 100)
end

-- Clamp de posição da janela dentro da viewport
local function clampWindowPos(x, y, w, h)
    local vpW, vpH = getVP()
    return
        math.clamp(x, 0, math.max(0, vpW - w)),
        math.clamp(y, 0, math.max(0, vpH - h))
end

-- ══════════════════════════════════════════════════════════════════════════════
--  MÓDULOS EXTERNOS
-- ══════════════════════════════════════════════════════════════════════════════
local function loadModule(name, errorFrame)
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(GITHUB_RAW .. name .. ".lua", true))()
    end)
    if ok and res then return res end
    if errorFrame then
        mk("TextLabel", {
            Size = UDim2.new(1,-20,0,0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.fromOffset(10,10),
            BackgroundTransparency = 1,
            Text = "⚠ " .. name .. " falhou:\n" .. tostring(res),
            TextColor3 = T.ERR,
            Font = T.FONT,
            TextSize = 11,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = errorFrame,
        })
    end
    warn("[UI] " .. name .. ": " .. tostring(res))
    return nil
end

-- ══════════════════════════════════════════════════════════════════════════════
--  QUEST TAB  (built-in, integra a lógica do QuestHelper)
-- ══════════════════════════════════════════════════════════════════════════════
local QUEST_MAP = {
    ["DragonHollow"]      = { path = "Workspace.DialogueInteractables.DragonHollowQuest_BaseRemedy",  label = "Dragon Hollow Quest" },
    ["MissingParty"]      = { path = "Workspace.DialogueInteractables.MissingPartyQuest",              label = "Missing Party Quest" },
    ["PowerControl"]      = { path = "Workspace.DialogueInteractables.PowerControlQuest",              label = "Power Control Quest" },
    ["OutskirtsWW"]       = { path = "Workspace.DialogueInteractables.OutskirtsWWQuest",               label = "Outskirts WW Quest" },
    ["MiscSkilltree"]     = { path = "Workspace.DialogueInteractables.MiscSkilltreeQuest",             label = "Skilltree Quest" },
    ["Ointment"]          = { path = "Workspace.DialogueInteractables.OintmentQuest",                  label = "Ointment Quest" },
    ["Aura"]              = { path = "Workspace.DialogueInteractables.AuraQuest",                      label = "Aura Quest" },
    ["OneHandStance"]     = { path = "Workspace.DialogueInteractables.OneHandStanceQuest",             label = "One Hand Stance Quest" },
    ["Respirator"]        = { path = "Workspace.DialogueInteractables.RespiratorQuest",                label = "Respirator Quest" },
    ["OutskirtsStatue"]   = { path = "Workspace.DialogueInteractables.OutskirtsStatueQuest",           label = "Statue Quest" },
    ["MissionTicket"]     = { path = "Workspace.DialogueInteractables.OutskirtsMissionTicketQuest",    label = "Mission Ticket Quest" },
    ["SpiritAlloy"]       = { path = "Workspace.DialogueInteractables.SpiritAlloyQuest",               label = "Spirit Alloy Quest" },
    ["SparringArena"]     = { path = "Workspace.DialogueInteractables.SparringArenaQuest",             label = "Sparring Arena Quest" },
    ["FirstErrand"]       = { path = "Workspace.DialogueInteractables.FirstErrandClassQuestNPC",       label = "First Errand Quest" },
    ["GreyHunter"]        = { path = "Workspace.DialogueInteractables.GreyHunterQuest",                label = "Grey Hunter Quest" },
    ["KillMenos"]         = { path = "Workspace.DialogueInteractables.KillMenosQuest",                 label = "Kill Menos Quest" },
    ["Nindus"]            = { path = "Workspace.DialogueInteractables.NindusQuest",                    label = "Nindus Quest" },
    ["InvasionOutskirts"] = { path = "Workspace.DialogueInteractables.InvasionQuestOutskirts",         label = "Invasion Quest" },
    ["Dragonfly"]         = { path = "Workspace.DialogueInteractables.DragonflyQuestOutskirts",        label = "Dragonfly Quest" },
    ["CapturePoint"]      = { path = "Workspace.DialogueInteractables.CapturePointQuest",              label = "Capture Point Quest" },
    ["HuecoEntrance"]     = { path = "Workspace.DialogueInteractables.HuecoEntranceQuest",             label = "Hueco Entrance Quest" },
    ["MaskedWarrior"]     = { path = "Workspace.DialogueInteractables.MaskedWarriorQuest",             label = "Masked Warrior Quest" },
    ["BatHollow"]         = { path = "Workspace.DialogueInteractables.BatHollowTip",                   label = "Bat Hollow Quest" },
    ["DrVoris"]           = { path = "Workspace.DialogueInteractables.DrVoris",                        label = "Dr. Voris" },
    ["Miello"]            = { path = "Workspace.DialogueInteractables.Miello",                         label = "Miello" },
    ["Hale"]              = { path = "Workspace.DialogueInteractables.Hale",                           label = "Hale" },
    ["Smeek"]             = { path = "Workspace.DialogueInteractables.Smeek",                          label = "Smeek" },
    ["MizukiSato"]        = { path = "Workspace.DialogueInteractables.MizukiSatoElder",                label = "Mizuki Sato (Elder)" },
    ["SweetwaterLeader"]  = { path = "Workspace.DialogueInteractables.SweetwaterLeader",               label = "Sweetwater Leader" },
    ["Scorpion"]          = { path = "Workspace.Debris.ScorpionQuestMarker",                           label = "Scorpion Location" },
    ["Mantis"]            = { path = "Workspace.Debris.MantisQuestMarker",                             label = "Mantis Location" },
    ["GiantDragonfly"]    = { path = "Workspace.Debris.GiantDragonflyQuestMarker",                     label = "Giant Dragonfly Location" },
    ["StrangeCave"]       = { path = "Workspace.Debris.StrangeCaveMarker",                             label = "Strange Cave" },
    ["MissingCousin"]     = { path = "Workspace.Debris.MissingCounsinQuestMarker",                     label = "Missing Cousin Location" },
    ["Necklace"]          = { path = "Workspace.Debris.NecklaceMarker",                                label = "Necklace Location" },
    ["Lizard"]            = { path = "Workspace.Debris.LizardQuestMarker",                             label = "Lizard Location" },
    ["Shipment"]          = { path = "Workspace.Debris.ShipmentMarker",                                label = "Shipment Location" },
    ["OutskirtsWWMarker"] = { path = "Workspace.Debris.OutskirtsWWQuestMarker",                        label = "WW Target Location" },
    ["DragonflyMarker"]   = { path = "Workspace.Debris.DragonflyQuestMarker",                         label = "Dragonfly Location" },
    ["PowerControlMarker"]= { path = "Workspace.Debris.PowerControlQuestMarker",                      label = "Power Control Location" },
    ["MizumiVillage"]     = { path = "Workspace.Debris.MizumiVillageMarker",                          label = "Mizumi Village" },
    ["NebukaiVillage"]    = { path = "Workspace.Debris.NebukaiVillageMarker",                         label = "Nebukai Village" },
    ["BatQuest"]          = { path = "Workspace.Debris.BatQuestMarker",                               label = "Bat Location" },
}

local QuestState = {
    activeHighlight = nil,
    activeBillboard = nil,
    targetObj       = nil,
}

local function questResolvePath(pathStr)
    local parts = string.split(pathStr, ".")
    local obj = game
    for _, part in ipairs(parts) do
        obj = obj:FindFirstChild(part)
        if not obj then return nil end
    end
    return obj
end

local function questGetRootPart(obj)
    if not obj then return nil end
    if obj:IsA("Model") then
        return obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
    elseif obj:IsA("BasePart") then
        return obj
    end
    return nil
end

local function questClearMarker()
    if QuestState.activeHighlight then
        QuestState.activeHighlight:Destroy()
        QuestState.activeHighlight = nil
    end
    if QuestState.activeBillboard then
        QuestState.activeBillboard:Destroy()
        QuestState.activeBillboard = nil
    end
    QuestState.targetObj = nil
end

local function questApplyMarker(obj, label)
    questClearMarker()
    local root = questGetRootPart(obj) or obj
    if not root then return end
    QuestState.targetObj = obj

    -- Highlight
    local hl = Instance.new("Highlight")
    hl.FillColor    = Color3.fromRGB(255, 200, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency    = 0.5
    hl.OutlineTransparency = 0
    hl.Adornee = root
    hl.Parent  = root
    QuestState.activeHighlight = hl

    -- BillboardGui
    local bb = Instance.new("BillboardGui")
    bb.Size         = UDim2.fromOffset(180, 50)
    bb.StudsOffset  = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop  = true
    bb.Adornee      = root
    bb.Parent       = root
    QuestState.activeBillboard = bb

    local bg = mk("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.fromRGB(12, 12, 18),
        BackgroundTransparency = 0.3,
        Parent = bb,
    })
    corner(bg, UDim.new(0, 6))

    mk("TextLabel", {
        Size = UDim2.new(1, -8, 0.6, 0),
        Position = UDim2.fromOffset(4, 3),
        BackgroundTransparency = 1,
        Text = label or obj.Name,
        TextColor3 = Color3.fromRGB(255, 230, 80),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = bg,
    })

    local distL = mk("TextLabel", {
        Name = "DistLabel",
        Size = UDim2.new(1, -8, 0.4, 0),
        Position = UDim2.new(0, 4, 0.6, 0),
        BackgroundTransparency = 1,
        Text = "...",
        TextColor3 = Color3.fromRGB(180, 180, 220),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = bg,
    })

    -- Atualiza distância
    task.spawn(function()
        while QuestState.activeBillboard and QuestState.activeBillboard.Parent do
            local char = LP.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local rp  = questGetRootPart(obj)
                if hrp and rp then
                    local d = math.floor((hrp.Position - rp.Position).Magnitude)
                    distL.Text = d .. " studs"
                end
            end
            task.wait(0.15)
        end
    end)
end

-- Constrói a aba Quest dentro de um frame pai
local function buildQuestTab(parent)
    -- scroll container
    local scroll = mk("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.ACCENT,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = parent,
    })
    mk("UIPadding", {
        PaddingTop    = UDim.new(0, 6),
        PaddingLeft   = UDim.new(0, 8),
        PaddingRight  = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 6),
        Parent = scroll,
    })
    mk("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 5),
        Parent    = scroll,
    })

    -- Status display
    local statusRow = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = T.SURFACE,
        LayoutOrder = 0,
        Parent = scroll,
    })
    corner(statusRow, UDim.new(0, 6))
    local statusDot = mk("Frame", {
        Size = UDim2.fromOffset(8, 8),
        Position = UDim2.new(0, 8, 0.5, -4),
        BackgroundColor3 = T.SUBTEXT,
        BorderSizePixel = 0,
        Parent = statusRow,
    })
    corner(statusDot, UDim.new(1, 0))
    local statusLbl = mk("TextLabel", {
        Size = UDim2.new(1, -26, 1, 0),
        Position = UDim2.fromOffset(22, 0),
        BackgroundTransparency = 1,
        Text = "Nenhuma quest ativa",
        TextColor3 = T.SUBTEXT,
        Font = T.FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = statusRow,
    })

    -- Info rows helper
    local function infoRow(order, label, defaultVal)
        local row = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            LayoutOrder = order,
            Parent = scroll,
        })
        mk("TextLabel", {
            Size = UDim2.new(0.42, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = T.SUBTEXT,
            Font = T.FONT,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = row,
        })
        local val = mk("TextLabel", {
            Size = UDim2.new(0.58, 0, 1, 0),
            Position = UDim2.fromScale(0.42, 0),
            BackgroundTransparency = 1,
            Text = defaultVal or "—",
            TextColor3 = T.TEXT,
            Font = T.FONTB,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })
        return val
    end

    -- Separator helper
    local function sep(order)
        local s = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.BORDER,
            BorderSizePixel = 0,
            LayoutOrder = order,
            Parent = scroll,
        })
        return s
    end

    local valQuest  = infoRow(1,  "Quest:",     "—")
    local valTarget = infoRow(2,  "Alvo:",      "—")
    local valDist   = infoRow(3,  "Distância:", "—")
    sep(4)

    -- Botões de ação
    local function actionBtn(order, txt, color)
        local btn = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = color or T.ACCENT,
            Text = txt,
            TextColor3 = T.TEXT,
            Font = T.FONTB,
            TextSize = 11,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            LayoutOrder = order,
            Parent = scroll,
        })
        corner(btn, UDim.new(0, 6))
        btn.MouseEnter:Connect(function() tw(btn, 0.1, {BackgroundTransparency = 0.3}) end)
        btn.MouseLeave:Connect(function() tw(btn, 0.1, {BackgroundTransparency = 0}) end)
        return btn
    end

    local btnClear   = actionBtn(5, "✕  Limpar Marcador",  Color3.fromRGB(140, 40, 40))
    sep(6)

    -- Lista de quests
    local listLabel = mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "QUESTS DISPONÍVEIS",
        TextColor3 = T.SUBTEXT,
        Font = T.FONTB,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 7,
        Parent = scroll,
    })

    -- Ordena as quests pelo label
    local sortedQuests = {}
    for k, v in pairs(QUEST_MAP) do
        table.insert(sortedQuests, { key = k, data = v })
    end
    table.sort(sortedQuests, function(a, b) return a.data.label < b.data.label end)

    local activeKey = nil

    for idx, entry in ipairs(sortedQuests) do
        local k, v = entry.key, entry.data
        local row = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = T.SURFACE,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            LayoutOrder = 7 + idx,
            Parent = scroll,
        })
        corner(row, UDim.new(0, 5))

        local dot = mk("Frame", {
            Size = UDim2.fromOffset(6, 6),
            Position = UDim2.new(0, 8, 0.5, -3),
            BackgroundColor3 = T.SUBTEXT,
            BorderSizePixel = 0,
            Parent = row,
        })
        corner(dot, UDim.new(1, 0))

        mk("TextLabel", {
            Size = UDim2.new(1, -26, 1, 0),
            Position = UDim2.fromOffset(22, 0),
            BackgroundTransparency = 1,
            Text = v.label,
            TextColor3 = T.TEXT,
            Font = T.FONT,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = row,
        })

        row.MouseEnter:Connect(function()
            if activeKey ~= k then
                tw(row, 0.1, {BackgroundColor3 = T.BORDER})
            end
        end)
        row.MouseLeave:Connect(function()
            if activeKey ~= k then
                tw(row, 0.1, {BackgroundColor3 = T.SURFACE})
            end
        end)

        row.Activated:Connect(function()
            -- Deseleciona anterior visualmente
            activeKey = k

            -- Resolve e aplica
            local obj = questResolvePath(v.path)
            if obj then
                questApplyMarker(obj, v.label)
                dot.BackgroundColor3 = T.SUCCESS
                statusDot.BackgroundColor3 = T.SUCCESS
                statusLbl.Text = v.label
                valQuest.Text  = v.label
                valTarget.Text = obj.Name
                tw(row, 0.1, {BackgroundColor3 = Color3.fromRGB(30, 50, 35)})
            else
                questClearMarker()
                dot.BackgroundColor3 = T.ERR
                statusDot.BackgroundColor3 = T.ERR
                statusLbl.Text = "Objeto não encontrado"
                valQuest.Text  = v.label
                valTarget.Text = "— não encontrado —"
                valDist.Text   = "—"
                tw(row, 0.1, {BackgroundColor3 = Color3.fromRGB(50, 20, 20)})
            end
        end)
    end

    -- Distância loop
    task.spawn(function()
        while parent.Parent do
            if QuestState.targetObj then
                local char = LP.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local rp  = questGetRootPart(QuestState.targetObj)
                    if hrp and rp then
                        local d = math.floor((hrp.Position - rp.Position).Magnitude)
                        valDist.Text = d .. " studs"
                    end
                end
            end
            task.wait(0.2)
        end
    end)

    -- Limpar
    btnClear.Activated:Connect(function()
        questClearMarker()
        activeKey = nil
        statusDot.BackgroundColor3 = T.SUBTEXT
        statusLbl.Text = "Nenhuma quest ativa"
        valQuest.Text  = "—"
        valTarget.Text = "—"
        valDist.Text   = "—"
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
--  SCREENGU  +  JANELA
-- ══════════════════════════════════════════════════════════════════════════════
local SG = mk("ScreenGui", {
    Name            = "MainGui",
    ResetOnSpawn    = false,
    ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    Parent          = PlayerGui,
})

-- Tamanhos iniciais (serão recalculados pelo sistema responsivo)
local plat = getPlatform()
local cfg  = PLATFORM_CFG[plat]
local WIN_W = cfg.WIN_W
local WIN_H = cfg.WIN_H

-- ── Janela ────────────────────────────────────────────────────────────────────
local Window = mk("Frame", {
    Name             = "Window",
    Size             = UDim2.fromOffset(WIN_W, WIN_H),
    Position         = UDim2.fromScale(0.5, 0.5),
    AnchorPoint      = Vector2.new(0.5, 0.5),
    BackgroundColor3 = T.BG,
    BorderSizePixel  = 0,
    Parent           = SG,
})
corner(Window)
mk("UIStroke", {
    Color            = T.BORDER,
    Thickness        = 1,
    ApplyStrokeMode  = Enum.ApplyStrokeMode.Border,
    Parent           = Window,
})

-- Converte AnchorPoint 0.5/0.5 para posição absoluta ao montar
do
    local vpW, vpH = getVP()
    local cx = math.clamp((vpW - WIN_W) / 2, 0, vpW - WIN_W)
    local cy = math.clamp((vpH - WIN_H) / 2, 0, vpH - WIN_H)
    Window.AnchorPoint = Vector2.new(0, 0)
    Window.Position    = UDim2.fromOffset(cx, cy)
end

-- ── Header ────────────────────────────────────────────────────────────────────
local Header = mk("Frame", {
    Size             = UDim2.new(1, 0, 0, cfg.HDR_H),
    BackgroundColor3 = T.SURFACE,
    BorderSizePixel  = 0,
    Parent           = Window,
})
corner(Header)
mk("Frame", {    -- cobre canto inferior do header
    Size             = UDim2.new(1, 0, 0, 10),
    Position         = UDim2.new(0, 0, 1, -10),
    BackgroundColor3 = T.SURFACE,
    BorderSizePixel  = 0,
    Parent           = Header,
})
mk("TextLabel", {
    Size               = UDim2.new(1, -60, 1, 0),
    Position           = UDim2.fromOffset(10, 0),
    BackgroundTransparency = 1,
    Text               = "✦ Menu",
    TextColor3         = T.TEXT,
    Font               = T.FONTB,
    TextSize           = cfg.TITLE_S,
    TextXAlignment     = Enum.TextXAlignment.Left,
    Parent             = Header,
})

-- ── Botão Toggle (fixo no SG, sempre visível) ─────────────────────────────────
local BTN_SZ  = cfg.BTN
local BTN_PAD = 8
local ToggleBtn = mk("TextButton", {
    Size             = UDim2.fromOffset(BTN_SZ, BTN_SZ),
    Position         = UDim2.fromOffset(BTN_PAD, BTN_PAD),
    BackgroundColor3 = T.ACCENT,
    Text             = "×",
    TextColor3       = T.TEXT,
    Font             = T.FONTB,
    TextSize         = BTN_SZ > 40 and 18 or 15,
    BorderSizePixel  = 0,
    AutoButtonColor  = false,
    ZIndex           = 20,
    Parent           = SG,
})
corner(ToggleBtn, UDim.new(0, BTN_SZ > 40 and 12 or 8))

-- ── Botão Reset Position ──────────────────────────────────────────────────────
local ResetBtn = mk("TextButton", {
    Size             = UDim2.fromOffset(BTN_SZ, BTN_SZ),
    Position         = UDim2.fromOffset(BTN_PAD, BTN_PAD + BTN_SZ + 6),
    BackgroundColor3 = T.SURFACE,
    Text             = "⌖",
    TextColor3       = T.TEXT,
    Font             = T.FONTB,
    TextSize         = BTN_SZ > 40 and 16 or 13,
    BorderSizePixel  = 0,
    AutoButtonColor  = false,
    ZIndex           = 20,
    Parent           = SG,
})
corner(ResetBtn, UDim.new(0, BTN_SZ > 40 and 12 or 8))
mk("UIStroke", { Color = T.BORDER, Thickness = 1, Parent = ResetBtn })

-- ── TabBar ────────────────────────────────────────────────────────────────────
local TabBar = mk("Frame", {
    Size                = UDim2.new(1, -16, 0, cfg.TAB_H),
    Position            = UDim2.new(0, 8, 0, cfg.HDR_H + 4),
    BackgroundTransparency = 1,
    Parent              = Window,
})
mk("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    SortOrder     = Enum.SortOrder.LayoutOrder,
    Padding       = UDim.new(0, 3),
    Parent        = TabBar,
})

-- ── ContentArea ───────────────────────────────────────────────────────────────
local TAB_OFFSET = cfg.HDR_H + cfg.TAB_H + 8
local ContentArea = mk("Frame", {
    Size                = UDim2.new(1, 0, 1, -TAB_OFFSET),
    Position            = UDim2.fromOffset(0, TAB_OFFSET),
    BackgroundTransparency = 1,
    Parent              = Window,
})

-- ══════════════════════════════════════════════════════════════════════════════
--  TABS
-- ══════════════════════════════════════════════════════════════════════════════
local tabBtns, tabFrames, activeTab = {}, {}, nil

local function setActive(name)
    if activeTab == name then return end
    activeTab = name
    for _, td in ipairs(TABS) do
        local btn = tabBtns[td.name]
        local frm = tabFrames[td.name]
        local on  = (td.name == name)
        tw(btn, 0.1, {BackgroundTransparency = on and 0 or 1})
        btn.TextColor3 = on and T.TEXT or T.SUBTEXT
        if frm then frm.Visible = on end
    end
end

for i, td in ipairs(TABS) do
    local btn = mk("TextButton", {
        Size             = UDim2.new(1/#TABS, -3, 1, 0),
        BackgroundColor3 = T.ACCENT,
        BackgroundTransparency = 1,
        Text             = td.name,
        TextColor3       = T.SUBTEXT,
        Font             = T.FONT,
        TextSize         = cfg.FONT_S,
        BorderSizePixel  = 0,
        AutoButtonColor  = false,
        LayoutOrder      = i,
        Parent           = TabBar,
    })
    corner(btn, UDim.new(0, 5))
    tabBtns[td.name] = btn

    local frm = mk("Frame", {
        Size                = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible             = false,
        Parent              = ContentArea,
    })
    tabFrames[td.name] = frm

    if td.name == "Quest" then
        -- aba built-in
        buildQuestTab(frm)
    elseif td.module then
        local mod = loadModule(td.module, frm)
        if mod and mod.Init then
            pcall(mod.Init, frm, T)
        end
    end

    btn.Activated:Connect(function() setActive(td.name) end)
end

setActive(TABS[1].name)

-- ══════════════════════════════════════════════════════════════════════════════
--  MINIMIZAR / RESTAURAR
-- ══════════════════════════════════════════════════════════════════════════════
local minimized = false

local function setMin(s)
    minimized = s
    Window.Visible                  = not s
    ToggleBtn.Text                  = s and "✦" or "×"
    ToggleBtn.BackgroundColor3      = s and T.ACCENT or Color3.fromRGB(80, 30, 30)
    -- ao restaurar, garante que a janela está dentro da tela
    if not s then
        local px = Window.Position.X.Offset
        local py = Window.Position.Y.Offset
        local nx, ny = clampWindowPos(px, py, WIN_W, WIN_H)
        Window.Position = UDim2.fromOffset(nx, ny)
    end
end

ToggleBtn.Activated:Connect(function() setMin(not minimized) end)

-- ══════════════════════════════════════════════════════════════════════════════
--  RESET POSITION
-- ══════════════════════════════════════════════════════════════════════════════
ResetBtn.Activated:Connect(function()
    local vpW, vpH = getVP()
    local nx = math.clamp((vpW - WIN_W) / 2, 0, vpW - WIN_W)
    local ny = math.clamp((vpH - WIN_H) / 2, 0, vpH - WIN_H)
    tw(Window, 0.25, {Position = UDim2.fromOffset(nx, ny)})
    if minimized then setMin(false) end
end)

-- ══════════════════════════════════════════════════════════════════════════════
--  DRAG  (clampado, mouse + touch)
-- ══════════════════════════════════════════════════════════════════════════════
do
    local dragging  = false
    local startPos  = Vector2.zero
    local startWin  = Vector2.zero

    local function beginDrag(pos)
        dragging = true
        startPos = Vector2.new(pos.X, pos.Y)
        startWin = Vector2.new(Window.Position.X.Offset, Window.Position.Y.Offset)
    end
    local function endDrag()
        dragging = false
    end
    local function moveDrag(pos)
        if not dragging then return end
        local dx = pos.X - startPos.X
        local dy = pos.Y - startPos.Y
        local nx, ny = clampWindowPos(startWin.X + dx, startWin.Y + dy, WIN_W, WIN_H)
        Window.Position = UDim2.fromOffset(nx, ny)
    end

    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            beginDrag(i.Position)
        end
    end)
    Header.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            endDrag()
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement
        or i.UserInputType == Enum.UserInputType.Touch then
            moveDrag(i.Position)
        end
    end)
    -- Garante que drag cancela se soltar fora do header
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
        or i.UserInputType == Enum.UserInputType.Touch then
            endDrag()
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
--  RESPONSIVIDADE  — reajusta ao mudar resolução
-- ══════════════════════════════════════════════════════════════════════════════
local lastPlat = plat
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local newPlat = getPlatform()
    if newPlat == lastPlat then
        -- Mesma plataforma: apenas reclamp a posição
        local px = Window.Position.X.Offset
        local py = Window.Position.Y.Offset
        local nx, ny = clampWindowPos(px, py, WIN_W, WIN_H)
        Window.Position = UDim2.fromOffset(nx, ny)
        return
    end

    -- Plataforma mudou: reconfigura tamanhos
    lastPlat = newPlat
    local nc = PLATFORM_CFG[newPlat]
    WIN_W = nc.WIN_W
    WIN_H = nc.WIN_H

    Window.Size = UDim2.fromOffset(WIN_W, WIN_H)
    Header.Size = UDim2.new(1, 0, 0, nc.HDR_H)

    TabBar.Size     = UDim2.new(1, -16, 0, nc.TAB_H)
    TabBar.Position = UDim2.new(0, 8, 0, nc.HDR_H + 4)

    local newOffset = nc.HDR_H + nc.TAB_H + 8
    ContentArea.Size     = UDim2.new(1, 0, 1, -newOffset)
    ContentArea.Position = UDim2.fromOffset(0, newOffset)

    -- Clamp para nova viewport
    local px = Window.Position.X.Offset
    local py = Window.Position.Y.Offset
    local nx, ny = clampWindowPos(px, py, WIN_W, WIN_H)
    Window.Position = UDim2.fromOffset(nx, ny)

    -- Ajusta botões flutuantes
    ToggleBtn.Size = UDim2.fromOffset(nc.BTN, nc.BTN)
    ResetBtn.Size  = UDim2.fromOffset(nc.BTN, nc.BTN)
    ResetBtn.Position = UDim2.fromOffset(BTN_PAD, BTN_PAD + nc.BTN + 6)
end)

-- ══════════════════════════════════════════════════════════════════════════════
--  RECUPERAÇÃO AUTOMÁTICA  — verifica a cada 5s se a janela está acessível
-- ══════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while SG.Parent do
        task.wait(5)
        if not minimized then
            local vpW, vpH = getVP()
            local px = Window.Position.X.Offset
            local py = Window.Position.Y.Offset
            -- Se menos de 30px estão visíveis em qualquer eixo, recupera
            local rightEdge  = px + WIN_W
            local bottomEdge = py + WIN_H
            local outOfBounds =
                px > vpW - 30 or
                py > vpH - 30 or
                rightEdge  < 30 or
                bottomEdge < 30
            if outOfBounds then
                local nx, ny = clampWindowPos(px, py, WIN_W, WIN_H)
                tw(Window, 0.4, {Position = UDim2.fromOffset(nx, ny)})
                warn("[UI] Janela recuperada automaticamente.")
            end
        end
        -- Garante que os botões flutuantes estão dentro da tela
        local vpW, vpH = getVP()
        local bx = math.clamp(BTN_PAD, 0, vpW - BTN_SZ - BTN_PAD)
        local by = math.clamp(BTN_PAD, 0, vpH - BTN_SZ * 2 - 20)
        ToggleBtn.Position = UDim2.fromOffset(bx, by)
        ResetBtn.Position  = UDim2.fromOffset(bx, by + BTN_SZ + 6)
    end
end)
