--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]


local t={}
for i=1,6 do
    local sY=(155/zoom)*(i-1)
    for i=1,4 do
        local sX=(361/zoom)*(i-1)
        t[#t+1]={sX=sX,sY=sY}
    end
end



ui.rendering["Osiągnięcia"]=function(a, mainA)
    a=a > mainA and mainA or a

    local texs=assets.textures["Osiągnięcia"]
    if(not texs or (texs and #texs < 1))then return false end

    local list = ui.info.achievements

    -- header
    dxDrawText("Osiągnięcia", 426/zoom, 63/zoom, 0, 0, tocolor(200, 200, 200, a), 1, assets.fonts[5], "left", "top")
    dxDrawText("Graj i zdobywaj kamienie milowe, aby otrzymać nagrodę.", 426/zoom, 93/zoom, 0, 0, tocolor(150, 150, 150, a), 1, assets.fonts[1], "left", "top")

    local k=0
    local row=1
    for i=row,row+(ui.info.achievementsLength+1) do
        local v=list[i]
        if(v)then
            k=k+1

            local p=t[k]
            if(p)then
                local have=exports.px_achievements:isPlayerHaveAchievement(v.title)
                local aa=not have and 100 or 255
                aa=aa > a and a or aa

                dxDrawImage(426/zoom+p.sX, 151/zoom+p.sY, 344/zoom, 138/zoom, texs[1], 0, 0, 0, tocolor(255, 255, 255, aa))
                dxDrawImage(426/zoom+p.sX+24/zoom, 151/zoom+p.sY+43/zoom, 67/zoom, 67/zoom, texs[2], 0, 0, 0, tocolor(255, 255, 255, aa))

                dxDrawText(have and v.title or string.rep("?",#v.title), 426/zoom+p.sX+24/zoom, 151/zoom+p.sY+15/zoom, 0, 0, tocolor(200, 200, 200, aa), 1, assets.fonts[8], "left", "top")
                dxDrawText(have and v.description or string.rep("?",#v.description), 426/zoom+p.sX+112/zoom, 151/zoom+p.sY+42/zoom, 426/zoom+p.sX+112/zoom+170/zoom, 0, tocolor(200, 200, 200, aa), 1, assets.fonts[2], "left", "top", false, true)

                dxDrawText((have and v.moneyPrize or "?").." RP", 426/zoom+p.sX+112/zoom, 151/zoom+p.sY+105/zoom, 426/zoom+p.sX+112/zoom+170/zoom, 0, tocolor(150, 150, 150, aa), 1, assets.fonts[2], "left", "top", false, true)

                if(have)then
                    dxDrawRectangle(426/zoom+p.sX, 151/zoom+p.sY+138/zoom-4, 344/zoom, 4/zoom, tocolor(56,143,75, aa))
                else
                    dxDrawRectangle(426/zoom+p.sX, 151/zoom+p.sY+138/zoom-4, 344/zoom, 4/zoom, tocolor(80,80,80, aa))
                end
            end
        end
    end
end