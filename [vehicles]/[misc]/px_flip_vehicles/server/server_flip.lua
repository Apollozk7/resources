--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local timer={}

function action(i, element, client, name, id, veh)
    if(getElementData(client, "oferta:obracanie"))then return end

    if(getElementType(veh) ~= "vehicle")then
        local lastElement=element
        element=veh
        veh=lastElement

        if(getElementData(element, "oferta:obracanie"))then return end
    else
        if(getElementData(element, "oferta:obracanie"))then return end
    end

    exports.px_noti:noti("Wysłano prośbę o pomoc, w odwróceniu samochodu do: "..getPlayerName(element), client)

    setElementData(client, "oferta:obracanie", element, false)
    setElementData(element, "oferta:obracanie", client, false)

    triggerClientEvent(element,"client>oferta",resourceRoot,veh,client)
end

addEvent("client->anuluj",true)
addEventHandler("client->anuluj",resourceRoot,function()
    noti=exports.px_noti

    local oferta=getElementData(client, "oferta:obracanie")
    if(not oferta)then return end

    if(isElement(oferta))then
        exports.px_noti:noti("Gracz "..getPlayerName(client).." anulował twoją prośbę.", oferta)
        exports.px_noti:noti("Pomyślnie anulowano prośbę od gracza "..getPlayerName(oferta)..".", client)

        setElementData(client, "oferta:obracanie", false, false)
        setElementData(oferta, "oferta:obracanie", false, false)
    else
        exports.px_noti:noti("Pomyślnie anulowano prośbę.", client)
        setElementData(client, "oferta:obracanie", false, false)
    end
end)

addEvent("client->cancel",true)
addEventHandler("client->cancel",resourceRoot,function()
    noti=exports.px_noti

    local oferta=getElementData(client, "oferta:obracanie")
    if(not oferta)then return end

    if(oferta and isElement(oferta))then
        exports.px_noti:noti("Czas na obrócienie pojazdu minął.", oferta)
        setElementData(oferta, "oferta:obracanie", false, false)
        setElementFrozen(oferta, false)
    end

    exports.px_noti:noti("Czas na obrócienie pojazdu minął.", client)
    setElementData(client, "oferta:obracanie", false, false)
    setElementFrozen(client, false)
end)

addEvent("client->akceptuj",true)
addEventHandler("client->akceptuj",resourceRoot,function(pojazd)
    noti=exports.px_noti

    local oferta=getElementData(client, "oferta:obracanie")
    if(not oferta)then return end

    if(isElement(oferta))then
        triggerClientEvent(client,"client>obroc_pojazd",resourceRoot,pojazd)
        triggerClientEvent(oferta,"client>obroc_pojazd",resourceRoot,pojazd)
    else
        exports.px_noti:noti("Gracz wyszedł z serwera.", client)
        setElementData(client, "oferta:obracanie", false, false)
    end
end)

addEvent("server>obroc_pojazd",true)
addEventHandler("server>obroc_pojazd",resourceRoot,function(pojazd)
    noti=exports.px_noti
    core = exports.px_core

    local pomocnik=getElementData(client, "oferta:obracanie")
    if(pomocnik and isElement(pomocnik))then
        if(getElementData(pomocnik, "oferta:obracanie"))then
            exports.px_noti:noti("Teraz zaczekaj na drugą osobę.", client)

            setElementData(client, "oferta:obracanie", false, false)

            setElementFrozen(client, false)
        else
            local data=getElementData(client, "oferta:obracanie")
            if(data)then
                exports.px_noti:noti("Pomyślnie obrócono pojazd na koła.", client)

                local rx,ry,rz = getElementRotation(pojazd)
                setElementRotation(pojazd, 0, ry,rz)

                setElementFrozen(client, false)

                exports.px_core:outputChatWithDistance(client, "wraz z "..getPlayerName(data)..", wspólnymi siłami, przewracają pojazd "..getVehicleName(pojazd).." na koła.", 15)
            end
            setElementData(client, "oferta:obracanie", false, false)
        end
    else
        setElementData(client, "oferta:obracanie", false, false)
        exports.px_noti:noti("Gracz wyszedł z serwera.", client)
    end
end)

addEventHandler("onPlayerQuit", root, function()
    local oferta=getElementData(source, "oferta:obracanie")
    if(oferta)then
        setElementData(source, "oferta:obracanie", false, false)
        if(isElement(oferta))then
            setElementData(oferta, "oferta:obracanie", false, false)
            setElementFrozen(oferta, false)
        end
    end
end)
