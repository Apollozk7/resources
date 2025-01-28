--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local cb={}

cb['players']={}

cb['command']=function(player, cmd, ...)
    if(cb['players'][player])then
        if(...)then
            local text=table.concat({...}, " ")
            if(#text > 3)then
                for i,v in pairs(cb['players']) do
                    if(i and isElement(i))then
                        outputChatBox('#000000CB-RADIO> #c4c4c4['..getElementData(player, "user:id")..'] '..getPlayerName(player)..': '..text, i, 255, 255, 255, true)
                    else
                        cb['players'][i]=nil
                    end
                end
            else
                exports.px_noti:noti('Prawidłowe użycie: /cb <tekst> (minimum 3 znaki)', player, 'error')
            end
        else
            exports.px_noti:noti('Prawidłowe użycie: /cb <tekst>', player, 'error')
        end
    end
end
addCommandHandler('cb', cb['command'])
addCommandHandler('CB', cb['command'])

addEventHandler('onElementDataChange', root, function(data,old,new)
    if(data == 'vehicle:cbRadio')then
        local controller=getVehicleController(source)
        if(not controller)then return end

        if(new)then
            cb['players'][controller]=true
        else
            if(cb['players'][controller])then
                cb['players'][controller]=nil
            end
        end
    end
end)

addEventHandler('onVehicleEnter', root, function(player, seat)
    if(seat ~= 0 or not getElementData(source, 'vehicle:cbRadio'))then return end

    cb['players'][player]=true
end)

addEventHandler('onVehicleExit', root, function(player, seat)
    if(seat ~= 0 or not cb['players'][player])then return end

    cb['players'][player]=nil
end)

addEventHandler('onPlayerQuit', root, function()
    if(cb['players'][source])then
        cb['players'][source]=nil
    end
end)