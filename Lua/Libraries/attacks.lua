local lib = {}
lib.anticipation = {}
lib.attacks = {}
local mask = CreateSprite("px", "BelowBullet")
mask.ypivot = 0
mask.Mask("stencil")
local timer = 0
local f_parry = require "f_parry"
local easing = require "easing"

function lib.Anticipate(x, y, warntime, event, params)
	local a = CreateSprite("attack/anticipation", "BelowBullet")
	a.SetParent(mask)
	a.x = x
	a.y = y
	a["event"] = event
	a["params"] = params or {}
	a["time"] = timer + warntime
	a["state"] = 0
	lib.anticipation[#lib.anticipation+1] = a
	return a
end

local function empty() end

local function slashupdate(s)
	local diff = s["endtime"] - timer
	local t = 1 - diff/30
	s.sprite.yscale = easing.Lerp(0, 300, easing.Out(t, 2))
	s.sprite.alpha = (math.random() * 0.5 + 0.5)*easing.Out(t, 2)
end

local function slash(x, y, rot)
	local rad = math.rad(rot + 90)
	local s = CreateProjectile("px", x + math.cos(rad) * 150, y + math.sin(rad) * 150)
	s.ppcollision = true
	s.sprite.ypivot = 1
	s.sprite.Scale(2, 0)
	s.sprite.rotation = rot
	s.sprite.SetParent(mask)
	NewAudio.PlaySound("slash", "hit4")
	s["endtime"] = timer + 30
	s["damage"] = 15
	s["update"] = slashupdate
	lib.attacks[#lib.attacks+1] = s
end

function lib.AnticipatedSlash(x, y, rot, warntime)
	local a = lib.Anticipate(x, y, warntime or 30, slash, {x, y, rot or 0})
	a.rotation = rot or 0
end

function lib.Update()
	f_parry.Update()
	mask.Scale(Arena.currentwidth, Arena.currentheight)
	mask.MoveTo(Arena.currentx, Arena.currenty)

	for i = #lib.anticipation, 1, -1 do
		local a = lib.anticipation[i]
		if a["time"] < timer then
			a["event"](table.unpack(a["params"]))
			a.Remove()
			table.remove(lib.anticipation, i)
		else
			if a["state"] == 0 and (a["time"] - timer) % 8 >= 4 then
				a["state"] = 1
				a.color = {1, 0, 0}
				NewAudio.PlaySound("warning", "menumove")
			elseif a["state"] == 1 and (a["time"] - timer) % 8 < 4 then
				a["state"] = 0
				a.color = {1, 1, 0}
				NewAudio.PlaySound("warning", "menumove")
			end
		end
	end

	for i = #lib.attacks, 1, -1 do
		local a = lib.attacks[i]
		if a["update"] then a["update"](a) end

		if a["endtime"] < timer then
			a.Remove()
			table.remove(lib.attacks, i)
		end
	end

	timer = timer + Time.timeScale
end

function lib.EndingWave()
	f_parry.EndingWave()

	for i = 1, #lib.anticipation do
		lib.anticipation[i].Remove()
	end
	lib.anticipation = {}

	for i = 1, #lib.attacks do
		lib.attacks[i].Remove()
	end
	lib.attacks = {}
end

function lib.OnHit(bullet)
	local dmg = bullet["damage"] or 4
	if f_parry.IsParrying() then
		f_parry.Parry(dmg / 2)
		for i = 1, #lib.attacks do
			if lib.attacks[i] == bullet then
				table.remove(lib.attacks, i)
				break
			end
		end
		bullet.Remove()
		return
	end

	Player.Hurt(dmg)
end

return lib