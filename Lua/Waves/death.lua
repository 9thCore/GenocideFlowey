cover = CreateSprite("black", "Top")
player = CreateSprite("ut-heart", "Top")
player.color = {1, 0, 0}
player.y = 300
timer = -120
Audio.Stop()

function Update()
	if timer > -120 and timer < 60 then
		player.x = 320 + math.random() * 2 - 1
		player.y = 300 + math.random() * 2 - 1
	elseif timer == 60 then
		player.Set("ut-heart-broken")
		Audio.PlaySound("heartbeatbreaker")
	elseif timer == 120 then
		Audio.PlaySound("noise")
		player.alpha = 0
	elseif timer == 123 then
		State("DONE")
	end

	timer = timer + 1
end