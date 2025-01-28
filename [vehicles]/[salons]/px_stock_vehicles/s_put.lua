--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

VEH = {}

-- wystawienie pojazdu

function addStockVehicle(v, cost, offline)
    local owner_uid=getElementData(v, "vehicle:ownerName")
    if(not owner_uid)then return end

    local business=false
    local r=exports['px_connect']:query('select name from groups_business where owner=? limit 1', owner_uid)
    if(r and #r == 1)then
        business=r[1].name
        offline=false
    end

    local engine=getElementData(v, "vehicle:engine") or export:getVehicleEngineFromModel(getElementModel(v))
    local fuel_usage=exports.px_custom_vehicles:getFuelUsage(engine)
    local naped=getVehicleHandling(v).driveType

    local tune=''
    local infos={
        {"MK1", 'mk1'},
        {"MK2", 'mk2'},
        {"MultiLED", 'multiLED'},
        {"Zawieszenie", 'suspension'},
        {"Turbo", 'turbo'},
        {"Hamulce", 'brakes'},
        {"Nitro", 'nitro'},
        {"ASR OFF", 'ASR'},
        {"ALS", 'ALS'},
        {"Wykrywacz radarów", 'radarDetector'},
        {"CB-Radio", 'cbRadio'},
        {"Kolor licznika", 'speedoColor'},
        {"Maskowanie szyb", 'tint'},
    }
    for _,k in pairs(infos) do
        local data=getElementData(v, 'vehicle:'..k[2])
        if(data)then
            if(data == true)then
                tune=#tune > 0 and tune..', '..k[1] or k[1]
            else
                local text=data == true and 'tak' or data
                if(k[1] == 'Maskowanie szyb')then
                    text=text..'%'
                end
                tune=#tune > 0 and tune..', '..k[1]..' ('..text..')' or k[1]..' ('..text..')'
            end
        end
    end
    if(tune == '')then
        tune='brak'
    end

    local upgrades=''
    local u=getVehicleUpgrades(v)
    for _,k in pairs(u) do
        local t=exports['px_workshop_tuning']:getVehicleUpgradeInfo(k) or '(?)'
        upgrades=#upgrades > 0 and upgrades..", "..t or t
    end
    if(upgrades == '')then
        upgrades='brak'
    end

    setElementData(v, "vehStock:puted", {
        cost=cost, 
        distance=string.format("%08.1f", getElementData(v, "vehicle:distance")),
        fuel=math.floor(getElementData(v, "vehicle:fuel")),
        tank=getElementData(v, "vehicle:fuelTank"),
        fuelType=getElementData(v, "vehicle:fuelType"),
        naped=naped == "rwd" and "Tylna oś" or naped == "fwd" and "Przednia oś" or naped == "awd" and "Obie osie",
        engine=engine,
        fuel_usage=fuel_usage,
        drawCost=convertNumber(cost),
        owner=getElementData(v, "vehicle:ownerName"),
        id=getElementData(v, "vehicle:id"),
        offline=offline,
        ownerID=getElementData(v, "vehicle:owner"),
        mech_tune=tune,
        tune=upgrades,
        business=business
    })

    if(offline)then
        setElementData(v, "interaction", {options={
            {name="Zakup pojazd", alpha=150, animate=false, tex=":px_salon_vehicles/textures/car_buy.png"},
        }, scriptName="px_stock_vehicles", dist=3, type="server"})
    end
end

function saveStockVehicles()
    exports.px_connect:query("delete from vehicles_stock")
    for i,v in pairs(getElementsByType("vehicle")) do
        local puted=getElementData(v, "vehStock:puted")
        if(puted)then
            exports.px_connect:query("insert into vehicles_stock (vehID,cost,offline) values(?,?,?)", getElementData(v, "vehicle:id"), puted.cost, puted.offline)
        end
    end
end
addEventHandler("onResourceStop", resourceRoot, saveStockVehicles)

function loadStockVehicles()
    for i,v in pairs(exports.px_connect:query("select * from vehicles_stock")) do
        local veh=getElementByID("px_vehicles_id:"..v.vehID)
        if(veh and isElement(veh))then
            addStockVehicle(veh,v.cost,v.offline == 1 and true)
        end
    end
end
addEventHandler("onResourceStart", resourceRoot, loadStockVehicles)

addEvent("set.vehicle", true)
addEventHandler("set.vehicle", resourceRoot, function(v, cost, offline)
    local uid=getElementData(client, 'user:uid')
    if(not uid)then return end
    
    if(offline)then
        local r=exports['px_connect']:query('select name from groups_business where owner=? limit 1', uid)
        if(r and #r == 1)then
            exports['px_noti']:noti('Posiadając biznes nie możesz handlować offline.', client, 'error')
            return
        end

        if(getPlayerMoney(client) < 500)then
            exports.px_noti:noti("Aby wystawić pojazd offline potrzebujesz 500$.", client, "error")
            return
        else
            takePlayerMoney(client, 500)
        end
    end

    exports.px_noti:noti("Pomyślnie wystawiono pojazd "..getVehicleName(v).." za kwotę "..convertNumber(cost).."$.", client, "success")

    addStockVehicle(v, cost, offline)
end)

-- usuwanie jak wyjedzie z gieldy (tablicy etc)

function destroySellOpis(veh)
    if(veh and isElement(veh))then
        if(getElementData(veh, "vehStock:puted"))then
            setElementData(veh, "interaction", false)
            setElementData(veh, "vehStock:puted", false)
            setElementFrozen(veh, false)
        end
    end
end

addEventHandler("onColShapeLeave", resourceRoot, function(hit, dim)
    if(hit and isElement(hit) and dim and getElementType(hit) == "player")then
        local v=getPedOccupiedVehicle(hit)
        if(v and isElement(v))then
            setElementData(v, "vehStock:ghost", false)

            destroySellOpis(v)
        end
    end
end)

addEventHandler("onElementDestroy", root, function()
    destroySellOpis(source)
end)

-- ghost pojazdow, usuwanie jak stoja na gieldzie

VEH.shape = createColPolygon(2758.5244,1224.0465,2860.3921,1224.0924,2860.3872,1382.3395,2798.1992,1382.3472,2797.3958,1302.5215,2758.2861,1302.3951,2758.5247,1224.0465)
addEventHandler("onColShapeHit", VEH.shape, function(hit, dim)
    if(hit and isElement(hit) and dim and getElementType(hit) == "player")then
        local elements=getElementsWithinColShape(source, "vehicle")
        triggerClientEvent(hit, "onShapeHit", resourceRoot, elements)

        local v=getPedOccupiedVehicle(hit)
        if(v and isElement(v))then
            setElementData(v, "vehStock:ghost", true)
        end
    end
end)

addEventHandler("onVehicleExit", root, function(player,seat)
    if(not isElement(source))then return end
    if(seat == 0 and isElementWithinColShape(source,VEH.shape))then
        setElementData(source,"vehicle:handbrake", true)
        setElementFrozen(source,true)
    end
end)

setTimer(function()
    for i,v in pairs(getElementsWithinColShape(VEH.shape, "vehicle")) do
        if(not getVehicleController(v) and not getElementData(v, "vehStock:puted"))then
            setTimer(function()
                if(v and isElement(v) and not getVehicleController(v) and not getElementData(v, "vehStock:puted"))then
                    local i = getElementData(v, "vehicle:id")
                    local group=getElementData(v, "vehicle:group_id")
                    if(group)then
                        exports.px_groups_vehicles:saveVehicle(v)
                        destroyElement(v)
                        exports.px_connect:query("update groups_vehicles set parking=1 where id=?", group)
                    else
                        local owner=getElementData(v, "vehicle:owner")
                        if(owner and i)then
                            local parking_id=exports.px_connect:query("select id from vehicles_garages where playerID=? limit 1", owner)
                            if(parking_id and #parking_id == 1)then
                                exports.px_vehicles:saveVehicle(v)
                                destroyElement(v)
                
                                exports.px_connect:query("update vehicles set parking=?,position=NULL where id=?", parking_id[1].id, i)
                            end
                        end
                    end
                end
            end, 1000*30, 1)
        end
    end
end, 1000*30, 0) -- timer co minutke

-- export

function action(id, veh, player, name)
    if(name == "Zakup pojazd")then
        local uid=getElementData(player, "user:uid")
        local sell=getElementData(veh, "vehStock:puted")
        local id=getElementData(veh, "vehicle:id")
        if(not sell or not uid or not id)then return end

        if(sell.ownerID ~= uid)then
            local q=exports.px_connect:query("select * from vehicles where owner=? and id=?", sell.ownerID, id)
            if(q and #q > 0)then
                local getFree,have,slots=exports.px_vehicles:getPlayerFreeVehicleSlot(player)
                if(getFree)then
                    if(getPlayerMoney(player) >= tonumber(sell.cost))then
                        takePlayerMoney(player, tonumber(sell.cost))

                        local owner=getPlayerFromName(sell.owner)
                        if(owner and isElement(owner) and getElementData(owner, "user:uid"))then
                            givePlayerMoney(owner, tonumber(sell.cost))
                            exports.px_noti:noti(getPlayerName(player).." zakupił twój pojazd "..getVehicleName(veh).." ["..id.."] za kwotę "..convertNumber(sell.cost).."$", owner, "success")
                        else
                            exports.px_phone:sendSMS(sell.ownerID, "Kupno pojazdu", "Gracz "..getPlayerName(player).." zakupił twój pojazd "..getVehicleName(veh).." ("..id..") za cene "..sell.cost.."$.", "Giełda Las Venturas")
                            exports.px_connect:query("update accounts set money=money+? where id=?", tonumber(sell.cost), sell.ownerID)
                        end

                        setElementData(veh, "vehicle:owner", uid)
                        setElementData(veh, "vehicle:ownerName", getPlayerName(player))

                        setElementData(veh, "interaction", false)
                        setElementData(veh, "vehStock:puted", false)
                        setElementFrozen(veh, false)

                        exports.px_discord:sendDiscordLogs("[GIELDA] Kupiono pojazd "..getVehicleName(veh).." za cene "..convertNumber(sell.cost).."$.", "wymiany", player)
                        exports.px_discord:sendDiscordLogs("[GIELDA] Kupiono pojazd "..getVehicleName(veh).." za cene "..convertNumber(sell.cost).."$.", "hajs", player)

                        exports.px_connect:query("update vehicles set owner=?,ownerName=?, orgRank=0, organization=? where id=?", uid, getPlayerName(player), "", id)

                        warpPedIntoVehicle(player, veh)

                        exports.px_noti:noti("Pomyślnie zakupiłeś pojazd "..getVehicleName(veh).." za cene "..convertNumber(sell.cost).."$.", player, "success")
                    else
                        exports.px_noti:noti("Nie stać cię na zakup tego pojazdu.", player, "error")
                    end
                else
                    exports.px_noti:noti("Posiadasz już maksymalną ilość pojazdów: "..math.floor(have).."/"..math.floor(slots)..".", player, "error")
                end
            else
                exports.px_noti:noti("Dany pojazd został już sprzedany.", player, "error")
            end
        else
            exports.px_noti:noti("Nie możesz zakupić swojego pojazdu.", player, "error")
        end
    end
end

-- useful

function convertNumber ( number )
	local formatted = number
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if ( k==0 ) then
			break
		end
	end
	return formatted
end

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
    end
end

addEvent("get.vehicle", true)
addEventHandler("get.vehicle", resourceRoot, destroySellOpis)

-- export

function setGhost(veh, state)
    if(veh and isElement(veh) and isElementWithinColShape(veh, VEH.shape))then
        setElementData(veh, "vehStock:ghost", state)
    end
end