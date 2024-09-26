function lerp(min, max, val)
	return min + (max - min) * val
end
function propertyOrDefault(propertyName, defaultValue)
    local value = property.getNumber(propertyName)
    if value == nil or value == 0 then
        value = defaultValue
    end
    return value
end
-- Constants
local HELO_MIN_THROTTLE = propertyOrDefault("Helo Min RPS", 20)
local HELO_MAX_THROTTLE = propertyOrDefault("Helo Max RPS", 33.334)
local PLANE_MIN_THROTTLE = propertyOrDefault("Plane Min RPS", 12)
local PLANE_MAX_THROTTLE = propertyOrDefault("Plane Max RPS", 55)
local IDLE_THROTTLE = propertyOrDefault("Idle RPS", 8)
local SAFE_LANDING_ALTITUDE = propertyOrDefault("Safe Landing Altitude", 1) -- meters
local SAFE_LANDING_SPEED = propertyOrDefault("Safe Landing Speed", 2) -- m/s
local THROTTLE_ZERO_THRESHOLD = 0.001

function onTick()
    -- Read inputs
    local throttleInput = input.getNumber(1)  -- Assume this is 0-1
    local altitude = input.getNumber(2)
    local speed = input.getNumber(3)
    local planeMode = input.getBool(1)        -- false for helo, true for plane
    
    

    -- Apply mode-specific logic
    local effectiveThrottle
    if planeMode then
        -- Plane mode
        local minThrottle = altitude < SAFE_LANDING_ALTITUDE and IDLE_THROTTLE or PLANE_MIN_THROTTLE
        effectiveThrottle = lerp(minThrottle, PLANE_MAX_THROTTLE, throttleInput)
    else
        -- Helicopter mode

        if altitude < SAFE_LANDING_ALTITUDE and speed < SAFE_LANDING_SPEED and throttleInput < THROTTLE_ZERO_THRESHOLD then
            effectiveThrottle = IDLE_THROTTLE
        else
            effectiveThrottle = lerp(HELO_MIN_THROTTLE, HELO_MAX_THROTTLE, throttleInput)
        end
    end

    
    -- Output the effective throttle
    output.setNumber(1, effectiveThrottle)
end
