-- Modules/QuestTab.lua  v3.0
-- UI redesenhada + performance otimizada (sem crashes)
-- Busca por proximidade ao marker (sem depender de nomes de NPC)
-- ══════════════════════════════════════════════════════════════════════════════

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LP           = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════════════════════
--  HELPERS DE UI (locais, sem depender do mk do UI.lua)
-- ══════════════════════════════════════════════════════════════════════════════
local function mk(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(p, r)
    mk("UICorner", { CornerRadius = r or UDim.new(0, 8) }, p)
end
local function tw(obj, t, props)
    TweenService:Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad), props):Play()
end

-- ══════════════════════════════════════════════════════════════════════════════
--  MUNDOS / CATEGORIAS
-- ══════════════════════════════════════════════════════════════════════════════
-- Cada quest tem: path (NPC que dá a missão), label, world, icon
-- e opcionalmente markerPath (onde o objetivo está no mapa)
local WORLDS = {
    { id = "outskirts", label = "Soul Society Outskirts", icon = "⛩" },
    { id = "sweetwater", label = "Sweetwater Pass",       icon = "🌿" },
    { id = "marsh",      label = "The Marsh",             icon = "🌊" },
    { id = "tundra",     label = "Arctic / Tundra",       icon = "❄" },
    { id = "hueco",      label = "Hueco Mundo",           icon = "🌑" },
    { id = "other",      label = "Outros",                icon = "📌" },
}

