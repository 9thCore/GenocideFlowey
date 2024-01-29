attacks = require "attacks"
f_parry = require "f_parry"
easing = require "easing"
Encounter["wavetimer"] = 16
timer = 0
dir = 1
shotgunradius = math.rad(90)
attacks.CreateLocket()

function Update()
	attacks.Update()

	if timer > 30 and timer < 60 then
		local t = easing.Out((timer - 30) / 30)
		attacks.SetLocketAlpha(t, 4)
		Audio.Volume(easing.Lerp(0.75, 0.25, t))
	elseif timer == 120 then
		Audio.PlaySound("box")
		attacks.Musical(160, {0, 1, 1, 1, 1, 1, 0.5, 1.5, 2, 1, 1, 1, 1, 0.5, 1.5, 1, 1, 1, 1, 1, 1, 0.5, 1.5, 2, 1, 1, 1, 1, 0.5, 1.5}, function()
			local dx, dy = Player.absx - attacks.locket.hitbox.absx, Player.absy - attacks.locket.hitbox.absy
			local rot = math.atan2(dy, dx)
			local x, y = Player.x + math.cos(rot + dir * shotgunradius) * 30, Player.y + math.sin(rot + dir * shotgunradius) * 30
			dir = -dir
			return x, y
		end, 2)
	end

	if timer % 60 == 59 then
		attacks.AnticipatedSlash(Player.x, Player.y)
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