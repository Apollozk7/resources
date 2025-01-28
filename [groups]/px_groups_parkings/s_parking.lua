--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local CL={}

CL.places={
    {get={2281.3213,2431.6772,3.2734},respawn={2281.2671,2431.4424,3.2734,358.5130},faction="SAPD",desc="Pojazdy frakcyjne (SAPD)"},
    {get={2504.5784,911.8063,10.8281},respawn={2504.1885,912.5555,10.4495,89.9898},faction="SACC",desc="Pojazdy frakcyjne (SACC)"},
    --{get={70.6395,-333.5543,1.5781},respawn={70.1420,-334.5282,2.0715,0.6703},faction="SARA",desc="Pojazdy frakcyjne (SARA)"},
    --{get={2310.2310,1800.9346,11.0747,1.1},respawn={2293.8389,1798.4414,10.8530,179.3188},type="rental",desc="Pojazdy wypożyczone"}, -- wypo
    --{get={-2087.8528,-231.2360,35.5071},respawn={-2087.8528,-231.2360,35.5071,270},faction="PSP",desc="Pojazdy frakcyjne (PSP)"},
    --{get={-41.1081,1177.7872,19.5,1.5},respawn={-51.6565,1175.4554,19.3890,180.0133},type="organization",desc="Pojazdy organizacyjne"}, -- wypo
}

CL.getMarkers=function()
    for i,v in pairs(CL.places) do
        v.markerGet=createMarker(v.get[1], v.get[2], v.get[3], "cylinder", v.get[4] or 2, 255, 0, 0)

        setElementData(v.markerGet, "pos:z", v.get[3]-0.97)
        setElementData(v.markerGet, "text", {text="Parking wirtualny", desc=v.desc})
        setElementData(v.markerGet, "icon", ":px_groups_parkings/textures/garageMarker.png")

        setElementData(v.markerGet,"marker:get",v.respawn,false)
        setElementData(v.markerGet, "faction", v.faction, false)
        setElementData(v.markerGet, "org", v.org, false)
        setElementData(v.markerGet, "rental", v.type, false)
    end
end
CL.getMarkers()

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim)then
        local rental=getElementData(source, "rental")
        local uid=getElementData(hit, "user:uid")

        local faction=getElementData(source, "faction")
        local my=getElementData(hit, "user:faction")
        if(faction)then
            if(my ~= faction)then
                exports.px_noti:noti("Nie należysz do tej frakcji.", hit, "error")
                return
            end
        end

        local org=getElementData(source, "org")
        local my=getElementData(hit, "user:organization_tag")
        if(org)then
            if(my ~= org)then
                exports.px_noti:noti("Nie należysz do tej organizacji.", hit, "error")
                return
            end
        end
        
        local data=getElementData(source,"marker:get")
        if(data)then
            if(isPedInVehicle(hit))then 
                local veh=getPedOccupiedVehicle(hit)
                if(veh and isElement(veh) and not getElementData(veh, "respawned") and getVehicleController(veh) == hit)then
                    local id=getElementData(veh,"vehicle:group_id")
                    if(id)then
                        local q = exports.px_connect:query("update groups_vehicles set parking=1 where id=?", id)
                        if(q)then
                            exports.px_noti:noti("Pomyślnie oddano pojazd do przechowalni.", hit)
                            exports.px_groups_vehicles:saveVehicle(veh,'destroy')
                        end
                    end
                end
            else
                local faction_=getElementData(hit, "user:faction")
                local org_=getElementData(hit, "user:organization")
                if((faction and faction_) or (org and org_))then
                    local vehs=exports.px_connect:query("select * from groups_vehicles where owner=? and parking=1", (faction and faction_) or (org and org_))
                    if(vehs and #vehs > 0)then
                        triggerClientEvent(hit, "get.vehicles", resourceRoot, vehs)
                        setElementData(hit,"marker:get",data,false)
                    else
                        exports.px_noti:noti("Na parkingu wirtualnym nie ma żadnych pojazdów.", hit)
                    end
                else
                    if(rental)then
                        if(rental == "organization")then
                            if(org_)then
                                local vehs=exports.px_connect:query("select * from groups_vehicles where owner=? and parking=1", org_)
                                if(vehs and #vehs > 0)then
                                    triggerClientEvent(hit, "get.vehicles", resourceRoot, vehs)
                                    setElementData(hit,"marker:get",data,false)
                                else
                                    exports.px_noti:noti("Na parkingu wirtualnym nie ma żadnych pojazdów.", hit)
                                end
                            end
                        else
                            local vehs=exports.px_connect:query("select * from groups_vehicles where owner=? and parking=1", uid)
                            if(vehs and #vehs > 0)then
                                triggerClientEvent(hit, "get.vehicles", resourceRoot, vehs)
                                setElementData(hit,"marker:get",data,false)
                            else
                                exports.px_noti:noti("Na parkingu wirtualnym nie ma żadnych pojazdów.", hit)
                            end
                        end
                    end
                end
            end
        end
    end
end)

addEventHandler("onMarkerLeave", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and dim)then
        local data=getElementData(source,"marker:get")
        if(data)then
            triggerClientEvent(hit, "get.vehicles", resourceRoot)
            setElementData(hit,"marker:get",false,false)
        end
    end
end)

-- triggers

addEvent("get.vehicle", true)
addEventHandler("get.vehicle", resourceRoot, function(id)
    local uid=getElementData(client,"user:uid")
    if(not uid)then return end

    local data=getElementData(client,"marker:get")
    if(not data)then return end

    local q=exports.px_connect:query("select * from groups_vehicles where id=? and parking=1", id, uid)
    if(q and #q > 0)then
        local access=q[1].access
        if(access and #access > 0)then
            if(not exports.px_factions:isPlayerHaveRole(getPlayerName(client),access))then exports.px_noti:noti("Brak uprawnień.", client, "error") return end
        end

        exports.px_connect:query("update groups_vehicles set parking=0 where id=?", id)

        local veh=exports.px_groups_vehicles:createNewVehicle(id,client)
        if(veh and isElement(veh))then
            setElementPosition(veh, data[1],data[2],data[3])
            setElementRotation(veh, 0,0,data[4])

            setElementData(veh,"respawned",true,false)
            setTimer(function()
                setElementData(veh,"respawned",false,false)
            end,150,1)

            exports.px_noti:noti("Pomyślnie wyciągnięto pojazd z przechowalni.", client)
        else
            exports.px_connect:query("update groups_vehicles set parking=1 where id=?", id)
        end
    end
end)