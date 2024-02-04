easing = require "easing"
cover = CreateSprite("black", "Top")
Player.sprite.alpha = 0
timer = 0
Encounter["shakeshake"] = false
Player.SetControlOverride(true)
gameover = CreateText("[instant][novoice]", {0, 0}, 565, "Top")
gameover.linePrefix = "[noskip][novoice][waitall:2]"
gameover.color = {1, 1, 1}
gameover.HideBubble()
gameover.SetFont("uidialog")
gameover.progressmode = "none"
gameover.y = 80
yes = CreateSprite("spr/yes", "Top")
no = CreateSprite("spr/no", "Top")
yes.MoveTo(400, 20)
yes.alpha = 0
no.MoveTo(240, 20)
no.alpha = 0
choice = 1
choicing = false
builder = CreateSprite("px", "Top")
builder.alpha = 0
builder.Scale(640, 480)
buildtime = 0
building = false
function Choice()
	yes.alpha = 1
	no.alpha = 1
	choicing = true
end
function Buildup()
	Audio.PlaySound("buildup")
	building = true
end
function Update()
	if timer == 240 then
		gameover.SetText{"The fight\n[w:4]has ended.[w:40][next]", "You have[w:4]\nbecome god.[w:40][next]", "Next time...[w:40][next]", "The same[w:4]\nmight occur.[w:40][next]", "They may[w:4]\nattack again.[w:40][next]", "You will[w:4]\nnot remember.[w:40][next]", "And neither[w:4]\nwill they.[w:40][next]", "Still,[w:4] reset[w:4]\nthe timeline?[w:40][func:Choice]"}
		gameover.x = 320 - gameover.GetTextWidth() / 2
	end

	if choicing then
		if Input.Left == 1 or Input.Right == 1 then
			Audio.PlaySound("menumove")
			choice = 3 - choice
		end

		if choice == 1 then
			no.color = {1, 1, 0}
			yes.color = {1, 1, 1}
			if Input.Confirm == 1 then
				yes.alpha = 0
				no.alpha = 0
				gameover.SetText{"Of course.[w:40][next]", "Then the world[w:4]\nshall remain.[w:40][func:State, DONE]"}
				Audio.PlaySound("menuconfirm")
			end
		else
			yes.color = {1, 1, 0}
			no.color = {1, 1, 1}
			if Input.Confirm == 1 then
				yes.alpha = 0
				no.alpha = 0
				gameover.SetText{"How[w:4]\ninteresting.[w:40][next]", "Very well[w:4]\nthen.[w:40][next]", "[func:Buildup]The clock[w:4]\nwill turn back."}
				SetAlMightyGlobal("genoflow_skipintro", nil)
				SetAlMightyGlobal("genoflow_soulsintroskip", nil)
				SetAlMightyGlobal("genoflow_souls", nil)
				SetAlMightyGlobal("genoflow_win", nil)
				SetAlMightyGlobal("genoflow_talked1", nil)
				SetAlMightyGlobal("genoflow_talked2", nil)
				Audio.PlaySound("menuconfirm")
			end
		end
	end

	if building then
		builder.alpha = easing.In(easing.InvLerp(0, 300, buildtime), 2)
		if buildtime > 330 then
			State("DONE")
		end
		buildtime = buildtime + 1
	end

	timer = timer + 1
end