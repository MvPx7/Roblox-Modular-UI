-- Modules/QuestTab.lua  v2.0
-- Visual redesenhado + mesma lógica funcional preservada
-- ══════════════════════════════════════════════════════════════════════════════

local Players = game:GetService("Players")
local LP      = Players.LocalPlayer

-- ══════════════════════════════════════════════════════════════════════════════
--  MAPA DE QUESTS (preservado integralmente)
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
    ["NebukaiVillage"]    = { path = "Workspace.Debris.NebukaiVillageMarker",                          label = "Nebukai Village" },
    ["BatQuest"]          = { path = "Workspace.Debris.BatQuestMarker",                                label = "Bat Location" },
}

-- ══════════════════════════════════════════════════════════════════════════════
--  OBJETIVOS (preservado integralmente)
-- ══════════════════════════════════════════════════════════════════════════════
local QUEST_OBJECTIVES = {
    ["KillMenos"]         = {{ type="kill",    names={"Menos","GrandFisher","Hollow"},      hint="Mate os Menos na área" }},
    ["GreyHunter"]        = {{ type="kill",    names={"Wolf","GreyWolf","Hunter"},           hint="Mate os lobos cinza" }},
    ["InvasionOutskirts"] = {{ type="kill",    names={"InvasionEnemy","Invader"},            hint="Elimine os invasores" }},
    ["Dragonfly"]         = {{ type="kill",    names={"Dragonfly","GiantDragonfly"},         hint="Mate as libélulas" }},
    ["SparringArena"]     = {{ type="kill",    names={"SparringDummy","TrainingDummy"},      hint="Derrote os dummies na arena" }},
    ["Ointment"]          = {{ type="collect", names={"Herb","OintmentHerb","Plant"},        hint="Colete as ervas medicinais" }},
    ["SpiritAlloy"]       = {{ type="collect", names={"SpiritOre","AlloyOre","Ore"},         hint="Colete minério de Spirit Alloy" }},
    ["Necklace"]          = {{ type="collect", names={"Necklace","LostNecklace"},            hint="Encontre e colete o colar" }},
    ["Shipment"]          = {{ type="collect", names={"Shipment","Package","Crate"},         hint="Colete os pacotes do carregamento" }},
    ["MissingParty"]      = {
        { type="kill",    names={"MissingMember","Enemy"},         hint="Resgate/elimine ameaças ao grupo" },
        { type="collect", names={"Survivor","SurvivorItem"},       hint="Encontre sobreviventes" },
    },
    ["BatHollow"]         = {{ type="kill",    names={"Bat","BatCreature","HollowBat"},      hint="Mate os morcegos no hollow" }},
    ["MaskedWarrior"]     = {{ type="kill",    names={"MaskedWarrior","MaskedEnemy"},        hint="Derrote o Guerreiro Mascarado" }},
    ["CapturePoint"]      = {{ type="kill",    names={"Defender","CaptureEnemy"},            hint="Elimine defensores do ponto" }},
    ["Scorpion"]          = {{ type="kill",    names={"Scorpion","GiantScorpion"},           hint="Mate o escorpião na localização" }},
    ["Mantis"]            = {{ type="kill",    names={"Mantis","GiantMantis"},               hint="Mate o louva-a-deus" }},
    ["Lizard"]            = {{ type="kill",    names={"Lizard","GiantLizard"},               hint="Mate o lagarto na localização" }},
}

-- ══════════════════════════════════════════════════════════════════════════════
--  ETAPAS (preservado integralmente)
-- ══════════════════════════════════════════════════════════════════════════════
local QUEST_STEPS = {
    ["Necklace"] = {
        { stepId=1, label="Necklace Location", hint="Encontre e colete o colar",    type="collect", path="Workspace.Debris.NecklaceMarker", names={"NecklaceMarker","Necklace","LostNecklace"} },
        { stepId=2, label="Return to Niklo",   hint="Retorne ao Niklo com o colar", type="return",  names={"Niklo"} },
    },
    ["Lizard"] = {
        { stepId=1, label="Lizard Location",       hint="Encontre e mate o lagarto", type="kill",   path="Workspace.Debris.LizardQuestMarker", names={"LizardQuestMarker","Lizard","GiantLizard"} },
        { stepId=2, label="Return to Quest Giver", hint="Retorne ao NPC de quest",   type="return", names={"QuestGiver","NPC"} },
    },
}

