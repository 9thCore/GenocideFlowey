local lib = {}
lib.started = false
lib.timer = 0

function lib.Start()
	Arena.outerColor = {0, 0, 0}
	Player.sprite.alpha = 0
	State("NONE")
	ppbar.background.Move(9999, 0)
	pp.alpha = 0
	lib.background = CreateSprite("black")
	lib.background.SendToBottom()
	lib.started = true
end

function lib.Update()
	if not lib.started then return end

	if lib.timer == 60 then
		lib.text = CreateText({
			"[voice:v_flowey][effect:none]Hey...",
			"[voice:v_flowey][effect:none]You're not actually " .. GetAlMightyGlobal("genoflow_name") .. ",[w:2] are you?",
			"[voice:v_flowey][effect:none]No...",
			"[voice:v_floweymad][waitall:2][effect:shake]They wouldn't have been such an IDIOT.",
			"[voice:v_floweymad][waitall:2][effect:shake]Hee hee hee...",
			"[voice:v_floweymad][waitall:2][effect:shake]Let's see the \"power of friendship\"...",
			"[voice:v_floweymad][waitall:2][effect:shake]Save you THIS time!",
			"[novoice][func:StartSoulFight][nextthisnow]"
		}, {0, 140}, 240, "Top", 100)
		lib.text.SetSpeechThingPositionAndSide("down", "50%")
		lib.text.x = 200
		lib.text.progressmode = "manual"
	end

	lib.timer = lib.timer + 1
end

function lib.End()
	lib.text.Remove()
	ppbar.background.Move(-9999, 0)
	lib.background.Remove()
	pp.alpha = 1
end

return lib