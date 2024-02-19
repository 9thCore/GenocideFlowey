easing = require "easing"
attacks = require "attacks"
f_parry = require "f_parry"
NewAudio.CreateChannel("finale")
NewAudio.PlayMusic("finale", "finale")
NewAudio.Pause("finale")
Encounter["wavetimer"] = math.huge
timer = 0
attacktime = 0
souls = {}
Arena.outerColor = {0, 0, 0}
radius = 0
srot = -math.pi/3
musicstage = 0
nexthit = 0
fighting = false
btnanim = false
fightbtn = nil
t = Time.time
atks = {}
trytoheal = false
healing = false
healtime = 0
healtimer = 0
fnextheal = 0
stage6start = math.huge
finaleattack = 1
attackvar1 = 0
attackvar2 = 0
lastslash = 0
lastslashrot = 0
nextlaunch = 0
itembt = CreateSprite("UI/Buttons/itembt_2", "Top")
itembt.MoveTo(320, 460)
itembt.alpha = 0
healtext = CreateText("[novoice]", {0, 450}, 640)
healtext.progressmode = "none"
healtext.HideBubble()
healtext.color = {1, 1, 1, 0}
soul = CreateSprite("ut-heart", "Top")
soul.color = {1, 0, 0, 0}
soul.MoveTo(280, 460)
mask = CreateSprite("px", "Top")
mask.Mask("box")
mask.alpha = 0
mask.y = Arena.y + Arena.height/2 + 5
mask.Scale(565, Arena.height + 0.5)
attacks.CreateLocket()

local function infightbox()
	return  Player.x + 8 >= -UI.fightbtn.width/2
		and Player.x - 8 <= UI.fightbtn.width/2
		and Player.y + 16 >= -UI.fightbtn.height/2
		and Player.y - 8 <= UI.fightbtn.height/2
end

function NewFinale()
	finaleattack = math.random(1, 6)
end

