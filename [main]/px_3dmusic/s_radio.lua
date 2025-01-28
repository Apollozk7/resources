--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local zone = createColCuboid(-152.57025, 1067.51501, 18.74999, 12.771240234375, 5, 3.3099998474121)
local zoneLV = createColPolygon(
    2555.7927,2307.0186,
    2555.7927,2307.0186,
    2552.0295,2304.8279,
    2545.7412,2315.3813,
    2549.7249,2317.7214
)

local messages={}

addEventHandler("onPlayerChat", root, function(tekst,type)
    if(type == 0 and source and isElement(source))then
        local x,y,z=getElementPosition(source)
        if(isElementWithinColShape(source,zone) or (isElementWithinColShape(source,zoneLV) and z < 14))then
            if(not messages[source] and #tekst > 1 and #tekst < 150)then
                local inf=exports.px_informations
                local dc=exports.px_discord

                messages[source]=true

                dc:sendDiscordLogs(getPlayerName(source).."/"..getElementData(source, "user:id")..": "..tekst, "ogloszenia", source)

                inf:noti(getPlayerName(source).."/"..getElementData(source, "user:id")..": "..tekst, "premium")

                setTimer(function(player)
                    if(player and isElement(player))then
                        messages[player]=nil
                    end
                end, 20000, 1, source)        
            end
        end
    end
end)

-- audycje

local api='https://radio-admin.pixelmta.pl/api/nowplaying/pixel'
local commandName='audycja'

local program=createElement('radio_program')
setElementID(program, 'radio_program')

local function getAPIJson(responseData, errorCode, player)
    if(errorCode == 0)then
        local table=fromJSON(responseData) or {}
        local music_name=table['now_playing']['song']['text']
        local streamer=table['live']['is_live'] and table['live']['streamer_name'] or 'autopilot'

        if(player)then
            outputChatBox(streamer == 'autopilot' and 'Aktualnie gra autopilot.' or "Aktualnie audycje prowadzi: "..streamer..".", player, 0,100,200)
            outputChatBox("Aktualna piosenka: "..music_name, player)

            exports.px_custom_chat:addMessage(streamer == 'autopilot' and 'Aktualnie gra autopilot.' or "Aktualnie audycje prowadzi: "..streamer..".", player, false, tocolor(0,100,200))
            exports.px_custom_chat:addMessage("Aktualna piosenka: "..music_name, player)
        end

        local program=getElementByID('radio_program')
        if(program)then
            setElementData(program, 'program:info', {
                music_name=music_name,
                streamer=streamer
            })
        end
    end
end

setTimer(function()
    fetchRemote(api, getAPIJson, '', false)
end, (60*1000)*5, 0)
fetchRemote(api, getAPIJson, '', false)

addCommandHandler(commandName, function(player)
    fetchRemote(api, getAPIJson, '', false, player)
end)