-- ══════════════════════════════════════════════════════════════════════════════
--  LÓGICA (preservada integralmente da v1.0)
-- ══════════════════════════════════════════════════════════════════════════════
local function detectQuestStep(questKey)
    if questKey == "Necklace" then
        local marker = workspace:FindFirstChild("Debris") and workspace.Debris:FindFirstChild("NecklaceMarker")
        if not marker then return 2 end
        return 1
    end
    local function tryReadStep(container)
        if not container then return nil end
        local attr = container:GetAttribute(questKey.."_step") or container:GetAttribute(questKey.."Step") or container:GetAttribute(questKey)
        if attr and type(attr)=="number" then return attr end
        local child = container:FindFirstChild(questKey.."_step") or container:FindFirstChild(questKey.."Step") or container:FindFirstChild(questKey)
        if child and (child:IsA("NumberValue") or child:IsA("IntValue")) then return child.Value end
        if child and child:IsA("StringValue") then return tonumber(child.Value) end
        return nil
    end
    for _, loc in ipairs({LP:FindFirstChild("QuestData"),LP:FindFirstChild("PlayerData"),LP:FindFirstChild("Quests"),LP:FindFirstChild("Data"),LP:FindFirstChild("leaderstats")}) do
        local s = tryReadStep(loc)
        if s then return s end
    end
    return 1
end

local QuestState = { activeHighlight=nil, activeBillboard=nil, targetObj=nil, objectiveMarkers={} }

local function questResolvePath(pathStr)
    local obj = game
    for _, part in ipairs(string.split(pathStr,".")) do
        obj = obj:FindFirstChild(part)
        if not obj then return nil end
    end
    return obj
end

local function questGetRootPart(obj)
    if not obj then return nil end
    if obj:IsA("Model") then return obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart") end
    if obj:IsA("BasePart") then return obj end
    return nil
end

local function questClearMarker()
    if QuestState.activeHighlight then QuestState.activeHighlight:Destroy(); QuestState.activeHighlight=nil end
    if QuestState.activeBillboard then QuestState.activeBillboard:Destroy(); QuestState.activeBillboard=nil end
    QuestState.targetObj = nil
end

local function questClearObjectiveMarkers()
    for _, m in ipairs(QuestState.objectiveMarkers) do
        if m.highlight and m.highlight.Parent then m.highlight:Destroy() end
        if m.billboard and m.billboard.Parent then m.billboard:Destroy() end
    end
    QuestState.objectiveMarkers = {}
end

local function questApplyMarker(obj, label)
    questClearMarker()
    local root = questGetRootPart(obj) or obj
    if not root then return end
    QuestState.targetObj = obj
    local hl = Instance.new("Highlight")
    hl.FillColor=Color3.fromRGB(255,200,0); hl.OutlineColor=Color3.fromRGB(255,255,255)
    hl.FillTransparency=0.5; hl.OutlineTransparency=0
    hl.Adornee=root; hl.Parent=root
    QuestState.activeHighlight=hl
    local bb = Instance.new("BillboardGui")
    bb.Size=UDim2.fromOffset(180,50); bb.StudsOffset=Vector3.new(0,3,0)
    bb.AlwaysOnTop=true; bb.Adornee=root; bb.Parent=root
    QuestState.activeBillboard=bb
    local bg=Instance.new("Frame",bb); bg.Size=UDim2.fromScale(1,1)
    bg.BackgroundColor3=Color3.fromRGB(12,12,18); bg.BackgroundTransparency=0.3
    local c=Instance.new("UICorner",bg); c.CornerRadius=UDim.new(0,6)
    local tl=Instance.new("TextLabel",bg); tl.Size=UDim2.new(1,-8,0.6,0); tl.Position=UDim2.fromOffset(4,3)
    tl.BackgroundTransparency=1; tl.Text=label or obj.Name; tl.TextColor3=Color3.fromRGB(255,230,80)
    tl.Font=Enum.Font.GothamBold; tl.TextSize=13; tl.TextXAlignment=Enum.TextXAlignment.Center
    local dl=Instance.new("TextLabel",bg); dl.Name="DistLabel"
    dl.Size=UDim2.new(1,-8,0.4,0); dl.Position=UDim2.new(0,4,0.6,0)
    dl.BackgroundTransparency=1; dl.Text="..."; dl.TextColor3=Color3.fromRGB(180,180,220)
    dl.Font=Enum.Font.Gotham; dl.TextSize=11; dl.TextXAlignment=Enum.TextXAlignment.Center
    task.spawn(function()
        while QuestState.activeBillboard and QuestState.activeBillboard.Parent do
            local char=LP.Character
            if char then
                local hrp=char:FindFirstChild("HumanoidRootPart"); local rp=questGetRootPart(obj)
                if hrp and rp then dl.Text=math.floor((hrp.Position-rp.Position).Magnitude).." studs" end
            end
            task.wait(0.15)
        end
    end)
