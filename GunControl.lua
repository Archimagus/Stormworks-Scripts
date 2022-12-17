require("MyMath")


targetList = {}
function onTick()
	closest=9999999999;
	target=nil;
    -- your code
    for i=1, 8, 1
    	do
			if input.getBool(i) then
				dist = input.getNumber((i-1)*4+1)
				if dist > 10 and dist < closest then
					closest = dist;
					target =  {d=input.getNumber((i-1)*4+1), az=input.getNumber((i-1)*4+2), el=input.getNumber((i-1)*4+3), tsd=input.getNumber((i-1)*4+4), t=0}
				end
			end
    	end

		if target ~= nil then
			output.setBool(1, target.az < 0.1 and target.el < 0.1)
			output.setNumber(1, target.az);
			output.setNumber(2, target.el);
		else
			output.setBool(1, false)
			output.setNumber(1, 0);
			output.setNumber(2, 0);
		end
end

function onDraw()
	
end