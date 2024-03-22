intro = require "intro"
f_attacks = require "f_attacks"
f_anim = require "f_anim"
f_flee = require "f_flee"
intro2 = require "intro2"
name = require "name"

NewAudio.CreateChannel("warning")
NewAudio.CreateChannel("slash")
NewAudio.CreateChannel("musicbox")

autolinebreak = true
music = "relentless_killer"
startencountertext = "[effect:none]Parry white attacks with [Confirm]!"
encountertext = startencountertext
playerskipdocommand = true
nextwaves = {}
wavetimer = 0
arenasize = {155, 130}
noscalerotationbug = true
flee = false
turn = 0
dead = false
f_dead = false
item = ""
itemheal = 0
ppval = 0
shakeshake = false
talked = false
fdef = 0
naming = false
debug = false

enemies = {
    "human"
}

enemypositions = {
    {0, 0}
}

function EncounterStarting()
    fleeingspr = CreateSprite("black", "Top")
    fleeingspr.alpha = 0

    Player.name = "FLOWEY"
    Player.maxhp = 100
    Player.hp = 100
    Player.sprite.Set("f")
    Player.sprite.color = {1, 1, 1}
    Player.SetAttackAnim({}, 0)
    UI.namelv.SetText("[instant]" .. Player.name)
    Inventory.AddCustomItems({"hng"}, {0})
    Inventory.AddItem("hng")
    UI.hplabel.x = UI.hplabel.x - 100
    UI.hpbar.background.x = UI.hpbar.background.x - 100
    UI.hptext.x = UI.hptext.x - 100
    ppbar = CreateBar(510, UI.hpbar.background.absy, 100)
    ppbar.SetLerp(0, 0)
    ppbar.fill.color = {1, 0.6, 0}
    ppbar.background.color = {1, 0, 0}
    pp = CreateSprite("UI/pp")
    pp.ypivot = 0
    pp.MoveTo(492, UI.hplabel.absy)
    f_anim.Start()

    if GetAlMightyGlobal("genoflow_name") == nil then
        CopyImage("preview3", "preview")
        name.newMusic = "menu"
        name.confirmSound = "buildup"
        name.Finish = OnFinish
        naming = true
        name.Start()
    elseif GetAlMightyGlobal("genoflow_win") == true then
        encountertext = "[novoice]"
        Audio.Stop()
        StartWave("reset", math.huge)
        return
    elseif GetAlMightyGlobal("genoflow_souls") == true then
        Audio.Pause()
        shakeshake = false
        if GetAlMightyGlobal("genoflow_soulsintroskip") ~= true then
            intro2.Start()
        else
            encountertext = "[novoice]"
            StartWave("omega", math.huge)
        end
    else
        StartFightProper()
    end
end

function OnFinish()
    naming = false
    SetAlMightyGlobal("genoflow_name", name.name)
    Audio.LoadFile("relentless_killer")
    StartFightProper()
end

function StartFightProper()
    enemies[1].Call("SetName", GetAlMightyGlobal("genoflow_name"))
    if GetAlMightyGlobal("genoflow_skipintro") ~= true then
        Audio.Pause()
        intro.Start()
        pp.alpha = 0
        ppbar.background.x = ppbar.background.x + 300
    else
        shakeshake = true
    end
end

function CopyImage(src, dest)
    local status, result = pcall(Misc.OpenFile, "Sprites/" .. src .. ".png", "r")
    if status then
        Misc.OpenFile("Sprites/" .. dest .. ".png", "w").WriteBytes(result.ReadBytes())
    end
end

function StartWave(wave, timer)
    State("ACTIONSELECT")
    nextwaves = {wave}
    wavetimer = timer or 4
    State("DEFENDING")
end

function StartTutorial()
    StartWave("parry_tutorial", 999999)
end

function SetIntroSkip()
    SetAlMightyGlobal("genoflow_skipintro", true)
end

function MovePP(x, y)
    ppbar.background.MoveTo(510 + x, UI.hpbar.background.absy + y)
    pp.MoveTo(492 + x, UI.hplabel.absy + y)
end

function EndTutorial()
    SetIntroSkip()
    UI.Hide(false)
    Audio.Unpause()
    wavetimer = 0
    encountertext = startencountertext
    State("ACTIONSELECT")
    ppbar.background.x = ppbar.background.x - 300
    pp.alpha = 1
    shakeshake = true
end

function IsDead()
    return enemies[1]["hp"] < 1
end

function SetDialogue(...)
    enemies[1]["currentdialogue"] = {...}
    State("ENEMYDIALOGUE")
end

function GTransition(t)
    f_anim.GTransition(t)
end

function Attack()
    StartWave("attacking", 999999)
end

function HealTurn()
    StartWave("heal", 5)
end

function SetHead(spr)
    f_anim.h1.head.Set(spr)
end

