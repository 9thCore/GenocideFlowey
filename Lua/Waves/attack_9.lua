attacks = require "attacks"
f_parry = require "f_parry"
easing = require "easing"
Encounter["wavetimer"] = 12
timer = 0
attacks.CreateLocket()
Arena.Resize(64, 64)

function Update()
	attacks.Update()

	if timer > 30 and timer < 60 then
		local t = easing.Out((timer - 30) / 30)
		attacks.SetLocketAlpha(t, 4)
		Audio.Volume(easing.Lerp(0.75, 0.25, t))
		Arena.MoveTo(320, 90 + 66 * t, true, true)
	elseif timer == 90 then
		Audio.PlaySound("box3")
		attacks.Musical(120, {0, 1, 1, 1, 1, 1, 0.5, 1.5, 2, 1, 1, 1, 1, 0.5, 1.5})
	end

	if timer % 60 == 59 then
		attacks.AnticipatedSlash(Player.x, Player.y, math.floor(timer/60) * 180 + 90)
	end

	timer = timer + 1
end

function EndingWave()
	attacks.EndingWave()
	Audio.Volume(0.75)
end

function OnHit(bullet)
	attacks.OnHit(bullet)
end