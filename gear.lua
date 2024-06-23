function onTick()
	r = input.getBool(1) -- Read the first number from the script's composite input
	g2 = input.getBool(2) and 2 or 0
	g3 = input.getBool(3) and 3 or 0
	g4 = input.getBool(4) and 4 or 0
	g5 = input.getBool(5) and 5 or 0
	g6 = input.getBool(6) and 6 or 0

	if r then
		output.setNumber(1, -1)
	else
		output.setNumber(1, 1 + math.max(g2, g3, g4, g5, g6))
	end
end
