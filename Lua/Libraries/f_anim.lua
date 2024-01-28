local lib = {}

lib.h1 = {}
lib.h2 = {}

local function constructhuman(t, l, to, h, al, ar, k)
	t.legs = CreateSprite("human/legs/" .. l)
	t.legs.SetParent(enemies[1]["monstersprite"])
	t.legs.Scale(2, 2)
	t.legs.ypivot = 0.05

	t.torso = CreateSprite("human/torso/" .. to)
	t.torso.SetParent(t.legs)
	t.torso.Scale(2, 2)
	t.torso.x = 1
	t.torso.y = 38

	t.head = CreateSprite("human/head/" .. h)
	t.head.SetParent(t.torso)
	t.head.Scale(2, 2)
	t.head.y = 35
	t.head.x = 0

	t.arml = CreateSprite("human/arm/" .. al)
	t.arml.SetParent(t.legs)
	t.arml.SendToBottom()
	t.arml.Scale(2, 2)
	t.arml.x = 24
	t.arml.y = 38

	t.armr = CreateSprite("human/arm/" .. ar)
	t.armr.SetParent(t.legs)
	t.armr.SendToBottom()
	t.armr.Scale(2, 2)
	t.armr.y = 38
	t.armr.x = -23

	t.knife = CreateSprite("human/knife/" .. k)
	t.knife.SetParent(t.legs)
	t.knife.Scale(2, 2)
	t.knife.SetPivot(0, 0.5)

	t.locket = CreateSprite("human/locket/heart")
	t.locket.SetParent(t.head)
	t.locket.Scale(2, 2)
	t.locket.y = -22
	t.locket.x = 1
end

local function updatehuman(t)
	t.legs.yscale = math.sin(Time.time * 0.5) * 0.05 + 1.95
	t.torso.yscale = math.cos(Time.time * 0.5) * 0.025 + 1.975

	t.knife.absx = t.armr.absx - 10
	t.knife.absy = t.armr.absy - 14
end

function lib.Start()
	constructhuman(lib.h1, "normal", "two", "unused", "lhard", "rhard", "realknife")
	-- constructhuman(lib.h2, "normal", "one", "smile", "ltrue", "rtrue", "realerknife")
end

function lib.Update()
	updatehuman(lib.h1)
	-- updatehuman(lib.h2)
end

function lib.Transition(t)
	lib.h2.legs.alpha = t
	lib.h2.torso.alpha = t
	lib.h2.head.alpha = t
	lib.h2.arml.alpha = t
	lib.h2.armr.alpha = t
	lib.h2.knife.alpha = t
end

return lib