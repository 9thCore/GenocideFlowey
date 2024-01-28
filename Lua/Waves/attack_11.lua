attacks = require "attacks"
f_parry = require "f_parry"
easing = require "easing"
Encounter["wavetimer"] = 15
timer = 0
attacks.CreateLocket()
Arena.Resize(100, 100)
nextslash = 90
nextslasht = nextslash
rot = 0

function Update()
	attacks.Update()

	if timer > 30 and timer < 60 then
		local t = easing.Out((timer - 30) / 30)
		attacks.SetLocketAlpha(t, 4)
		Audio.Volume(easing.Lerp(0.75, 0.25, t))
		Arena.MoveTo(320, 90 + 30 * t, true, true)
	elseif timer == 90 then
		Audio.PlaySound("box")
		attacks.Musical(160, {0, 1, 1, 1, 1, 1, 0.5, 1.5, 2, 1, 1, 1, 1, 0.5, 1.5, 1, 1, 1, 1, 1, 1, 0.5, 1.5, 2, 1, 1, 1, 1, 0.5, 1.5})
	end

	if timer >= nextslasht then
		attacks.AnticipatedSlash(Player.x, Player.y, rot)
		nextslash = math.max(nextslash - 5, 40)
		nextslasht = timer + nextslash
		rot = rot - 90
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