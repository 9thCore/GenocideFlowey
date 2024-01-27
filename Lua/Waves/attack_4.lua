attacks = require "attacks"
f_parry = require "f_parry"
easing = require "easing"
Encounter["wavetimer"] = 8.75
timer = 0
attacks.CreateLocket()

function Update()
	attacks.Update()

	if timer > 30 and timer < 60 then
		attacks.SetLocketAlpha(easing.Out((timer - 30) / 30), 4)
	elseif timer % 240 == 60 then
		attacks.LaunchLocket(Player.absx, Player.absy, 120)
	end

	timer = timer + 1
end

function EndingWave()
	attacks.EndingWave()
end

function OnHit(bullet)
	attacks.OnHit(bullet)
end