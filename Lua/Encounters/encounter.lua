intro = require "intro"
f_attacks = require "f_attacks"
f_anim = require "f_anim"
f_flee = require "f_flee"

NewAudio.CreateChannel("warning")
NewAudio.CreateChannel("slash")
NewAudio.CreateChannel("musicbox")

autolinebreak = true
music = "relentless_killer"
startencountertext = "[effect:none]Parry white attacks with [Z]!"
encountertext = startencountertext
playerskipdocommand = true
nextwaves = {}
wavetimer = 0
arenasize = {155, 130}
noscalerotationbug = true
flee = false
turn = 14
dead = false
f_dead = false
item = ""
itemheal = 0
ppval = 0
shakeshake = false
talked = false

-- FIRST PHASE: SURVIVAL
-- MUSIC: RELENTLESS_KILLER
-- Survive to the end of the fight
-- Killing the human results in a reload
-- Human tires themselves out
-- Flee when the human is tired and collect the 6 human souls
-- Fleeing before the end gives the human enough time to reload

-- SECOND PHASE: JUDGEMENT
-- MUSIC: FINALE
-- Checkpoint
-- Perpetual wave, similar to the Photoshop Flowey fight
-- FIGHT button appears periodically in the Arena
-- Light damage taken from human
-- Heavy damage dealt to human
-- Killing the human results in a win, as FLOWEY has more DT
-- Post second phase, a TRUE RESET can be done by FLOWEY

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

    if GetAlMightyGlobal("genoflow_skipintro") ~= true then
        Audio.Pause()
        intro.Start()
        pp.alpha = 0
        ppbar.background.x = ppbar.background.x + 300
    else
        shakeshake = true
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

function SetDialogue(...)
    enemies[1]["currentdialogue"] = {...}
    State("ENEMYDIALOGUE")
end

function Attack()
    StartWave("attacking", 999999)
end

function HealTurn()
    StartWave("heal", 5)
end

function TryHeal()
    item = enemies[1].Call("Heal")
    if item ~= nil then
        itemheal = enemies[1].Call("GetHeal", item)
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
    intro.Update()
    f_attacks.Update()
    f_anim.Update()
    f_flee.Update()

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
end

function EnemyDialogueStarting()
    if talked then return end
    if turn == 8 then
        BattleDialogue{"[effect:none]They ask why you won't die."}
        talked = true
    elseif turn == 12 then
        BattleDialogue{"[effect:none]They ask [w:4][color:ff0000][lettereffect:shake]why[w:4][speed:1][lettereffect:none][color:ffffff] you won't die."}
        talked = true
    end
end

function EnemyDialogueEnding()
    turn = turn + 1
    nextwaves = {"attack_" .. tostring(turn)}
    talked = false
end

function DefenseEnding()
    encountertext = RandomEncounterText()
    if turn == 14 then
        encountertext = "[effect:none]They seem to be preparing for something."
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
        BattleDialogue{"[noskip][effect:none][sound:runaway]You escaped...[w:30][next]"}
    end
end