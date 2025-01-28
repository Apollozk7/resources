--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local wrapped=false
local floor=math.floor
local x,y=floor(sw/2-538/2/zoom+538/zoom+25/zoom),floor(sh/2-168/zoom)

ui.news={}

ui.scrollPosition=0

ui.newsRT=dxCreateRenderTarget(floor(300/zoom), floor(414/zoom), true)

ui.updateRT=function()
    -- variables
    local firstDraw={}
    local draw={}
    local max=0
    local aY=-exports.px_scroll:dxScrollGetRTPosition(ui.scroll) or 0

    -- save
    for i,v in pairs(ui.news) do
        local w=50/zoom

        draw[#draw+1]={18/zoom, aY+11/zoom, 0, 0, 'date', v.date}

        local add=0
        if(v.wrapedDesc)then
            for i,v in pairs(v.wrapedDesc) do
                local sY=(20/zoom)*(i-1)
                draw[#draw+1]={18/zoom, aY+31/zoom+sY, 270/zoom, 0, 'desc', v}
                w=w+20/zoom
                add=add+22/zoom
            end
        end

        for i,v in pairs({v.sub_1,v.sub_2,v.sub_3,v.sub_4}) do
            if(#v > 0)then
                local sY=(20/zoom)*(i-1)
                draw[#draw+1]={18/zoom, aY+31/zoom+sY+add+2/zoom, 11/zoom, 10/zoom, 'plus'}
                draw[#draw+1]={18/zoom+20/zoom, aY+31/zoom+sY+add, 270/zoom, 0, 'plusText', v}
                w=w+20/zoom
            end
        end

        if(i == 1)then
            firstDraw[#firstDraw+1]={1, aY, 299/zoom, w, 'bg'}
            firstDraw[#firstDraw+1]={115/zoom, aY+13/zoom, 59/zoom, 16/zoom, 'new'}
        end
        draw[#draw+1]={1, aY+w, 299/zoom, 1, 'line'}

        aY=aY+w+1
        max=max+w
    end

    -- draw rt
    dxSetRenderTarget(ui.newsRT, true)
    dxSetBlendMode("add")
        for i,v in pairs(firstDraw) do
            if(v[5] == 'bg')then
                dxDrawImage(v[1], v[2], v[3], v[4], assets.newsTxt[4])
            elseif(v[5] == 'new')then
                dxDrawImage(v[1], v[2], v[3], v[4], assets.newsTxt[5])
            end
        end

        for i,v in pairs(draw) do
            if(v[5] == 'date')then
                dxDrawText(v[6], v[1], v[2], v[3], v[4], tocolor(170, 170, 170), 1, assets.fonts[1], 'left', 'top')
            elseif(v[5] == 'desc')then
                dxDrawText(v[6], v[1], v[2], v[3], v[4], tocolor(255,255,255), 1, assets.fonts[3], 'left', 'top')
            elseif(v[5] == 'plus')then
                dxDrawImage(v[1], v[2], v[3], v[4], assets.newsTxt[3])
            elseif(v[5] == 'plusText')then
                dxDrawText(v[6], v[1], v[2], v[3], v[4], tocolor(255,255,255), 1, assets.fonts[6], 'left', 'top')
            elseif(v[5] == 'line')then
                dxDrawRectangle(v[1], v[2], v[3], v[4], tocolor(80,80,80,125))
            end
        end
    dxSetBlendMode("blend")
    dxSetRenderTarget()
    --

    -- save weight
    exports.px_scroll:dxScrollUpdateRTSize(ui.scroll, max)
end

ui.draw["Aktualizacje"]=function(a)
    dxDrawImage(x, y, 300/zoom, 464/zoom, assets.newsTxt[1], 0, 0, 0, tocolor(255,255,255,a))
    dxDrawImage(x+18/zoom, y+(48-18)/2/zoom, 18/zoom, 18/zoom, assets.newsTxt[2], 0, 0, 0, tocolor(255,255,255,a))
    dxDrawText('Aktualizacje', x+49/zoom, y, 0, y+48/zoom, tocolor(200, 200, 200, a), 1, assets.fonts[1], 'left', 'center')
    dxDrawRectangle(x, y+48/zoom, 300/zoom, 1, tocolor(80,80,80,a > 125 and 125 or a))
    dxDrawImage(x, y+floor(48/zoom), floor(300/zoom), floor(414/zoom), ui.newsRT, 0, 0, 0, tocolor(255,255,255,a))

    local scrollPos = exports.px_scroll:dxScrollGetRTPosition(ui.scroll) or 0
    if(ui.scrollPosition ~= scrollPos) then 
        ui.updateRT()
    end
end

addEvent('px_auth:getChangelogList', true)
addEventHandler('px_auth:getChangelogList', resourceRoot, function(r)
    ui.news=r

    for i,v in pairs(ui.news) do
        v.wrapedDesc=wordWrap(v.desc, 270/zoom, 1, assets.fonts[3])
    end

    ui.scroll=exports.px_scroll:dxCreateScroll(x+300/zoom-4/zoom, y+48/zoom, 4, 414/zoom, 0, 2, false, 414/zoom, 255, 0, false, true, 0, 414/zoom, 150)
    ui.updateRT()
end)

-- useful

function wordWrap(text, maxwidth, scale, font, colorcoded)
    local lines = {}
    local words = split(text, " ") -- this unfortunately will collapse 2+ spaces in a row into a single space
    local line = 1 -- begin with 1st line
    local word = 1 -- begin on 1st word
    local endlinecolor
    while (words[word]) do -- while there are still words to read
        repeat
            if colorcoded and (not lines[line]) and endlinecolor and (not string.find(words[word], "^#%x%x%x%x%x%x")) then -- if on a new line, and endline color is set and the upcoming word isn't beginning with a colorcode
                lines[line] = endlinecolor -- define this line as beginning with the color code
            end
            lines[line] = lines[line] or "" -- define the line if it doesnt exist

            if colorcoded then
                local rw = string.reverse(words[word]) -- reverse the string
                local x, y = string.find(rw, "%x%x%x%x%x%x#") -- and search for the first (last) occurance of a color code
                if x and y then
                    endlinecolor = string.reverse(string.sub(rw, x, y)) -- stores it for the beginning of the next line
                end
            end
      
            lines[line] = lines[line]..words[word] -- append a new word to the this line
            lines[line] = lines[line] .. " " -- append space to the line

            word = word + 1 -- moves onto the next word (in preparation for checking whether to start a new line (that is, if next word won't fit)
        until ((not words[word]) or dxGetTextWidth(lines[line].." "..words[word], scale, font, colorcoded) > maxwidth) -- jumps back to 'repeat' as soon as the code is out of words, or with a new word, it would overflow the maxwidth
    
        lines[line] = string.sub(lines[line], 1, -2) -- removes the final space from this line
        if colorcoded then
            lines[line] = string.gsub(lines[line], "#%x%x%x%x%x%x$", "") -- removes trailing colorcodes
        end
        line = line + 1 -- moves onto the next line
    end -- jumps back to 'while' the a next word exists
    return lines
end