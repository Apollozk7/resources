--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local sw,sh=guiGetScreenSize()
local baseX=1920
local maxZoom=2
local zoom=1
if(baseX > sw)then
    zoom=math.min(baseX/sw,maxZoom)
end

local floor=math.floor

local ui={}

ui['texture']=false
ui['radar_type']=exports['px_dashboard']:getSettingState("radar_type")

ui['render']=function()
    local x,y=320/zoom, sh-100/zoom
    local w,h=158/zoom,88/zoom
    w,h=w/1.5,h/1.5

    if(not ui['radar_type'])then
        x=x+100/zoom
    end

    dxDrawImage(floor(x), floor(y), floor(w), floor(h), ui['texture'])
end

ui['create']=function()
    ui['texture']=dxCreateTexture('textures/radiox69.png', 'argb', false, 'clamp')

    addEventHandler('onClientRender', root, ui['render'])
end 

ui['destroy']=function()
    if(ui['texture'])then
        destroyElement(ui['texture'])
        ui['texture']=false
    end

    removeEventHandler('onClientRender', root, ui['render'])
end

addEventHandler('onClientElementDataChange', root, function(data, old, new)
    if(data == 'user:hud_disabled' and source == localPlayer)then
        ui['destroy']()
        if(not new)then
            local el=getElementByID('radio_program')
            if(el)then
                local data=getElementData(el, 'program:info')
                if(data and data['streamer'] ~= 'autopilot')then
                    ui['create']()
                end
            end
        end
    elseif(data == 'user:showed_hud' and source == localPlayer)then
        ui['destroy']()
        if(new)then
            local el=getElementByID('radio_program')
            if(el)then
                local data=getElementData(el, 'program:info')
                if(data and data['streamer'] ~= 'autopilot')then
                    ui['create']()
                end
            end
        end
    elseif(data == 'program:info')then
        ui['destroy']()
        if(new and new['streamer'] ~= 'autopilot' and not getElementData(localPlayer, 'user:hud_disabled') and not getElementData(localPlayer, 'user:showed_hud'))then
            ui['create']()
        end
    elseif(data == 'user:dash_settings' and source == localPlayer)then
        ui['radar_type']=exports['px_dashboard']:getSettingState("radar_type")
    end
end)

-- on start

if(not getElementData(localPlayer, 'user:hud_disabled') and not getElementData(localPlayer, 'user:showed_hud'))then
    ui['create']()
    setTimer(function()
        local el=getElementByID('radio_program')
        if(el)then
            local data=getElementData(el, 'program:info')
            if(data and data['streamer'] == 'autopilot')then
                ui['destroy']()
            end
        end
    end, 500, 1)
end