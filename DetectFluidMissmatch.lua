function getN(...)
	local a = {}
	for b, c in ipairs({ ... }) do a[b] = input.getNumber(c) end; return a
end

function onTick()
	local left = getN(01, 02, 03, 06, 07, 09, 10)
	local right = getN(15, 16, 17, 20, 21, 23, 24)

	local leftFluidIndex = 0
	local rightFluidIndex = 0
	for i = 1, 7, 1 do
		local l = left[i]
		local r = right[i]
		if l > 0 then
			leftFluidIndex = i
		end
		if r > 0 then
			rightFluidIndex = i
		end
	end
	if leftFluidIndex == 0 or rightFluidIndex == 0 then
		output.setBool(6, false)
	else
		output.setBool(6, leftFluidIndex ~= rightFluidIndex)
	end
end
