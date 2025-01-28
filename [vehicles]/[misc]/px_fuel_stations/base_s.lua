--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- variables

local FUEL={}

FUEL.places={
    ["Fort Carson"]={
        {64.8319,1220.0867,18.8283},
        {70.5568,1218.6897,18.8125},
        {76.2120,1217.2383,18.8272},
    },

    ['LV obok tunelu']={
        {622.5535,1680.2396,6.9922},
        {619.0626,1684.7028,6.9922},
        {615.5170,1689.8892,6.9922},
        {612.2433,1694.9374,6.9922},
        {608.5046,1699.4756,6.9922},
        {605.1069,1704.5791,6.9922},
    },

    ['LV Mechanik']={
        {2639.7019,1116.4891,10.8203},
        {2640.1560,1106.7784,10.8203},
        {2640.2720,1096.1189,10.8203},
    },

    ['LV Strip']={
        {2114.7493,909.9753,10.8203},
        {2114.5767,919.4855,10.8203},
        {2114.7090,929.8077,10.8203},
    },

    ['LV Redsands']={
        {1596.1211,2189.4702,10.8203},
        {1595.7023,2199.5391,10.8203},
        {1595.9597,2209.8589,10.8203},
    },

    ['LV Spinybed']={
        {2147.9248,2757.2146,10.8203},
        {2147.8298,2748.0303,10.8203},
        {2147.7764,2739.7610,10.8203},
    },

    ['LV KGP']={
        {2202.3853,2474.8154,10.8203},
        {2193.5193,2474.8154,10.8203},
        {2210.9531,2474.8154,10.8203},
    },

    ['Wioska 51']={
        {209.1153,1938.4254,18.3750},
        {198.4745,1938.4692,18.3848},
        {188.2576,1938.2045,18.3750},
    }
}

FUEL.allowedTypes={
    ['Automobile']=true,
    ['Quad']=true,
    ['Bike']=true,
}

FUEL.blockedModels={
    ['Bike']=true,
    ['Mountain Bike']=true
}

-- create

for place, markers in pairs(FUEL.places) do
    outputDebugString('[px_fuel_stations] ✓ Successfully created fuel station in '..place)

    local savePosition
    for i,v in pairs(markers) do
        local marker=createMarker(v[1], v[2], v[3]+0.1, 'cylinder', 2, 0, 200, 100)
        setElementData(marker, "icon", ":px_fuel_new/textures/fuel_marker.png")
        setElementData(marker, "text", {text="Tankowanie pojazdu",desc="W tym miejscu zatankujesz swój pojazd"})

        if(not savePosition)then
            savePosition=v
        end
    end

    if(savePosition)then
        local blip = createBlip(savePosition[1], savePosition[2], savePosition[3], 10)
        setBlipVisibleDistance(blip, 500)
    end
end

-- events

addEventHandler('onMarkerHit', resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and dim and getElementType(hit) == 'player' and isPedInVehicle(hit))then
        local v=getPedOccupiedVehicle(hit)
        if(FUEL.allowedTypes[getVehicleType(v)] and not FUEL.blockedModels[getElementModel(v)])then
            if(getVehicleController(v) == hit)then
                triggerClientEvent(hit, 'fuelStation:createTankUI', resourceRoot, v, source)
            end
        else
            exports.px_noti:noti('Niestety ale nie możesz zatankować tego typu pojazdu. :/', hit, 'error')
        end
    end
end)

-- triggers

addEvent("fuel.add", true)
addEventHandler("fuel.add", resourceRoot, function(vehicle, newFuel, cost, type)
    if(vehicle and isElement(vehicle))then
        cost=tonumber(cost)
        cost=math.floor(cost)

        newFuel=tonumber(newFuel)

        if(getPlayerMoney(client) >= cost)then
            takePlayerMoney(client, cost) -- take money

            local bak=getElementData(vehicle, 'vehicle:fuelTank') or 25
            if(type == "LPG")then
                local lastFuel = getElementData(vehicle, "vehicle:gas") or 0
                local max=lastFuel+newFuel
                if(max > bak)then
                    max=bak
                end

                setElementData(vehicle, "vehicle:gas", max) -- tank vehicle

                exports.px_noti:noti("Dolałeś "..math.floor(newFuel).."L gazu ("..type.."), do pojazdu "..getVehicleName(vehicle)..", za cene "..cost.."$", client) -- get info
            else
                local lastFuel = getElementData(vehicle, "vehicle:fuel") or 0
                local max=lastFuel+newFuel
                if(max > bak)then
                    max=bak
                end

                setElementData(vehicle, "vehicle:fuel", max) -- tank vehicle

                exports.px_noti:noti("Dolałeś "..math.floor(newFuel).."L paliwa ("..type.."), do pojazdu "..getVehicleName(vehicle)..", za cene "..cost.."$", client) -- get info
            end

            local org=getElementData(client, "user:organization")
            if(org)then
                exports.px_organizations:updateOrganizationTask(org, "addFromFuelStation", newFuel)
            end
        else
            exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
        end
    else
        exports.px_noti:noti("Podany pojazd nie istnieje.", client, "error")
    end
end)