function Soul(color)
	local h = CreateSprite("ut-heart", "Top")
	h.MoveTo(Arena.x, Arena.y)
	h.color = color
	h.alpha = 0
	souls[#souls+1] = h
end

Soul{0, 0, 1}
Soul{1, 0.6, 0}
Soul{0, 1, 1}
Soul{1, 1, 0}
Soul{0, 1, 0}
Soul{0.6, 0, 0.6}
f_parry.SetCooldown(60)

local function delayheal()
	healtime = timer + 120
	trytoheal = true
end

local function vine(v)
	if v["timer"] < 15 then
		local t = easing.InvLerp(0, 15, v["timer"])
		local r = easing.Lerp(400, -80, t)
		local rr = v["rr"]
		v.MoveTo(320 - math.cos(rr) * r, 290 - math.sin(rr) * r)
	elseif v["timer"] == 15 then
		if v["attack"] then
			Player.ForceAttack(1, 15)
			delayheal()
			if Encounter.Call("GetHP") <= 35 then
				Encounter.Call("SetHead", "human/head/unused8")
			end
		end
	elseif v["timer"] > 15 and v["timer"] < 60 then
		local t = easing.InvLerp(60, 45 + v["offset"], v["timer"])
		v.alpha = t
	else
		return true
	end

	v["timer"] = v["timer"] + 1
	return false
end

function Attack()
	Audio.PlaySound("yowl")
	for i = 1, 18 do
		local v = CreateSprite("attack/vine", "Top")
		local r = math.random() * 30 - 15 - 90
		local rr = math.rad(r)
		v.MoveTo(math.huge, math.huge)
		v.SetPivot(1, 0.5)
		v.rotation = r
		v["rr"] = rr
		v["func"] = vine
		v["timer"] = 0
		v["offset"] = math.random(0, 10)
		v["attack"] = (i == 1)
		atks[#atks+1] = v
	end
end

local function heal(h)
	h.Move(0, -1)
	h.sprite.rotation = h.sprite.rotation + 1
	h.x = easing.Lerp(h.x, Player.x, 0.025)

	if h.y < -Arena.height then
		return true
	end

	return false
end

function Heal(h)
	h = h or math.random(1, 6)
	local healb

	if h == 1 then
		healb = CreateProjectile("spr/bandage", 0, 65 + 34/2)
		healb.sprite.Scale(0.5, 0.5)
	elseif h == 2 then
		healb = CreateProjectile("spr/nice", 0, 65 + 36/2)
	elseif h == 3 then
		healb = CreateProjectile("spr/note", 0, 65 + 19/2)
	elseif h == 4 then
		healb = CreateProjectile("spr/hope", 0, 65 + 10/2)
	elseif h == 5 then
		healb = CreateProjectile("spr/eg", 0, 65 + 22/2)
	elseif h == 6 then
		healb = CreateProjectile("spr/utyreference", 0, 65 + 18/2)
	end
	healb.ppcollision = true
	healb.sprite.color = {0, 1, 0}
	healb["func"] = heal
	healb["heal"] = true
	healb.SetParent(mask)
	healb.x = Player.x
	atks[#atks+1] = healb
end

function Update()
	f_parry.IgnoreInput(fighting and infightbox())
	attacks.Update()

	local playtime = NewAudio.GetPlayTime("finale")

	for i = #atks, 1, -1 do
		local a = atks[i]
		if a["func"](a) then
			table.remove(atks, i)
			a.Remove()
		end
	end

	for i = 1, #souls do
		local rad = math.sin((Time.time - t) * 2) * (radius * 0.1) + radius * 0.9
		local rot = (i-1.5) * math.pi / 3 + srot
		souls[i].MoveTo(Arena.currentx + math.sin(rot) * rad, Arena.currenty + Arena.currentheight/2 + math.cos(rot) * rad)
	end

	if trytoheal and timer >= healtime then
		if Encounter.Call("IsDead") then
			EndWave()
			Encounter.Call("StartWave", {"death", math.huge})
			return
		end
		Encounter["item"], Encounter["itemheal"] = Encounter.Call("FHeal")
		if Encounter["item"] ~= nil then
			healing = true
			healtimer = 0
			healtext.SetText{"[novoice][effect:none][font:uidialog][instant]" .. Encounter["item"]}
			healtext.x = 320 - healtext.GetTextWidth()/2
		end
		trytoheal = false
	end

	if healing then
		if healtimer == 60 then
			Audio.PlaySound("menumove")
			itembt.alpha = 1
			soul.alpha = 1
		elseif healtimer == 90 then
			Audio.PlaySound("menuconfirm")
			itembt.alpha = 0
			healtext.alpha = 1
			soul.MoveTo(healtext.x - 16, 450 + healtext.GetTextHeight()/2)
		elseif healtimer == 120 then
			Audio.PlaySound("menuconfirm")
			Audio.PlaySound("healsound")
			healtext.alpha = 0
			soul.alpha = 0
			Player.ForceAttack(1, -Encounter["itemheal"])
		elseif healtimer == 240 then
			healtext.SetText{"[novoice]"}
			soul.MoveTo(280, 460)
			soul.alpha = 0
		end

		healtimer = healtimer + 1
	end

	if timer <= 15 then
		local t = easing.InvLerp(0, 15, timer)
		Arena.outerColor = {t, t, t}
	elseif timer == 120 then
		Audio.PlaySound("create")
		for i = 1, #souls do
			souls[i].alpha = 1
		end
	elseif timer <= 150 then
		local t = easing.Out(easing.InvLerp(120, 150, timer), 3)
		radius = easing.Lerp(0, 60, t)
		srot = easing.Lerp(-math.pi/3, 0, t)
	elseif timer == 210 then
		NewAudio.Unpause("finale")
		musicstage = 1
		yspd = 0
	end

	if musicstage == 1 then
		yspd = yspd - 0.025
		UI.mercybtn.y = UI.mercybtn.y + yspd * 0.9
		UI.mercybtn.rotation = UI.mercybtn.rotation + yspd * 0.25
		UI.itembtn.y = UI.itembtn.y + yspd * 1.15
		UI.itembtn.rotation = UI.itembtn.rotation - yspd * 0.82
		UI.actbtn.y = UI.actbtn.y + yspd * 0.7
		UI.actbtn.rotation = UI.actbtn.rotation + yspd * 1.31

		if playtime >= 2.522 then
			musicstage = 2
		end
	elseif musicstage == 2 then
		local t = easing.Out(easing.InvLerp(2.522, 5.06, playtime), 2)
		Encounter.Call("MovePP", {easing.Lerp(0, 200, t), 0})
		UI.fightbtn.absx = easing.Lerp(32, 320 - UI.fightbtn.width/2, t)

		if playtime >= 5.06 then
			musicstage = 3
		end
	elseif musicstage == 3 then
		local t = easing.Out(easing.InvLerp(5.06, 7.592, playtime), 2)
		Player.maxhp = easing.Lerp(100, 999, t)
		Player.hp = Player.maxhp
		UI.hpbar.Resize(easing.Lerp(120, 600, t), 20)
		UI.hpbar.background.absx = easing.Lerp(176, 20, t)
		UI.hptext.absx = easing.Lerp(310, 630 - UI.hptext.GetTextWidth(), t)
		UI.hptext.absy = easing.Lerp(63, 56 - UI.hptext.GetTextHeight(), t)
		UI.hplabel.alpha = 1 - t
		UI.namelv.absx = easing.Lerp(30, 10, t)
		UI.namelv.absy = easing.Lerp(63, 56 - UI.namelv.GetTextHeight(), t)

		if playtime >= 7.592 then
			Player.maxhp = 999
			Player.hp = 999
			UI.hpbar.Resize(600, 20)
			UI.hptext.absx = 630 - UI.hptext.GetTextWidth()
			musicstage = 4
		end
	elseif musicstage == 4 then
		local t = easing.InvLerp(7.592, 10.051, playtime)
		local t2 = easing.In(t, 3)
		local t3 = easing.Out(t, 2)
		radius = easing.Lerp(60, 600, t2)
		srot = easing.Lerp(0, 2*math.pi, t2)
		Arena.ResizeImmediate(easing.Lerp(155, 565, t3), Arena.height)
		UI.fightbtn.alpha = 1 - t3

		if playtime >= 10.051 then
			musicstage = 5
			attacktime = timer

			fightbtn = CreateSprite("UI/Buttons/fightbt_0", "BelowPlayer")
			fightbtn.MoveToAbs(Arena.x, Arena.y + Arena.height/2)
			fightbtn.alpha = 0
		end
	elseif musicstage == 5 then
		local time = timer - attacktime

		if time < 540 and time % 60 == 0 then
			attacks.AnticipatedSlash(Player.x, Player.y, time * 1.5)
		elseif time >= 540 and time % 45 == 0 then
			attacks.AnticipatedSlash(Player.x, Player.y, time * 2)
		end

		if time >= 360 and time <= 390 then
			attacks.SetLocketAlpha(easing.InvLerp(360, 390, time))
		end

		if time >= 390 and time < 870 and time % 240 == 150 then
			attacks.LaunchLocket(Player.absx, Player.absy, 120)
		elseif time >= 870 and time % 180 == 150 and time <= 2310 then
			attacks.LaunchLocket(Player.absx, Player.absy, 90)
		end

		if time == 1410 then
			attacks.Musical(160, {0, 1, 1, 1, 1, 1, 0.5, 1.5, 2, 1, 1, 1, 1, 0.5, 1.5, 1, 1, 1, 1, 1, 1, 0.5, 1.5, 2, 1, 1, 1, 1, 0.5, 1.5}, nil, 1, true)
		end

		if playtime >= 50.473 then
			attacktime = timer + 1
			stage6start = timer
			musicstage = 6
			attacks.MusicalBPM(240)
			attacks.MusicalSpeed(1.5)
			NewFinale()
			lastslash = timer
			nextlaunch = timer + 60
		end
	elseif musicstage == 6 then
		local time = timer - attacktime

		if finaleattack == 1 then
			if time == 0 then
				attacks.MusicalFunc()
			end

			if timer - lastslash >= 45 then
				attacks.AnticipatedSlash(Player.x, Player.y, lastslashrot + 90)
				lastslash = timer
				lastslashrot = lastslashrot + 90
			end

			if timer >= nextlaunch then
				attacks.LaunchLocket(Player.absx, Player.absy, 60)
				nextlaunch = timer + 120
			end

			if time == 359 then
				attacktime = timer + 1
				NewFinale()
			end
		elseif finaleattack == 2 then
			if time == 0 then
				attacks.MusicalFunc(function()
					if math.floor(attackvar1) == attackvar1 then
						attackvar2 = attackvar2 + 1/5
					end
					local r = (attackvar1 + attackvar2) * 2 * math.pi
					attackvar1 = attackvar1 + 1/4
					return math.cos(r) * 120, math.sin(r) * 120
				end, 4)
				attacks.LaunchLocket(Arena.x, Arena.y + Arena.height/2 + 5, 60, 180)
			end

			if timer - lastslash >= 60 then
				attacks.AnticipatedSlash(Player.x, Player.y, lastslashrot + 90)
				lastslash = timer
				lastslashrot = lastslashrot + 90
			end

			if time > 300 then
				attacktime = timer + 1
				NewFinale()
				attackvar1 = 0
				attackvar2 = 0
			end
		elseif finaleattack == 3 then
			if time == 0 then
				attacks.MusicalFunc(function(x, y)
					attackvar1 = attackvar1 + 1
					local r = (attackvar1*0.25 + 0.33*math.floor((attackvar1-1)*0.125))*math.pi
					return x + math.cos(r) * 45, y + math.sin(r) * 45
				end, 8)
				attacks.MusicalBPM(80)
			end

			if timer >= nextlaunch then
				attacks.LaunchLocket(Player.absx, Player.absy, 120)
				nextlaunch = timer + 240
			end

			if time == 719 then
				attacktime = timer + 1
				attackvar1 = 0
				NewFinale()
				attacks.MusicalBPM(240)
			end
		elseif finaleattack == 4 then
			if time == 0 then
				attackvar1 = -1/6
				attacks.MusicalFunc(function(x, y)
					attackvar1 = attackvar1 + 1/3
					local frac = attackvar1 - math.floor(attackvar1)
					local r = easing.Lerp(-math.pi, math.pi, frac) * 0.33 - math.pi/2
					return x + math.cos(r) * 180, y + math.sin(r) * 180
				end, 3)
			end

			if timer - lastslash >= 60 then
				attacks.AnticipatedSlash(Player.x, Player.y, lastslashrot + 45)
				lastslash = timer
				lastslashrot = lastslashrot + 90
			end

			if timer >= nextlaunch then
				attacks.LaunchLocket(Player.absx, attacks.locket.hitbox.absy, 90)
				nextlaunch = timer + 180
			end

			if time == 539 then
				attacktime = timer + 1
				attackvar1 = 0
				NewFinale()
			end
		elseif finaleattack == 5 then
			if time == 0 then
				attackvar1 = 0
				attacks.MusicalFunc(function(x, y)
					attackvar1 = attackvar1 + 1/4
					if math.floor(attackvar1) == attackvar1 then
						attackvar2 = attackvar2 + 1/5
					end
					local r = (attackvar1 + attackvar2) * 2 * math.pi
					return x + math.cos(r), y + math.sin(r)
				end, 4, function(n)
					if not n["rot"] then
						n["rot"] = math.atan2(n["ty"] - n["oy"], n["tx"] - n["ox"])
					end
					n["rot"] = n["rot"] + math.pi/480*easing.InvLerp(-480, 480, timer - attacktime)
					n["tx"] = n["ox"] + math.cos(n["rot"]) * 90
					n["ty"] = n["oy"] - math.sin(n["rot"]) * 90
				end)
			end

			if timer - lastslash >= 90 then
				attacks.AnticipatedSlash(Player.x, Player.y, lastslashrot + 90)
				lastslash = timer
				lastslashrot = lastslashrot + 90
			end

			if time == 480 then
				attacktime = timer + 1
				attackvar1 = 0
				attackvar2 = 0
				NewFinale()
			end
		elseif finaleattack == 6 then
			if time == 0 then
				attacks.MusicalFunc(nil, nil, function(n)
					if (timer - attacktime) % 60 == 0 then
						n["movetime"] = 0
						n["ox"], n["oy"] = n.x, n.y
						n["tx"], n["ty"] = Player.x, Player.y
					end
				end)
			end

			if timer - lastslash >= 60 then
				attacks.AnticipatedSlash(Player.x, Player.y, lastslashrot + 90)
				lastslash = timer
				lastslashrot = lastslashrot + 90
			end

			if time == 480 then
				attacktime = timer + 1
				NewFinale()
			end
		end
	end

	if musicstage >= 5 then
		if not fighting and timer > nexthit then
			fighting = true
			fightbtn.alpha = 1
		end

		if fighting and infightbox() then
			fightbtn.Set("UI/Buttons/fightbt_1")

			if Input.Confirm == 1 then
				Audio.PlaySound("menuconfirm")
				Attack()
				nexthit = timer + 270
				fighting = false
				fightbtn.alpha = 0
			end
		else
			fightbtn.Set("UI/Buttons/fightbt_0")
		end

		if timer > fnextheal then
			fnextheal = timer + 240
			Heal()
		end
	end

	if playtime >= 80.792 then
		NewAudio.SetPlayTime("finale", playtime - 30.316)
	end
	
	timer = timer + 1
end

function OnHit(b)
	local add = math.max(math.floor((timer - stage6start) / 120), 0)
	if b["heal"] then
		local h = math.random(60, 80) + math.min(add, 15) * 2
		Player.Heal(h)
		for i = 1, #atks do
			if atks[i] == b then
				table.remove(atks, i)
				b.Remove()
				break
			end
		end
		return
	end

	if Player.ishurting then return end
	local d = b["damage"]
	b["damage"] = d * (5 + math.floor(math.min(add/4, 5) + 0.5))
	attacks.OnHit(b)
	b["damage"] = d
end

function EndingWave()
	attacks.EndingWave()
	itembt.Remove()
	healtext.Remove()
	soul.Remove()
	mask.Remove()
	for i = 1, #atks do
		atks[i].Remove()
	end
	atks = nil
end