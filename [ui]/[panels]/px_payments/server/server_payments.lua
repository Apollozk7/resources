--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local UI={}

UI.assets={}

UI.assets.marker=createMarker(929.4231,1732.1750,8.8516-1, "cylinder", 1.5, 136, 141, 74)
setElementData(UI.assets.marker, "icon", ":px_payments/assets/images/withdrawMarker.png")
setElementData(UI.assets.marker, "text", {text="Wypłaty", desc="Tutaj wypłacisz gotówkę z pracy"})

addEventHandler("onMarkerHit",UI.assets.marker,function(hit,dim)
    if(hit and isElement(hit) and getElementType(hit) == "player" and not isPedInVehicle(hit) and dim)then
        local uid=getElementData(hit, "user:uid")
        if(not uid)then return end

        db=exports.px_connect
        local r=db:query("select faction_money, faction_time, busi_money, busi_time from accounts where id=?", uid)
        if(r and #r > 0)then
            local v=r[1]

            -- exports
            local faction=exports.px_factions:isPlayerInFaction(getPlayerName(hit))
            local f_rank="brak"
            local f_payment=0
            if(faction and #faction > 0)then
                f_rank=exports.px_factions:getPlayerRank(getPlayerName(hit),faction)
                f_payment=exports.px_factions:getPayment(f_rank,faction)
            else
                faction="brak"
            end

            local business="brak"
            local b_rank="brak"
            local b_payment=0
            --

            local info={
                ["faction"]={v.faction_money,v.faction_time,faction,f_rank,f_payment},
                ["busi"]={v.busi_money,v.busi_time,business,b_rank,b_payment}
            }
            triggerClientEvent(hit, "payments.open", resourceRoot, info)
        else
            triggerClientEvent(hit, "payments.open", resourceRoot, info)
        end
    end
end)

addEvent("get.payment",true)
addEventHandler("get.payment",resourceRoot,function(money,time,type,online)
    local uid=getElementData(client, "user:uid")
    if(not uid)then return end

    db=exports.px_connect

    local r=db:query("select login from accounts where id=?", uid)
    if(r and #r > 0)then
        if(type == 2)then
            local q=db:query("select busi_money,busi_time from accounts where busi_money>0 and busi_time>0 and id=?", uid)
            if(q and #q > 0)then
                local xp=online
                local first_money=money

                db:query("update accounts set busi_money=0, busi_time=0 where id=?", uid)

                local normal_text="Pomyślnie odebrałeś "..first_money.."$ oraz "..xp.."XP za przepracowane "..time.."."
                if(getElementData(client, "user:premium"))then
                    local p_money=math.percent(5, money)
                    local p_xp=math.percent(5, xp)

                    money=math.floor(money+p_money)
                    xp=math.floor(xp+p_xp)

                    normal_text=normal_text.." Otrzymujesz dodatkowe "..p_money.."$ oraz "..p_xp.."xp z posiadania konta PREMIUM."
                end
        
                if(getElementData(client, "user:gold"))then
                    local p_money=math.percent(10, money)
                    local p_xp=math.percent(10, xp)

                    money=math.floor(money+p_money)
                    xp=math.floor(xp+p_xp)

                    normal_text=normal_text.." Otrzymujesz dodatkowe "..p_money.."$ oraz "..p_xp.."xp z posiadania konta GOLD."
                end

                local exp=getElementData(client, "user:exp") or 0
                setElementData(client, "user:exp", exp+xp)
        
                exports.px_discord:sendDiscordLogs("[WYPLATY] "..normal_text, "hajs", client)
                exports.px_noti:noti(normal_text, client, "success")
                
                givePlayerMoney(client, money)
            end
        elseif(type == 1)then
            local q=db:query("select faction_money,faction_time from accounts where faction_money>0 and faction_time>0 and id=?", uid)
            if(q and #q > 0)then
                local xp=online*4
                local first_money=money

                db:query("update accounts set faction_money=0, faction_time=0 where id=?", uid)

                local normal_text="Pomyślnie odebrałeś "..first_money.."$ oraz "..xp.."XP za przepracowane "..time.."."
                if(getElementData(client, "user:premium"))then
                    local p_money=math.percent(5, money)
                    local p_xp=math.percent(5, xp)

                    money=math.floor(money+p_money)
                    xp=math.floor(xp+p_xp)

                    normal_text=normal_text.." Otrzymujesz dodatkowe "..p_money.."$ oraz "..p_xp.."xp z posiadania konta PREMIUM."
                end
        
                if(getElementData(client, "user:gold"))then
                    local p_money=math.percent(10, money)
                    local p_xp=math.percent(10, xp)

                    money=math.floor(money+p_money)
                    xp=math.floor(xp+p_xp)

                    normal_text=normal_text.." Otrzymujesz dodatkowe "..p_money.."$ oraz "..p_xp.."xp z posiadania konta GOLD."
                end

                local exp=getElementData(client, "user:exp") or 0
                setElementData(client, "user:exp", exp+xp)
        
                exports.px_discord:sendDiscordLogs("[WYPLATY] "..normal_text, "hajs", client)
                exports.px_noti:noti(normal_text, client, "success")
                
                givePlayerMoney(client, money)
            end
        end
    end
end)

-- useful

function math.percent(percent,maxvalue)
    if tonumber(percent) and tonumber(maxvalue) then
        return (maxvalue*percent)/100
    end
    return false
end