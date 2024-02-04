local lib = {}

local pi2 = math.pi * 2
local time = 0

local events = {}
local spr = {}

local function lerp(a, b, t)
	return t * b + (1 - t) * a
end

local function pellet(p)
	local afktime = p["afktime"]
	if p["timer"] > afktime then
		local lt = (p["timer"] - afktime) / p["movetime"]
		p.x = lerp(p["ox"], p["tx"], lt)
		p.y = lerp(p["oy"], p["ty"], lt)
		if lt > 1 then
			return true
		end
	end

	p.rotation = math.floor(p["timer"] / 4) * 90
	p["timer"] = p["timer"] + 1
	return false
end

local function createcirclepellet(x, y, radius, angle, layer, timeoffset, afktime, movetime)
	Audio.PlaySound("chug")
	local p = CreateSprite("pellet", layer)
	p.x = x + math.cos(angle) * radius
	p.y = y + math.sin(angle) * radius
	p["ox"] = p.x; p["oy"] = p.y
	p["tx"] = x; p["ty"] = y
	p["behaviour"] = pellet
	p["timer"] = 0; p["afktime"] = afktime + timeoffset; p["movetime"] = movetime
	spr[#spr+1] = p
end

function lib.Circle(x, y, radius, count, timediff, afktime, movetime, layer)
	for i = 0, count - 1 do
		local diff = timediff or 2
		events[#events+1] = {time = time + i * diff, func = createcirclepellet, params = {x, y, radius, -(i / count - 0.25) * pi2, layer or "BelowArena", (count - i) * diff, afktime or 90, movetime or 60}}
	end
end

local function heartshard(s)
	s.x = s.x + s["xspd"] * Time.dt
	s.y = s.y + s["yspd"] * Time.dt
	s["yspd"] = s["yspd"] - 100 * Time.dt

	if s.y < 0 then return true end
	return false
end

local function shatterheart(h)
	Audio.PlaySound("heartsplosion")
	h["shattered"] = true

	for i = 1, 6 do
		local s = CreateSprite("empty", h.layer)
		s.SetAnimation({"heartshard_0", "heartshard_1", "heartshard_2", "heartshard_3"}, 1/5, "UI/Battle")
		s["behaviour"] = heartshard
		s.color = h.color
		local angle = math.random() * pi2
		s["xspd"] = math.cos(angle) * 100
		s["yspd"] = math.sin(angle) * 100
		s.MoveTo(h.x, h.y)
		spr[#spr+1] = s
	end
end

local function breakheart(h)
	h.Set("ut-heart-broken")
	Audio.PlaySound("heartbeatbreaker")
	h["broken"] = true
end

local function heart(h)
	if h["shattered"] then return true end
	if h["broken"] then return end
	h.x = h["ox"] + math.random() * 2 - 1
	h.y = h["oy"] + math.random() * 2 - 1
end

function lib.BrokenHeart(x, y, color, breaktime, shattertime, layer)
	local h = CreateSprite("ut-heart", layer or "BelowArena")
	h.MoveTo(x, y)
	h.color = color
	h["behaviour"] = heart
	h["ox"] = x; h["oy"] = y
	h["broken"] = false
	h["shattered"] = false
	events[#events+1] = {time = time + (breaktime or 120), func = breakheart, params = {h}}
	events[#events+1] = {time = time + (breaktime or 120) + (shattertime or 60), func = shatterheart, params = {h}}
	spr[#spr+1] = h
	return h
end

function lib.Update()
	for i = #events, 1, -1 do
		local e = events[i]
		if e.time <= time then
			e.func(table.unpack(e.params))
			e.params = nil
			table.remove(events, i)
		end
	end

	for i = #spr, 1, -1 do
		if spr[i]["behaviour"](spr[i]) then
			spr[i].Remove()
			table.remove(spr, i)
		end
	end

	time = time + 1
end

return lib