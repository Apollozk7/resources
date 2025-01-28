--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local blur=exports.blur

-- assets

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Bold.ttf", 15},
        {":px_assets/fonts/Font-Regular.ttf", 13},
        {":px_assets/fonts/Font-Bold.ttf", 13},
        {":px_assets/fonts/Font-Regular.ttf", 11},
    },

    textures={},
    textures_paths={
        "assets/textures/bg.png",

        "assets/textures/wallet.png",
        "assets/textures/time.png",
        "assets/textures/hour.png",

        "assets/textures/line.png",
        "assets/textures/check.png",

        "assets/textures/red_line.png",
        "assets/textures/repeat_time.png",
        "assets/textures/take_money.png",
        "assets/textures/bonus.png",
    },
}

assets.create = function()
    for k,t in pairs(assets) do
        if(k=="fonts_paths")then
            for i,v in pairs(t) do
                assets.fonts[i] = dxCreateFont(v[1], v[2]/zoom)
            end
        elseif(k=="textures_paths")then
            for i,v in pairs(t) do
                assets.textures[i] = dxCreateTexture(v, "argb", false, "clamp")
            end
        end
    end
end

assets.destroy = function()
    for k,t in pairs(assets) do
        if(k == "textures" or k == "fonts")then
            for i,v in pairs(t) do
                if(v and isElement(v))then
                    destroyElement(v)
                end
            end
            assets.fonts={}
            assets.textures={}
        end
    end
end

function dxDrawShadowText(text,x,y,w,h,color,size,font,alignX,alignY)
    dxDrawText(text,x+1,y+1,w+1,h+1,tocolor(0,0,0),size,font,alignX,alignY)
    dxDrawText(text,x,y,w,h,color,size,font,alignX,alignY)
end

--

local JOB = {}

JOB.sec=0
JOB.paymentSec=0

JOB.showed=false

JOB.panelHeight=186/zoom
JOB.lineWidth=0

JOB.lastMoney=0

JOB.timer=function()
    if(not getElementData(localPlayer, "user:afk") and not getElementData(localPlayer, "user:factionAFK"))then
        local data=getElementData(localPlayer, "user:job_settings")

        JOB.sec=JOB.sec+1
        JOB.paymentSec=JOB.paymentSec+1

        if(data and data.job_add_hour_money and data.job_hour_money and JOB.paymentSec >= 60)then
            local money=math.floor((data.job_hour_money)/60) -- na minute
            data.money=(data.money or 0)+money
            setElementData(localPlayer, "user:job_settings", data)

            JOB.paymentSec=0

            triggerServerEvent("add.job.money", resourceRoot, money)
        end
    end
end