local QUEST_MAP = {
    -- ── Soul Society Outskirts ────────────────────────────────────────────────
    { key="DragonHollow",      world="outskirts",  icon="⚔",
      path="Workspace.DialogueInteractables.DragonHollowQuest_BaseRemedy",
      label="Dragon Hollow Quest",
      markerPath="Workspace.Debris.StrangeCaveMarker" },

    { key="MissingParty",      world="outskirts",  icon="⚔",
      path="Workspace.DialogueInteractables.MissingPartyQuest",
      label="Missing Party Quest",
      markerPath="Workspace.Debris.MissingCounsinQuestMarker" },

    { key="PowerControl",      world="outskirts",  icon="⚔",
      path="Workspace.DialogueInteractables.PowerControlQuest",
      label="Power Control Quest",
      markerPath="Workspace.Debris.PowerControlQuestMarker" },

    { key="OutskirtsWW",       world="outskirts",  icon="⚔",
      path="Workspace.DialogueInteractables.OutskirtsWWQuest",
      label="Outskirts WW Quest",
      markerPath="Workspace.Debris.OutskirtsWWQuestMarker" },

    { key="MiscSkilltree",     world="outskirts",  icon="📖",
      path="Workspace.DialogueInteractables.MiscSkilltreeQuest",
      label="Skilltree Quest" },

    { key="Ointment",          world="outskirts",  icon="🌿",
      path="Workspace.DialogueInteractables.OintmentQuest",
      label="Ointment Quest" },

    { key="Aura",              world="outskirts",  icon="✨",
      path="Workspace.DialogueInteractables.AuraQuest",
      label="Aura Quest" },

    { key="OneHandStance",     world="outskirts",  icon="🗡",
      path="Workspace.DialogueInteractables.OneHandStanceQuest",
      label="One Hand Stance Quest" },

    { key="Respirator",        world="outskirts",  icon="📖",
      path="Workspace.DialogueInteractables.RespiratorQuest",
      label="Respirator Quest" },

    { key="OutskirtsStatue",   world="outskirts",  icon="🗿",
      path="Workspace.DialogueInteractables.OutskirtsStatueQuest",
      label="Mystery Statue Quest",
      markerPath="Workspace.Debris.OutskirtsWWQuestMarker" },

    { key="MissionTicket",     world="outskirts",  icon="🎫",
      path="Workspace.DialogueInteractables.OutskirtsMissionTicketQuest",
      label="Mission Ticket Quest" },

    { key="SpiritAlloy",       world="outskirts",  icon="⛏",
      path="Workspace.DialogueInteractables.SpiritAlloyQuest",
      label="Spirit Alloy Quest" },

    { key="SparringArena",     world="outskirts",  icon="⚔",
      path="Workspace.DialogueInteractables.SparringArenaQuest",
      label="Sparring Arena Quest" },

    { key="FirstErrand",       world="outskirts",  icon="📜",
      path="Workspace.DialogueInteractables.FirstErrandClassQuestNPC",
      label="First Errand Quest" },

    { key="GreyHunter",        world="outskirts",  icon="⚔",
      path="Workspace.DialogueInteractables.GreyHunterQuest",
      label="Grey Hunter Quest" },

    { key="KillMenos",         world="outskirts",  icon="💀",
      path="Workspace.DialogueInteractables.KillMenosQuest",
      label="Kill Menos Quest" },

    { key="InvasionOutskirts", world="outskirts",  icon="⚔",
      path="Workspace.DialogueInteractables.InvasionQuestOutskirts",
      label="Invasion Quest" },

    { key="Dragonfly",         world="outskirts",  icon="🐉",
      path="Workspace.DialogueInteractables.DragonflyQuestOutskirts",
      label="Dragonfly Quest",
      markerPath="Workspace.Debris.DragonflyQuestMarker" },

    { key="CapturePoint",      world="outskirts",  icon="🚩",
      path="Workspace.DialogueInteractables.CapturePointQuest",
      label="Capture Point Quest" },

    { key="BatHollow",         world="outskirts",  icon="🦇",
      path="Workspace.DialogueInteractables.BatHollowTip",
      label="Bat Hollow Quest",
      markerPath="Workspace.Debris.BatQuestMarker" },

    { key="MaskedWarrior",     world="outskirts",  icon="⚔",
      path="Workspace.DialogueInteractables.MaskedWarriorQuest",
      label="Masked Warrior Quest" },

    { key="Nindus",            world="outskirts",  icon="📜",
      path="Workspace.DialogueInteractables.NindusQuest",
      label="Nindus Quest" },

    -- NPCs avulsos (Outskirts)
    { key="DrVoris",           world="outskirts",  icon="🧪",
      path="Workspace.DialogueInteractables.DrVoris",
      label="Dr. Voris" },

    { key="Hale",              world="outskirts",  icon="💬",
      path="Workspace.DialogueInteractables.Hale",
      label="Hale" },

    { key="Smeek",             world="outskirts",  icon="💬",
      path="Workspace.DialogueInteractables.Smeek",
      label="Smeek" },

    { key="MizukiSato",        world="outskirts",  icon="👴",
      path="Workspace.DialogueInteractables.MizukiSatoElder",
      label="Mizuki Sato (Elder)" },

    -- ── Sweetwater Pass ───────────────────────────────────────────────────────
    { key="SweetwaterLeader",  world="sweetwater", icon="👑",
      path="Workspace.DialogueInteractables.SweetwaterLeader",
      label="Sweetwater Leader" },

    { key="Miello",            world="sweetwater", icon="💬",
      path="Workspace.DialogueInteractables.Miello",
      label="Miello" },

    { key="Scorpion",          world="sweetwater", icon="🦂",
      path="Workspace.Debris.ScorpionQuestMarker",
      label="Scorpion Quest",
      markerPath="Workspace.Debris.ScorpionQuestMarker" },

    { key="Mantis",            world="sweetwater", icon="🐛",
      path="Workspace.Debris.MantisQuestMarker",
      label="Mantis Quest",
      markerPath="Workspace.Debris.MantisQuestMarker" },

    { key="GiantDragonfly",    world="sweetwater", icon="🐉",
      path="Workspace.Debris.GiantDragonflyQuestMarker",
      label="Giant Dragonfly Quest",
      markerPath="Workspace.Debris.GiantDragonflyQuestMarker" },

    { key="Lizard",            world="sweetwater", icon="🦎",
      path="Workspace.Debris.LizardQuestMarker",
      label="Lizard Quest",
      markerPath="Workspace.Debris.LizardQuestMarker" },

    { key="Necklace",          world="sweetwater", icon="📿",
      path="Workspace.Debris.NecklaceMarker",
      label="Necklace Quest",
      markerPath="Workspace.Debris.NecklaceMarker" },

    { key="Shipment",          world="sweetwater", icon="📦",
      path="Workspace.Debris.ShipmentMarker",
      label="Shipment Quest",
      markerPath="Workspace.Debris.ShipmentMarker" },

    -- ── Hueco Mundo ───────────────────────────────────────────────────────────
    { key="HuecoEntrance",     world="hueco",      icon="🌑",
      path="Workspace.DialogueInteractables.HuecoEntranceQuest",
      label="Hueco Entrance Quest" },

    -- ── Outros / Marcadores ───────────────────────────────────────────────────
    { key="StrangeCave",       world="other",      icon="🕳",
      path="Workspace.Debris.StrangeCaveMarker",
      label="Strange Cave",
      markerPath="Workspace.Debris.StrangeCaveMarker" },

    { key="MizumiVillage",     world="other",      icon="🏘",
      path="Workspace.Debris.MizumiVillageMarker",
      label="Mizumi Village",
      markerPath="Workspace.Debris.MizumiVillageMarker" },

    { key="NebukaiVillage",    world="other",      icon="🏘",
      path="Workspace.Debris.NebukaiVillageMarker",
      label="Nebukai Village",
      markerPath="Workspace.Debris.NebukaiVillageMarker" },

    { key="MissingCousin",     world="other",      icon="🔍",
      path="Workspace.Debris.MissingCounsinQuestMarker",
      label="Missing Cousin",
      markerPath="Workspace.Debris.MissingCounsinQuestMarker" },
}

