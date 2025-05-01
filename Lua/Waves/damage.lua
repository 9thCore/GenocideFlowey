local pellet_value = 5;
local heal_value = Encounter["heal_value"];
Encounter["heal_value"] = 0;
local pellet_count = math.ceil(heal_value / pellet_value);

local pellets = {};

local ro = math.random() * math.pi;
local radius = math.max(Arena.width, Arena.height);

local tx = (math.random() * 2 - 1) * Arena.width / 4;
local ty = (math.random() * 2 - 1) * Arena.height / 4;

for i = 1, pellet_count do
	local ratio = i / pellet_count;
	local angle = 2 * math.pi * ratio + ro + math.random() * math.pi;
	local cx = math.cos(angle) * radius;
	local cy = math.sin(angle) * radius;
	local ox = (math.random() * 2 - 1) * 16;
	local oy = (math.random() * 2 - 1) * 16;

	local p = CreateProjectile("pellet", cx, cy);
	p.sprite.color = {0, 1, 0};
	p["sx"] = (tx + ox - p.x) * 0.0005;
	p["sy"] = (ty + oy - p.y) * 0.0005;
	p["timer"] = ratio * 20;
	p["movetime"] = 0;
	p.OnHit = function()
		Player.Heal(math.min(pellet_value, heal_value));
		heal_value = heal_value - pellet_value;
		p.Remove();
	end
	table.insert(pellets, p);
end

function Update()
	for _, p in ipairs(pellets) do
		if p.isactive then
			p["timer"] = p["timer"] + 1;
			p.sprite.rotation = math.floor(p["timer"] / 4) * 90;
			if (p["timer"] > 60) then
				p.Move(p["sx"] * p["movetime"], p["sy"] * p["movetime"]);
				p["movetime"] = p["movetime"] + 1/10;
			end
		end
	end
end