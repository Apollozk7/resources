--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

local CLASS={}

CLASS.places={
    ["Warsztat LV"]={
        startMarker={2651.4907,1238.3418,10.8500},
        endCS={2617.50391, 1163.48975, 9.6, 59.740234375, 79.58935546875, 10.590000534058},
        slots={
            ["Mechanik"]={value=0,max=2,elements={}},
            ["Lakiernik"]={value=0,max=1,elements={}},
            ["Tuner"]={value=0,max=2,elements={}},
        },
    },
}

CLASS.createPlaces=function()
    for i,v in pairs(CLASS.places) do
        v.tag=i

        local start=createMarker(v.startMarker[1], v.startMarker[2], v.startMarker[3]-0.99, "cylinder", 1.5, 160, 176, 110)
        local cs=createColCuboid(unpack(v.endCS))
        setElementData(start, "icon", ":px_workshops/assets/images/wrench.png")
        setElementData(start, "pos:z", true)
        setElementData(start, "tag", v.tag)
        setElementData(cs, "tag", v.tag)
        setElementData(start, "text", {text="Warsztat",desc="Tutaj rozpoczniesz pracę"})
    end
end

CLASS.isPlayerInJob=function(player, tag)
    local uid=getElementData(player, "user:uid")
    if(not uid)then return false end

    local q=exports.px_connect:query("select * from office_jobs_users where name=? and (job=? or job=?)", getPlayerName(player), "Mechanik "..tag, "Tuner "..tag)
    if(#q > 0)then
        return q
    end
    return false
end

CLASS.setFreeSlot=function(player,tag,name)
    if(not CLASS.places[tag])then return end

    local places=CLASS.places[tag].slots[name]
    if(places and places.elements[player])then
        places.value=places.value-1
        places.elements[player]=nil
    end
end

addEventHandler("onMarkerHit", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and dim and getElementType(hit) == "player" and not isPedInVehicle(hit))then
        local tag=getElementData(source, "tag")
        if(tag)then
            local is=CLASS.isPlayerInJob(hit,string.sub(tag,#tag-1,#tag))
            if(is)then
                triggerClientEvent(hit, "ui.open", resourceRoot, tag, is, string.sub(tag,#tag-1,#tag))
            else
                exports.px_noti:noti("Nie jesteś zatrudniony w żadnej pracy urzędowej.", hit, "error")
            end
        end
    end
end)

addEventHandler("onColShapeLeave", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and dim and getElementType(hit) == "player")then
        local tag=getElementData(source, "tag")
        local data=getElementData(hit, "user:job_settings")
        if(tag and data and data.job_tag == tag)then
            local skin=getElementData(hit, "user:skin")
            if(skin)then
                setElementModel(hit, skin)
                setElementData(hit, "user:skin", false, false)
                setElementData(hit, 'custom_name', false)
            end

            setElementData(hit, "user:job_settings", false)
            setElementData(hit, "user:job", false)

            exports.px_noti:noti("Wyszedłeś poza teren warsztatu, praca została zakończona.", hit, "info")

            CLASS.setFreeSlot(hit,tag,data.job_name)
        end
    end
end)

addEventHandler("onPlayerWasted", root, function()
    local data=getElementData(source, "user:job_settings")
    if(data and CLASS.places[data.job_tag])then
        local skin=getElementData(source, "user:skin")
        if(skin)then
            setElementModel(source, skin)
            setElementData(source, "user:skin", false, false)
            setElementData(source, 'custom_name', false)
        end

        setElementData(source, "user:job_settings", false)
        setElementData(source, "user:job", false)

        exports.px_noti:noti("Zginąłeś, praca została zakończona.", source, "info")

        CLASS.setFreeSlot(source,data.job_tag,data.job_name)
    end
end)

addEvent("last.skin", true)
addEventHandler("last.skin", resourceRoot, function(tag,name,info,city)
    CLASS.setFreeSlot(client,tag,name)

    local skin=getElementData(client, "user:skin")
    if(skin)then
        setElementData(client, 'custom_name', false)
        setElementModel(client, skin)
        setElementData(client, "user:skin", false)
    end
end)

addEventHandler("onPlayerQuit", root, function()
    local data=getElementData(source, "user:job_settings")
    if(data and data.job_tag and CLASS.places[data.job_tag])then
        CLASS.setFreeSlot(source,data.job_tag,data.job_name)
    end
end)

local checkTimers={}

addEvent("set.duty", true)
addEventHandler("set.duty", resourceRoot, function(info,tag,city)
    local places=CLASS.places[tag].slots[info.name]
    if(places)then
        if((places.value+1) <= places.max)then
            exports.px_noti:noti("Pomyślnie rozpoczęto pracę w warsztacie jako "..info.name..".", client, "success")
            if(info.name == 'Lakiernik')then
                exports.px_noti:noti("Pamiętaj że służba Lakiernika nie wystarczy aby nie zwolniono Cię z pracy!", client, "success")
            end

            setElementData(client, "user:job_settings", {
                job_name=info.name,
                job_tag=tag,
                job_hour_money=3500,
                job_add_hour_money=true,
                officeCity=city
            })
        
            setElementData(client, "user:job", info.name)
        
            setElementData(client, "user:skin", getElementModel(client))
            setElementData(client, 'custom_name', utf8.lower(info.name)..'_skin')
        
            exports.px_connect:query("update office_jobs_users set date=now() where name=? and job=?", getPlayerName(client), info.name.." "..city)

            places.value=places.value+1
            places.elements[client]=true

            if(getElementData(client, "color:spray"))then
                setElementData(client, "color:spray", false)
            end
            takeWeapon(client,41)

            checkTimers[client]=setTimer(function(client)
                if(client and isElement(client))then
                    local places=CLASS.places[tag].slots[info.name]
                    if(places)then
                        if(places.value > places.max)then
                            setElementData(client, "user:job_settings", false)
                            setElementData(client, "user:job", false)
                
                            CLASS.setFreeSlot(client,tag,info.name)

                            local skin=getElementData(client, "user:skin")
                            if(skin)then
                                setElementModel(client, skin)
                                setElementData(client, "user:skin", false)
                                setElementData(client, 'custom_name', false)
                            end      
                            
                            checkTimers[client]=nil
                        end
                    end
                end
            end, 1500, 1, client)
        else
            exports.px_noti:noti("W tej pracy wszystkie miejsca są zajęte.", client, "error")
        end
    end
end)

CLASS.createPlaces()

addEventHandler('onElementDataChange', root, function(data,old,new)
    if(data == 'user:job_settings' and not new and old.officeCity)then
        exports.px_connect:query("update office_jobs_users set date=now() where name=? and job=?", getPlayerName(source), old.job_name.." "..old.officeCity)
    end
end)