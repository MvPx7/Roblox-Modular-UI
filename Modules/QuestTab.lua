-- QuestTab.lua  v1.0  ─ Módulo Quest com Auto-Quest Manual
-- Retorna { Init = function(parent, T) } compatível com o sistema de módulos da UI
-- ══════════════════════════════════════════════════════════════════════════════

local Players  = game:GetService("Players")
local LP       = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════════════════════
--  MAPA DE QUESTS  (onde pegar a missão)
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
    ["DragonflyMarker"]   = { path = "Workspace.Debris.DragonflyQuestMarker",                          label = "Dragonfly Location" },
    ["PowerControlMarker"]= { path = "Workspace.Debris.PowerControlQuestMarker",                       label = "Power Control Location" },
    ["MizumiVillage"]     = { path = "Workspace.Debris.MizumiVillageMarker",                           label = "Mizumi Village" },
    ["NebukaiVillage"]    = { path = "Workspace.Debris.NebukaiVillageMarker",                         label = "Nebukai Village" },
    ["BatQuest"]          = { path = "Workspace.Debris.BatQuestMarker",                               label = "Bat Location" },
}

-- ══════════════════════════════════════════════════════════════════════════════
--  MAPA DE OBJETIVOS  (NPCs a matar / Itens a coletar por quest)
--  Adicione ou edite conforme o jogo. Campos:
--    type   = "kill"    → procura NPC pelo nome no Workspace
--    type   = "collect" → procura item pelo nome no Workspace / Map
--    names  = lista de nomes possíveis no Workspace
--    hint   = texto de dica mostrado na UI
-- ══════════════════════════════════════════════════════════════════════════════
local QUEST_OBJECTIVES = {
    ["KillMenos"] = {
        { type = "kill",    names = {"Menos", "GrandFisher", "Hollow"},      hint = "Mate os Menos na área" },
    },
    ["GreyHunter"] = {
        { type = "kill",    names = {"Wolf", "GreyWolf", "Hunter"},          hint = "Mate os lobos cinza" },
    },
    ["InvasionOutskirts"] = {
        { type = "kill",    names = {"InvasionEnemy", "Invader"},            hint = "Elimine os invasores" },
    },
    ["Dragonfly"] = {
        { type = "kill",    names = {"Dragonfly", "GiantDragonfly"},         hint = "Mate as libélulas" },
    },
    ["SparringArena"] = {
        { type = "kill",    names = {"SparringDummy", "TrainingDummy"},      hint = "Derrote os dummies na arena" },
    },
    ["Ointment"] = {
        { type = "collect", names = {"Herb", "OintmentHerb", "Plant"},       hint = "Colete as ervas medicinais" },
    },
    ["SpiritAlloy"] = {
        { type = "collect", names = {"SpiritOre", "AlloyOre", "Ore"},        hint = "Colete minério de Spirit Alloy" },
    },
    ["Necklace"] = {
        { type = "collect", names = {"Necklace", "LostNecklace"},            hint = "Encontre e colete o colar" },
    },
    ["Shipment"] = {
        { type = "collect", names = {"Shipment", "Package", "Crate"},        hint = "Colete os pacotes do carregamento" },
    },
    ["MissingParty"] = {
        { type = "kill",    names = {"MissingMember", "Enemy"},              hint = "Resgate/elimine ameaças ao grupo" },
        { type = "collect", names = {"Survivor", "SurvivorItem"},            hint = "Encontre sobreviventes" },
    },
    ["BatHollow"] = {
        { type = "kill",    names = {"Bat", "BatCreature", "HollowBat"},     hint = "Mate os morcegos no hollow" },
    },
    ["MaskedWarrior"] = {
        { type = "kill",    names = {"MaskedWarrior", "MaskedEnemy"},        hint = "Derrote o Guerreiro Mascarado" },
    },
    ["CapturePoint"] = {
        { type = "kill",    names = {"Defender", "CaptureEnemy"},            hint = "Elimine defensores do ponto" },
    },
    ["Scorpion"] = {
        { type = "kill",    names = {"Scorpion", "GiantScorpion"},           hint = "Mate o escorpião na localização" },
    },
    ["Mantis"] = {
        { type = "kill",    names = {"Mantis", "GiantMantis"},               hint = "Mate o louva-a-deus na localização" },
    },
    ["Lizard"] = {
        { type = "kill",    names = {"Lizard", "GiantLizard"},               hint = "Mate o lagarto na localização" },
    },
}