-- ══════════════════════════════════════════════════════════════════════════════
--  ESTADO DE MARCADORES
--  Um único highlight + billboard por vez para não acumular na memória
-- ══════════════════════════════════════════════════════════════════════════════
local State = {
    hl        = nil,   -- Highlight ativo
    bb        = nil,   -- BillboardGui ativo
    target    = nil,   -- objeto marcado
    distConn  = nil,   -- conexão do loop de distância
    running   = false, -- flag para o loop
}

local function clearMarker()
    State.running = false
    if State.hl  and State.hl.Parent  then State.hl:Destroy()  end
    if State.bb  and State.bb.Parent  then State.bb:Destroy()  end
    State.hl = nil; State.bb = nil; State.target = nil
end

-- resolve "Workspace.X.Y" → objeto
local function resolvePath(pathStr)
    if not pathStr then return nil end
    local obj = game
    for _, part in ipairs(string.split(pathStr, ".")) do
        if not obj then return nil end
        obj = obj:FindFirstChild(part)
    end
    return obj
end

-- retorna o BasePart raiz de um objeto
local function rootPart(obj)
    if not obj then return nil end
    if obj:IsA("Model") then
        return obj:FindFirstChild("HumanoidRootPart")
            or obj.PrimaryPart
            or obj:FindFirstChildWhichIsA("BasePart")
    end
    if obj:IsA("BasePart") then return obj end
    return nil
end

-- ══════════════════════════════════════════════════════════════════════════════
--  BUSCA POR PROXIMIDADE AO MARKER
--  Em vez de GetDescendants(), busca só nos filhos diretos de containers
--  conhecidos, com raio limitado → muito mais leve
-- ══════════════════════════════════════════════════════════════════════════════
local SEARCH_CONTAINERS = {"NPCs","Mobs","Enemies","Map","World"}
local SEARCH_RADIUS     = 120  -- studs ao redor do marker

local function findNearbyEnemy(markerPos)
    local best, bestDist = nil, math.huge

    -- monta lista de containers uma vez (filhos diretos do workspace)
    local containers = {}
    for _, name in ipairs(SEARCH_CONTAINERS) do
        local c = workspace:FindFirstChild(name)
        if c then table.insert(containers, c) end
    end
    -- também busca no workspace direto (alguns jogos colocam mobs lá)
    table.insert(containers, workspace)

    for _, container in ipairs(containers) do
        -- usa GetChildren() em vez de GetDescendants() — muito mais leve
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("Model") and child:FindFirstChildOfClass("Humanoid") then
                -- ignora personagens de jogadores
                if not Players:GetPlayerFromCharacter(child) then
                    local rp = rootPart(child)
                    if rp then
                        local dist = (rp.Position - markerPos).Magnitude
                        if dist < SEARCH_RADIUS and dist < bestDist then
                            bestDist = dist
                            best = child
                        end
                    end
                end
            end
        end
    end
    return best
end

