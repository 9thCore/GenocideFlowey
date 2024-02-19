f_attacks = require "f_attacks"
easing = require "easing"
cover = CreateSprite("black", "Top")
player = f_attacks.BrokenHeart(320, 300, {1, 0, 0}, 180, 60, "Top")
timer = -120
Audio.Stop()
truedeath = GetAlMightyGlobal("genoflow_souls") or false
text = {}
if truedeath then
	cover.alpha = 0
	Arena.ResizeImmediate(565, Arena.height)
end

function Update()
	f_attacks.Update()

	if timer > -120 and timer < 60 then
		player.x = 320 + math.random() * 2 - 1
		player.y = 300 + math.random() * 2 - 1
	end

	if truedeath then
		local t = math.max(easing.InvLerp(0, -120, timer), 0)
		NewAudio.SetVolume("finale", t)
		cover.alpha = 1 - t

		if timer == 600 then
			SetAlMightyGlobal("genoflow_win", true)
			Audio.LoadFile("ending")

			local ioff = 0
			local f = Misc.OpenFile("Sprites/spr/exit.png", "r")
			local ft = f.ReadLines()
			local logo = CreateSprite("logo", "Top")
			logo.x = 320
			logo.y = -87
			table.insert(text, logo)
			for i = 1, #ft do
				if #ft[i] < 2 then
					ioff = ioff + 1
				else
					local txt = CreateText("", {0, -175 - (i + ioff/2)*24}, 600, "Top")
					txt.SetFont("uidialog")
					txt.progressmode = "none"
					txt.color = {1, 1, 1}
					txt.HideBubble()
					txt.SetText{"[instant][novoice]" .. ft[i]}
					txt.x = 320 - txt.GetTextWidth()/2
					table.insert(text, txt)
				end
			end
		elseif timer > 3800 and timer < 3920 then
			local t = easing.InvLerp(3920, 3800, timer)
			Audio.Volume(t)
		elseif timer == 3920 then
			EndWave()
			cover.Remove()
        	Encounter.Call("StartWave", {"reset", math.huge})
		end
	else
		if timer == 116 then
			Audio.PlaySound("noise")
			player.alpha = 0
		elseif timer == 119 then
			State("DONE")
		end
	end

	if timer % 2 == 0 then
		for i = #text, 1, -1 do
			text[i].Move(0, 1)
			if text[i].y > 640 then
				text[i].Remove()
				table.remove(text, i)
			end
		end
	end

	timer = timer + 1
end