-- ══════════════════════════════════════════════════════════════════════════════
--  ETAPAS DE QUEST  (para quests com múltiplas fases)
--  Cada etapa tem:
--    stepId   = identificador único da etapa (string ou número)
--    label    = nome exibido
--    path     = caminho do alvo no Workspace (opcional — usa busca dinâmica se nil)
--    hint     = dica exibida
--    type     = "npc" | "collect" | "kill" | "return"
--    names    = lista de nomes para busca dinâmica no Workspace (opcional)
--
--  A detecção da etapa atual tenta ler de:
--    LP:FindFirstChild("QuestData") ou LP:FindFirstChild("PlayerData")
--    via atributos, StringValues ou NumberValues com o nome da quest
-- ══════════════════════════════════════════════════════════════════════════════
local QUEST_STEPS = {
    ["Necklace"] = {
        {
            stepId = 1,
            label  = "Necklace Location",
            hint   = "Encontre e colete o colar",
            type   = "collect",
            path   = "Workspace.Debris.NecklaceMarker",
            names  = {"NecklaceMarker", "Necklace", "LostNecklace"},
        },
        {
            stepId = 2,
            label  = "Return to Niklo",
            hint   = "Retorne ao Niklo com o colar",
            type   = "return",
            -- Adicione aqui o path do NPC Niklo quando souber
            -- path = "Workspace.DialogueInteractables.Niklo",
            names  = {"Niklo"},
        },
    },
    ["Lizard"] = {
        {
            stepId = 1,
            label  = "Lizard Location",
            hint   = "Encontre e mate o lagarto",
            type   = "kill",
            path   = "Workspace.Debris.LizardQuestMarker",
            names  = {"LizardQuestMarker", "Lizard", "GiantLizard"},
        },
        {
            stepId = 2,
            label  = "Return to Quest Giver",
            hint   = "Retorne ao NPC de quest",
            type   = "return",
            names  = {"QuestGiver", "NPC"},
        },
    },
    -- Adicione mais quests com etapas aqui conforme necessário
}

-- ══════════════════════════════════════════════════════════════════════════════
--  DETECTA ETAPA ATUAL DA QUEST
--  Tenta várias estratégias para ler progresso do PlayerData
-- ══════════════════════════════════════════════════════════════════════════════
local function detectQuestStep(questKey)
    -- Estratégia 1: Verificar se o item de coleta sumiu do Workspace
    -- (se o NecklaceMarker não existe mais, provavelmente foi coletado)
    if questKey == "Necklace" then
        local marker = workspace:FindFirstChild("Debris")
            and workspace.Debris:FindFirstChild("NecklaceMarker")
        if not marker then
            -- Marcador sumiu = item coletado, provavelmente na etapa de retorno
            return 2
        end
        return 1
    end

    -- Estratégia 2: Ler atributos do PlayerData / QuestData
    local function tryReadStep(container)
        if not container then return nil end
        -- Tenta como atributo direto
        local attr = container:GetAttribute(questKey .. "_step")
            or container:GetAttribute(questKey .. "Step")
            or container:GetAttribute(questKey)
        if attr and type(attr) == "number" then return attr end
        -- Tenta como filho StringValue/NumberValue/IntValue
        local child = container:FindFirstChild(questKey .. "_step")
            or container:FindFirstChild(questKey .. "Step")
            or container:FindFirstChild(questKey)
        if child and (child:IsA("NumberValue") or child:IsA("IntValue")) then
            return child.Value
        end
        if child and child:IsA("StringValue") then
            return tonumber(child.Value)
        end
        return nil
    end

    -- Tenta diferentes locais onde o jogo pode guardar progresso
    local locations = {
        LP:FindFirstChild("QuestData"),
        LP:FindFirstChild("PlayerData"),
        LP:FindFirstChild("Quests"),
        LP:FindFirstChild("Data"),
        LP:FindFirstChild("leaderstats"),
    }
    for _, loc in ipairs(locations) do
        local step = tryReadStep(loc)
        if step then return step end
    end

    -- Estratégia 3: Verificar inventário do personagem / hotbar
    -- Se o item da quest estiver no inventário, provavelmente foi coletado
    if questKey == "Necklace" then
        local backpack = LP:FindFirstChild("Backpack")
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do
                if item.Name:lower():find("necklace") then
                    return 2 -- tem o item = etapa de retorno
                end
            end
        end
        local char = LP.Character
        if char then
            for _, item in ipairs(char:GetChildren()) do
                if item.Name:lower():find("necklace") then
                    return 2
                end
            end
        end
    end

    return 1 -- padrão: etapa 1
