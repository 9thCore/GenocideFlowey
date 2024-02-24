attacks = require "attacks"
f_parry = require "f_parry"

Player.sprite.alpha = 1
Arena.Resize(16, 110)

local passed = false
local shakemult = 0.5
local timer = 0
local fakeplayer = CreateSprite("f", "Top")
fakeplayer.Mask("invertedstencil")
local fade = CreateSprite("black", "Top")
fade.SetParent(fakeplayer)
fade.Scale(2, 2)
fade.alpha = 0
local playermimic = CreateSprite("f", "Top")
playermimic.alpha = 0
local z = CreateSprite("attack/Z", "Top")
z.MoveTo(400, 150)
z.alpha = 0
local probablyz = CreateText("[instant][font:uidialog][effect:none](probably Z)", {0, 110}, 640, "Top")
probablyz.Scale(1/2, 1/2)
probablyz.x = 400 - probablyz.GetTextWidth()/4
probablyz.progressmode = "none"
probablyz.color = {1/2, 1/2, 1/2, 0}
probablyz.HideBubble()

f_parry.SetActive(false)

function Update()
	attacks.Update()

	if not passed then
		Player.MoveTo(0, 0)
		Player.sprite.MoveTo(Player.absx + math.random(-1, 1) * shakemult, Player.absy + math.random(-1, 1) * shakemult)
		fakeplayer.MoveTo(Player.absx, Player.absy)

		if timer == 60 then
			attacks.AnticipatedSlash(Player.x, Player.y)
		elseif timer == 90 then
			NewAudio.Pause("slash")
			Time.timeScale = 0
			Player.sprite.MoveTo(Player.absx, Player.absy)
			Audio.PlaySound("snd")
			fade.alpha = 0.75
			shakemult = 0
		elseif timer > 132 and timer < 372 then
			shakemult = (timer - 132) / 240
		elseif timer == 372 then
			Audio.PlaySound("create")
		elseif timer > 372 and timer < 432 then
			local t = (timer - 372) / 60
			playermimic.xscale = 2 - (1-t)*(1-t)*(1-t)
			playermimic.yscale = playermimic.xscale
			playermimic.alpha = 1-t
			shakemult = 0
			playermimic.MoveTo(Player.absx, Player.absy)
			f_parry.SetActive(true)
		elseif timer > 612 then
			probablyz.alpha = probablyz.alpha + 1/60
		elseif timer > 492 then
			z.alpha = z.alpha + 1/60
		end

		if timer > 372 and Input.Confirm == 1 then
			if not f_parry.IsParrying() then
				f_parry.StartParry()
			end
			fade.alpha = 0
			z.alpha = 0
			probablyz.alpha = 0
			timer = -9999
			Time.timeScale = 1
			NewAudio.Unpause("slash")
			playermimic.alpha = 0
			passed = true
			timer = 0
		end

		z.xscale = 0.75 + math.sin(timer/60 * math.pi) * 0.25
		z.yscale = z.xscale
	else
		if timer == 120 then
			Encounter.Call("EndTutorial")
		end
	end

	timer = timer + 1
end

function EndingWave()
	attacks.EndingWave()
	fade.Remove()
	fakeplayer.Remove()
	z.Remove()
	probablyz.Remove()
end

function OnHit(bullet)
	attacks.OnHit(bullet)
end