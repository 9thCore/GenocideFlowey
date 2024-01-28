Player.sprite.alpha = 0
timer = 0
Arena.Resize(565, 130)

itembt = CreateSprite("UI/Buttons/itembt_2", "Top")
itembt.MoveTo(320, 460)
itembt.alpha = 0
healtext = CreateText("[font:uidialog][instant]" .. Encounter["item"], {0, 450}, 640)
healtext.progressmode = "none"
healtext.HideBubble()
healtext.color = {1, 1, 1, 0}
healtext.x = 320 - healtext.GetTextWidth()/2
soul = CreateSprite("ut-heart", "Top")
soul.color = {1, 0, 0, 0}
soul.MoveTo(280, 460)

function Update()
	if timer == 60 then
		Audio.PlaySound("menumove")
		itembt.alpha = 1
		soul.alpha = 1
	elseif timer == 90 then
		Audio.PlaySound("menuconfirm")
		itembt.alpha = 0
		healtext.alpha = 1
		soul.MoveTo(healtext.x - 16, 450 + healtext.GetTextHeight()/2)
	elseif timer == 120 then
		Audio.PlaySound("menuconfirm")
		Audio.PlaySound("healsound")
		healtext.alpha = 0
		soul.alpha = 0
		Player.ForceAttack(1, -Encounter["itemheal"])
	elseif timer == 240 then
		EndingWave()
		EndWave()
	end

	timer = timer + 1
end

function EndingWave()
	Player.sprite.alpha = 1
	itembt.Remove()
	healtext.Remove()
	soul.Remove()
end