--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

ui.getItems={
    ["Kastet"]=true,
    ["Kij golfowy"]=true,
    ["Nóż"]=true,
    ["Kij do baseballa"]=true,
    ["Łopata"]=true,
    ["Katana"]=true,
    ["Deagle"]=true,
    ["Strzelba"]=true,
    ["Uzi"]=true,
    ["MP5"]=true,
    ["AK-47"]=true,
    ["M4"]=true,
}

ui.render=function(text, desc, player)
    local items=getElementData(player, "user:eq") or {}

    local cx,cy=getCursorPosition()
    cx,cy=cx*sw,cy*sh

    -- header
    dxDrawText(text, 0+1, 85/zoom+100/zoom+1, sw+1, sh+1, tocolor(0, 0, 0, 255), 1, assets.fonts[1], "center", "top")
    dxDrawText(text, 0, 85/zoom+100/zoom, sw, sh, tocolor(200, 200, 200, 255), 1, assets.fonts[1], "center", "top")
    dxDrawRectangle(sw/2-409/2/zoom, 134/zoom+100/zoom, 409/zoom, 1, tocolor(85, 85, 85, 255))
    dxDrawText(desc, 0+1, 150/zoom+100/zoom+1, sw+1, sh+1, tocolor(0, 0, 0, 255), 1, assets.fonts[2], "center", "top", false, false, false, true)
    dxDrawText(desc, 0, 150/zoom+100/zoom, sw, sh, tocolor(200, 200, 200, 255), 1, assets.fonts[2], "center", "top", false, false, false, true)

    -- items
    blur:dxDrawBlur(sw/2-753/2/zoom, sh/2-420/2/zoom, 753/zoom, 420/zoom)
    dxDrawImage(sw/2-753/2/zoom, sh/2-420/2/zoom, 753/zoom, 420/zoom, assets.textures[1])

    dxDrawImage(sw/2-753/2/zoom+753/zoom-10/zoom-10/zoom, sh/2-420/2/zoom+10/zoom, 10/zoom, 10/zoom, assets.textures[3])
    onClick(sw/2-753/2/zoom+753/zoom-10/zoom-10/zoom, sh/2-420/2/zoom+10/zoom, 10/zoom, 10/zoom, function()
        s.destroy()
    end)

    local row=math.floor(scroll:dxScrollGetPosition(s.scroll)+1)
    local i=0
    for x=row,row+15 do
        i=i+1

        local v=ui.places[i]
        if(v)then
            dxDrawImage(sw/2-753/2/zoom+40/zoom+v.sX, sh/2-420/2/zoom+35/zoom+v.sY, 127/zoom, 115/zoom, assets.textures[2])

            local item=items[x]
            if(item)then
                local tex=exports.px_eq:getItemTexture(item.name)
                if(tex)then
                    dxDrawImage(sw/2-753/2/zoom+40/zoom+v.sX+(127-80)/2/zoom, sh/2-420/2/zoom+35/zoom+v.sY+(115-80)/2/zoom, 80/zoom, 80/zoom, tex, 0, 0, 0, tocolor(255, 255, 255, 255))
                end
            end
        end
    end
end

ui.click=function(button)
    if(button == "left" and s.player and isElement(s.player))then
        local items=getElementData(s.player, "user:eq") or {}

        local row=math.floor(scroll:dxScrollGetPosition(s.scroll)+1)
        local i=0
        for x=row,row+15 do
            i=i+1
    
            local v=ui.places[i]
            if(v)then    
                local item=items[x]
                if(item)then
                    local tex=exports.px_eq:getItemTexture(item.name)
                    if(tex)then
                        if(isMouseInPosition(sw/2-753/2/zoom+40/zoom+v.sX+(127-80)/2/zoom, sh/2-420/2/zoom+35/zoom+v.sY+(115-80)/2/zoom, 80/zoom, 80/zoom))then
                            if(utf8.find(item.name, "Ammo") or ui.getItems[item.name])then
                                exports.px_noti:noti("Pomyślnie zabezpieczono przedmiot "..item.name.." gracza "..getPlayerName(s.player), "success")

                                items[x]=nil
                                setElementData(s.player, "user:eq", items)
                            else
                                exports.px_noti:noti("Zabezpieczyć możesz jedynie bronie i amunicje.", "error")
                            end

                            break
                        end
                    end
                end
            end
        end
    end
end