end

-- ══════════════════════════════════════════════════════════════════════════════
--  ESTADO INTERNO
-- ══════════════════════════════════════════════════════════════════════════════
local QuestState = {
    activeHighlight  = nil,
    activeBillboard  = nil,
    targetObj        = nil,
    objectiveMarkers = {},   -- lista de {highlight, billboard} dos objetivos
}

-- ══════════════════════════════════════════════════════════════════════════════
--  HELPERS INTERNOS
-- ══════════════════════════════════════════════════════════════════════════════
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

-- Limpa o marcador principal (NPC da quest)
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

-- Limpa marcadores de objetivos (NPCs/Itens)
local function questClearObjectiveMarkers()
    for _, m in ipairs(QuestState.objectiveMarkers) do
        if m.highlight and m.highlight.Parent then m.highlight:Destroy() end
        if m.billboard and m.billboard.Parent then m.billboard:Destroy() end
    end
    QuestState.objectiveMarkers = {}
end

-- ══════════════════════════════════════════════════════════════════════════════
--  APLICA MARCADOR PRINCIPAL  (onde pegar a quest)
-- ══════════════════════════════════════════════════════════════════════════════
local function questApplyMarker(obj, label)
    questClearMarker()
    local root = questGetRootPart(obj) or obj
    if not root then return end
    QuestState.targetObj = obj

    local hl = Instance.new("Highlight")
    hl.FillColor           = Color3.fromRGB(255, 200, 0)
    hl.OutlineColor        = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency    = 0.5
    hl.OutlineTransparency = 0
    hl.Adornee = root
    hl.Parent  = root
    QuestState.activeHighlight = hl

    local bb = Instance.new("BillboardGui")
    bb.Size        = UDim2.fromOffset(180, 50)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Adornee     = root
    bb.Parent      = root
    QuestState.activeBillboard = bb

    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    bg.BackgroundTransparency = 0.3
    bg.Parent = bb
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = bg

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -8, 0.6, 0)
    titleLbl.Position = UDim2.fromOffset(4, 3)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = label or obj.Name
    titleLbl.TextColor3 = Color3.fromRGB(255, 230, 80)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 13
    titleLbl.TextXAlignment = Enum.TextXAlignment.Center
    titleLbl.Parent = bg

    local distL = Instance.new("TextLabel")
    distL.Name = "DistLabel"
    distL.Size = UDim2.new(1, -8, 0.4, 0)
    distL.Position = UDim2.new(0, 4, 0.6, 0)
    distL.BackgroundTransparency = 1
    distL.Text = "..."
    distL.TextColor3 = Color3.fromRGB(180, 180, 220)
    distL.Font = Enum.Font.Gotham
    distL.TextSize = 11
    distL.TextXAlignment = Enum.TextXAlignment.Center
    distL.Parent = bg

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

