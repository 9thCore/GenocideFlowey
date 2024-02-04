local lib = {}
lib.active = true
local parrytimer = 0
local parrycooldown = 0
local c = 90
local startwavecooldown = 10
local timescaleoverride
local fp = CreateSprite("fp")
fp.SetParent(Player.sprite)
fp.alpha = 0
fp.x = 0
fp.y = 0
local ignore = false

function lib.IgnoreInput(t)
	ignore = t
end

function lib.SetActive(active)
	lib.active = active
	if not active then
		lib.StopParry()
		fp.alpha = 0
	end
end

function lib.StartParry()
	if ignore then
		ignore = false
		return
	end
	parrytimer = 30
	parrycooldown = c
	fp.alpha = 1
	Audio.PlaySound("bell")
end

function lib.StopParry()
	parrytimer = 0
end

function lib.Parry(pp)
	Audio.PlaySound("parry")
	f_parry.StopParry()
	Encounter.Call("AddPP", pp)
end

function lib.SetCooldown(cooldown)
	c = cooldown
end

function lib.OverrideTimeScale(override)
	timescaleoverride = override
end

function lib.IsParrying()
	return parrytimer > 0
end

function lib.CanStartParry()
	return parrytimer < 1 and parrycooldown < 1
end

function lib.Update()
	if not lib.active then return end
	if startwavecooldown > 0 then
		startwavecooldown = startwavecooldown - 1
		return
	end

	if lib.CanStartParry() and Input.Confirm == 1 then
		lib.StartParry()
	end

	if parrytimer > 0 then
		parrytimer = parrytimer - (timescaleoverride or Time.timeScale)

		if parrytimer <= 0 then
			lib.StopParry()
		end
	else
		fp.alpha = fp.alpha - 1/10
	end

	parrycooldown = parrycooldown - (timescaleoverride or Time.timeScale)
end

function lib.EndingWave()
	fp.Remove()
	parrycooldown = 0
	parrytimer = 0
end

return lib