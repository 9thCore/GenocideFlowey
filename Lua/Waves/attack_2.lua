attacks = require "attacks"
f_parry = require "f_parry"
timer = 0
rot = 0
Encounter["wavetimer"] = 6

function Update()
	attacks.Update()

	if timer % 90 == 0 then
		attacks.AnticipatedSlash(Player.x, Player.y, rot)
		x = Player.x
		y = Player.y
	elseif timer % 90 == 20 then
		attacks.AnticipatedSlash(x + math.cos(math.rad(rot)) * 12 + math.cos(math.rad(rot + 90)) * 8, y + math.sin(math.rad(rot)) * 12 + math.sin(math.rad(rot + 90)) * 8, rot + 180)
		rot = rot + 90
	end

	timer = timer + 1
end

function EndingWave()
	attacks.EndingWave()
end

function OnHit(bullet)
	attacks.OnHit(bullet)
end