attacks = require "attacks"
f_parry = require "f_parry"
easing = require "easing"
Encounter["wavetimer"] = 7
timer = 0

function Update()
	attacks.Update()

	timer = timer + 1
end

function EndingWave()
	attacks.EndingWave()
end

function OnHit(bullet)
	attacks.OnHit(bullet)
end