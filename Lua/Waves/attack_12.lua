attacks = require "attacks"
f_parry = require "f_parry"
easing = require "easing"
Encounter["wavetimer"] = 15
timer = 0
attacks.CreateLocket()
Arena.Resize(32, 130)

function Update()
	attacks.Update()

	if timer > 30 and timer < 60 then
		local t = easing.Out((timer - 30) / 30)
		attacks.SetLocketAlpha(t, 4)
		Audio.Volume(easing.Lerp(0.75, 0.25, t))
	elseif timer == 120 then
		Audio.PlaySound("box4")
		attacks.Musical(80, {0, 1, 1, 1, 1, 1, 0.5, 1.5, 2, 1, 1, 1, 1, 0.5, 1.5})
	end

	if timer % 480 == 240 then
		attacks.LaunchLocket(Arena.x, Player.absy, 120)
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