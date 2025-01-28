local elementSyncer = Object(1339, 0, 0, -5)
setElementID(elementSyncer, "faction_calls_syncer")
setElementData(elementSyncer, "callers", {
    ["SARA"] = {},
    ["SACC"] = {},
    ["PSP"] = {}
})

function addNewReport(player, faction, text)
    if(getElementDimension(player) ~= 0 or getElementInterior(player) ~= 0)then
        exports.px_noti:noti("Najpierw opuść interior!", player, "error")
        return
    end

    local syncData = elementSyncer:getData("callers")
    if(syncData[faction])then
        local x,y,z = getElementPosition(player)
        table.insert(syncData[faction], {
            location = {x,y,z},
            faction = faction,
            reporter = player.name .. " - ID: "..player:getData("user:id"),
            text = text,
            reporterEl = player,
            time = getRealTime().timestamp
        })
        player:setData("faction_report->active", {'not_approved', faction, #syncData[faction]})
    end
    elementSyncer:setData("callers", syncData)
end

addEvent("faction_calls->deleteReport", true)
addEventHandler("faction_calls->deleteReport", resourceRoot, function(id, faction, time)
    if(client:getData("faction_report->active")) then
        exports.px_noti:noti("Masz już aktywne zgłoszenie!", client, "error")
        return
    end

    local syncData = elementSyncer:getData("callers")
    local report = syncData[faction][id];

    if(report and report.time == time)then
        if(isElement(report.reporterEl))then
            local x,y,z = report.location[1], report.location[2], report.location[3]
            local shape = createColSphere(x, y, z, 20)
            attachElements(shape, report.reporterEl)

            report.reporterEl:setData("faction_report->active", {client, shape})
            client:setData("faction_report->active", {"driver", report.reporterEl, shape})

            exports.px_noti:noti("Pomyślnie przyjęto zgłoszenie.", client, "success")
            client:triggerEvent("faction_calls->setGPS", resourceRoot, report.location)

            exports.px_noti:noti(client.name.." przyjął Twoje zgłoszenie ("..faction..").", report.reporterEl, "success")
            table.remove(syncData[faction], id)

            local pos={getElementPosition(report.reporterEl)}
            local zone=getZoneName(pos[1],pos[2],pos[3],false)..", "..getZoneName(pos[1],pos[2],pos[3],true)
            for i,v in pairs(getElementsByType("player")) do
                if(getElementData(v,"user:faction") == "SACC" and faction == "SACC")then
                    outputChatBox(getPlayerName(client).." przyjął zgłoszenie od "..getPlayerName(report.reporterEl).." ("..zone..")", v, 255, 255, 0)
                    exports.px_custom_chat:addMessage(getPlayerName(client).." przyjął zgłoszenie od "..getPlayerName(report.reporterEl).." ("..zone..")", v, false, tocolor(255,255,0), client)
                elseif(getElementData(v,"user:faction") == "SARA" and faction == "SARA")then
                    outputChatBox(getPlayerName(client).." przyjął zgłoszenie od "..getPlayerName(report.reporterEl).." ("..zone..")", v, 255, 255, 0)
                    exports.px_custom_chat:addMessage(getPlayerName(client).." przyjął zgłoszenie od "..getPlayerName(report.reporterEl).." ("..zone..")", v, false, tocolor(255,255,0), client)
                elseif(getElementData(v,"user:faction") == "PSP" and faction == "PSP")then
                    outputChatBox(getPlayerName(client).." przyjął zgłoszenie od "..getPlayerName(report.reporterEl).." ("..zone..")", v, 255,0,0)
                    exports.px_custom_chat:addMessage(getPlayerName(client).." przyjął zgłoszenie od "..getPlayerName(report.reporterEl).." ("..zone..")", v, false, tocolor(255,0,0), client)
                end
            end
        else
            exports.px_noti:noti("Gracz zgłaszający wylogował się, zgłoszenie zostało odrzucone.", client, "error")
            table.remove(syncData[faction], id)
        end
    else
        exports.px_noti:noti("Te zgłoszenie zostało już przez kogoś przyjęte!", client, "error")
    end

    setElementData(elementSyncer, "callers", syncData)
end)

addEvent("faction_calls->denyReport", true)
addEventHandler("faction_calls->denyReport", resourceRoot, function(id, faction, time)
    if(client:getData("faction_report->active")) then
        exports.px_noti:noti("Masz już aktywne zgłoszenie!", client, "error")
        return
    end

    local syncData = elementSyncer:getData("callers")
    local report = syncData[faction][id];

    if(report and report.time == time)then
        if(isElement(report.reporterEl))then
            report.reporterEl:setData("faction_report->active", false) 
            exports.px_noti:noti("Pomyślnie odrzucono zgłoszenie.", client, "success")

            exports.px_noti:noti(client.name.." odrzucił Twoje zgłoszenie ("..faction..").", report.reporterEl, "success")
            table.remove(syncData[faction], id)
        else
            exports.px_noti:noti("Gracz zgłaszający wylogował się, zgłoszenie zostało odrzucone.", client, "error")
            table.remove(syncData[faction], id)
        end
    else
        exports.px_noti:noti("Te zgłoszenie zostało już przez kogoś przyjęte!", client, "error")
    end

    setElementData(elementSyncer, "callers", syncData)
end)

addEventHandler("onColShapeHit", resourceRoot, function(plr, md)
    if(plr:getData("faction_report->active"))then
        local currentReport = plr:getData("faction_report->active")
        if(currentReport[1] == "driver")then
            plr:triggerEvent("faction_calls->setGPS", resourceRoot, false)
            exports.px_noti:noti("Pomyślnie dojechano na miejsce zgłoszenia.", plr, "success")
            exports.px_noti:noti(plr.name.." dojechał na miejsce Twojego zgłoszenia.", currentReport[2], "success")
            plr:setData("faction_report->active", false)
            currentReport[2]:setData("faction_report->active", false)
            currentReport[3]:destroy()
        end
    end
end)

addEvent("cancel.report", true)
addEventHandler("cancel.report", resourceRoot, function(info)
    local source=client
    if(source:getData("faction_report->active"))then
        local currentReport = source:getData("faction_report->active")
        if(currentReport[1] == "driver")then
            exports.px_noti:noti(info and "Twoje zgłoszenie zostało anulowane." or "Zgłoszenie zostało anulowane ponieważ "..source.name.." wyszedł z gry!", currentReport[2], "success")
            currentReport[2]:setData("faction_report->active", false)

            if(currentReport[3] and isElement(currentReport[3]))then
                currentReport[3]:destroy()
            end

            if(info)then
                exports.px_noti:noti("Pomyślnie anulowano zgłoszenie.", client, "success")
                client:triggerEvent("faction_calls->setGPS", resourceRoot, false)
                client:setData("faction_report->active", false)
            end
        else
            if(currentReport[1] == "not_approved")then
                local syncData = elementSyncer:getData("callers")
                table.remove(syncData[currentReport[2]], syncData[currentReport[3]])
                elementSyncer:setData("callers", syncData)
            else
                currentReport[1]:triggerEvent("faction_calls->setGPS", resourceRoot, false)
                exports.px_noti:noti("Zgłoszenie zostało anulowane ponieważ "..source.name.." wyszedł z gry!", currentReport[1], "success")
                currentReport[1]:setData("faction_report->active", false)

                if(currentReport[2] and isElement(currentReport[2]))then
                    currentReport[2]:destroy()
                end
            end
        end
    end
end)

addEventHandler("onPlayerQuit", root, function()
    if(source:getData("faction_report->active"))then
        local currentReport = source:getData("faction_report->active")
        if(currentReport[1] == "driver")then
            exports.px_noti:noti("Zgłoszenie zostało anulowane ponieważ "..source.name.." wyszedł z gry!", currentReport[2], "success")
            currentReport[2]:setData("faction_report->active", false)

            if(currentReport[3] and isElement(currentReport[3]))then
                currentReport[3]:destroy()
            end
        else
            if(currentReport[1] == "not_approved")then
                local syncData = elementSyncer:getData("callers")
                table.remove(syncData[currentReport[2]], syncData[currentReport[3]])
                elementSyncer:setData("callers", syncData)
            else
                currentReport[1]:triggerEvent("faction_calls->setGPS", resourceRoot, false)
                exports.px_noti:noti("Zgłoszenie zostało anulowane ponieważ "..source.name.." wyszedł z gry!", currentReport[1], "success")
                currentReport[1]:setData("faction_report->active", false)

                if(currentReport[2] and isElement(currentReport[2]))then
                    currentReport[2]:destroy()
                end            
            end
        end
    end
end)