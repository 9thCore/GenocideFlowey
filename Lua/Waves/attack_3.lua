attacks = require "attacks"
f_parry = require "f_parry"
easing = require "easing"
Encounter["wavetimer"] = 11
timer = 0

function Update()
	attacks.Update()

	if timer >= 60 and timer < 300 and timer % 30 == 0 then
		local t = easing.InvLerp(60, 300, timer)
		local d = timer % 60
		attacks.AnticipatedSlash((d/30) * 20 - 10, -Arena.height/2 + 6 + easing.Lerp(0, Arena.height, t), 90 + d*6)
	elseif timer >= 360 and timer < 600 and timer % 20 == 0 then
		local t = easing.InvLerp(360, 600, timer)
		local d = timer % 40
		attacks.AnticipatedSlash((d/30) * 20 - 10, Arena.height/2 - 6 - easing.Lerp(0, Arena.height, t), 90 + d*9)
	end

	timer = timer + 1
end

function EndingWave()
	attacks.EndingWave()
end

function OnHit(bullet)
	attacks.OnHit(bullet)
end