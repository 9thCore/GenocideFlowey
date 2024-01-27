attacks = require "attacks"
f_parry = require "f_parry"
easing = require "easing"
Encounter["wavetimer"] = 12
timer = 0
attacks.CreateLocket()
Arena.Resize(100, 100)
rot = 0

function Update()
	attacks.Update()

	if timer > 30 and timer < 60 then
		local t = easing.Out((timer - 30) / 30)
		attacks.SetLocketAlpha(t, 4)
		Arena.MoveTo(320, 90 + 30 * t, true, true)
	elseif timer == 60 then
		attacks.LaunchLocket(Arena.x, Arena.y + Arena.height/2 + 4, 120, math.huge)
	end

	if timer > 180 and timer % 45 == 0 then
		attacks.AnticipatedSlash(0, 0, 90 + math.deg(math.atan2(Player.y, Player.x)))
	end

	timer = timer + 1
end

function EndingWave()
	attacks.EndingWave()
end

function OnHit(bullet)
	attacks.OnHit(bullet)
end