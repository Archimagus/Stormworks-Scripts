--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "3x3")
    simulator:setProperty("Initial Camera", 3)
    simulator:setProperty("Input 1", true)
    simulator:setProperty("Input 2", true)
    simulator:setProperty("Input 3", true)
    simulator:setProperty("Input 4", true)
    simulator:setProperty("Use Buttons", false)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputBool(2, screenConnection.isTouchedAlt)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))       -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1))        -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))       -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50)   -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

M=math
si=M.sin
co=M.cos
pi=M.pi
pi2=pi*2

S=screen
dL=S.drawLine
dC=S.drawCircle
dCF=S.drawCircleF
dR=S.drawRect
dRF=S.drawRectF
dT=S.drawTriangle
dTF=S.drawTriangleF
dTx=S.drawText
dTxB=S.drawTextBox

C=S.setColor

MS=map.mapToScreen
SM=map.screenToMap

I=input
O=output
P=property
prB=P.getBool
prN=P.getNumber
prT=P.getText

tU=table.unpack

fov=0.5
ir=false

function getN(...)local a={}for b,c in ipairs({...})do a[b]=I.getNumber(c)end;return tU(a)end
function outN(o, ...) for i,v in ipairs({...}) do O.setNumber(o+i-1,v) end end
function getB(...)local a={}for b,c in ipairs({...})do a[b]=I.getBool(c)end;return tU(a)end
function propB(...)local a={}for b,c in ipairs({...})do a[b]=P.getBool(c)end;return a end
function propN(...)local a={}for b,c in ipairs({...})do a[b]=P.getNumber(c)end;return a end
function outB(o, ...) for i,v in ipairs({...}) do O.setBool(o+i-1,v) end end
function round(x,...)local a=10^(... or 0)return M.floor(a*x+0.5)/a end
function clamp(a,b,c) return M.min(M.max(a,b),c) end
function inRect(x,y,a,b,w,h) return x>a and y>b and x<a+w and y<b+h end

TOUCH = nil

act = {}
btn = {}

selectedSignal = math.floor(prN("Initial Camera")) or 1
selectedButton = selectedSignal

function onTick()
	if TOUCH == nil then
		if w ~= nil then
		set=false
		TOUCH = {}	
			act[1] = function() fov = fov+0.004 if fov > 1 then fov = 1 end  end
			act[2] = function() fov = fov-0.004 if fov < 0 then fov = 0 end  end
			act[3] = function() ir = not ir end
			
		inputs = propB("Input 1","Input 2","Input 3","Input 4")
		useButtons = prB("Use Buttons")
		buttonX=5
		buttonIndex=4
		for k, v in ipairs(inputs) do
			if v then
				if selectedSignal == k then
					btn[buttonIndex]={toggle=true}
					set=true
				end
				TOUCH [buttonIndex] = {buttonX,5,5,5,tostring(k), buttonIndex, k}
				buttonX = buttonX+7
				act[buttonIndex] = function(i)
					selectedSignal = k
					cb = i
					btn[i].toggle=true
				end
				buttonIndex=buttonIndex+1
			end
		end
		
		end
	end
	

	t1,t2=getB(1,2)
		
	cb = 0
	
	if useButtons then
		w,h,tx,ty=getN(1,2,3,4,5,6);
	
		for i,t in ipairs(TOUCH) do
			b = btn[i] or {}
			if inRect(tx,ty,t[1],t[2],t[3],t[4]) then
				b.click = t1 and not b.hold
				b.hold = t1
				if b.click then
					if act[i] then 
						act[i](i) 
					end
				end
				if b.hold and i < 3 then
					if act[i] then 
						act[i](i)
					end
				end
			else
				b.hold = false
			end
			btn[i] = b
		end
		
		if cb ~= 0 then
			for i,t in ipairs(btn) do
				if i ~= cb then
					btn[i].toggle = false
				end	
			end
		end
	else
		if not hold then
			if t1 then
				selectedButton = selectedButton+1
				if not TOUCH[selectedButton] then
					selectedButton = 1
				end
			end
		end
		if t1 then
			if not hold then
				hold = true
				selectedSignal = TOUCH[selectedButton][7]
			end
		else
			hold = false
		end
		
	end

	
	outN(1, selectedSignal)
	outN(2, fov)
	outB(1, ir)
end

function onDraw()
	if t1==nil then return true end -- safety check to make sure variables are set
	
	w = S.getWidth()
	h = S.getHeight()
	cx,cy = w/2,h/2 -- coordinates of the screen center (always useful)

	if useButtons then
		for i,t in ipairs(TOUCH) do -- loop through defined buttons and render them
			C(20,20,20)
			if btn[i].hold then C(80,80,80) end -- color while holding the button
			dRF(tU(t,1,4)) -- draw button background (tU outputs the first 4 values from the button as parameters here)
			C(255,0,0)
			if btn[i].toggle then C(0,255,0) end -- text green if button is toggled on
			bx,by,bw,bh,btx=tU(t,1,5)
			if i < 3 then bx = bx+1 end
			dTxB(bx,by,bw,bh,btx) -- draw textbox with the button text
		end
	else
		C(255,0,0)
		dTxB(5,5,5,5, tostring(selectedSignal))
	end
end