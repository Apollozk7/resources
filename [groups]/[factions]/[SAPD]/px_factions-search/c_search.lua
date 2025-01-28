--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local tbl={}
for i=1,50 do
    table.insert(tbl,{})
end

s={}

s.player=false
s.scroll=false

s.render=function()
    if(s.player and isElement(s.player))then
        ui.render("PRZESZUKIWANIE", "Ekwipunek gracza: "..getPlayerName(s.player).."\nKliknij dwa razy LPM na przedmiot aby go zabezpieczyć.", s.player)
    else
        s.destroy()
    end
end

s.create=function(player)
    s.player=player

    assets.create()
    addEventHandler("onClientRender", root, s.render)
    addEventHandler("onClientDoubleClick", root, ui.click)

    showCursor(true)

    s.scroll = scroll:dxCreateScroll(sw/2-753/2/zoom+720/zoom, sh/2-420/2/zoom+35/zoom, 4/zoom, 4/zoom, 0, 15, tbl, 420/zoom-(35*2)/zoom, 255, 5, false, false, false, false, false, true)
end

s.destroy=function(cancel)
    removeEventHandler("onClientRender", root, s.render)
    removeEventHandler("onClientDoubleClick", root, ui.click)

    assets.destroy()

    showCursor(false)

    s.player=false

    scroll:dxDestroyScroll(s.scroll)
end

function action(id,player,name)
    if(name == "Przeszukaj")then
        s.create(player)
    end
end