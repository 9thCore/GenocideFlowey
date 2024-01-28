easing = require "easing"
Audio.Stop()
NewAudio.Stop("slash")
NewAudio.Stop("warning")
cover = CreateSprite("black", "Top")
Player.sprite.layer = "Top"
Audio.PlaySound("hurtsound")
timer = 0
Encounter["shakeshake"] = false
px = Player.absx
py = Player.absy
Player.sprite.xpivot = 0.5
Player.sprite.ypivot = 0.5
Player.SetControlOverride(true)
slash = CreateSprite("empty", "Top")
slash.loopmode = "oneshotempty"
slash.Scale(2, 2)
hitspr = 0
gameover = CreateText("[instant][novoice]", {0, 0}, 565, "Top")
gameover.linePrefix = "[noskip][novoice][waitall:2]"
gameover.color = {1, 1, 1}
gameover.HideBubble()
gameover.SetFont("uidialog")
gameover.progressmode = "none"
gameover.y = 60
p = CreateSprite("px", "Top")
p.Scale(640, 480)
p.alpha = 0
function Update()
	if timer > 30 and timer < 240 then
		local t = easing.InOut(easing.InvLerp(30, 240, timer), 2)
		local s = easing.Lerp(1, 8, t)
		Player.sprite.Scale(s, s)
		Player.MoveToAbs(easing.Lerp(px, 320, t), easing.Lerp(py, 240, t), true)
	elseif timer >= 300 and timer < 720 and timer % 60 == 0 then
		Player.sprite.absx = 320
		slash.SetAnimation({"spr_slice_o_0", "spr_slice_o_1", "spr_slice_o_2", "spr_slice_o_3", "spr_slice_o_4", "spr_slice_o_5"}, 1/7, "UI/Battle")
		Audio.PlaySound("dust")
	elseif timer >= 300 and timer < 720 and timer % 60 == 40 then
		Audio.PlaySound("hurtsound")
		Player.sprite.Set("spr/hit" .. hitspr)
		hitspr = hitspr + 1
	elseif timer >= 300 and timer < 720 and timer % 60 > 40 then
		Player.sprite.absx = 320 + (((timer % 60) % 10 < 5) and 20 or -20)
	end
	if timer == 1000 then
		gameover.SetText{"The human[w:8]\nhas reset."}
		gameover.x = 320 - gameover.GetTextWidth() / 2
	elseif timer == 1100 then
		Audio.PlaySound("buildup")
	elseif timer > 1100 and timer < 1430 then
		p.alpha = easing.In((timer - 1100) / 300, 2)
	elseif timer == 1430 then
		State("DONE")
	end
	timer = timer + 1
end