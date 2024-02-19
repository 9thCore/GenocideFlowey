local lib = {}

CreateLayer("TopperTop", "Top")

local state = -1
local timer = 0

local a
local as

local function lerp(a, b, t)
	return t * b + (1 - t) * a
end

function lib.Start()
	f_anim.h1.legs.x = 60

    UI.Hide(true)
    State("NONE")
    Arena.outerColor = {0, 0, 0}
    Player.sprite.alpha = 0
	state = 0

	a = CreateSprite("asgore", "TopperTop")
	a.Scale(2, 2)
	a.ypivot = 0
	a.y = 210
end

function lib.Update()
	timer = timer + 1

	if state == 0 then
		if timer == 120 then
			f_attacks.Circle(a.x, a.y + a.height, 120, 36, 2, nil, nil, "Top")
		elseif timer == 342 then
			Audio.PlaySound("hurtsound")
		elseif timer > 342 and timer < 462 then
			a.x = 320 + math.cos(math.floor((timer - 342) / 8) * math.pi) * 16
		elseif timer == 462 then
			a.x = 320
			a.Dust()
			as = f_attacks.BrokenHeart(320, a.y + a.height, {1, 1, 1}, 408, nil, "Top")
			as.SendToBottom()
			as.yscale = -1
			lib.State(1)
		end
	elseif state == 1 then
		if timer == 180 then
			f_attacks.Circle(a.x, a.y + a.height, 120, 36, 2, nil, nil, "Top")
		elseif timer >= 540 and timer < 660 then
			f_anim.h1.legs.x = lerp(60, 0, (timer - 540) / 120)
		elseif timer == 660 then
			f_anim.h1.legs.x = 0
			lib.State(2)
		end
	elseif state == 2 then
		if timer > 60 and timer < 120 then
			local v = (timer - 60) / 60
			Arena.outerColor = {v, v, v}
		elseif timer == 150 then
			BattleDialog{
				"[voice:v_flowey]\"See? I never betrayed you!\"",
				"[voice:v_flowey]\"It was all a trick, see?\"",
				"[voice:v_flowey]\"I was waiting to kill him for you!\"",
				"[voice:v_flowey]\"After all it's me your best friend!\"",
				"[voice:v_flowey]\"I'm helpful, I can be useful to you\"",
				"[voice:v_flowey]\"I promise I won't get in your way\"",
				"[voice:v_flowey][effect:shake][waitall:2]\"I can help...\rI can...\rI can...\"",
				"[voice:v_asriel][effect:shake][waitall:3]\"Please don't kill me.\"",
				"[func:StartTutorial][nextthisnow]"
			}
		end
	end
end

function lib.State(newstate)
	state = newstate
	timer = 0
end

return lib