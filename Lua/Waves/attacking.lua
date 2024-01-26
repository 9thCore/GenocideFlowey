Arena.Resize(565, 130)
eye = CreateSprite("UI/spr_target_0", "Top")
eye.xscale = 0
eye.y = Arena.y + Arena.height/2 + 4
eye.alpha = 0
target = CreateSprite("empty", "Top")
target.SetAnimation({"spr_targetchoice_0", "spr_targetchoice_1"}, 1/5, "UI/Battle")
target.x = 320 + Arena.width/2 - 7
target.y = eye.y + 1
Player.sprite.alpha = 0
timer = 0
hits = 0
perfects = 0
speed = 0
speedincrease = 0.1
stoptime = 0
alreadyhit = false
perfected = false
lastdir = -1
vines = {}
mimics = {}

local function sign(a)
	if a > 0 then return 1
	else return -1
	end
end

local function lerp(a, b, t)
	return b*t+a*(1-t)
end

local function invlerp(a, b, v)
	return (v-a)/(b-a)
end

local function dirtovalue(v1, v2, dir)
	if dir == -1 then return v1
	else return v2
	end
end

function SpawnVine(damage)
	local dir = math.random(0, 1) * 2 - 1
	local v = CreateSprite("attack/vine", "Top")
	v.xpivot = 1
	v.xscale = dir
	v.x = (dir + 1) * 320
	v.y = 320
	v["dir"] = dir
	v["timer"] = 0
	v["damage"] = damage
	vines[#vines+1] = v
end

function SpawnMimic(color)
	local m = CreateSprite(target.spritename, "Top")
	m.color = color
	m.x = target.x
	m.y = target.y
	mimics[#mimics+1] = m
end

function Update()
	if timer <= 15 then
		local t = timer / 15
		local t2 = 1-(1-t)*(1-t)
		eye.xscale = t2
		eye.alpha = t2
	end

	if stoptime == 0 then
		if target.x > 320 then
			speed = speed - speedincrease
		else
			speed = speed + speedincrease
		end
		target.x = target.x + speed

		if lastdir ~= sign(speed) then
			target.color = {1, 1, 1}
			lastdir = sign(speed)
			if not alreadyhit then
				stoptime = timer
				Audio.PlaySound("guh")
				Player.ForceAttack(1, 0)
				target.color = {0.5, 0.5, 0.5}
			end
			alreadyhit = false
		end

		if not alreadyhit and Input.Confirm == 1 then
			local diff = math.abs(320 - target.x)
			local t = invlerp(320, 0, diff)
			local dmg = math.floor(t*t*t*(2+math.floor(perfects*0.5)) + 0.5)

			if diff <= 20 then
				Audio.PlaySound("hit2")
				SpawnVine(dmg)
				SpawnMimic{1, 1, 0}
				perfects = perfects + 1
			elseif diff > 100 then
				Audio.PlaySound("guh")
				stoptime = timer
				Player.ForceAttack(1, 0)
			else
				Audio.PlaySound("hit1")
				SpawnVine(dmg)
				SpawnMimic{1, 1, 1}
			end

			target.color = {0.5, 0.5, 0.5}
			alreadyhit = true
			hits = hits + 1
			speedincrease = speedincrease + 0.125

			if hits == 4 then
				stoptime = timer
				if perfects == 4 then
					perfected = true
				end
			end
		end
	else
		if timer - stoptime > 90 then
			EndWave()
		end
	end

	for i = #vines, 1, -1 do
		local v = vines[i]
		v["timer"] = v["timer"] + 1
		if v["timer"] < 10 then
			local x = 32 * v["timer"]
			v.x = dirtovalue(640 - x, x, v["dir"])
		elseif v["timer"] == 10 then
			v.x = 320
			if perfected then
				Audio.PlaySound("hit3")
			end
			Player.ForceAttack(1, v["damage"])
		elseif v["timer"] <= 40 then
			local t = (v["timer"] - 10) / 30
			local t2 = (1-t)*(1-t)
			v.x = lerp(320, dirtovalue(640, 0, v["dir"]), 1 - t2)
		else
			table.remove(vines, i)
			v.Remove()
		end
	end

	for i = #mimics, 1, -1 do
		local m = mimics[i]
		m.xscale = m.xscale + (1.5 - m.xscale) * 0.15
		m.yscale = m.xscale
		m.alpha = m.alpha - 1/30
	end

	timer = timer + 1
end

function EndingWave()
	Player.sprite.alpha = 1
	eye.Remove()
	target.Remove()
	for i = #vines, 1, -1 do
		vines[i].Remove()
	end
	vines = nil
	for i = #mimics, 1, -1 do
		mimics[i].Remove()
	end
	mimics = nil
	if not Encounter.Call("TryHeal") then
		Player.CheckDeath()
		State("ENEMYDIALOGUE")
	end
end