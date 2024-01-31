-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561197993236437/myworkshopfiles/?appid=573090
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        simulator:setInputNumber(1, simulator:getSlider(1) * math.pi*2)
        simulator:setInputNumber(2, simulator:getSlider(2) * math.pi*2)
        simulator:setInputNumber(3, simulator:getSlider(3) * math.pi*2)
        simulator:setInputNumber(4, math.ceil(simulator:getSlider(4)*5))
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

I=input
O=output
tU = table.unpack
function getN(...)local a={}for b,c in ipairs({...})do a[b]=I.getNumber(c)end;return tU(a)end
function outN(o, ...) for i,v in ipairs({...}) do O.setNumber(o+i-1,v) end end

local function rotateX(angle)
    local c, s = math.cos(angle), math.sin(angle)
    return {
        {1, 0, 0},
        {0, c, -s},
        {0, s, c}
    }
end

local function rotateY(angle)
    local c, s = math.cos(angle), math.sin(angle)
    return {
        {c, 0, s},
        {0, 1, 0},
        {-s, 0, c}
    }
end

local function rotateZ(angle)
    local c, s = math.cos(angle), math.sin(angle)
    return {
        {c, -s, 0},
        {s, c, 0},
        {0, 0, 1}
    }
end

local function matrixMultiply(a, b)
    local result = {}
    for i = 1, 3 do
        result[i] = {}
        for j = 1, 3 do
            result[i][j] = 0
            for k = 1, 3 do
                result[i][j] = result[i][j] + a[i][k] * b[k][j]
            end
        end
    end
    return result
end

local function eulerToGlobalYRotation(x, y, z, order)
    order = order or "XYZ"

    local rotation

    if order == "XYZ" then
        rotation = matrixMultiply(matrixMultiply(rotateX(x), rotateY(y)), rotateZ(z))
    elseif order == "XZY" then
        rotation = matrixMultiply(matrixMultiply(rotateX(x), rotateZ(z)), rotateY(y))
    elseif order == "YXZ" then
        rotation = matrixMultiply(matrixMultiply(rotateY(y), rotateX(x)), rotateZ(z))
    elseif order == "YZX" then
        rotation = matrixMultiply(matrixMultiply(rotateY(y), rotateZ(z)), rotateX(x))
    elseif order == "ZXY" then
        rotation = matrixMultiply(matrixMultiply(rotateZ(z), rotateX(x)), rotateY(y))
    elseif order == "ZYX" then
        rotation = matrixMultiply(matrixMultiply(rotateZ(z), rotateY(y)), rotateX(x))
    else
        error("Invalid rotation order")
    end

     -- Calculate the global rotation angles in radians
	 local globalXRotationRadians = math.atan(rotation[2][3], rotation[3][3])
	 local globalYRotationRadians = math.atan(-rotation[1][3], math.sqrt(rotation[1][1]^2 + rotation[1][2]^2))
	 local globalZRotationRadians = math.atan(rotation[1][2], rotation[1][1])

    return globalXRotationRadians,globalYRotationRadians,globalZRotationRadians
end

function onTick()

	local x,y,z,o = getN(4,5,6,31)

	local order = ({"XYZ","XZY","YXZ","YZX","ZXY","ZYX"})[o]

	local globalXRotationRadians, globalYRotationRadians, globalZRotationRadians = eulerToGlobalYRotation(x, y, z, order)

	outN(1, globalXRotationRadians, globalYRotationRadians, globalZRotationRadians, o )
end
