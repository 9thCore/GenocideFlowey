attacks = require "attacks"
f_parry = require "f_parry"
easing = require "easing"
Encounter["wavetimer"] = 18
timer = 0
rot = math.pi/2
dir = 1
attacks.CreateLocket()

function Update()
	attacks.Update()

	if timer > 30 and timer < 60 then
		local t = easing.Out((timer - 30) / 30)
		attacks.SetLocketAlpha(t, 4)
		Audio.Volume(easing.Lerp(0.75, 0.25, t))
	elseif timer == 60 then
		attacks.LaunchLocket(Arena.x, Arena.y + Arena.height/2 + 4, 120, math.huge)
	elseif timer == 240 then
		Audio.PlaySound("box")
		attacks.Musical(160, {0, 1, 1, 1, 1, 1, 0.5, 1.5, 2, 1, 1, 1, 1, 0.5, 1.5, 1, 1, 1, 1, 1, 1, 0.5, 1.5, 2, 1, 1, 1, 1, 0.5, 1.5}, function()
			local x, y = math.cos(rot) * 80 * dir, math.sin(rot) * 80 * dir
			rot = rot + math.rad(10)
			dir = -dir
			return x, y
		end, 2)
	end

	if timer == 120 then
		attacks.AnticipatedSlash(0, 0)
	elseif timer == 150 then
		attacks.AnticipatedSlash(0, 0, 20)
	end

	if timer >= 600 and timer % 60 == 0 and timer < 1000 then
		attacks.AnticipatedSlash(Player.x, Player.y, math.floor(math.deg(rot)/45 + 0.5) * 45 + 45)
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