end

local function questApplyObjectiveMarker(obj, lbl, objType)
    local root=questGetRootPart(obj) or obj; if not root then return end
    local fc = objType=="kill" and Color3.fromRGB(220,50,50) or Color3.fromRGB(50,220,100)
    local oc = objType=="kill" and Color3.fromRGB(255,120,120) or Color3.fromRGB(120,255,160)
    local hl=Instance.new("Highlight"); hl.FillColor=fc; hl.OutlineColor=oc
    hl.FillTransparency=0.45; hl.OutlineTransparency=0; hl.Adornee=root; hl.Parent=root
    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.fromOffset(160,44)
    bb.StudsOffset=Vector3.new(0,3.5,0); bb.AlwaysOnTop=true; bb.Adornee=root; bb.Parent=root
    local bg=Instance.new("Frame",bb); bg.Size=UDim2.fromScale(1,1)
    bg.BackgroundColor3=Color3.fromRGB(8,8,14); bg.BackgroundTransparency=0.3
    local c=Instance.new("UICorner",bg); c.CornerRadius=UDim.new(0,5)
    local icon=objType=="kill" and "⚔ " or "◈ "
    local tl=Instance.new("TextLabel",bg); tl.Size=UDim2.new(1,-6,0.6,0); tl.Position=UDim2.fromOffset(3,2)
    tl.BackgroundTransparency=1; tl.Text=icon..lbl
    tl.TextColor3=objType=="kill" and Color3.fromRGB(255,130,130) or Color3.fromRGB(130,255,170)
    tl.Font=Enum.Font.GothamBold; tl.TextSize=11; tl.TextXAlignment=Enum.TextXAlignment.Center; tl.TextTruncate=Enum.TextTruncate.AtEnd
    local dl=Instance.new("TextLabel",bg); dl.Size=UDim2.new(1,-6,0.4,0); dl.Position=UDim2.new(0,3,0.6,0)
    dl.BackgroundTransparency=1; dl.Text="..."; dl.TextColor3=Color3.fromRGB(160,160,200)
    dl.Font=Enum.Font.Gotham; dl.TextSize=10; dl.TextXAlignment=Enum.TextXAlignment.Center
    task.spawn(function()
        while bb and bb.Parent do
            local char=LP.Character
            if char then
                local hrp=char:FindFirstChild("HumanoidRootPart"); local rp=questGetRootPart(obj)
                if hrp and rp then dl.Text=math.floor((hrp.Position-rp.Position).Magnitude).." studs" end
            end
            task.wait(0.2)
        end
    end)
    table.insert(QuestState.objectiveMarkers,{highlight=hl,billboard=bb})
    return hl,bb
end

