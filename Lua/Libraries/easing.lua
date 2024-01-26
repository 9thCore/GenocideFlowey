local lib = {}

function lib.Lerp(a, b, t)
	return a*(1-t) + b*t
end

function lib.InvLerp(a, b, v)
	return (v-a)/(b-a)
end

function lib.Out(t, f)
	return 1 - (1-t)^(f or 2)
end

function lib.In(t, f)
	return t^(f or 2)
end

function lib.InOut(t, f)
	f = f or 2
	if t < 0.5 then
		return 2^(f-1) * t^f
	else
		local t2 = 1 - 2^f*(1-t)^f
		return t2*0.5 + 0.33 + 0.16
	end
end

return lib