--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Project X (MTA)
]]

function getOrganizationActivity()
    local have=0
    local max=#ui.sql.users

    for i,v in pairs(ui.sql.users) do
        if(not v.not_today or getPlayerFromName(v.login))then
            have=have+1
        end
    end

    local s=math.floor((have/max)*100)
    return tonumber(s)
end

function getOrganizationUpgradeLevel()
    local t=fromJSON(ui.sql.org.upgrades) or {}
    local have=table.size(t)
    local max=#ui.sql.upgrades
    local s=math.floor((have/max)*100)
    return tonumber(s)
end

ui.rendering["stats"]=function(execute, a)
    local texs=ui.getTextures(execute)
    if(not texs)then return false end

    local nextExp=ui.sql.org.level*ui.sql.lvl_up

    -- logo, level
    dxDrawImage(sw/2-730/2/zoom+42/zoom+50/zoom, sh/2-581/2/zoom+42/zoom+36/zoom, 95/zoom, 95/zoom, texs[2], 0, 0, 0, tocolor(255, 255, 255, a))
    
    local x,y,w=getCirclePosition(sw/2-730/2/zoom+42/zoom+50/zoom, sh/2-581/2/zoom+42/zoom+36/zoom, 95/zoom)
    if(a == 255)then
        _dxDrawCircle(x, y, w, 0, 360*(ui.sql.org.exp/nextExp), tocolor(0,100,255,a))
    end
    dxDrawImage(sw/2-730/2/zoom+42/zoom+50/zoom, sh/2-581/2/zoom+42/zoom+36/zoom, 95/zoom, 95/zoom, texs[3], 0, 0, 0, tocolor(37,39,40,a))

    dxDrawImage(sw/2-730/2/zoom+42/zoom+50/zoom+(95-88)/2/zoom, sh/2-581/2/zoom+42/zoom+36/zoom+(95-88)/2/zoom, 88/zoom, 88/zoom, texs[1], 0, 0, 0, tocolor(255, 255, 255, a))
    if(ui.logo)then
        dxDrawImage(sw/2-730/2/zoom+42/zoom+50/zoom+(95-88)/2/zoom, sh/2-581/2/zoom+42/zoom+36/zoom+(95-88)/2/zoom, 88/zoom, 88/zoom, ui.logo, 0, 0, 0, tocolor(255, 255, 255, a))
    else
        dxDrawImage(sw/2-730/2/zoom+42/zoom+50/zoom+(95-31)/2/zoom, sh/2-581/2/zoom+42/zoom+36/zoom+(95-37)/2/zoom, 31/zoom, 37/zoom, assets.textures[13], 0, 0, 0, tocolor(255, 255, 255, a))
    end
    --

    -- names
    dxDrawText(ui.sql.org.org, sw/2-730/2/zoom+42/zoom+172/zoom, sh/2-581/2/zoom+42/zoom+50/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[7], "left", "top")
    dxDrawText(ui.sql.org.tag, sw/2-730/2/zoom+42/zoom+172/zoom, sh/2-581/2/zoom+42/zoom+55/zoom+15/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[6], "left", "top")
    --

    -- exp, level
    dxDrawImage(sw/2-730/2/zoom+42/zoom+172/zoom, sh/2-581/2/zoom+42/zoom+98/zoom, 63/zoom, 23/zoom, texs[4], 0, 0, 0, tocolor(255, 255, 255, a))

    dxDrawText(ui.sql.org.exp.."/"..nextExp, sw/2-730/2/zoom+42/zoom+172/zoom, sh/2-581/2/zoom+42/zoom+98/zoom, 63/zoom+sw/2-730/2/zoom+42/zoom+172/zoom, 23/zoom+sh/2-581/2/zoom+42/zoom+98/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[8], "center", "center")
    
    dxDrawText("Poziom "..ui.sql.org.level, sw/2-730/2/zoom+42/zoom+246/zoom, sh/2-581/2/zoom+42/zoom+99/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[6], "left", "top")
    --

    -- money
    dxDrawText("#4eb451$ #b9babb"..formatNumber(math.floor(ui.sql.org.money)), sw/2-730/2/zoom+42/zoom+477/zoom, sh/2-581/2/zoom+42/zoom+67/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[7], "left", "top", false, false, false, true)
    dxDrawText("Saldo organizacji", sw/2-730/2/zoom+42/zoom+477/zoom, sh/2-581/2/zoom+42/zoom+90/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[6], "left", "top")
    --

    dxDrawRectangle(sw/2-730/2/zoom+42/zoom, sh/2-581/2/zoom+42/zoom+171/zoom, (730-42)/zoom, 1, tocolor(80,80,80,a))

    -- rows
    local w,h=344/zoom,182/zoom

    local x,y=sw/2-730/2/zoom+42/zoom,sh/2-581/2/zoom+42/zoom+172/zoom
    dxDrawImage(x,y,w,h,texs[6],0,0,0,tocolor(255,255,255,a))
    dxDrawImage(x+80/zoom,y+(h-51/zoom)/2,59/zoom,51/zoom,texs[7],0,0,0,tocolor(255,255,255,a))
    dxDrawText("Ilość członków", x+163/zoom,y+70/zoom,w,h, tocolor(200, 200, 200, a), 1, assets.fonts[6], "left", "top")
    dxDrawText(#ui.sql.users, x+163/zoom,y+70/zoom+22/zoom,w,h, tocolor(200, 200, 200, a), 1, assets.fonts[7], "left", "top")

    local x,y=sw/2-730/2/zoom+42/zoom+344/zoom,sh/2-581/2/zoom+42/zoom+172/zoom
    dxDrawImage(x,y,w,h,texs[5],0,0,0,tocolor(255,255,255,a))
    dxDrawImage(x+85/zoom,y+(h-50/zoom)/2,50/zoom,50/zoom,texs[8],0,0,0,tocolor(255,255,255,a))
    dxDrawText("Ilość pojazdów", x+163/zoom,y+70/zoom,w,h, tocolor(200, 200, 200, a), 1, assets.fonts[6], "left", "top")
    dxDrawText(#ui.sql.vehs, x+163/zoom,y+70/zoom+22/zoom,w,h, tocolor(200, 200, 200, a), 1, assets.fonts[7], "left", "top")

    local x,y=sw/2-730/2/zoom+42/zoom,sh/2-581/2/zoom+42/zoom+172/zoom+182/zoom
    dxDrawImage(x,y,w,h,texs[5],0,0,0,tocolor(255,255,255,a))
    dxDrawImage(x+84/zoom,y+(h-42/zoom)/2,50/zoom,42/zoom,texs[9],0,0,0,tocolor(255,255,255,a))
    dxDrawText("Poziom rozwoju", x+158/zoom,y+70/zoom,w,h, tocolor(200, 200, 200, a), 1, assets.fonts[6], "left", "top")
    dxDrawText(getOrganizationUpgradeLevel().."%", x+158/zoom,y+70/zoom+22/zoom,w,h, tocolor(200, 200, 200, a), 1, assets.fonts[7], "left", "top")

    local x,y=sw/2-730/2/zoom+42/zoom+344/zoom,sh/2-581/2/zoom+42/zoom+172/zoom+182/zoom
    dxDrawImage(x,y,w,h,texs[6],0,0,0,tocolor(255,255,255,a))
    dxDrawImage(x+73/zoom,y+(h-50/zoom)/2,50/zoom,50/zoom,texs[10],0,0,0,tocolor(255,255,255,a))
    dxDrawText("Aktywność dziś", x+144/zoom,y+70/zoom,w,h, tocolor(200, 200, 200, a), 1, assets.fonts[6], "left", "top")
    dxDrawText(getOrganizationActivity().."%", x+144/zoom,y+70/zoom+22/zoom,w,h, tocolor(200, 200, 200, a), 1, assets.fonts[7], "left", "top")
end

function _dxDrawCircle(x,y,w,r1,r2,color)
    r1=r1+90
    r2=r2+90
    if(r2 > 270)then
        dxDrawCircle(x,y,w,r1,r2,color)
        dxDrawCircle(x,y,w,r2,(r2-(270-90)),color)
    else
        dxDrawCircle(x,y,w,r1,r2,color)
    end
end

function getCirclePosition(x,y,w)
    return x+w/2,y+w/2,w/2
end