function SetLArm(spr, a, x, y)
    f_anim.h1.arml2.alpha = a
    f_anim.h1.arml.alpha = 1-a
    f_anim.h1.locket.alpha = a
    f_anim.h1.arml2.Set(spr)
    f_anim.h1.arml2.MoveTo(x, y)
end

function GetHP()
    return enemies[1]["hp"]
end

function FHeal()
    local i = enemies[1].Call("Heal")
    if i ~= nil then
        local c = enemies[1].Call("GetHeal", i)
        return i, c
    end
    return nil, nil
end

function TryHeal()
    item, itemheal = FHeal()
    if item ~= nil then
        HealTurn()
        return true
    end
    return false
end

function TurnHeal(hp)
    Player.Heal(hp)
end

function ClampPP(pp)
    return math.max(math.min(math.floor(pp), 40), 0)
end

function AddPP(pp)
    ppval = ClampPP(ppval + pp)
    ppbar.SetLerp(ppval / 40, 30)
end

function SetPP(pp)
    ppval = ClampPP(pp)
    ppbar.SetLerp(ppval / 40, 30)
end

function GetPP()
    return ppval
end

function Update()
    if naming then
        name.Update()
        return
    end

    intro.Update()
    f_attacks.Update()
    f_anim.Update()
    f_flee.Update()
    intro2.Update()

    if shakeshake then
        Player.sprite.xpivot = 0.5 + math.random() * 1/16 - 1/32
        Player.sprite.ypivot = 0.5 + math.random() * 1/16 - 1/32
    end

    if dead then
        StartWave("death", 99)
        dead = false
    end

    if f_dead then
        StartWave("f_death", 99)
        f_dead = false
    end

    if debug then
        if Input.GetKey("S") == 1 then
            Audio.PlaySound("menuconfirm")
            DEBUG("Enabled 'genoflow_souls'!")
            SetAlMightyGlobal("genoflow_souls", true)
        elseif Input.GetKey("W") == 1 then
            Audio.PlaySound("menuconfirm")
            DEBUG("Enabled 'genoflow_win'!")
            SetAlMightyGlobal("genoflow_win", true)
        elseif Input.GetKey("I") == 1 then
            Audio.PlaySound("menuconfirm")
            DEBUG("Enabled 'genoflow_skipintro'!")
            SetAlMightyGlobal("genoflow_skipintro", true)
        end
    end
end

function EnemyDialogueStarting()
    if talked then return end
    if turn == 8 and not GetAlMightyGlobal("genoflow_talked1") then
        BattleDialogue{"[novoice][effect:none]\"Why won't you die already?\""}
        talked = true
        SetAlMightyGlobal("genoflow_talked1", true)
    elseif turn == 12 and not GetAlMightyGlobal("genoflow_talked2") then
        BattleDialogue{"[novoice][effect:none]\"[color:ff0000][lettereffect:shake]Why[w:4][lettereffect:none][color:ffffff] won't you die already?\""}
        talked = true
        SetAlMightyGlobal("genoflow_talked2", true)
    end
end

function NoDef()
    fdef = -99
end

function StartSoulFight()
    SetAlMightyGlobal("genoflow_soulsintroskip", true)
    Player.sprite.alpha = 1
    intro2.End()
    StartWave("omega", math.huge)
end

function EnemyDialogueEnding()
    if turn < 15 then
        turn = turn + 1
        nextwaves = {"attack_" .. tostring(turn)}
        talked = false
    else
        nextwaves = {}
        wavetimer = 0
    end
end

function DefenseEnding()
    encountertext = RandomEncounterText()
    if turn == 14 then
        encountertext = "[effect:shake][voice:v_flowey]" .. enemies[1]["name"] .. " seems to be preparing for something..?"
    elseif turn == 15 then
        encountertext = "[effect:shake, 0.5][voice:v_flowey]Now's my chance."
    end
end

function HandleSpare()
    State("ENEMYDIALOGUE")
end

function EnteringState(newstate, oldstate)
    if newstate == "ATTACKING" then
        Attack()
    elseif newstate == "ITEMMENU" then
        if ppval == 0 then
            BattleDialogue{"[effect:none]You tried creating green pellets.", "[effect:none]...But you did not have any PARRY POINTS."}
        else
            local diff = math.min(ppval, Player.maxhp - Player.hp)
            if diff == 0 then
                BattleDialogue{"[effect:none]You tried creating green pellets.", "[effect:none]...But you did not need any healing."}
            else
                BattleDialogue{"[effect:none]You tried creating green pellets.", "[func:TurnHeal, " .. diff .. "][effect:none]Healed " .. diff .. " HP!"}
                AddPP(-diff)
            end
        end
    elseif newstate == "MERCYMENU" then
        f_flee.Start()
        BattleDialogue{"[noskip][effect:none][sound:runaway]Escaped...[w:30][nextthisnow]"}
    end
end