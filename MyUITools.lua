---@section MyUITools
w=0
h=0
gridX=12
gridY=12

I=input
O=output
P=property
prB=property.getBool
prN=property.getNumber
prT=property.getText

dTB = screen.drawTextBox
dR = screen.drawRect
dRF = screen.drawRectF
sC = screen.setColor

tU = table.unpack
tI=table.insert



function inRect(x,y,a,b,w,h) return x>a and y>b and x<a+w and y<b+h end
function getN(...)local a={}for b,c in ipairs({...})do a[b]=I.getNumber(c)end;return tU(a)end
function outN(o, ...) for i,v in ipairs({...}) do O.setNumber(o+i-1,v) end end
function getB(...)local a={}for b,c in ipairs({...})do a[b]=I.getBool(c)end;return tU(a)end
function outB(o, ...) for i,v in ipairs({...}) do O.setBool(o+i-1,v) end end


 function Black() sC(0,0,0) end
 function White() sC(255,255,255) end
 function Red() sC(255,0,0) end
 function Lime() sC(0,255,0) end
 function Blue() sC(0,0,255) end
 function Yellow() sC(255,255,0) end
 function Cyan() sC(0,255,255) end
 function Magenta() sC(255,0,255) end
 function Silver() sC(192,192,192) end
 function Gray() sC(128,128,128) end
 function Maroon() sC(128,0,0) end
 function Olive() sC(128,128,0) end
 function Green() sC(0,128,0) end
 function Purple() sC(128,0,128) end
 function Teal() sC(0,128,128) end
 function Navy() sC(0,0,128) end
 function Brown() sC(165,42,42) end

baseStyle={
	bg=Gray, -- background color
	fg=Brown, -- foreground color
	p=Red, -- pressed color
	tg=Blue, -- toggled color
	bdr=Maroon, -- border color
	ha=0, -- horizontal text alignment
	va=0 -- vertical text alignment
}
	
function getRect(b, f)
	local r = {b.x*gridX, b.y*gridY ,b.w*gridX, b.h*gridY}
	if f then
		r[3] = r[3] * (b.fh or 1)
		r[4] = r[4] * (b.fv or 1)
	end
	return r
end

function addElement(e)
	e.x = e.x or 0
	e.y = e.y or 0
	e.w = e.w or 1
	e.h = e.h or 1
	e.t = e.t or ""
	--e.st  style
	--e.tg  make button toggle
	--e.cf  click funtion
	--e.hf  hold funtion
	--e.uf  update function
	if e.tg~=nil or e.cf~=nil or e.hf~=nil then
		e.p=false -- make this a clickable element if any of the above are defined
	end
	tI(elements, e)
	return e
end


elements={}

-- ADD ELEMENTS HERE
-- time=0
-- addElement({x=1, y=1, t="A", cf=function(b) outB(2,true) end})
-- addElement({x=2, y=1, t="B", cf=function(b) outB(2,false) end})
-- addElement({x=3, y=1, h=2, t="CW", tg=false})
-- addElement({x=1, y=3, w=2, t="TX", tg=false,
-- 	uf=function(b) outB(1,b.tg) end -- Output true on channel if button is toggled
-- })
-- addElement({x=1, y=4, w=4,
-- 	uf=function(b) 
-- 		time = time+0.016
-- 		b.fh = math.abs(math.sin(time))
-- 	end
-- })
-- addElement({x=1, y=5, w=4,t="label"})


function toggleB(b) b.tg = not b.tg end
function tickUI()
	w,h,tx,ty=getN(1,2,3,4)
	t1=getB(1)
	
	
	for k,b in pairs(elements) do 
		if b.p ~= nil then
			if inRect(tx,ty,tU(getRect(b),1,4)) then
				if t1 and not b.p then
					if b.tg ~= nil then
						toggleB(b)
					end
					if b.cf then
						b:cf()
					end
				end
				b.p = t1
			end
			if not t1 and b.p then
				b.p = false;
			end
			if b.p and b.hf then
				b:hf()
			end
		end
		if b.uf then
			b:uf()
		end
	end
end

function drawUI()
	w = screen.getWidth()
	h = screen.getHeight()
	for k,b in pairs(elements) do
		local s = baseStyle;
		if b.st then
			for k,v in pairs(b.st) do s[k]=v end
		end
		if b.p then
			s.p()
		elseif b.tg then
			s.tg()
		else
			s.bg()
		end
		local r = getRect(b)
		dRF(tU(r,1,4))
		if b.fh ~= nil or b.fv ~= nil then
			local fr = getRect(b, true)
			s.tg()
			dRF(tU(fr,1,4))
		end
		tI(r,b.t)
		tI(r,s.ha)
		tI(r,s.va)
		s.fg()
		dTB(tU(r,1,7))
		s.bdr()
		dR(tU(getRect(b),1,4))
	end
end

---@endsection`