local function findObjectivesInWorkspace(nameList)
    local found = {}
    local searchRoots = {workspace}
    for _, name in ipairs({"NPCs","Mobs","Enemies","Items","Collectibles","Map","World","Debris"}) do
        local f=workspace:FindFirstChild(name); if f then table.insert(searchRoots,f) end
    end
    for _, root in ipairs(searchRoots) do
        for _, child in ipairs(root:GetDescendants()) do
            for _, targetName in ipairs(nameList) do
                if child.Name:lower():find(targetName:lower()) then
                    local valid = (child:IsA("Model") and child:FindFirstChildOfClass("Humanoid")) or child:IsA("BasePart") or child:IsA("Model")
                    if valid then
                        local dup=false
                        for _,r in ipairs(found) do if r.obj==child then dup=true;break end end
                        if not dup then table.insert(found,{obj=child,name=child.Name}) end
                    end
                end
            end
        end
    end
    return found
end

-- ══════════════════════════════════════════════════════════════════════════════
--  HELPERS DE UI
-- ══════════════════════════════════════════════════════════════════════════════
local function mk(cls, props, parent)
    local o=Instance.new(cls)
    for k,v in pairs(props) do o[k]=v end
    if parent then o.Parent=parent end
    return o
end
local function corner(p,r) mk("UICorner",{CornerRadius=r or UDim.new(0,8)},p) end
local function tw(obj,t,props) game:GetService("TweenService"):Create(obj,TweenInfo.new(t,Enum.EasingStyle.Quad),props):Play() end

