attacks = require "attacks"
f_parry = require "f_parry"
easing = require "easing"
Encounter["wavetimer"] = 10.75
timer = 0
attacks.CreateLocket()
Arena.Resize(32, 130)

function Update()
	attacks.Update()

	if timer > 30 and timer <= 60 then
		attacks.SetLocketAlpha(easing.Out((timer - 30) / 30), 4)
	end

	if timer % 300 == 120 then
		attacks.LaunchLocket(Arena.x, Player.absy - 16, 120)
	end

	if timer % 120 == 60 then
		attacks.AnticipatedSlash(Player.x, Player.y)
	end

	timer = timer + 1
end

function EndingWave()
	attacks.EndingWave()
end

function OnHit(bullet)
	attacks.OnHit(bullet)
end