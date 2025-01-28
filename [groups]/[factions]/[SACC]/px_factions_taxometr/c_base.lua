--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- global variables

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

-- assets

local assets={}
assets.list={
    texs={
        "assets/tablet.png",
    },

    fonts={
        {"assets/digital-7.ttf", 13},
        {"assets/digital-7.ttf", 20},
    },
}

assets.create=function()
    assets.textures={}
    for i,v in pairs(assets.list.texs) do
        assets.textures[i]=dxCreateTexture(v, "argb", false, "clamp")
    end

    assets.fonts={}
    for i,v in pairs(assets.list.fonts) do
        assets.fonts[i]=dxCreateFont(v[1], v[2]/zoom)
    end
end

assets.destroy=function()
    for i,v in pairs(assets.textures) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.textures={}

    for i,v in pairs(assets.fonts) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.fonts={}
end

-- variables

local ui={}

ui.bonusForKM=5 -- $ za 1km
ui.bonusPayment=0
ui.distance=0
ui.pos={}

ui.payment=0

-- functions

ui.paymentTimer=function()
    if(math.floor(ui.payment) > 0)then
        exports.px_jobs_info:addPlayerPayment(ui.payment)
        exports.px_noti:noti("Otrzymujesz bonus za przewóz w wysokości $"..math.floor(ui.payment)..".", "success")
        ui.payment=0
    end
end

ui.preRender=function()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if(not vehicle)then return end

    local players=getVehicleOccupants(vehicle)
    if(table.size(players) <= 1)then return end

    if(getPedOccupiedVehicleSeat(localPlayer) == 0)then
        if(#ui.pos < 3)then
            ui.pos = {getElementPosition(vehicle)}
        else
            local x,y,z = getElementPosition(vehicle)
            local dist = getDistanceBetweenPoints3D(ui.pos[1], ui.pos[2], ui.pos[3], x, y, z)
            if(dist > 10 and ui.bonusPayment < 200)then
                ui.pos = {getElementPosition(vehicle)}

                ui.distance=ui.distance+0.03
                
                local add=(ui.bonusForKM/100)
                ui.bonusPayment=ui.bonusPayment+add

                ui.payment=ui.payment+add
            end
        end
    end
end

ui.render=function()
    if(not isPedInVehicle(localPlayer))then
        removeEventHandler("onClientRender", root, ui.render)
        removeEventHandler("onClientPreRender", root, ui.preRender)

        assets.destroy()

        killTimer(ui.timer)
        ui.timer=nil

        ui.paymentTimer()

        ui.bonusPayment=0
        ui.distance=0
        ui.pos={}
        ui.payment=0

        return
    end

    local players=getVehicleOccupants(getPedOccupiedVehicle(localPlayer))
    if(table.size(players) <= 1)then 
        ui.bonusPayment=0
        ui.distance=0
        ui.pos={}
        ui.payment=0
        return 
    end

    dxDrawImage(sw/2-308/2/zoom, sh-215/zoom, 308/zoom, 171/zoom, assets.textures[1])

    -- distance
    local km=string.format("%.1f", ui.distance)
    dxDrawText(km, sw/2-308/2/zoom+52/zoom, sh-215/zoom+72/zoom, 0, 0, tocolor(251, 146, 23), 1, assets.fonts[2])
    dxDrawText("KM", sw/2-308/2/zoom+52/zoom+dxGetTextWidth(km,1,assets.fonts[2]), sh-215/zoom+82/zoom, 0, 0, tocolor(251, 146, 23), 1, assets.fonts[1])

    -- bonus
    dxDrawText("$", sw/2-308/2/zoom+203/zoom, sh-215/zoom+82/zoom, 0, 0, tocolor(251, 146, 23), 1, assets.fonts[1])
    dxDrawText(string.format("%.1f", ui.bonusPayment), sw/2-308/2/zoom+216/zoom, sh-215/zoom+72/zoom, 0, 0, tocolor(251, 146, 23), 1, assets.fonts[2])
end

addEventHandler("onClientVehicleEnter", root, function(plr,seat)
    if(plr ~= localPlayer or seat ~= 0)then return end

    if(getElementData(source, "vehicle:group_ownerName") == "SACC")then
        assets.create()

        addEventHandler("onClientRender", root, ui.render)
        addEventHandler("onClientPreRender", root, ui.preRender)

        ui.timer=setTimer(ui.paymentTimer,(30*1000),0)
    end
end)

if(isPedInVehicle(localPlayer))then
    if(getElementData(getPedOccupiedVehicle(localPlayer), "vehicle:group_ownerName") == "SACC" and getPedOccupiedVehicleSeat(localPlayer) == 0)then
        assets.create()
        
        addEventHandler("onClientRender", root, ui.render)
        addEventHandler("onClientPreRender", root, ui.preRender)

        ui.timer=setTimer(ui.paymentTimer,(30*1000),0)
    end
end

-- useful

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end