JOB.onRender = function()
    local data=getElementData(localPlayer, "user:job_settings")
    if(not data)then
        JOB.close()
        return
    end

	if(not getElementData(localPlayer, "user:hud_disabled"))then
        local back=getElementData(localPlayer, "user:jobBackTime")
        if(not data.backToVehicle and back)then
            data.backToVehicle=back
        end

        local todo=getElementData(localPlayer, "user:jobs_todo")
        if(todo)then
            data.quests=todo
        end

        dxDrawImage(sw-478/zoom, 229/zoom, 478/zoom, JOB.panelHeight, assets.textures[1])
        dxDrawShadowText("Praca: "..data.job_tag or data.job_name, sw-478/zoom, 229/zoom+15/zoom, sw-57/zoom, JOB.panelHeight, tocolor(200, 200, 200), 1, assets.fonts[1], "right", "top")
        JOB.panelHeight=40/zoom

        local hours = math.floor(JOB.sec / 3600)
        local minutes = math.floor((JOB.sec / 60) % 60)
        local seconds = math.floor(JOB.sec % 60)
        local time=(hours > 0 and hours.."h " or "")..(minutes > 0 and minutes.."m " or "")..seconds.."s"
        
        local info={
            [assets.textures[3]]={pos={16/zoom, 16/zoom},text=time},
            [assets.textures[4]]={pos={14/zoom, 14/zoom},text="$"..convertNumber(math.floor(data.money or 0))},
        }

        if(data.job_hour_money)then
            local hour_money="$"..convertNumber(data.job_hour_money).."/h"
            info[assets.textures[2]]={pos={14/zoom, 14/zoom},text=hour_money}
        end

        if(data.giveMoney)then
            info[assets.textures[10]]={pos={14/zoom, 14/zoom},text=data.giveMoney.."%"}
        end

        local minus=0
        for i,v in pairs(info) do
            local pos={sw-57/zoom-14/zoom-minus,229/zoom+57/zoom,v.pos[1],v.pos[2]}

            dxDrawImage(pos[1], pos[2], pos[3], pos[4], i)
            dxDrawShadowText(v.text, pos[1], pos[2], pos[3]+pos[1]-14/zoom-pos[3], pos[4]+pos[2], tocolor(200, 200, 200), 1, assets.fonts[2], "right", "center")

            minus=minus+dxGetTextWidth(v.text,1,assets.fonts[2])
            minus=minus+pos[3]+32/zoom
        end

        JOB.panelHeight=JOB.panelHeight+50/zoom

        dxDrawRectangle(sw-274/zoom-57/zoom, 229/zoom+89/zoom, 274/zoom, 1, tocolor(80,80,80))
        dxDrawImage(sw-274/zoom-57/zoom-(290-274)/2/zoom+((290/zoom)-(290/zoom)*(JOB.lineWidth/100)), 229/zoom+89/zoom-19/2/zoom, (290/zoom)*(JOB.lineWidth/100), 19/zoom, assets.textures[5])

        JOB.panelHeight=JOB.panelHeight+25/zoom

        local plus=0
        local infos={}
        if(data.backToVehicle and tonumber(data.backToVehicle) and tonumber(data.backToVehicle) < 60 and tonumber(data.backToVehicle) > 0)then
            infos[assets.textures[8]]={pos={sw-57/zoom-14/zoom, 229/zoom+57/zoom+57/zoom, 14/zoom, 14/zoom},text=data.backToVehicle.."s"}
        end
        if(data.takeMoney and tonumber(data.takeMoney) > 0)then
            infos[assets.textures[9]]={pos={sw-57/zoom-14/zoom, 229/zoom+57/zoom+57/zoom, 14/zoom, 14/zoom},text=data.takeMoney.."%"}
        end

        if(table.size(infos) > 0)then
            local last=0
            for i,v in pairs(infos) do
                dxDrawImage(v.pos[1]-last, v.pos[2], v.pos[3], v.pos[4], i)
                dxDrawShadowText(v.text, v.pos[1], v.pos[2], v.pos[3]+v.pos[1]-14/zoom-v.pos[3]-last, v.pos[4]+v.pos[2], tocolor(200, 200, 200), 1, assets.fonts[2], "right", "center")

                last=v.pos[3]+35/zoom+dxGetTextWidth(v.text,1,assets.fonts[2])
            end

            dxDrawRectangle(sw-274/zoom-57/zoom, 229/zoom+89/zoom+57/zoom, 274/zoom, 1, tocolor(80,80,80))
            dxDrawImage(sw-274/zoom-57/zoom-(290-274)/2/zoom, 229/zoom+89/zoom-19/2/zoom+57/zoom, 290/zoom, 19/zoom, assets.textures[7])

            plus=plus+57/zoom
            JOB.panelHeight=JOB.panelHeight+57/zoom
        end

        local quests=data.quests or {}
        JOB.lineWidth=0
        for i,v in pairs(quests) do
            local sY=(22/zoom)*(i-1)
            local lastDone=(quests[i-1] and quests[i-1].done) and true or false
            local font=v.done and assets.fonts[2] or lastDone and assets.fonts[3] or (not lastDone and i == 1) and assets.fonts[3] or assets.fonts[2]
            local alpha=v.done and 100 or lastDone and 222 or (not lastDone and i == 1) and 222 or 175

            dxDrawShadowText(v.name, sw-478/zoom, 229/zoom+110/zoom+sY+plus, sw-57/zoom, JOB.panelHeight, tocolor(200, 200, 200, alpha), 1, font, "right", "top")
            
            if(v.done)then
                dxDrawImage(sw-57/zoom-dxGetTextWidth(v.name, 1, font)-20/zoom, 229/zoom+110/zoom+sY+13/2/zoom+plus, 13/zoom, 9/zoom, assets.textures[6])

                JOB.lineWidth=JOB.lineWidth+(100/#quests)
            end

            JOB.panelHeight=JOB.panelHeight+25/zoom
        end
    end
end

JOB.onStart=function()
    local data=getElementData(localPlayer, "user:job_settings")
    if(data and not JOB.showed)then
        blur=exports.blur

        JOB.sec=data.sec or 0
        JOB.paymentSec=0
        JOB.showed=true

        assets.create()
        addEventHandler("onClientRender", root, JOB.onRender)

        JOB.timerElement=setTimer(JOB.timer,1000,0)
    end
end

JOB.close=function()
    JOB.sec=0
    JOB.paymentSec=0
    JOB.showed=false

    removeEventHandler("onClientRender", root, JOB.onRender)
    assets.destroy()

    if(JOB.timerElement)then
        killTimer(JOB.timerElement)
        JOB.timerElement=nil
    end
end

addEventHandler("onClientElementDataChange", root, function(data, last, new)
    if(data == "user:job_settings" and source == localPlayer)then
        if(new)then
            JOB.onStart()
        else
            JOB.close()
        end
    end
end)

JOB.onStart()

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

function table.size(tbl)
    local k=0
    for i,v in pairs(tbl) do
        k=k+1
    end
    return k
end

-- exports

function addPlayerPayment(money)
    local data=getElementData(localPlayer, "user:job_settings")
    if(data)then
        data.money=(data.money or 0)+money
        setElementData(localPlayer, "user:job_settings", data)
    end

    triggerServerEvent("add.job.money_2", resourceRoot, money)
end