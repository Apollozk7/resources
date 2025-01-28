--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local floor=math.floor

SPEEDO.getRenderLPG=function(vehicle, x, y, type)
    x,y=floor(x),floor(y)

    local gas=getElementData(vehicle, 'vehicle:fuelType')
    if(gas and gas == 'LPG')then
        local fuel=getElementData(vehicle, "vehicle:gas") or 25
        local bak=getElementData(vehicle, "vehicle:fuelTank") or 25

        fuel=fuel < 0 and 0 or fuel
        fuel=fuel > bak and bak or fuel

        if(type)then
            dxDrawImage(x, y, floor(112/zoom), floor(35/zoom), SPEEDO.TEXTURES["lpg_bg2"])

            local circles=floor(5*(fuel/bak))
            for i=1,5 do
                local id=6-i
    
                local sX=(20/zoom)*(i-1)
    
                if(circles >= id)then
                    dxDrawImage(x+floor(8/zoom+sX), y+floor(8/zoom), floor(13/zoom), floor(13/zoom), SPEEDO.TEXTURES["lpg_circle_2"])
                else
                    dxDrawImage(x+floor(8/zoom+sX), y+floor(8/zoom), floor(13/zoom), floor(13/zoom), SPEEDO.TEXTURES["lpg_circle_1"])
                end
            end
        else
            dxDrawImage(x, y, floor(35/zoom), floor(112/zoom), SPEEDO.TEXTURES["lpg_bg"])

            local circles=floor(5*(fuel/bak))
            for i=1,5 do
                local id=6-i
    
                local sY=(20/zoom)*(i-1)
    
                if(circles >= id)then
                    dxDrawImage(x+floor(15/zoom), y+floor(8/zoom+sY), floor(13/zoom), floor(13/zoom), SPEEDO.TEXTURES["lpg_circle_2"])
                else
                    dxDrawImage(x+floor(15/zoom), y+floor(8/zoom+sY), floor(13/zoom), floor(13/zoom), SPEEDO.TEXTURES["lpg_circle_1"])
                end
            end
        end
    end
end