-- ══════════════════════════════════════════════════════════════════════════════
--  APLICAR MARCADOR
-- ══════════════════════════════════════════════════════════════════════════════
local function applyMarker(obj, label, distLabel)
    clearMarker()
    local rp = rootPart(obj) or obj
    if not rp then return end
    State.target = obj

    -- Highlight
    local hl = Instance.new("Highlight")
    hl.FillColor         = Color3.fromRGB(255, 200, 0)
    hl.OutlineColor      = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency  = 0.5
    hl.OutlineTransparency = 0
    hl.Adornee           = rp
    hl.Parent            = rp
    State.hl             = hl

    -- BillboardGui
    local bb = Instance.new("BillboardGui")
    bb.Size         = UDim2.fromOffset(170, 46)
    bb.StudsOffset  = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop  = true
    bb.Adornee      = rp
    bb.Parent       = rp
    State.bb        = bb

    local bg = Instance.new("Frame", bb)
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    bg.BackgroundTransparency = 0.25
    corner(bg, UDim.new(0, 6))

    local tl = Instance.new("TextLabel", bg)
    tl.Size = UDim2.new(1, -8, 0.6, 0)
    tl.Position = UDim2.fromOffset(4, 2)
    tl.BackgroundTransparency = 1
    tl.Text = label or obj.Name
    tl.TextColor3 = Color3.fromRGB(255, 225, 80)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 12
    tl.TextXAlignment = Enum.TextXAlignment.Center
    tl.TextTruncate = Enum.TextTruncate.AtEnd

    local dl = Instance.new("TextLabel", bg)
    dl.Name = "DistLabel"
    dl.Size = UDim2.new(1, -8, 0.4, 0)
    dl.Position = UDim2.new(0, 4, 0.6, 0)
    dl.BackgroundTransparency = 1
    dl.Text = "..."
    dl.TextColor3 = Color3.fromRGB(170, 170, 210)
    dl.Font = Enum.Font.Gotham
    dl.TextSize = 10
    dl.TextXAlignment = Enum.TextXAlignment.Center

    -- loop de distância: tick a cada 0.5s (era 0.15s antes — 3x mais leve)
    State.running = true
    task.spawn(function()
        while State.running and State.bb and State.bb.Parent do
            local char = LP.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local trp = rootPart(obj)
                if hrp and trp then
                    local d = math.floor((hrp.Position - trp.Position).Magnitude)
                    dl.Text = d .. " studs"
                    if distLabel then distLabel.Text = d .. " studs" end
                end
            end
            task.wait(0.5)
        end
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
--  BUILD DA INTERFACE
-- ══════════════════════════════════════════════════════════════════════════════
local function buildQuestTab(parent, T)
    -- fallbacks de tema
    T.FONTB   = T.FONTB   or Enum.Font.GothamBold
    T.FONT    = T.FONT    or Enum.Font.GothamMedium
    T.MUTED   = T.MUTED   or Color3.fromRGB(120, 120, 140)
    T.ACCENT  = T.ACCENT  or Color3.fromRGB(99, 102, 241)
    T.TEXT    = T.TEXT    or Color3.new(1, 1, 1)
    T.SURFACE = T.SURFACE or Color3.fromRGB(20, 20, 30)
    T.BG      = T.BG      or Color3.fromRGB(12, 12, 18)
    T.BORDER  = T.BORDER  or Color3.fromRGB(35, 35, 55)
    T.ERR     = T.ERR     or Color3.fromRGB(220, 60, 60)
    T.SUCCESS = T.SUCCESS or Color3.fromRGB(80, 220, 130)
    T.WARN    = T.WARN    or Color3.fromRGB(255, 190, 60)

    -- ── ScrollingFrame raiz ───────────────────────────────────────────────────
    local scroll = mk("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.ACCENT,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = parent,
    })
    mk("UIPadding", {
        PaddingTop    = UDim.new(0, 6),
        PaddingLeft   = UDim.new(0, 6),
        PaddingRight  = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        Parent = scroll,
    })
    mk("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 4),
        Parent    = scroll,
    })

    -- ── Card de quest ativa ───────────────────────────────────────────────────
    local activeCard = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundColor3 = Color3.fromRGB(14, 14, 24),
        BorderSizePixel = 0,
        LayoutOrder = 0,
        Parent = scroll,
    })
    corner(activeCard)
    mk("UIStroke", { Color = T.BORDER, Thickness = 1, Parent = activeCard })

    local statusDot = mk("Frame", {
        Size = UDim2.fromOffset(8, 8),
        Position = UDim2.fromOffset(10, 10),
        BackgroundColor3 = T.MUTED,
        BorderSizePixel = 0,
        Parent = activeCard,
    })
    corner(statusDot, UDim.new(1, 0))

    local statusLbl = mk("TextLabel", {
        Size = UDim2.new(1, -36, 0, 14),
        Position = UDim2.fromOffset(24, 8),
        BackgroundTransparency = 1,
        Text = "Nenhuma quest ativa",
        TextColor3 = T.MUTED,
        Font = T.FONTB,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = activeCard,
    })

    mk("Frame", {
        Size = UDim2.new(1, -16, 0, 1),
        Position = UDim2.fromOffset(8, 26),
        BackgroundColor3 = T.BORDER,
        BorderSizePixel = 0,
        Parent = activeCard,
    })

    -- alvo + distância
    local function miniCell(xOff, labelTxt)
        local col = mk("Frame", {
            Size = UDim2.fromOffset(120, 30),
            Position = UDim2.fromOffset(xOff, 30),
            BackgroundTransparency = 1,
            Parent = activeCard,
        })
        mk("TextLabel", {
            Size = UDim2.new(1, 0, 0, 11),
            BackgroundTransparency = 1,
            Text = labelTxt,
            TextColor3 = T.MUTED,
            Font = T.FONT,
            TextSize = 8,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = col,
        })
        return mk("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.fromOffset(0, 12),
            BackgroundTransparency = 1,
            Text = "—",
            TextColor3 = T.TEXT,
            Font = T.FONTB,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = col,
        })
    end
    local valTarget = miniCell(8,   "ALVO")
    local valDist   = miniCell(130, "DISTÂNCIA")

    -- botão limpar marcador (pequeno, discreto)
    local btnClear = mk("TextButton", {
        Size = UDim2.fromOffset(22, 22),
        Position = UDim2.new(1, -28, 0, 8),
        BackgroundColor3 = Color3.fromRGB(80, 20, 20),
        Text = "✕",
        TextColor3 = T.TEXT,
        Font = T.FONTB,
        TextSize = 11,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Parent = activeCard,
    })
    corner(btnClear, UDim.new(0, 5))

    -- ── Buscar inimigo próximo ─────────────────────────────────────────────────
    -- botão que aparece quando a quest tem markerPath
    local btnFindEnemy = mk("TextButton", {
        Size = UDim2.new(1, 0, 0, 26),
        BackgroundColor3 = Color3.fromRGB(35, 70, 35),
        Text = "🎯  Marcar Inimigo Próximo",
        TextColor3 = T.TEXT,
        Font = T.FONTB,
        TextSize = 10,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        LayoutOrder = 1,
        Visible = false,
        Parent = scroll,
    })
    corner(btnFindEnemy, UDim.new(0, 6))
    mk("UIStroke", { Color = Color3.fromRGB(60, 120, 60), Thickness = 1, Parent = btnFindEnemy })

    btnFindEnemy.MouseEnter:Connect(function()
        tw(btnFindEnemy, 0.1, { BackgroundTransparency = 0.3 })
    end)
    btnFindEnemy.MouseLeave:Connect(function()
        tw(btnFindEnemy, 0.1, { BackgroundTransparency = 0 })
    end)

    -- ── Separador + título ────────────────────────────────────────────────────
    mk("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = T.BORDER,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        Parent = scroll,
    })
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = "QUESTS POR MUNDO",
        TextColor3 = T.MUTED,
        Font = T.FONTB,
        TextSize = 8,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 3,
        Parent = scroll,
    })

    -- ── Estado ativo ──────────────────────────────────────────────────────────
    local activeKey        = nil
    local activeMarkerPath = nil
    local activeQuestRows  = {}  -- referência às rows para resetar cor

    local function resetActiveRow()
        for _, row in ipairs(activeQuestRows) do
            if row and row.Parent then
                tw(row, 0.1, { BackgroundColor3 = T.SURFACE })
                local dot = row:FindFirstChild("__dot")
                if dot then dot.BackgroundColor3 = T.MUTED end
            end
        end
        activeQuestRows = {}
    end

    local function doSelectQuest(questData, row, dot)
        -- limpa seleção anterior
        resetActiveRow()
        clearMarker()
        btnFindEnemy.Visible = false
        activeKey = questData.key
        activeMarkerPath = questData.markerPath

        -- destaca row selecionada
        tw(row, 0.12, { BackgroundColor3 = Color3.fromRGB(20, 35, 48) })
        dot.BackgroundColor3 = T.SUCCESS
        table.insert(activeQuestRows, row)

        -- resolve NPC da quest
        local obj = resolvePath(questData.path)
        if obj then
            applyMarker(obj, questData.label, valDist)
            valTarget.Text = questData.label
            valDist.Text   = "calculando..."
            statusLbl.Text = questData.label
            statusDot.BackgroundColor3 = T.SUCCESS
        else
            -- NPC não encontrado (outro mundo?)
            valTarget.Text = "⚠ Fora deste mundo"
            valDist.Text   = "—"
            statusLbl.Text = questData.label
            statusDot.BackgroundColor3 = T.WARN
        end

        -- mostra botão de busca de inimigo se tiver markerPath
        if questData.markerPath then
            btnFindEnemy.Visible = true
        end
    end

    -- lógica do botão de busca de inimigo próximo
    btnFindEnemy.Activated:Connect(function()
        if not activeMarkerPath then return end
        local marker = resolvePath(activeMarkerPath)
        if not marker then
            statusLbl.Text = "⚠ Marker não encontrado"
            statusDot.BackgroundColor3 = T.ERR
            return
        end
        local markerPos = rootPart(marker) and rootPart(marker).Position
                       or (marker:IsA("BasePart") and marker.Position)
                       or nil
        if not markerPos then
            statusLbl.Text = "⚠ Posição do marker inválida"
            statusDot.BackgroundColor3 = T.ERR
            return
        end

        btnFindEnemy.Text = "🔍 Buscando..."
        task.delay(0.05, function()
            local enemy = findNearbyEnemy(markerPos)
            if enemy then
                applyMarker(enemy, "⚔ Inimigo", valDist)
                valTarget.Text = "Inimigo próximo"
                valDist.Text   = "calculando..."
                statusLbl.Text = "⚔ Inimigo marcado!"
                statusDot.BackgroundColor3 = T.SUCCESS
            else
                statusLbl.Text = "Nenhum inimigo próximo (raio: "..SEARCH_RADIUS.."st)"
                statusDot.BackgroundColor3 = T.WARN
            end
            btnFindEnemy.Text = "🎯  Marcar Inimigo Próximo"
        end)
    end)

    btnClear.Activated:Connect(function()
        clearMarker()
        resetActiveRow()
        btnFindEnemy.Visible = false
        activeKey = nil; activeMarkerPath = nil
        statusDot.BackgroundColor3 = T.MUTED
        statusLbl.Text = "Nenhuma quest ativa"
        valTarget.Text = "—"; valDist.Text = "—"
    end)

    -- ── Categorias colapsáveis por mundo ─────────────────────────────────────
    -- agrupa quests por world
    local byWorld = {}
    for _, w in ipairs(WORLDS) do byWorld[w.id] = {} end
    for _, q in ipairs(QUEST_MAP) do
        if byWorld[q.world] then
            table.insert(byWorld[q.world], q)
        end
    end

    local layoutOrder = 10
    for _, worldDef in ipairs(WORLDS) do
        local quests = byWorld[worldDef.id]
        if #quests == 0 then continue end

        layoutOrder += 1

        -- Header do mundo (clicável para colapsar)
        local worldHeader = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundColor3 = Color3.fromRGB(22, 22, 34),
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            LayoutOrder = layoutOrder,
            Parent = scroll,
        })
        corner(worldHeader, UDim.new(0, 6))
        mk("UIStroke", { Color = T.BORDER, Thickness = 1, Parent = worldHeader })

        local wIcon = mk("TextLabel", {
            Size = UDim2.fromOffset(20, 24),
            Position = UDim2.fromOffset(6, 0),
            BackgroundTransparency = 1,
            Text = worldDef.icon,
            TextColor3 = T.TEXT,
            Font = T.FONTB,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = worldHeader,
        })

        mk("TextLabel", {
            Size = UDim2.new(1, -60, 1, 0),
            Position = UDim2.fromOffset(28, 0),
            BackgroundTransparency = 1,
            Text = worldDef.label,
            TextColor3 = T.TEXT,
            Font = T.FONTB,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = worldHeader,
        })

        local countLbl = mk("TextLabel", {
            Size = UDim2.fromOffset(26, 16),
            Position = UDim2.new(1, -32, 0.5, -8),
            BackgroundColor3 = T.ACCENT,
            BackgroundTransparency = 0.4,
            Text = tostring(#quests),
            TextColor3 = T.TEXT,
            Font = T.FONTB,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Center,
            BorderSizePixel = 0,
            Parent = worldHeader,
        })
        corner(countLbl, UDim.new(0, 4))

        local arrowLbl = mk("TextLabel", {
            Size = UDim2.fromOffset(16, 24),
            Position = UDim2.new(1, -14, 0, 0),
            BackgroundTransparency = 1,
            Text = "▾",
            TextColor3 = T.MUTED,
            Font = T.FONTB,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Center,
            Parent = worldHeader,
        })

        -- Container de quests deste mundo
        layoutOrder += 1
        local questContainer = mk("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = layoutOrder,
            Parent = scroll,
        })
        mk("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding   = UDim.new(0, 2),
            Parent    = questContainer,
        })
        mk("UIPadding", {
            PaddingLeft  = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 0),
            Parent = questContainer,
        })

        -- toggle colapsar/expandir
        local expanded = true
        worldHeader.Activated:Connect(function()
            expanded = not expanded
            questContainer.Visible = expanded
            arrowLbl.Text = expanded and "▾" or "▸"
            tw(worldHeader, 0.1, {
                BackgroundColor3 = expanded
                    and Color3.fromRGB(22, 22, 34)
                    or  Color3.fromRGB(18, 18, 26)
            })
        end)

        -- hover no header
        worldHeader.MouseEnter:Connect(function()
            tw(worldHeader, 0.1, { BackgroundColor3 = Color3.fromRGB(28, 28, 42) })
        end)
        worldHeader.MouseLeave:Connect(function()
            tw(worldHeader, 0.1, {
                BackgroundColor3 = expanded
                    and Color3.fromRGB(22, 22, 34)
                    or  Color3.fromRGB(18, 18, 26)
            })
        end)

        -- rows de quest dentro do container
        for qi, q in ipairs(quests) do
            local row = mk("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = T.SURFACE,
                Text = "",
                BorderSizePixel = 0,
                AutoButtonColor = false,
                LayoutOrder = qi,
                Parent = questContainer,
            })
            corner(row, UDim.new(0, 5))
            mk("UIStroke", { Color = T.BORDER, Thickness = 1, Parent = row })

            -- dot de status
            local dot = mk("Frame", {
                Name = "__dot",
                Size = UDim2.fromOffset(5, 5),
                Position = UDim2.new(0, 7, 0.5, -2),
                BackgroundColor3 = T.MUTED,
                BorderSizePixel = 0,
                Parent = row,
            })
            corner(dot, UDim.new(1, 0))

            -- ícone
            mk("TextLabel", {
                Size = UDim2.fromOffset(16, 26),
                Position = UDim2.fromOffset(16, 0),
                BackgroundTransparency = 1,
                Text = q.icon or "•",
                TextColor3 = T.MUTED,
                Font = T.FONT,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = row,
            })

            -- label
            mk("TextLabel", {
                Size = UDim2.new(1, -36, 1, 0),
                Position = UDim2.fromOffset(34, 0),
                BackgroundTransparency = 1,
                Text = q.label,
                TextColor3 = T.TEXT,
                Font = T.FONT,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = row,
            })

            -- badge "🎯" se tem marker de objetivo
            if q.markerPath then
                mk("TextLabel", {
                    Size = UDim2.fromOffset(14, 26),
                    Position = UDim2.new(1, -16, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "🎯",
                    TextColor3 = T.TEXT,
                    Font = T.FONT,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    Parent = row,
                })
            end

            -- hover
            row.MouseEnter:Connect(function()
                if activeKey ~= q.key then
                    tw(row, 0.1, { BackgroundColor3 = T.BORDER })
                end
            end)
            row.MouseLeave:Connect(function()
                if activeKey ~= q.key then
                    tw(row, 0.1, { BackgroundColor3 = T.SURFACE })
                end
            end)

            -- clique
            row.Activated:Connect(function()
                doSelectQuest(q, row, dot)
            end)
        end
    end

    -- ── Cleanup ao fechar UI ──────────────────────────────────────────────────
    if UI_REGISTRY then
        UI_REGISTRY.onClose(function()
            clearMarker()
        end)
    end
end

return {
    Init = function(parent, T)
        buildQuestTab(parent, T)
    end
}
