attacks = require "attacks"
f_parry = require "f_parry"
timer = 0
Encounter["wavetimer"] = 7

function Update()
	attacks.Update()

	if timer % 120 == 0 then
		attacks.AnticipatedSlash(Player.x, Player.y, timer / 480 * 360)
	end

	timer = timer + 1
end

function EndingWave()
	attacks.EndingWave()
end

function OnHit(bullet)
	attacks.OnHit(bullet)
end