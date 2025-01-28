--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

local floor=math.floor

ui.rendering["stats"]=function(execute, a)
    local texs=ui.getTextures(execute)
    if(not texs)then return false end

    -- top
    dxDrawRectangle(sw/2-689/2/zoom+42/zoom+42/2/zoom, sh/2-581/2/zoom+136/zoom, 689/zoom-42/zoom-42/2/zoom-42/2/zoom, 1, tocolor(100,100,100,a))

    local logo=ui.sql.fraction.tag == "SACC" and texs[3] or ui.sql.fraction.tag == 'SAPD' and texs[2] or ui.sql.fraction.tag == 'SARA' and texs[4] or texs[5]
    dxDrawImage(floor(sw/2-689/2/zoom+42/zoom+((689-42-168))/2/zoom), floor(sh/2-581/2/zoom+80/zoom), floor(168/zoom), floor(168/zoom), logo, 0, 0, 0, tocolor(255, 255, 255, a))

    -- left
    dxDrawText("Wszystkich członków", sw/2-689/2/zoom+42/zoom+42/2/zoom, sh/2-581/2/zoom+110/zoom, sw/2-689/2/zoom+42/zoom+42/2/zoom+230/zoom, 1, tocolor(200,200,200,a), 1, assets.fonts[1], "center", "top")
    dxDrawText(#ui.sql.users, sw/2-689/2/zoom+42/zoom+42/2/zoom, sh/2-581/2/zoom+140/zoom, sw/2-689/2/zoom+42/zoom+42/2/zoom+230/zoom, 1, tocolor(200,200,200,a), 1, assets.fonts[2], "center", "top")

    -- right
    dxDrawText("Obecnie aktywni", sw/2-689/2/zoom+42/zoom+42/2/zoom+689/zoom-42/zoom-42/2/zoom-42/2/zoom-230/zoom, sh/2-581/2/zoom+110/zoom, sw/2-689/2/zoom+42/zoom+42/2/zoom+689/zoom-42/zoom-42/2/zoom-42/2/zoom, 1, tocolor(200,200,200,a), 1, assets.fonts[1], "center", "top")
    dxDrawText(ui.sql.online, sw/2-689/2/zoom+42/zoom+42/2/zoom+689/zoom-42/zoom-42/2/zoom-42/2/zoom-230/zoom, sh/2-581/2/zoom+140/zoom, sw/2-689/2/zoom+42/zoom+42/2/zoom+689/zoom-42/zoom-42/2/zoom-42/2/zoom, 1, tocolor(200,200,200,a), 1, assets.fonts[2], "center", "top")

    -- bottom
    dxDrawRectangle(sw/2-689/2/zoom+42/zoom+42/2/zoom, sh/2-581/2/zoom+136/zoom+148/zoom, 689/zoom-42/zoom-42/2/zoom-42/2/zoom, 1, tocolor(100,100,100,a))

    dxDrawText("Aktywność pracowników", sw/2-689/2/zoom+77/zoom, sh/2-581/2/zoom+310/zoom, 689/zoom, 581/zoom, tocolor(200,200,200,a), 1, assets.fonts[1], "left", "top")
    local x,y,w,h=sw/2-689/2/zoom+77/zoom, sh/2-581/2/zoom+340/zoom,328/zoom,164/zoom
    dxDrawRectangle(x,y,w,h,tocolor(15,15,15,a > 100 and 100 or a))

    local dates={}
    local max=100
    local k=0
    for i,v in pairs(ui.sql.active) do
        if(v.week_time > max)then
            max=v.week_time
        end
    end

    for i=1,8 do
        local sX=(41/zoom)*(i-1)
        for i=1,4 do
            local sY=(41/zoom)*(i-1)
            local xx,yy,ww,hh=x+sX,y+sY,41/zoom,41/zoom
            dxDrawRectangle(xx,yy-1,ww,1,tocolor(83,82,80,a))
            dxDrawRectangle(xx,yy,1,hh,tocolor(83,82,80,a))
            dxDrawRectangle(xx+ww,yy,1,hh,tocolor(83,82,80,a))
            dxDrawRectangle(xx,yy+hh-1,ww,1,tocolor(83,82,80,a))
        end
    end

    local last={}
    local i=0
    for k,v in pairs(ui.sql.active) do
        i=i+1

        local sp=w*(i/8)
        dxDrawLine(last[1] or x,last[2] or y+h, x+sp, y+h-(h*(v.week_time/max)), tocolor(57, 116, 131, a), 2)
        dxDrawImage(x+sp-7/2/zoom+1, y+h-(h*(v.week_time/max))-7/2/zoom+1, 7/zoom, 7/zoom, texs[1], 0, 0, 0, tocolor(255, 255, 255, a))

        last={x+sp,y+h-(h*(v.week_time/max))}
    end

    -- right
    dxDrawText("Najaktywniejsi pracownicy", sw/2-689/2/zoom+77/zoom+355/zoom, sh/2-581/2/zoom+310/zoom, 689/zoom, 581/zoom, tocolor(200,200,200,a), 1, assets.fonts[1], "left", "top")
    for i,v in pairs(ui.sql.active) do
        local tex=exports.px_avatars:getPlayerAvatar(v.login)
        local sY=(30/zoom)*(i-1)

        local hours,minutes=convertMinutes(v.week_time)
        dxDrawImage(sw/2-689/2/zoom+77/zoom+355/zoom, sh/2-581/2/zoom+310/zoom+31/zoom+sY, 21/zoom, 21/zoom, tex, 0, 0, 0, tocolor(255,255,255,a))
        dxDrawText(v.login.." #8e8e8e("..hours.."h "..minutes.."m)", sw/2-689/2/zoom+77/zoom+355/zoom+30/zoom, sh/2-581/2/zoom+310/zoom+31/zoom+sY, 21/zoom, 21/zoom+sh/2-581/2/zoom+310/zoom+31/zoom+sY, tocolor(200,200,200,a), 1, assets.fonts[3], "left", "center", false, false, false, true)
    end
end