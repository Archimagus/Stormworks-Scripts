--- default onTick function; called once per in-game tick (60 per second)

codes={}
codes["a"] = {1,1,1,0,1,1,1}
codes["b"] = {0,0,1,1,1,1,1}
codes["c"] = {1,0,0,1,1,1,0}
codes["d"] = {0,1,1,1,1,0,1}
codes["e"] = {1,0,0,1,1,1,1}
codes["f"] = {1,0,0,0,1,1,1}
codes["g"] = {1,0,1,1,1,1,0}
codes["h"] = {0,0,1,0,1,1,1}
codes["i"] = {0,0,1,0,0,0,0}
codes["j"] = {0,1,1,1,0,0,0}
codes["k"] = {1,0,1,0,1,1,1}
codes["l"] = {0,0,0,1,1,1,0}
codes["m"] = {1,0,1,0,1,0,1}
codes["n"] = {0,0,1,0,1,0,1}
codes["o"] = {0,0,1,1,1,0,1}
codes["p"] = {1,1,0,0,1,1,1}
codes["q"] = {1,1,1,0,0,1,1}
codes["r"] = {0,0,0,0,1,0,1}
codes["s"] = {1,0,1,1,0,1,1}
codes["t"] = {0,0,0,1,1,1,1}
codes["u"] = {0,1,1,1,1,1,0}
codes["v"] = {0,0,1,1,1,0,0}
codes["w"] = {0,1,0,1,0,1,1}
codes["v"] = {0,1,1,0,1,1,1}
codes["y"] = {0,1,1,1,0,1,1}
codes["z"] = {1,1,0,1,1,0,1}
codes["0"] = {1,1,1,1,1,1,0}
codes["1"] = {0,1,1,0,0,0,0}
codes["2"] = {1,1,0,1,1,0,1}
codes["3"] = {1,1,1,1,0,0,1}
codes["4"] = {0,1,1,0,0,1,1}
codes["5"] = {1,0,0,1,0,1,1}
codes["6"] = {1,0,1,1,1,1,1}
codes["7"] = {1,1,1,0,0,0,0}
codes["8"] = {1,1,1,1,1,1,1}
codes["9"] = {1,1,1,1,0,1,1}
codes["-"] = {0,0,0,0,0,0,1}
codes["_"] = {0,0,0,1,0,0,0}

string="a"
function onTick()
	index = input.getNumber(3)
	if index == 0 then
		string=property.getText("ZeroLabel")
	elseif index == 1 then
		string=property.getText("OneLabel")
	elseif index == 2 then
		string=property.getText("TwoLabel")
	end

	out=1
	for i = 1, #string do
		local c = string:sub(i,i)
		code = codes[c]
		for i2, v in ipairs(code) do
			output.setBool(out, v==1)
			out = out+1
			if out > 32 then
				return
			end
		end
	end
end