-- ══════════════════════════════════════════════════════════════════════════════
--  BUILD
-- ══════════════════════════════════════════════════════════════════════════════
local function buildQuestTab(parent, T)
    T.FONTB  = T.FONTB  or Enum.Font.GothamBold
    T.FONT   = T.FONT   or Enum.Font.GothamMedium
    T.MUTED  = T.MUTED  or T.SUBTEXT or Color3.fromRGB(120,120,140)
    T.ACCENT = T.ACCENT or Color3.fromRGB(99,102,241)
    T.TEXT   = T.TEXT   or Color3.new(1,1,1)
    T.SURFACE= T.SURFACE or Color3.fromRGB(20,20,30)
    T.BORDER = T.BORDER  or Color3.fromRGB(35,35,55)
    T.ERR    = T.ERR     or Color3.fromRGB(220,60,60)
    T.SUCCESS= T.SUCCESS or Color3.fromRGB(80,220,130)
    T.WARN   = T.WARN    or Color3.fromRGB(255,190,60)

    local scroll = mk("ScrollingFrame",{
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1, BorderSizePixel=0,
        ScrollBarThickness=3, ScrollBarImageColor3=T.ACCENT,
        CanvasSize=UDim2.new(), AutomaticCanvasSize=Enum.AutomaticSize.Y, Parent=parent,
    })
    mk("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),PaddingBottom=UDim.new(0,8),Parent=scroll})
    mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,5),Parent=scroll})

    -- ── Card de status da quest ativa ─────────────────────────────────────────
    local card = mk("Frame",{Size=UDim2.new(1,0,0,72),BackgroundColor3=Color3.fromRGB(16,16,26),
        BorderSizePixel=0,LayoutOrder=0,Parent=scroll})
    corner(card)
    mk("UIStroke",{Color=T.BORDER,Thickness=1,Parent=card})

    -- ícone de status
    local statusDot = mk("Frame",{Size=UDim2.fromOffset(10,10),Position=UDim2.fromOffset(12,12),
        BackgroundColor3=T.MUTED,BorderSizePixel=0,Parent=card})
    corner(statusDot,UDim.new(1,0))
    local statusLbl = mk("TextLabel",{Size=UDim2.new(1,-40,0,16),Position=UDim2.fromOffset(28,10),
        BackgroundTransparency=1,Text="Nenhuma quest ativa",TextColor3=T.MUTED,
        Font=T.FONTB,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,Parent=card})

    -- linha divisória interna
    mk("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.fromOffset(10,30),
        BackgroundColor3=T.BORDER,BorderSizePixel=0,Parent=card})

    -- info grid: alvo + distância
    local function infoCell(xPos, labelTxt, defaultVal)
        local col = mk("Frame",{Size=UDim2.fromOffset(148,36),Position=UDim2.fromOffset(xPos,35),
            BackgroundTransparency=1,Parent=card})
        mk("TextLabel",{Size=UDim2.new(1,0,0,14),BackgroundTransparency=1,Text=labelTxt,
            TextColor3=T.MUTED,Font=T.FONT,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,Parent=col})
        local val=mk("TextLabel",{Size=UDim2.new(1,0,0,18),Position=UDim2.fromOffset(0,14),
            BackgroundTransparency=1,Text=defaultVal or "—",TextColor3=T.TEXT,
            Font=T.FONTB,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,
            TextTruncate=Enum.TextTruncate.AtEnd,Parent=col})
        return val
    end
    local valTarget = infoCell(12, "ALVO", "—")
    local valDist   = infoCell(170, "DISTÂNCIA", "—")

    -- ── Botões de ação ────────────────────────────────────────────────────────
    local function actionBtn(order, txt, color)
        local btn=mk("TextButton",{Size=UDim2.new(1,0,0,32),BackgroundColor3=color,
            Text=txt,TextColor3=T.TEXT,Font=T.FONTB,TextSize=12,
            BorderSizePixel=0,AutoButtonColor=false,LayoutOrder=order,Parent=scroll})
        corner(btn,UDim.new(0,7))
        btn.MouseEnter:Connect(function() tw(btn,0.1,{BackgroundTransparency=0.25}) end)
        btn.MouseLeave:Connect(function() tw(btn,0.1,{BackgroundTransparency=0}) end)
        return btn
    end

    local btnObjectives = actionBtn(1, "⚔  Mostrar Objetivos", Color3.fromRGB(45,90,190))
    local btnClear      = actionBtn(2, "✕  Limpar Marcadores", Color3.fromRGB(130,35,35))

    -- Painel de objetivos encontrados
    local objPanel = mk("Frame",{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,LayoutOrder=3,Parent=scroll})
    mk("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,3),Parent=objPanel})

    -- ── Separador + título da lista ───────────────────────────────────────────
    mk("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.BORDER,BorderSizePixel=0,LayoutOrder=4,Parent=scroll})
    mk("TextLabel",{Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,
        Text="QUESTS DISPONÍVEIS",TextColor3=T.MUTED,Font=T.FONTB,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left,LayoutOrder=5,Parent=scroll})

    -- ── Ordena ───────────────────────────────────────────────────────────────
    local sortedQuests = {}
    for k,v in pairs(QUEST_MAP) do table.insert(sortedQuests,{key=k,data=v}) end
    table.sort(sortedQuests, function(a,b) return a.data.label < b.data.label end)

    local activeKey, activeQuestKey = nil, nil

    local stepTrackKey, stepTrackStep = nil, nil

    local function stopStepTracking()
        stepTrackKey = nil; stepTrackStep = nil
    end

    local function clearAll()
        stopStepTracking()
        questClearMarker(); questClearObjectiveMarkers()
        activeKey=nil; activeQuestKey=nil
        statusDot.BackgroundColor3=T.MUTED; statusLbl.Text="Nenhuma quest ativa"
        valTarget.Text="—"; valDist.Text="—"
        for _,ch in ipairs(objPanel:GetChildren()) do
            if not ch:IsA("UIListLayout") then ch:Destroy() end
        end
    end

    -- Loop de distância central
    task.spawn(function()
        while parent.Parent do
            if QuestState.targetObj then
                local char=LP.Character
                if char then
                    local hrp=char:FindFirstChild("HumanoidRootPart")
                    local rp=questGetRootPart(QuestState.targetObj)
                    if hrp and rp then
                        valDist.Text=math.floor((hrp.Position-rp.Position).Magnitude).." studs"
                    end
                end
            end
            task.wait(0.2)
        end
    end)

    local function applyStepMarker(qKey, stepNum)
        local steps=QUEST_STEPS[qKey]; if not steps then return false end
        local step=steps[stepNum] or steps[1]; if not step then return false end
        questClearMarker(); questClearObjectiveMarkers()
        local obj = step.path and questResolvePath(step.path)
        if not obj and step.names then
            local found=findObjectivesInWorkspace(step.names)
            if #found>0 then obj=found[1].obj end
        end
        if obj then
            questApplyMarker(obj, step.label)
            valTarget.Text=obj.Name; valDist.Text="calculando..."
            statusLbl.Text=step.hint
            statusDot.BackgroundColor3=stepNum==1 and T.SUCCESS or Color3.fromRGB(255,165,0)
        else
            questClearMarker()
            valTarget.Text="⚠ "..(step.names and step.names[1] or "?").." não encontrado"
            valDist.Text="—"; statusLbl.Text="⚠ "..step.hint.." (alvo não localizado)"
            statusDot.BackgroundColor3=T.ERR
        end
        statusLbl.Text=step.hint
        return true
    end

    local function startStepTracking(qKey)
        stopStepTracking()
        if not QUEST_STEPS[qKey] then return end
        stepTrackKey=qKey
        local last=detectQuestStep(qKey)
        applyStepMarker(qKey,last); stepTrackStep=last
        task.spawn(function()
            while stepTrackKey==qKey and parent.Parent do
                task.wait(1)
                if stepTrackKey~=qKey then break end
                local new=detectQuestStep(qKey)
                if new~=stepTrackStep then
                    stepTrackStep=new; applyStepMarker(qKey,new)
                    statusDot.BackgroundColor3=Color3.fromRGB(255,220,0)
                    task.wait(0.5)
                    statusDot.BackgroundColor3=new==1 and T.SUCCESS or Color3.fromRGB(255,165,0)
                end
            end
        end)
    end

    local function showObjectives(qKey)
        for _,ch in ipairs(objPanel:GetChildren()) do
            if not ch:IsA("UIListLayout") then ch:Destroy() end
        end
        questClearObjectiveMarkers()
        local objectives=QUEST_OBJECTIVES[qKey]
        if not objectives then
            local w=mk("Frame",{Size=UDim2.new(1,0,0,34),BackgroundColor3=Color3.fromRGB(38,28,8),
                BorderSizePixel=0,LayoutOrder=1,Parent=objPanel})
            corner(w,UDim.new(0,6))
            mk("TextLabel",{Size=UDim2.new(1,-12,1,0),Position=UDim2.fromOffset(6,0),
                BackgroundTransparency=1,Text="⚠ Objetivos não mapeados para esta quest",
                TextColor3=T.WARN,Font=T.FONT,TextSize=10,TextWrapped=true,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=w})
            return
        end
        local totalFound=0; local idx=0
        for _,objDef in ipairs(objectives) do
            local found=findObjectivesInWorkspace(objDef.names)
            idx+=1
            -- cabeçalho do objetivo
            local hdr=mk("Frame",{Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,LayoutOrder=idx,Parent=objPanel})
            local hc=objDef.type=="kill" and Color3.fromRGB(255,130,130) or Color3.fromRGB(130,255,170)
            mk("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
                Text=(objDef.type=="kill" and "⚔ " or "◈ ")..objDef.hint,
                TextColor3=hc,Font=T.FONTB,TextSize=10,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=hdr})
            if #found==0 then
                idx+=1
                mk("TextLabel",{Size=UDim2.new(1,0,0,16),BackgroundTransparency=1,
                    Text="   Nenhum encontrado no momento",TextColor3=T.MUTED,
                    Font=T.FONT,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,
                    LayoutOrder=idx,Parent=objPanel})
            else
                for _,r in ipairs(found) do
                    totalFound+=1; questApplyObjectiveMarker(r.obj,r.name,objDef.type)
                    idx+=1
                    local row=mk("Frame",{Size=UDim2.new(1,0,0,22),LayoutOrder=idx,
                        BackgroundColor3=objDef.type=="kill" and Color3.fromRGB(38,10,10) or Color3.fromRGB(10,38,18),
                        BackgroundTransparency=0.25,BorderSizePixel=0,Parent=objPanel})
                    corner(row,UDim.new(0,5))
                    mk("TextLabel",{Size=UDim2.new(1,-10,1,0),Position=UDim2.fromOffset(8,0),
                        BackgroundTransparency=1,Text="· "..r.name,TextColor3=T.TEXT,
                        Font=T.FONT,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,
                        TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})
                end
            end
        end
    end

    btnObjectives.Activated:Connect(function()
        if not activeQuestKey then
            statusLbl.Text="Selecione uma quest primeiro!"
            statusDot.BackgroundColor3=T.WARN; return
        end
        showObjectives(activeQuestKey)
        statusDot.BackgroundColor3=T.ACCENT
    end)
    btnClear.Activated:Connect(clearAll)

    -- ── Lista de quests ───────────────────────────────────────────────────────
    for idx, entry in ipairs(sortedQuests) do
        local k, v = entry.key, entry.data
        local hasMapped = QUEST_OBJECTIVES[k] ~= nil
        local hasSteps  = QUEST_STEPS[k] ~= nil

        local row = mk("TextButton",{Size=UDim2.new(1,0,0,28),
            BackgroundColor3=T.SURFACE,Text="",BorderSizePixel=0,
            AutoButtonColor=false,LayoutOrder=10+idx,Parent=scroll})
        corner(row,UDim.new(0,6))
        mk("UIStroke",{Color=T.BORDER,Thickness=1,Parent=row})

        local dot=mk("Frame",{Size=UDim2.fromOffset(6,6),Position=UDim2.new(0,9,0.5,-3),
            BackgroundColor3=T.MUTED,BorderSizePixel=0,Parent=row})
        corner(dot,UDim.new(1,0))

        -- badges: ⚔ = tem objetivos, ↪ = tem etapas
        local badge = (hasSteps and "↪ " or "") .. (hasMapped and "⚔ " or "")
        mk("TextLabel",{Size=UDim2.new(1,-28,1,0),Position=UDim2.fromOffset(22,0),
            BackgroundTransparency=1,Text=badge..v.label,TextColor3=T.TEXT,
            Font=T.FONT,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,
            TextTruncate=Enum.TextTruncate.AtEnd,Parent=row})

        row.MouseEnter:Connect(function()
            if activeKey~=k then tw(row,0.1,{BackgroundColor3=T.BORDER}) end end)
        row.MouseLeave:Connect(function()
            if activeKey~=k then tw(row,0.1,{BackgroundColor3=T.SURFACE}) end end)

        row.Activated:Connect(function()
            stopStepTracking(); questClearObjectiveMarkers()
            for _,ch in ipairs(objPanel:GetChildren()) do
                if not ch:IsA("UIListLayout") then ch:Destroy() end
            end
            activeKey=k; activeQuestKey=k
            tw(row,0.1,{BackgroundColor3=Color3.fromRGB(25,42,32)})
            dot.BackgroundColor3=T.SUCCESS

            if QUEST_STEPS[k] then
                startStepTracking(k)
                statusLbl.Text=v.label
                statusDot.BackgroundColor3=T.SUCCESS
            else
                local obj=questResolvePath(v.path)
                if obj then
                    questApplyMarker(obj,v.label)
                    valTarget.Text=obj.Name; valDist.Text="calculando..."
                    statusLbl.Text=v.label; statusDot.BackgroundColor3=T.SUCCESS
                else
                    questClearMarker()
                    dot.BackgroundColor3=T.ERR; statusDot.BackgroundColor3=T.ERR
                    statusLbl.Text="Objeto não encontrado"
                    valTarget.Text="— não encontrado —"; valDist.Text="—"
                    tw(row,0.1,{BackgroundColor3=Color3.fromRGB(42,16,16)})
                end
            end
        end)
    end

    -- Cleanup ao fechar UI
    if UI_REGISTRY then
        UI_REGISTRY.onClose(function()
            stopStepTracking()
            questClearMarker()
            questClearObjectiveMarkers()
        end)
    end
end

return {
    Init = function(parent, T)
        buildQuestTab(parent, T)
    end
}
