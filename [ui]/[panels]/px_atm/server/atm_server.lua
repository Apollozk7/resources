--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local tick = {}

local ATM = {}

ATM.OBJECT = {
    -- lv
    {2300.9075,2444.0774,10.8203,88.7030},
    {2157.5332,2728.2144,11.1763,89.5087},
    {1050.4440,2347.5793,10.8203,0.0736},
    {937.0910,1722.1796,8.8581,89.7936},
    {1165.3237,1354.3893,10.8906,179.0317},
    {1624.4049,1009.9083,10.8203,91.0601},
    {1664.3424,1434.0940,10.7908,103.5354},
    {2104.1802,894.3049,11.1797,270.7226},
    {2209.7964,1418.6428,10.8125,179.6762},
    {2394.0239,1521.8131,10.8203,1.9030},
    {1087.5319,1793.0577,10.8203,273.7793},
    {2639.3157,1079.3939,10.8203,269.9174},
    {2766.4514,1443.5723,10.7143,359.7552},
    {2794.5327,2015.7883,10.8061,271.5289},
    {2802.4106,1250.8063,10.8279,178.6257},
    {2299.6655,1798.9060,11.0747,88.2783},
    {2193.8125,1966.4011,10.8203,180.6402},
    {2333.2593,2173.1208,10.8277,89.5935},
    {2543.2971,2154.7668,11.0157,1.1218},
    {2798.5476,976.1398,10.7500,270.0432},
    {1368.9401,675.9730,10.8880,270.4461},
    {2092.7368,2273.5830,10.8203,181.6378},

    {2510.7800,910.7338,10.8203,90.0525},

    -- fc
    {-97.4213,1126.8960,19.7422,180.2968},

    -- rafineria
    {271.0945,1423.0138,10.5859,2.2982},

    -- opuszczone
    {419.6062,2542.8601,16.4207,178.5938},
}

ATM.HIT = function(plr, dim)
    if(plr and isElement(plr) and getElementType(plr) == "player" and not isPedInVehicle(plr) and dim)then
        triggerClientEvent(plr, "ATM.CREATE_GUI", resourceRoot, "HIT", source)
        triggerClientEvent(plr, "ATM.UPDATE_ATM_MONEY", resourceRoot, ATM.MONEY(plr))
    end
end

ATM.createObjects=function()
    for i = 1,#ATM.OBJECT do
        local x,y,z,rz=unpack(ATM.OBJECT[i])
        if(ATM.OBJECT[i][4] == "marker")then
            local marker = createMarker(x, y, z-1, "cylinder", 1.5, 150, 0, 200, 0)
            if(ATM.OBJECT[i][5])then
                setElementDimension(marker, ATM.OBJECT[i][5])
            end
            setElementData(marker, "icon", ":px_atm/assets/images/bankomat.png")
            setElementData(marker, "text", {text="Bankomat", desc="Wypłata / wpłata gotówki"})
        else
            local atm=createObject(2618, x, y, z-0.35, 0, 0, rz)
            x,y,z=getPositionFromElementOffset(atm,0,-0.15,0)
            setElementPosition(atm,x,y,z)

            local cs=createColSphere(x, y, z, 1)
        end

        if(not ATM.OBJECT[i][5])then
            local blip = createBlip(x, y, z, 18)
            setBlipVisibleDistance(blip, 400)
        end
    end
end

ATM.MONEY = function(player)
	if player then
		local query = exports.px_connect:query("select bank_money from accounts where id=? limit 1", getElementData(player, "user:uid"))
		if(query and #query == 1)then
            return query[1].bank_money
        end
	end
    return 0
end

ATM.ACTIONS = function(type, money)
    local bank_money=ATM.MONEY(client)
	if type and tonumber(money) then
	    if type == "deposit" then
			if string.len(money) < 1 then
                return
            elseif not tonumber(money) or tonumber(money) and tonumber(money) < 1 then
                return
            end

            money = tonumber(money)
            money = math.floor(money)

            if getPlayerMoney(client) >= money then
                exports.px_noti:noti("Wpłaciłeś do bankomatu "..convertNumber(money).."$.", client, "success")
                exports.px_admin:addLogs("przelew", convertNumber(money).."$", client, "WPŁATA")
                exports.px_connect:query("update accounts set money=?, bank_money=bank_money+? where id=?", getPlayerMoney(client), money, getElementData(client, "user:uid"))
                triggerClientEvent(client, "ATM.UPDATE_ATM_MONEY", resourceRoot, bank_money+money)
                takePlayerMoney(client, money)

                exports.px_discord:sendDiscordLogs("[ATM] Wpłata "..money.."$", "hajs", client)

                if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                    tick[client] = getTickCount()
                elseif(tick[client] and (getTickCount()-tick[client]) < 3000)then
                    return
                end

                local x,y,z=getElementPosition(client)
                triggerClientEvent("playSound3D", resourceRoot, x, y, z)
            
                exports.px_core:outputChatWithDistance(client, "wpłaca fundusze do bankomatu.", 5)
                exports.px_quests:updateQuest(client, "Użyj bankomatu", 1)
            else
                exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
            end
        elseif type == "withdraw" then
            if string.len(money) < 1 then
                return
            elseif not tonumber(money) or tonumber(money) and tonumber(money) < 1 then
                return
            end

            money = tonumber(money)
            money = math.floor(money)

            if bank_money >= money then
                exports.px_noti:noti("Wypłaciłeś z bankomatu "..convertNumber(money).."$.", client, "success")
                exports.px_admin:addLogs("przelew", convertNumber(money).."$", client, "WYPŁATA")
                exports.px_connect:query("update accounts set money=?, bank_money=bank_money-? where id=?", getPlayerMoney(client), money, getElementData(client, "user:uid"))
                triggerClientEvent(client, "ATM.UPDATE_ATM_MONEY", resourceRoot, bank_money-money)
                givePlayerMoney(client, money)

                exports.px_discord:sendDiscordLogs("[ATM] Wypłata "..money.."$", "hajs", client)

                if(not tick[client] or tick[client] and (getTickCount()-tick[client]) > 3000)then
                    tick[client] = getTickCount()
                elseif(tick[client] and (getTickCount()-tick[client]) < 3000)then
                    return
                end

                exports.px_core:outputChatWithDistance(client, "wypłaca fundusze z bankomatu.", 5)

                local x,y,z=getElementPosition(client)
                triggerClientEvent("playSound3D", resourceRoot, x, y, z)

                exports.px_quests:updateQuest(client, "Użyj bankomatu", 1)
            else
                exports.px_noti:noti("Brak wystarczających funduszy.", client, "error")
            end
        end
	end
end

ATM.GETMONEY = function()
	triggerClientEvent(client, "ATM.UPDATE_ATM_MONEY", resourceRoot, ATM.MONEY(client))
end

-- triggers

addEvent("ATM.ACTIONS", true)
addEventHandler("ATM.ACTIONS", resourceRoot, ATM.ACTIONS)

addEvent("ATM.GETMONEY", true)
addEventHandler("ATM.GETMONEY", resourceRoot, ATM.GETMONEY)

addEventHandler("onMarkerHit", resourceRoot, ATM.HIT)
addEventHandler("onColShapeHit", resourceRoot, ATM.HIT)

-- exports

function getATMPositions()
    local t={}
    for i,v in pairs(ATM.OBJECT) do
        if(v.escort)then
            t[i]=v
        end
    end
    return t
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

function getPositionFromElementOffset(element,offX,offY,offZ)
	local m = getElementMatrix(element)
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x,y,z
end

-- create

ATM.createObjects()