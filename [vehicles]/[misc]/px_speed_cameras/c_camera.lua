--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

SPAM={}
SPAM.getSpam=function()
    local block=false

    if(SPAM.blockSpamTimer)then
        killTimer(SPAM.blockSpamTimer)
        exports.px_noti:noti("Zaczekaj jedną sekunde.", "error")
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return block
end

-- speed

function getElementSpeed(theElement, unit)
    -- Check arguments for errors
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    -- Default to m/s if no unit specified and "ignore" argument type if the string contains a number
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    -- Setup our multiplier to convert the velocity to the specified unit
    local mult = (unit == 0 or unit == "m/s") and 50 or ((unit == 1 or unit == "km/h") and 180 or 111.84681456)
    -- Return the speed by calculating the length of the velocity vector, after converting the velocity to the specified unit
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

--

-- variables

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

local miejsca = {
	{object={2598.8779,1307.1112,10.8203,64.0811}, zone={2589.1375,1313.2046,10.6719,4}, speed=70},
	{object={1013.4745,1673.3101,10.9141,136.3448}, zone={1007.5111,1666.9146,10.7734,4}, speed=70},
	{object={397.2316,1589.7578,18.2143,284.0371}, zone={409.2899,1592.7731,17.8160,4}, speed=110},
	{object={2517.5710,1479.2925,10.8203,227.8815}, zone={2524.0801,1473.4062,10.6719,4}, speed=70},
	{object={2613.2710,1131.6400,10.8203,146.4334}, zone={2607.3049,1121.8480,10.6719,4}, speed=70},
	{object={1713.4985,1996.0323,10.8203,146.2755}, zone={1707.5039,1986.7397,10.6719,4}, speed=70},
}

function getCameras()
	return miejsca
end

-- create

for k,v in pairs(miejsca) do
	local cs = createColSphere(unpack(v.zone))
	setElementData(cs, "cs", v, false)

	createObject(16101, v.object[1], v.object[2], v.object[3]-1.1, 0, 0, v.object[4]+180)
end

-- render

local cost=100 -- za kazde 10km

local tick=false
onRender=function()
	dxDrawImage(61/zoom, 419/zoom, 432/zoom, 243/zoom, render, 350, 0, 0, tocolor(255,255,255), true)

	if((getTickCount()-tick) > 5000)then
		removeEventHandler("onClientRender",root,onRender)

		checkAndDestroy(font)
		checkAndDestroy(ss)
		checkAndDestroy(render)

		tick=false
	end
end

-- hit

local antyLag=false
addEventHandler("onClientColShapeHit",resourceRoot,function(hit,dim)
	if(hit == localPlayer and isPedInVehicle(hit) and dim and not antyLag)then
		local cs=getElementData(source, "cs")
		if(not cs)then return end

		pojazd = getPedOccupiedVehicle(localPlayer)
	
		if(getVehicleSirensOn(pojazd) or getVehicleType(pojazd) == "Plane" or getVehicleType(pojazd) == "Helicopter" or getVehicleType(pojazd) == "Boat" or getVehicleType(pojazd) == "BMX" or getElementDimension(localPlayer) ~= 0 or getElementInterior(localPlayer) ~= 0 or getVehicleController(pojazd) ~= localPlayer)then return end
		
		if(getElementData(pojazd, "emergency_signals"))then return end

		if(SPAM.getSpam())then return end

		kmh = getElementSpeed(pojazd, 1)
		kmh=math.floor(kmh)
		przekroczenie = kmh-cs.speed
		limit = cs.speed

		antyLag=true
		setTimer(function() antyLag=not antyLag end, 1000, 1)

		if(kmh >= (cs.speed+10))then
			fadeCamera(false,0.1,255,255,255)

			ss = dxCreateScreenSource(432,243)
			ss = dxCreateScreenSource(432,243)
			font = dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 10)
			render = dxCreateRenderTarget(432,243)

			setTimer(function()
				dxSetRenderTarget(render)
					dxDrawImage(0, 0, 432, 243, ss, 0, 0, 0, tocolor(255,255,255), false)
			
					local w=dxGetTextWidth(getVehiclePlateText(pojazd),1,font)+15
					dxDrawRectangle(432/2-w/2, 10, w, 25,tocolor(15,15,15,200))
					dxDrawText(getVehiclePlateText(pojazd), 432/2-w/2, 10, w+432/2-w/2, 10+25, tocolor(0, 153, 51), 1, font, "center", "center")

					local w=dxGetTextWidth("KM/H: "..kmh,1,font)+15
					dxDrawRectangle(432-w, 243-70, w, 20, tocolor(15,15,15,200))
					dxDrawText("KM/H: "..kmh, 432-w, 243-70, w+432-w, 20+243-70, tocolor(200,200,200), 1, font, "center", "center", false)

					local w=dxGetTextWidth("LIMIT: "..limit.."KM/H",1,font)+15
					dxDrawRectangle(432-w, 243-45, w, 20, tocolor(15,15,15,200))
					dxDrawText("LIMIT: "..limit.."KM/H", 432-w, 243-45, w+432-w, 20+243-45, tocolor(200,200,200), 1, font, "center", "center", false)

					local w=dxGetTextWidth("PRZEKROCZYŁEŚ: "..przekroczenie.."KM/H",1,font)+15
					dxDrawRectangle(432-w, 243-20, w, 20, tocolor(15,15,15,200))
					dxDrawText("PRZEKROCZYŁEŚ: "..przekroczenie.."KM/H", 432-w, 243-20, w+432-w, 20+243-20, tocolor(200,200,200), 1, font, "center", "center", false)
				dxSetRenderTarget()
			end, 50, 1)

			setTimer(fadeCamera,60,1,true,1.5)

			dxUpdateScreenSource(ss)
			playSound("sounds/radar.wav")

			triggerLatentServerEvent("get.mandate", resourceRoot, ((przekroczenie/10)*cost))

			if(not tick)then
				addEventHandler("onClientRender",root,onRender)
				tick=getTickCount()
			end
		end
	end
end)

-- useful

checkAndDestroy=function(element)
	if(element and isElement(element))then
		destroyElement(element)
		element=nil
		return true
	end
	return false
end