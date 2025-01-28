--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

SPAM={}
SPAM.getSpam=function()
    local block=false

    if(SPAM.blockSpamTimer)then
        killTimer(SPAM.blockSpamTimer)
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 300, 1)

    return block
end

sw,sh=guiGetScreenSize()
zoom=1920/sw

noti=exports.px_noti
blur=exports.blur

-- assets

assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Medium.ttf", 11},
    },

    textures={},
    textures_paths={
        "textures/bg.png",
        "textures/progress.png",
        "textures/x_button.png",
        "textures/arrow.png",
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

--

ui={}

ui.markers={}
ui.blips={}
ui.objects={}

ui.lider=false
ui.players={}

ui.haveTrash=false
ui.vehicle=false
ui.tick=getTickCount()

ui.ids={
    [1339]="Kosz",
    [1265]="Worek"
}

ui.pos={
    -- progressbar
    [3]={sw/2-366/2/zoom, sh-97/zoom, 366/zoom, 49/zoom},
    [4]={sw/2-366/2/zoom+15/zoom, sh-97/zoom+7/zoom, sw/2-366/2/zoom+15/zoom+339/zoom, 0},
    [5]={sw/2-366/2/zoom+13/zoom, sh-97/zoom+49/zoom-16/zoom, 339/zoom, 7/zoom},
    --
}

-- useful

function checkAndDestroy(element)
    if(element and isElement(element))then
        destroyElement(element)
        element=nil
    end
end

function table.size(tbl)
    local k=0
    for i,v in pairs(tbl) do
        k=k+1
    end
    return k
end

function math.percent(percent,maxvalue)
    if tonumber(percent) and tonumber(maxvalue) then
        return (maxvalue*percent)/100
    end
    return false
end