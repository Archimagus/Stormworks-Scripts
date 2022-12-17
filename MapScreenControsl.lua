destination={0,0} --InW
isSetDestination=false --In
function pRect(x,y,rectX,rectY,rectW,rectH)
	return x>rectX and y>rectY and x<rectX+rectW and y<rectY+rectH
end
function onTick()
    isTouched=input.getBool(1) --j^[^b
    touchPosition={input.getNumber(3),input.getNumber(4)} --^bj^[W
    --OLuaJ[h
    position={input.getNumber(10),input.getNumber(11)}
    isCustomPlace=input.getBool(3)
    gps={input.getNumber(12),input.getNumber(13)}
    zoom=input.getNumber(14)
    compass=input.getNumber(15)
    if isTouched then
        --j^[s
            --j^[^bu1s
            if isCustomPlace and pRect(touchPosition[1],touchPosition[2],width-9,1,7,8) then
                --InZbg
                isSetDestination=true
                destination[1],destination[2]=map.screenToMap(position[1],position[2],zoom,width,height,width/2,height/2)
            elseif pRect(touchPosition[1],touchPosition[2],width-9,1,7,8) and isSetDestination then
                --InNA
                isSetDestination=false
                destination={0,0}
                distance=0
            end
    end
    if isSetDestination then
        --IvZ
        distance=math.sqrt((destination[1]-gps[1])^2+(destination[2]-gps[2])^2)
    end
    --I[gpCbgpo
    output.setBool(1,isSetDestination)
    output.setNumber(1,destination[1])
    output.setNumber(2,destination[2])
    output.setNumber(3,distance)

end
function onDraw()
    --j^[
    width=screen.getWidth() --j^[
    height=screen.getHeight() --j^[c
    screen.setColor(255,255,255)
    --In
    local gpsPixelX,gpsPixelY=map.mapToScreen(position[1],position[2],zoom,width,height,gps[1],gps[2])
    if isSetDestination then
        --nIn
        screen.setColor(0,0,0)
        local destinationPixelX,destinationPixelY=map.mapToScreen(position[1],position[2],zoom,width,height,destination[1],destination[2])
        screen.drawLine(gpsPixelX,gpsPixelY,destinationPixelX,destinationPixelY)
        --In}[J[
        screen.setColor(0,0,255)
        screen.drawRectF(destinationPixelX-1,destinationPixelY-1,3,3)
    end
    --u
    screen.setColor(255,0,0)
    screen.drawRectF(gpsPixelX-1,gpsPixelY-1,3,3)
    screen.drawLine(gpsPixelX,gpsPixelY,math.cos(compass-0.5*math.pi)*4+gpsPixelX,math.sin(compass-0.5*math.pi)*4+gpsPixelY)
    --In{^
    if isSetDestination or isCustomPlace then
        screen.setColor(0,0,0)
        screen.drawRect(width-9,1,7,8)
        if isCustomPlace then
            --S
            screen.drawLine(width/2-2,height/2,width/2+3,height/2)
            screen.drawLine(width/2,height/2-2,width/2,height/2+3)
            screen.setColor(0,0,255)
            screen.drawText(width-7,3,"d")
        else
            screen.setColor(255,0,0)
            screen.drawText(width-7,3,"c")
        end
    end
    --gEk{^
    if isTouched and pRect(touchPosition[1],touchPosition[2],1,height-10,6,8) then
        screen.setColor(255,255,255)
    else
        screen.setColor(0,0,0)
    end
    screen.drawRect(1,height-10,6,8)
    if isTouched and pRect(touchPosition[1],touchPosition[2],9,height-10,6,8) then
        screen.setColor(255,255,255)
    else
        screen.setColor(0,0,0)
    end
    screen.drawRect(9,height-10,6,8)
    screen.setColor(255,255,255)
    screen.drawText(3,height-8,"+")
    screen.drawText(11,height-8,"-")
    if isCustomPlace then
        --Zbg{^
        screen.setColor(0,0,0)
        screen.drawRect(width-9,height-10,7,8)
        screen.setColor(255,0,0)
        screen.drawText(width-7,height-8,"r")
    end
    --
    if isSetDestination then
        screen.setColor(0,0,0)
        if distance>=1000 then
            if width==32 then
                screen.drawText(1,1,string.format("%1.0f",distance/1000).."k")
            else
                screen.drawText(1,1,string.format("%1.1f",distance/1000).."km")
            end
        else
            screen.drawText(1,1,string.format("%1.0f",distance).."m")
        end
    end
end