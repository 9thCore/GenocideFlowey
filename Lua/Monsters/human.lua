comments = {"[voice:v_flowey][effect:shake]..."}
commands = {"Check", "Plead"}
randomdialogue = {"[nextthisnow]"}

sprite = "enemy"
name = "CHARA"
hp = 99
atk = 99
def = 0
check = "Check message goes here."
dialogbubble = "right"
canspare = false
cancheck = false
voice = "none"
dialogueprefix = "[effect:none]"
plead = 0
pleads = {
    {"[effect:none]You plead with CHARA to stop FIGHTing.", "[effect:none]...[w:4]\nBut nobody answered."},
    {"[effect:none]You remind CHARA of your fun times together.", "[effect:none]...[w:4]\nBut nobody answered."},
    {"[effect:none]You apologise for any grudges from back then.", "[effect:none]...[w:4]\nBut nobody answered."},
    {"[effect:none]You tell CHARA you will help in destroying humankind.", "[effect:none]...[w:4]\nBut nobody answered."},
    {"[effect:none]You can't think of any other topic.", "[effect:none]Seems like talking won't do any good."},
    {"[effect:none]..."}
}

items = {
    {
        name = "I. NOODLES",
        heal = 90
    },
    {
        name = "S. PIECE",
        heal = 45
    },
    {
        name = "L. HERO",
        heal = 40
    },
    {
        name = "L. HERO",
        heal = 40
    },
    {
        name = "L. HERO",
        heal = 40
    },
    {
        name = "QUICHE",
        heal = 34
    },
    {
        name = "G. BURGER",
        heal = 27
    },
    {
        name = "G. BURGER",
        heal = 27
    }
}
-- TOTAL: 343, +99 (MAX): 442

function HandleCustomCommand(command)
    if command == "CHECK" then
        BattleDialog{"[effect:none]CHARA LV 20\n..."}
    elseif command == "PLEAD" then
        plead = math.min(plead + 1, #pleads)
        BattleDialog(pleads[plead])
    end
end

function PauseMusic(pause)
    Encounter.Call("PauseMusic", pause)
end

function EndTutorial()
    Encounter.Call("EndTutorial")
end

function OnDeath()
    Encounter["dead"] = true
end

function Heal()
    if hp < 1 then return nil end
    for i = 1, #items do
        local item = items[i]
        if hp + item.heal <= maxhp then
            table.remove(items, i)
            return item.name
        end
    end
    return nil
end

function GetHeal(item)
    if item == "I. NOODLES" then return 90
    elseif item == "S. PIECE" then return 45
    elseif item == "L. HERO" then return 40
    elseif item == "QUICHE" then return 34
    elseif item == "G. BURGER" then return 27
    end
    return 0
end