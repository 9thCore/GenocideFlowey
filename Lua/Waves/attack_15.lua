attacks = require "attacks"
f_parry = require "f_parry"
easing = require "easing"
Encounter["wavetimer"] = math.huge
heads = {"unused3", "unused4", "unused5", "unused6", "unused7", "unused"}
timer = -10
timing = 60
nexthit = 860
stage = 1
attacks.CreateLocket()
switch = 0
uicover = CreateSprite("black", "BelowBullet")
uicover.y = -160
uicover.alpha = 0

function SetStage(s)
	stage = s
	timer = 0
end

function Update()
	attacks.Update() 

	if stage == 1 then
		uicover.alpha = easing.Lerp(0, 0.5, easing.InvLerp(0, 1230, timer))

		if timer <= 50 then
			local t = easing.Out(easing.InvLerp(-10, 50, timer))
			Audio.Volume(easing.Lerp(0.75, 0, t))
		end

		if timer == 110 then
			Encounter.Call("SetHead", "human/head/unused2")
		elseif timer == 230 then
			Audio.PlaySound("seriousmode")
		elseif timer > 230 and timer <= 255 then
			local idx = math.floor(easing.Lerp(1, 6, easing.InvLerp(230, 255, timer)))
			Encounter.Call("SetHead", "human/head/" .. heads[idx])
		end

		if timer >= 240 and timer < 480 and timer % 30 == 0 then
			attacks.AnticipatedSlash(Player.x, Player.y, timer * 1.5)
		elseif timer >= 480 and timer <= 800 and timer % 20 == 0 then
			attacks.AnticipatedSlash(Player.x, Player.y, timer * 2.25)
		end

		if timer >= nexthit and timer <= 1180 then
			attacks.AnticipatedSlash(0, 0, math.deg(math.atan2(Player.y, Player.x)) + easing.Lerp(90, 270, switch))
			timing = timing - 5
			nexthit = timer + timing
			switch = 1 - switch
		end

		if timer > 1200 and timer < 1230 then
			local t = easing.Out(easing.InvLerp(1200, 1230, timer))
			attacks.SetLocketAlpha(t)
		elseif timer == 1230 then
			SetStage(2)
		end

	elseif stage == 2 then
		uicover.alpha = easing.Lerp(0.5, 1, easing.InvLerp(0, 840, timer))

		if timer % 120 == 10 then
			attacks.LaunchLocket(Player.absx, Player.absy, 60)
		end

		if timer < 480 and timer % 60 == 59 then
			attacks.AnticipatedSlash(Player.x, Player.y, (timer - 59) * 1.5)
		elseif timer >= 480 and timer < 840 and timer % 15 == 0 then
			attacks.AnticipatedSlash(0, 0, timer * 1.5 + switch * 180)
			switch = 1 - switch
		elseif timer == 840 then
			SetStage(3)
		end

	elseif stage == 3 then

		if timer < 600 and timer % 150 == 60 then
			attacks.LaunchLocket(Player.absx, Player.absy, 60)
		elseif timer >= 600 and timer % 120 == 30 then
			attacks.LaunchLocket(Player.absx, Player.absy, 60)
		end

		if timer == 30 then
			NewAudio.PlayMusic("musicbox", "memory", true)
			attacks.Musical(160, {0, 1, 1, 1, 1, 1, 0.5, 1.5, 2, 1, 1, 1, 1, 0.5, 1.5, 1, 1, 1, 1, 1, 1, 0.5, 1.5, 2, 1, 1, 1, 1, 0.5, 1.5}, nil, 1, true)
		elseif timer > 120 and timer % 45 == 0 and timer <= 630 then
			attacks.AnticipatedSlash(Player.x, Player.y, timer * 4 + 90)
		elseif timer >= 660 and timer % 30 == 0 and timer <= 900 then
			attacks.AnticipatedSlash(Player.x, Player.y, timer * 6 + 90)
		elseif timer == 901 then
			SetStage(4)
		end

	elseif stage == 4 then

		if timer >= 60 and timer % 20 == 0 then
			attacks.AnticipatedSlash(Player.x, Player.y, timer * 2.25)
		end

		if timer > 240 and timer < 1440 then
			local t = easing.In(easing.InvLerp(240, 1440, timer))
			attacks.MusicalBPM(easing.Lerp(160, 320, t))
			attacks.MusicalSpeed(easing.Lerp(1, 2, t))
			NewAudio.SetPitch("musicbox", easing.Lerp(1, 2, t))
		elseif timer == 1440 then
			SetStage(5)
		end

	elseif stage == 5 then

		if timer == 1 then
			NewAudio.Stop("musicbox")
			attacks.MusicalStop()
			attacks.SetLocketAlpha(1)
			attacks.locket.heart.StopAnimation()
			attacks.locket.heart.Set("attack/heart-2")
			front = CreateSprite("attack/heart-1", "Top")
			front.color = attacks.locket.heart.color
			front.MoveTo(attacks.locket.heart.absx, attacks.locket.heart.absy)
			frontysp = 2
			Audio.PlaySound("kaboom")
			nexthit = 510
			timing = 60
		elseif timer > 1 and timer < 120 then
			frontysp = frontysp - 0.125
			front.Move(-1, frontysp)
			front.rotation = front.rotation + 1
		elseif timer > 120 and timer < 180 then
			local t = easing.InvLerp(180, 120, timer)
			attacks.SetLocketAlpha(t)
		elseif timer == 240 then
			Audio.PlaySound("grab")
			Encounter.Call("SetLArm", {"human/arm/lhardafter", 1, 10, 36})
		elseif timer == 242 then
			Encounter.Call("SetLArm", {"human/arm/lhard2", 1, 10, 44})
		elseif timer >= 260 and timer % 10 == 0 and timer < 320 then
			Audio.PlaySound("hitsound")
			Misc.ShakeScreen(1, 1, false)
		elseif timer == 320 then
			Audio.PlaySound("hitsound")
			Audio.PlaySound("glomp")
			Encounter.Call("SetLArm", {"human/arm/lhardafter", 1, 10, 36})
		elseif timer == 322 then
			Encounter.Call("SetLArm", {"human/arm/lhardafter", 0, 10, 36})
			h = CreateSprite("human/locket/heartonly", "BelowUI")
			h.Scale(2, 2)
			h.MoveTo(350, 280)
			hy = -2
		elseif timer > 322 and timer < 480 then
			h.Move(1, hy)
			hy = hy - 0.125
			h.rotation = h.rotation + hy
		elseif timer >= nexthit and timer < 1140 then
			attacks.AnticipatedSlash(Player.x, Player.y, math.random() * 360, timing)
			if timing > 5 then
				timing = timing - 5
			end
			nexthit = timer + timing
		elseif timer == 1240 then
			attacks.EndingWave()
			uicover.Remove()
			front.Remove()
			h.Remove()
			if not GetAlMightyGlobal("genoflow_congratulations") then
				BattleDialog{
					"[novoice][waitall:2][effect:none]\"...\"",
					"[novoice][waitall:2][effect:none]\"...\"",
					"[novoice][waitall:2][effect:none]\"...\"",
					"[novoice][waitall:2][effect:none]\"Congratulations.\"",
					"[novoice][waitall:2][effect:none]\"Congratulations, Flowey.\"",
					"[novoice][waitall:2][effect:none]\"You have survived until I tired myself out.\"",
					"[novoice][waitall:2][effect:none]\"And now, I no longer have the locket.\"",
					"[novoice][waitall:2][effect:none]\"But what now?\"",
					"[novoice][waitall:2][effect:none]\"You should know best...\"",
					"[novoice][waitall:2][effect:none]\"...what will happen if you kill me.\"",
					"[novoice][waitall:2][effect:none]\"I'll just come back.\"",
					"[novoice][waitall:2][effect:none]\"I'll just come back and FIGHT you again.\"",
					"[novoice][waitall:2][effect:none]\"The show was rigged from the start.\"",
					"[novoice][waitall:2][effect:none]\"You never stood a chance.\"",
					"[novoice][func:NoDef][func:State, ACTIONSELECT][nextthisnow]"
				}
				SetAlMightyGlobal("genoflow_congratulations", true)
			else
				BattleDialog{
					"[novoice][waitall:2][effect:none]\"...\"",
					"[novoice][waitall:2][effect:none]\"Congratulations.\"",
					"[novoice][waitall:2][effect:none]\"You have 'defeated' me again.\"",
					"[novoice][waitall:2][effect:none]\"But you don't remember that, do you?\"",
					"[novoice][waitall:2][effect:none]\"Go on. Have your best shot.\"",
					"[novoice][waitall:2][effect:none]\"Just like last time.\"",
					"[novoice][func:NoDef][func:State, ACTIONSELECT][nextthisnow]"
				}
			end
		end

		Encounter.Call("GTransition", easing.In(math.min(timer/1240, 1), 3))

	end

	timer = timer + 1
end

function OnHit(bullet)
	if Player.ishurting then return end
	local dmg = bullet["damage"] or 4
	if not f_parry.IsParrying() and stage > 2 and Player.hp - dmg <= 0 then
		Player.hp = dmg+1
	end
	attacks.OnHit(bullet)
end