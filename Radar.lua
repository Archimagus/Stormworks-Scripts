require("MyMath")

maxDistance = 5000

enabled = false
targetList = {}
clearTime = property.getNumber("Clear Time")
maxDistance = property.getNumber("MaxRange")
function onTick()
    -- your code
	enabled = input.getBool(32)
	if not enabled then
		return
	end
    for i=1, 8, 1
    	do
			target = input.getBool(i)
			
			if target then
				if input.getNumber((i-1)*4+1) > 0 then
					table.insert(targetList, {d=input.getNumber((i-1)*4+1), az=input.getNumber((i-1)*4+2), el=input.getNumber((i-1)*4+3), tsd=input.getNumber((i-1)*4+4), t=0})
				end
			end
    	end
end

function onDraw()
	if not enabled then
		return
	end
	width=screen.getWidth()
    height=screen.getHeight()
    hw=width/2
    hh=height/2
    -- your code
	i=0
    for k,t in  pairs(targetList) do
		normDist = (t.d/maxDistance)*hw
		if normDist < 1 then
			normDist = 1
		elseif normDist > hw then
			normDist = hw
		end


		a = (t.az * math.pi * 2)
		x = hw + normDist * math.sin(a)
		y = hh + normDist * -math.cos(a)

		if t.el > 0 then
			screen.setColor(0, 0, 255, 255)
		elseif t.el < 0 then
			screen.setColor(255, 0, 0, 255)
		else
			screen.setColor(255,255,0)
		end

		screen.drawCircle(x, y, 1)
		i=i+1
		t.t = t.t + 1/60
		if t.t > clearTime then
			table.remove(targetList, i)
		end		
	end
end