-- ══════════════════════════════════════════════════════════════════════════════
--  APLICA MARCADORES DE OBJETIVOS  (NPCs/Itens da quest)
--  Cor diferente: vermelho p/ kill, verde p/ collect
-- ══════════════════════════════════════════════════════════════════════════════
local function questApplyObjectiveMarker(obj, label, objType)
    local root = questGetRootPart(obj) or obj
    if not root then return end

    local fillColor    = objType == "kill"
        and Color3.fromRGB(220, 50, 50)
        or  Color3.fromRGB(50, 220, 100)
    local outlineColor = objType == "kill"
        and Color3.fromRGB(255, 120, 120)
        or  Color3.fromRGB(120, 255, 160)

    local hl = Instance.new("Highlight")
    hl.FillColor           = fillColor
    hl.OutlineColor        = outlineColor
    hl.FillTransparency    = 0.45
    hl.OutlineTransparency = 0
    hl.Adornee = root
    hl.Parent  = root

    local bb = Instance.new("BillboardGui")
    bb.Size        = UDim2.fromOffset(160, 44)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    bb.Adornee     = root
    bb.Parent      = root

    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(8, 8, 14)
    bg.BackgroundTransparency = 0.3
    bg.Parent = bb
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = bg

    local icon = objType == "kill" and "⚔ " or "◈ "
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -6, 0.6, 0)
    titleLbl.Position = UDim2.fromOffset(3, 2)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = icon .. label
    titleLbl.TextColor3 = objType == "kill"
        and Color3.fromRGB(255, 130, 130)
        or  Color3.fromRGB(130, 255, 170)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Center
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
    titleLbl.Parent = bg

    local distL = Instance.new("TextLabel")
    distL.Size = UDim2.new(1, -6, 0.4, 0)
    distL.Position = UDim2.new(0, 3, 0.6, 0)
    distL.BackgroundTransparency = 1
    distL.Text = "..."
    distL.TextColor3 = Color3.fromRGB(160, 160, 200)
    distL.Font = Enum.Font.Gotham
    distL.TextSize = 10
    distL.TextXAlignment = Enum.TextXAlignment.Center
    distL.Parent = bg

    -- Loop de distância local para este marcador
    task.spawn(function()
        while bb and bb.Parent do
            local char = LP.Character
            if char then
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local rp  = questGetRootPart(obj)
                if hrp and rp then
                    local d = math.floor((hrp.Position - rp.Position).Magnitude)
                    distL.Text = d .. " studs"
                end
            end
            task.wait(0.2)
        end
    end)

    table.insert(QuestState.objectiveMarkers, { highlight = hl, billboard = bb })
    return hl, bb
end

-- ══════════════════════════════════════════════════════════════════════════════
--  BUSCA OBJETIVOS NO WORKSPACE
--  Retorna lista de {obj, name} encontrados pelos nomes da tabela de objetivos
-- ══════════════════════════════════════════════════════════════════════════════
local function findObjectivesInWorkspace(nameList)
    local found = {}
    -- Busca nos filhos diretos do Workspace e subgrupos comuns (NPCs, Mobs, Items, etc.)
    local searchRoots = {workspace}
    -- Tenta adicionar pastas comuns de NPCs/mobs/itens se existirem
    local extras = {"NPCs", "Mobs", "Enemies", "Items", "Collectibles", "Map", "World", "Debris"}
    for _, name in ipairs(extras) do
        local f = workspace:FindFirstChild(name)
        if f then table.insert(searchRoots, f) end
    end

    for _, root in ipairs(searchRoots) do
        for _, child in ipairs(root:GetDescendants()) do
            for _, targetName in ipairs(nameList) do
                if child.Name:lower():find(targetName:lower()) then
                    -- Só inclui se for Model ou BasePart com Humanoid (NPC vivo) ou item
                    local valid = false
                    if child:IsA("Model") and child:FindFirstChildOfClass("Humanoid") then
                        valid = true
                    elseif child:IsA("BasePart") or child:IsA("Model") then
                        valid = true
                    end
                    if valid then
                        -- Evita duplicatas pelo mesmo objeto
                        local alreadyIn = false
                        for _, r in ipairs(found) do
                            if r.obj == child then alreadyIn = true; break end
                        end
                        if not alreadyIn then
                            table.insert(found, { obj = child, name = child.Name })
                        end
                    end
                end
            end
        end
    end
    return found
