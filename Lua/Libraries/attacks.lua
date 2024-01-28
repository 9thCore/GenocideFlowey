local lib = {}
lib.anticipation = {}
lib.attacks = {}
lib.locket = {}
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
	s["parryvalue"] = 5
	s["update"] = slashupdate
	lib.attacks[#lib.attacks+1] = s
end

function lib.AnticipatedSlash(x, y, rot, warntime)
	local a = lib.Anticipate(x, y, warntime or 30, slash, {x, y, rot or 0})
	a.rotation = rot or 0
end

function lib.CreateLocket()
	lib.locket.created = true
	lib.locket.moving = false
	lib.locket.hitbox = CreateProjectile("px", 0, 0)
	lib.locket.hitbox["damage"] = 12
	lib.locket.hitbox["unparriable"] = true
	lib.locket.hitbox.MoveToAbs(320, 300)
	lib.locket.hitbox.sprite.Scale(32, 24)
	lib.locket.hitbox.sprite.alpha = 0
	lib.locket.heart = CreateSprite("attack/heart", "BelowBullet")
	lib.locket.heart.color = {1, 0, 0, 0}
	lib.locket.heart.MoveToAbs(lib.locket.hitbox.absx, lib.locket.hitbox.absy - 4)
	lib.locket.heart.SendToBottom()
	lib.locket.startx = 320
	lib.locket.starty = 300
	lib.locket.targetx = 320
	lib.locket.targety = 300
	lib.locket.startmovetime = 0
	lib.locket.movetime = 0
	lib.locket.holdtime = 0
	lib.locket.supports = {}
	for i = -6, 6 do
		if i ~= 0 then 
			local s = CreateSprite("attack/locket", "BelowPlayer")
			s.SendToBottom()
			s.color = {0.75, 0.75, 0.75, 0}
			s["posmult"] = (math.abs(i)-1)/6
			if i < 0 then s["xpos"] = -1
			else s["xpos"] = 1
			end
			table.insert(lib.locket.supports, s)
		end
	end
	lib.locket.noteinfo = nil
	lib.locket.noteidx = 1
	lib.locket.bpm = 0
	lib.locket.musical = false
	lib.locket.musicaltimer = 0
	lib.locket.noteposfunc = nil
	lib.UpdateLocket()
end

function lib.SetLocketAlpha(alpha)
	lib.locket.heart.alpha = alpha
	for _, s in ipairs(lib.locket.supports) do
		s.alpha = alpha
	end
end

function lib.UpdateLocket()
	for _, support in ipairs(lib.locket.supports) do
		support.x = easing.Lerp(lib.locket.startx, lib.locket.hitbox.absx, support["posmult"]) + support["xpos"] * 23 * (1 - support["posmult"])
		support.y = easing.Lerp(lib.locket.starty, lib.locket.hitbox.absy, support["posmult"]) + 8
	end
end

function lib.LaunchLocket(x, y, movetime, holdtime)
	Audio.PlaySound("rise")
	lib.locket.targetx = x
	lib.locket.targety = y
	lib.locket.startmovetime = timer
	lib.locket.movetime = movetime or 60
	lib.locket.holdtime = holdtime or 0
	lib.locket.moving = true
end

local function noteupdate(n)
	local t = easing.InvLerp(n["movetime"], n["movetime"] + 120, timer)
	n.MoveTo(easing.Lerp(n["ox"], n["tx"], t) + math.random() - 0.5, easing.Lerp(n["oy"], n["ty"], t) + math.random() - 0.5)
	if n.absx + 16 < 0 or n.absx - 16 > 640 or n.absy + 16 < 0 or n.absy - 16 > 480 then
		n["endtime"] = 0
	end
end

function lib.Musical(bpm, noteinfo, noteposfunc)
	lib.locket.heart.SetAnimation({"heart2", "heart3", "heart2", "heart"}, 60/bpm, "attack")
	lib.locket.bpm = bpm
	lib.locket.noteinfo = noteinfo
	lib.locket.noteposfunc = noteposfunc or function() return Player.x, Player.y end
	lib.locket.musical = true
end

function lib.Update()
	f_parry.Update()
	mask.Scale(Arena.currentwidth, Arena.currentheight)
	mask.MoveTo(Arena.currentx, Arena.currenty)

	if lib.locket.created then
		if lib.locket.moving then
			local t = timer - lib.locket.startmovetime
			if t < lib.locket.movetime then
				local lt = easing.Out(t / lib.locket.movetime, 2)
				lib.locket.hitbox.MoveToAbs(easing.Lerp(lib.locket.startx, lib.locket.targetx, lt), easing.Lerp(lib.locket.starty, lib.locket.targety, lt))
				lib.locket.heart.MoveToAbs(lib.locket.hitbox.absx, lib.locket.hitbox.absy - 4)
			elseif t < lib.locket.movetime + lib.locket.holdtime then

			elseif t < 2 * lib.locket.movetime + lib.locket.holdtime then
				local lt = easing.In((t - lib.locket.movetime - lib.locket.holdtime) / lib.locket.movetime, 2)
				lib.locket.hitbox.MoveToAbs(easing.Lerp(lib.locket.targetx, lib.locket.startx, lt), easing.Lerp(lib.locket.targety, lib.locket.starty, lt))
				lib.locket.heart.MoveToAbs(lib.locket.hitbox.absx, lib.locket.hitbox.absy - 4)
			else
				lib.locket.moving = false
			end
			lib.UpdateLocket()
		end
		if lib.locket.musical then
			local t = lib.locket.noteinfo[lib.locket.noteidx]
			if t <= lib.locket.musicaltimer then
				local n = CreateProjectile("px", 0, 0)
				n.sprite.alpha = 0
				n.sprite.Scale(12, 12)
				local s = CreateSprite("empty")
				s.SetAnimation({"note1", "note2", "note3", "note2"}, 1/4, "attack")
				s.SetParent(n)
				s.MoveTo(0, 0)
				n.MoveToAbs(lib.locket.hitbox.absx, lib.locket.hitbox.absy)
				n["ox"] = n.x; n["oy"] = n.y
				n["tx"], n["ty"] = lib.locket.noteposfunc()
				n["update"] = noteupdate
				n["damage"] = 10
				n["parryvalue"] = 2
				n["movetime"] = timer
				n["endtime"] = math.huge
				lib.attacks[#lib.attacks+1] = n
				lib.locket.musicaltimer = 0
				lib.locket.noteidx = lib.locket.noteidx + 1
				if lib.locket.noteidx > #lib.locket.noteinfo then
					lib.locket.musical = false
				end
			end

			lib.locket.musicaltimer = lib.locket.musicaltimer + lib.locket.bpm/3600
		end
	end

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
	lib.anticipation = nil

	for i = 1, #lib.attacks do
		lib.attacks[i].Remove()
	end
	lib.attacks = nil
	if lib.locket.created then
		lib.locket.heart.Remove()
		lib.locket.hitbox.Remove()
		for _, s in ipairs(lib.locket.supports) do
			s.Remove()
		end
	end
end

function lib.OnHit(bullet)
	if Player.ishurting then return end

	local dmg = bullet["damage"] or 4
	if not bullet["unparriable"] and f_parry.IsParrying() then
		f_parry.Parry(bullet["parryvalue"] or dmg)
		for i = 1, #lib.attacks do
			if lib.attacks[i] == bullet then
				table.remove(lib.attacks, i)
				break
			end
		end
		bullet.Remove()
		return
	end

	if Player.hp - dmg <= 0 then
		Encounter["f_dead"] = true
		EndWave()
		return
	end

	Player.Hurt(dmg)
end

return lib