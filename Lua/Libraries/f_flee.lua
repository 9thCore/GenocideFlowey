local lib = {}
lib.active = false
lib.timer = 0
lib.cover = nil
lib.bg = nil
lib.fg = nil
lib.canisters = {}
lib.circle = {x = 320, y = 240, r = 0, rad = 80}
local easing = require "easing"

function lib.Canister(x, y, color)
	local c = CreateSprite("canister", "BarrierTop")
	c.Scale(4, 4)
	c.MoveTo(x, y)
	c.color = color
	c.alpha = 0

	local h = CreateSprite("ut-heart", "HeartBarrierTop")
	h.Scale(2, 2)
	h.MoveTo(c.x - 1.5, 1)
	h.color = color
	h.alpha = 0

	lib.canisters[#lib.canisters+1] = {c = c, h = h, r = #lib.canisters * math.pi / 3}
end

function lib.Start()
	CreateLayer("BarrierTop", "Top")
	CreateLayer("HeartBarrierTop", "BarrierTop")
	CreateLayer("CoverBarrierTop", "HeartBarrierTop")

	lib.bg = CreateSprite("black", "BarrierTop")
	lib.bg.alpha = 0

	lib.Canister(270, 280, {1, 0.6, 0})
	lib.Canister(370, 280, {0.6, 0, 0.6})
	lib.Canister(150, 250, {1, 1, 0})
	lib.Canister(490, 250, {0, 0, 1})
	lib.Canister(75, 220, {0, 1, 0})
	lib.Canister(565, 220, {0, 1, 1})

	lib.cover = CreateSprite("black", "CoverBarrierTop")
	lib.cover.alpha = 0
	lib.active = true

	lib.fg = CreateSprite("px", "CoverBarrierTop")
	lib.fg.Scale(640, 480)
	lib.fg.alpha = 0
end

function lib.Update()
	if not lib.active then return end

	if lib.timer < 120 then
		lib.cover.alpha = lib.timer / 120
	elseif lib.timer == 120 then
		lib.cover.alpha = 1
		Audio.Pause()
		State("NONE")

		for i = 1, #lib.canisters do
			lib.canisters[i].c.alpha = 1
			lib.canisters[i].h.alpha = 1
		end
	elseif lib.timer < 240 then
		lib.bg.alpha = 1
		lib.cover.alpha = 1 - (lib.timer - 120) / 120
	elseif lib.timer > 300 and lib.timer < 420 then
		for i = 1, #lib.canisters do
			lib.canisters[i].h.y = lib.canisters[i].c.y + 1 + 100 * (lib.timer - 300) / 120
		end
	elseif lib.timer == 480 then
		Audio.PlaySound("buildup")
	elseif lib.timer > 480 and lib.timer < 480 + 5 * 60 then
		local t = (lib.timer - 480) / (5*60)
		local t2 = math.min((lib.timer - 480) / 120, 1)
		lib.circle.r = t*t*t * 16 * math.pi
		for i = 1, #lib.canisters do
			local lc = lib.canisters[i]
			local r = lib.circle.r + lc.r
			lc.h.MoveToAbs(
				easing.Lerp(lc.c.x, lib.circle.x + math.cos(r) * lib.circle.rad, easing.InOut(t2)),
				easing.Lerp(lc.c.y + 101, lib.circle.y + math.sin(r) * lib.circle.rad, easing.InOut(t2))
			)
		end
		lib.fg.alpha = (t*1.125)*(t*1.125)*(t*1.125)
	elseif lib.timer > 480 + 5.19 * 60 then
		State("DONE")
	end

	if lib.timer < 300 then
		for i = 1, #lib.canisters do
			lib.canisters[i].h.y = lib.canisters[i].c.y + math.floor(math.sin(Time.time) * 2 + 1)
		end
	end

	lib.timer = lib.timer + 1
end

return lib