--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- variables

local grungeTextures = {}
grungeTextures[1] = dxCreateTexture("assets/nogrunge.jpg")
grungeTextures[2] = dxCreateTexture("assets/lowgrunge.jpg")
grungeTextures[3] = dxCreateTexture("assets/defaultgrunge.jpg")
grungeTextures[4] = dxCreateTexture("assets/biggrunge.jpg")
grungeTextures[5] = dxCreateTexture("assets/megagrunge.jpg")

local replaceTextures = {
	{"vehiclegrunge256"},
	{"grunge"},
    {"?emap*"},
}

local vehs={}
local pos={}

local materialIDs = {
	-- gravel
	[6] = 2,
	[85] = 2,
	[101] = 2,
	[134] = 2,
	[140] = 2,

	-- grass
	[9] = 0.5,
    [10] = 0.5,
    [11] = 0.5,
    [12] = 0.5,
    [13] = 0.5,
    [14] = 0.5,
    [15] = 0.5,
    [16] = 0.5,
    [17] = 0.5,
    [18] = 0.5,
    [19] = 0.5,
    [20] = 0.5,
    [80] = 0.5,
    [81] = 0.5,
    [82] = 0.5,
    [115] = 0.5,
    [116] = 0.5,
    [117] = 0.5,
    [118] = 0.5,
    [119] = 0.5,
    [120] = 0.5,
    [121] = 0.5,
    [122] = 0.5,
    [125] = 0.5,
    [146] = 0.5,
    [147] = 0.5,
    [148] = 0.5,
    [149] = 0.5,
    [150] = 0.5,
    [151] = 0.5,
    [152] = 0.5,
    [153] = 0.5,
    [160] = 0.5,

	-- dirt
    [19] = 1,
    [21] = 1,
    [22] = 1,
    [24] = 1,
    [25] = 1,
    [26] = 1,
    [27] = 1,
    [40] = 1,
    [83] = 1,
    [84] = 1,
    [87] = 1,
    [88] = 1,
    [100] = 1,
    [110] = 1,
    [123] = 1,
    [124] = 1,
    [126] = 1,
    [128] = 1,
    [129] = 1,
    [130] = 1,
    [132] = 1,
    [133] = 1,
    [141] = 1,
    [142] = 1,
    [145] = 1,
    [155] = 1,
    [156] = 1,

	-- sand
    [28] = 0.5,
    [29] = 0.5,
    [30] = 0.5,
    [31] = 0.5,
    [32] = 0.5,
    [33] = 0.5,
    [74] = 0.5,
    [75] = 0.5,
    [76] = 0.5,
    [77] = 0.5,
    [78] = 0.5,
    [79] = 0.5,
    [86] = 0.5,
    [96] = 0.5,
    [97] = 0.5,
    [98] = 0.5,
    [99] = 0.5,
    [131] = 0.5,
    [143] = 0.5,
    [157] = 0.5,

	-- vegetation
    [23] = 0.5,
    [41] = 0.5,
    [111] = 0.5,
    [112] = 0.5,
    [113] = 0.5,
    [114] = 0.5,

	-- misc
	[178] = 0.5,
}

function isLevel(level)
    level=math.floor(level)
    if(level < 1 or level == 1 or level == 2 or level == 3 or level == 4 or level == 5)then
        return true
    end
    return false
end

function addVariable(veh)
    local normal=0.5
    if(veh and getSurfaceVehicleIsOn(veh) and materialIDs[getSurfaceVehicleIsOn(veh)])then
        normal=materialIDs[getSurfaceVehicleIsOn(veh)]
    end
    return normal
end

function setVehicleDirtLevel(vehicle, level)
	level = tonumber(level)

    level=level > 5 and 5 or level
    level=not level and 1 or level
    level=level < 1 and 1 or level

    if(not isLevel(level))then return end
		
    if(vehs[vehicle] and vehs[vehicle].shader)then
    else
        vehs[vehicle]={}
        vehs[vehicle].shader = dxCreateShader("assets/textureReplace.fx")
    end

    dxSetShaderValue(vehs[vehicle].shader, "Grunge", grungeTextures[level])
    for k, v in pairs(replaceTextures) do
        for i=1, #v do
            engineApplyShaderToWorldTexture(vehs[vehicle].shader, v[i], vehicle)
        end
    end
end

function removeVehicleDirt(vehicle)
    if(vehs[vehicle] and vehs[vehicle].shader)then
        destroyElement(vehs[vehicle].shader)
        vehs[vehicle]={}
    end
end

function onPreRender()
    local v=getPedOccupiedVehicle(localPlayer)
    if(not v)then return removeEventHandler("onClientPreRender", root, onPreRender) end

    local data=getElementData(v, "vehicle:dirt") or 1
    if(not tonumber(data))then data=1 end

    if(#pos < 3)then
        pos={getElementPosition(v)}
    end

    local p={getElementPosition(v)}
    local dist=getDistanceBetweenPoints3D(p[1], p[2], p[3], pos[1], pos[2], pos[3])
    if(dist > 10 and data < 5)then
        pos={getElementPosition(v)}

        local add=addVariable(v)/2000
        data=data+add

        setElementData(v, "vehicle:dirt", data)
    end
end

addEventHandler("onClientVehicleEnter", root, function(plr,state)
    if(state ~= 0 or plr ~= localPlayer)then return end

    addEventHandler("onClientPreRender", root, onPreRender)
end)

addEventHandler("onClientVehicleExit", root, function(plr,state)
    if(state ~= 0 or plr ~= localPlayer)then return end

    removeEventHandler("onClientPreRender", root, onPreRender)
end)

addEventHandler("onClientElementDataChange", root, function(data, old, new)
    if(source and isElement(source) and getElementType(source) == "vehicle" and isElementStreamedIn(source) and data == "vehicle:dirt")then
        setVehicleDirtLevel(source, math.floor(new))
    end
end)

addEventHandler("onClientElementStreamIn", root, function()
    if(getElementType(source) ~= "vehicle")then return end

    local data=getElementData(source, "vehicle:dirt") or 1
    if(data)then
        setVehicleDirtLevel(source, math.floor(data))
    end
end)

addEventHandler("onClientElementStreamOut", root, function()
    local data=getElementData(source, "vehicle:dirt")
    if(data)then
        removeVehicleDirt(source)
    end
end)

for i,v in pairs(getElementsByType("vehicle", root, true)) do
    local data=getElementData(v, "vehicle:dirt") or 1
    setVehicleDirtLevel(v, math.floor(data))
end

if(isPedInVehicle(localPlayer))then
    addEventHandler("onClientPreRender", root, onPreRender)
end

-- useful

function getSurfaceVehicleIsOn(vehicle)
    if isElement(vehicle) and (isVehicleOnGround(vehicle) or isElementInWater(vehicle)) then -- Is an element and is touching any surface?
        local cx, cy, cz = getElementPosition(vehicle) -- Get the position of the vehicle
        local gz = getGroundPosition(cx, cy, cz) - 0.001 -- Get the Z position of the ground the vehicle is on (-0.001 because of processLineOfSight)
        local hit, _, _, _, _, _, _, _, surface = processLineOfSight(cx, cy, cz, cx, cy, gz, true, false) -- This will get the material of the thing the car is standing on
        if hit then
            return surface -- If everything is correct, stop executing this function and return the surface type
        end
    end
    return false -- If something isn't correct, return false
end