end

-- ══════════════════════════════════════════════════════════════════════════════
--  CONSTRÓI A ABA QUEST
-- ══════════════════════════════════════════════════════════════════════════════
local function mk(cls, props, parent)
    local o = Instance.new(cls)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(p, r)
    mk("UICorner", {CornerRadius = r or UDim.new(0, 10)}, p)
end
local function tw(obj, t, props)
    game:GetService("TweenService"):Create(obj, TweenInfo.new(t, Enum.EasingStyle.Quad), props):Play()
end

local function buildQuestTab(parent, T)
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

    local function sep(order)
        return mk("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.BORDER,
            BorderSizePixel = 0,
            LayoutOrder = order,
            Parent = scroll,
        })
    end

    local valQuest  = infoRow(1, "Quest:",          "—")
    local valTarget = infoRow(2, "Alvo:",            "—")
    local valDist   = infoRow(3, "Distância:",       "—")
    local valObj    = infoRow(4, "Objetivo:",        "—")
    sep(5)

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

    local btnObjectives = actionBtn(6, "⚔  Mostrar Objetivos", Color3.fromRGB(50, 100, 200))
    local btnClear      = actionBtn(7, "✕  Limpar Marcadores", Color3.fromRGB(140, 40, 40))
    sep(8)

    -- Painel de resultado da busca de objetivos
    local objResultFrame = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = T.SURFACE,
        BackgroundTransparency = 1,
        LayoutOrder = 9,
        Parent = scroll,
    })
    mk("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding   = UDim.new(0, 3),
        Parent    = objResultFrame,
    })

    -- Label da lista de quests
    mk("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "QUESTS DISPONÍVEIS",
        TextColor3 = T.SUBTEXT,
        Font = T.FONTB,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 10,
        Parent = scroll,
    })

    -- Ordena as quests pelo label
    local sortedQuests = {}
    for k, v in pairs(QUEST_MAP) do
        table.insert(sortedQuests, { key = k, data = v })
    end
    table.sort(sortedQuests, function(a, b) return a.data.label < b.data.label end)

    local activeKey     = nil
    local activeQuestKey = nil

    -- Limpa tudo
    local function clearAll()
        stopStepTracking()
        questClearMarker()
        questClearObjectiveMarkers()
        activeKey = nil
        activeQuestKey = nil
        statusDot.BackgroundColor3 = T.SUBTEXT
        statusLbl.Text = "Nenhuma quest ativa"
        valQuest.Text  = "—"
        valTarget.Text = "—"
        valDist.Text   = "—"
        valObj.Text    = "—"
        -- Limpa painel de resultados
        for _, ch in ipairs(objResultFrame:GetChildren()) do
            if not ch:IsA("UIListLayout") then ch:Destroy() end
        end
    end

    -- Mostra etapa atual da quest com rastreamento automático
    local stepTrackConnection = nil
    local currentTrackedKey   = nil
    local currentTrackedStep  = nil

    local function stopStepTracking()
        if stepTrackConnection then
            stepTrackConnection:Disconnect()
            stepTrackConnection = nil
        end
        currentTrackedKey  = nil
        currentTrackedStep = nil
    end

    local function applyStepMarker(qKey, stepNum)
        local steps = QUEST_STEPS[qKey]
        if not steps then return false end
        local step = steps[stepNum] or steps[1]
        if not step then return false end

        questClearMarker()
        questClearObjectiveMarkers()

        -- Tenta caminho direto primeiro
        local obj = step.path and questResolvePath(step.path)

        -- Se não achou, busca dinâmica por nome
        if not obj and step.names then
            local found = findObjectivesInWorkspace(step.names)
            if #found > 0 then obj = found[1].obj end
        end

        if obj then
            questApplyMarker(obj, step.label)
            valTarget.Text = obj.Name
            valDist.Text   = "calculando..."
            statusLbl.Text = step.hint
            statusDot.BackgroundColor3 = stepNum == 1 and T.SUCCESS or Color3.fromRGB(255, 165, 0)
        else
            questClearMarker()
            valTarget.Text = "⚠ " .. (step.names and step.names[1] or "?") .. " — não encontrado"
            valDist.Text   = "—"
            statusLbl.Text = "⚠ " .. step.hint .. " (alvo não localizado)"
            statusDot.BackgroundColor3 = T.ERR
        end

        valObj.Text = "Etapa " .. stepNum .. "/" .. #steps .. ": " .. step.hint
        valQuest.Text = QUEST_MAP[qKey] and QUEST_MAP[qKey].label or qKey
        return true
    end

    local function startStepTracking(qKey)
        stopStepTracking()
        if not QUEST_STEPS[qKey] then return end

        currentTrackedKey = qKey
        local lastStep = detectQuestStep(qKey)
        applyStepMarker(qKey, lastStep)
        currentTrackedStep = lastStep

        -- Monitora mudança de etapa a cada 1s
        stepTrackConnection = game:GetService("RunService").Heartbeat:Connect(function()
            -- Só checa a cada ~60 frames (~1s) para não sobrecarregar
        end)

        task.spawn(function()
            while currentTrackedKey == qKey and parent.Parent do
                task.wait(1)
                if currentTrackedKey ~= qKey then break end
                local newStep = detectQuestStep(qKey)
                if newStep ~= currentTrackedStep then
                    currentTrackedStep = newStep
                    applyStepMarker(qKey, newStep)
                    -- Notificação visual de mudança de etapa
                    statusDot.BackgroundColor3 = Color3.fromRGB(255, 220, 0)
                    task.wait(0.5)
                    statusDot.BackgroundColor3 = newStep == 1
                        and T.SUCCESS
                        or  Color3.fromRGB(255, 165, 0)
                end
            end
        end)
    end


    local function showObjectives(qKey)
        -- Limpa painel anterior
        for _, ch in ipairs(objResultFrame:GetChildren()) do
            if not ch:IsA("UIListLayout") then ch:Destroy() end
        end
        questClearObjectiveMarkers()

        local objectives = QUEST_OBJECTIVES[qKey]
        if not objectives then
            -- Quest sem mapeamento: avisa o usuário
            local lbl = mk("TextLabel", {
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Color3.fromRGB(40, 30, 10),
                BackgroundTransparency = 0.3,
                Text = "⚠ Objetivos não mapeados\nVerifique QuestHelper.lua",
                TextColor3 = T.WARN,
                Font = T.FONT,
                TextSize = 10,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Center,
                LayoutOrder = 1,
                Parent = objResultFrame,
            })
            corner(lbl, UDim.new(0, 5))
            valObj.Text = "Não mapeado"
            return
        end

        local totalFound = 0
        local objIdx = 0

        for _, objDef in ipairs(objectives) do
            local found = findObjectivesInWorkspace(objDef.names)

            -- Linha de dica
            objIdx = objIdx + 1
            local hintLbl = mk("TextLabel", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Text = (objDef.type == "kill" and "⚔ " or "◈ ") .. objDef.hint,
                TextColor3 = objDef.type == "kill"
                    and Color3.fromRGB(255, 130, 130)
                    or  Color3.fromRGB(130, 255, 170),
                Font = T.FONTB,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = objIdx,
                Parent = objResultFrame,
            })

            if #found == 0 then
                objIdx = objIdx + 1
                local notFound = mk("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = "   Nenhum encontrado no momento",
                    TextColor3 = T.SUBTEXT,
                    Font = T.FONT,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    LayoutOrder = objIdx,
                    Parent = objResultFrame,
                })
            else
                for _, r in ipairs(found) do
                    totalFound = totalFound + 1
                    questApplyObjectiveMarker(r.obj, r.name, objDef.type)

                    objIdx = objIdx + 1
                    local entryRow = mk("Frame", {
                        Size = UDim2.new(1, 0, 0, 22),
                        BackgroundColor3 = objDef.type == "kill"
                            and Color3.fromRGB(40, 12, 12)
                            or  Color3.fromRGB(12, 40, 20),
                        BackgroundTransparency = 0.3,
                        LayoutOrder = objIdx,
                        Parent = objResultFrame,
                    })
                    corner(entryRow, UDim.new(0, 4))

                    mk("TextLabel", {
                        Size = UDim2.new(1, -8, 1, 0),
                        Position = UDim2.fromOffset(6, 0),
                        BackgroundTransparency = 1,
                        Text = "• " .. r.name,
                        TextColor3 = T.TEXT,
                        Font = T.FONT,
                        TextSize = 10,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = entryRow,
                    })
                end
            end
        end

        valObj.Text = totalFound > 0 and (totalFound .. " encontrado(s)") or "Nenhum encontrado"
    end

    -- Botão Mostrar Objetivos
    btnObjectives.Activated:Connect(function()
        if not activeQuestKey then
            statusLbl.Text = "Selecione uma quest primeiro!"
            statusDot.BackgroundColor3 = T.WARN
            return
        end
        showObjectives(activeQuestKey)
        statusLbl.Text = "Objetivos marcados"
        statusDot.BackgroundColor3 = T.ACCENT
    end)

    -- Botão Limpar
    btnClear.Activated:Connect(clearAll)

    -- Loop de distância (marcador principal)
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

    -- Lista de quests
    for idx, entry in ipairs(sortedQuests) do
        local k, v = entry.key, entry.data
        local row = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = T.SURFACE,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            LayoutOrder = 10 + idx,
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

        -- Indica se a quest tem objetivos mapeados
        local hasMapped = QUEST_OBJECTIVES[k] ~= nil
        local questIcon = hasMapped and "⚔ " or ""

        mk("TextLabel", {
            Size = UDim2.new(1, -26, 1, 0),
            Position = UDim2.fromOffset(22, 0),
            BackgroundTransparency = 1,
            Text = questIcon .. v.label,
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
            -- Limpa anteriores
            stopStepTracking()
            questClearObjectiveMarkers()
            for _, ch in ipairs(objResultFrame:GetChildren()) do
                if not ch:IsA("UIListLayout") then ch:Destroy() end
            end

            activeKey      = k
            activeQuestKey = k
            tw(row, 0.1, {BackgroundColor3 = Color3.fromRGB(30, 50, 35)})
            dot.BackgroundColor3 = T.SUCCESS

            -- Se a quest tem etapas mapeadas, usa rastreamento automático
            if QUEST_STEPS[k] then
                startStepTracking(k)
            else
                -- Comportamento antigo: aponta só para o NPC inicial
                local obj = questResolvePath(v.path)
                if obj then
                    questApplyMarker(obj, v.label)
                    dot.BackgroundColor3 = T.SUCCESS
                    statusDot.BackgroundColor3 = T.SUCCESS
                    statusLbl.Text = v.label
                    valQuest.Text  = v.label
                    valTarget.Text = obj.Name
                    valObj.Text    = hasMapped and "Clique em 'Mostrar Objetivos'" or "Não mapeado"
                else
                    questClearMarker()
                    dot.BackgroundColor3 = T.ERR
                    statusDot.BackgroundColor3 = T.ERR
                    statusLbl.Text = "Objeto não encontrado"
                    valQuest.Text  = v.label
                    valTarget.Text = "— não encontrado —"
                    valDist.Text   = "—"
                    valObj.Text    = "—"
                    tw(row, 0.1, {BackgroundColor3 = Color3.fromRGB(50, 20, 20)})
                end
            end
        end)
    end
end

-- ══════════════════════════════════════════════════════════════════════════════
--  EXPORT  (padrão esperado pela UI.lua)
-- ══════════════════════════════════════════════════════════════════════════════
return {
    Init = function(parent, T)
        buildQuestTab(parent, T)
    end
}
