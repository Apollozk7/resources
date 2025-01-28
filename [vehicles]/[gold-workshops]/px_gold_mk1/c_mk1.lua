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
        exports.px_noti:noti("Zaczekaj jedną sekunde.", "error")
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return block
end

local noti=exports.px_noti
local buttons=exports.px_buttons
local blur=exports.blur

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

-- assets

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Regular.ttf", 13},
    },

    textures={},
    textures_paths={
        "textures/bg.png",

        "textures/progress.png",
        "textures/line.png",
        "textures/suwak.png",

        "textures/checkbox.png",
        "textures/checkbox_selected.png",
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

local ui={}

ui.veh=false

ui.buttons={}

ui.pos={
    bg={sw/2-467/2/zoom, sh/2-392/2/zoom, 467/zoom, 392/zoom},
    ht={sw/2-467/2/zoom, sh/2-392/2/zoom, 467/zoom+sw/2-467/2/zoom, sh/2-392/2/zoom+36/zoom},
    hl={sw/2-467/2/zoom, sh/2-392/2/zoom+36/zoom, 467/zoom, 1},

    b1={sw/2-467/2/zoom, sh/2-392/2/zoom+36/zoom+1, 467/zoom, 32/zoom, 90/zoom, 20/zoom},
    b2={sw/2-427/2/zoom, sh/2-392/2/zoom+36/zoom+1+45/zoom, 427/zoom, 13/zoom},
    b3={7/zoom, 8/zoom},

    bc={sw/2-467/2/zoom+100/zoom, sh/2-392/2/zoom+36/zoom+53/zoom, 18/zoom, 18/zoom, 100/zoom, 27/zoom}
}

ui.upgrades={}

ui.onRender = function()
    local p=ui.pos
    if(ui.veh and isElement(ui.veh))then
        blur:dxDrawBlur(p.bg[1], p.bg[2], p.bg[3], p.bg[4])
        dxDrawImage(p.bg[1], p.bg[2], p.bg[3], p.bg[4], assets.textures[1])
        dxDrawText("Modyfikacja układu MK1", p.ht[1], p.ht[2], p.ht[3], p.ht[4], tocolor(200, 200, 200), 1, assets.fonts[1], "center", "center")
        dxDrawRectangle(p.hl[1], p.hl[2], p.hl[3], p.hl[4], tocolor(80,80,80))
    
        -- bars
        for i,v in pairs(ui.upgrades) do
            local sY=p.b1[5]*(i-1)
            dxDrawImage(p.b1[1], p.b1[2]+sY, p.b1[3], p.b1[5], assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, 100))
            dxDrawImage(p.b1[1], p.b1[2]+sY, p.b1[3], p.b1[4], assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, 150))
    
            if(v.type == "slider")then
                local pr=math.floor(v.from+(v.to-v.from)*(v.progress/100))
                dxDrawText(v.name.." - "..pr, p.b1[1]+p.b1[6], p.b1[2]+sY, p.b1[3], p.b1[4]+p.b1[2]+sY, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
    
                dxDrawImage(p.b2[1], p.b2[2]+sY, p.b2[3], p.b2[4], assets.textures[2])
                dxDrawImage(p.b2[1], p.b2[2]+sY, p.b2[3]*(v.progress/100), p.b2[4], assets.textures[3])
                dxDrawImage(p.b2[1]+(p.b2[3]*(v.progress/100))-p.b3[1]/2, p.b2[2]+sY+p.b2[4], p.b3[1], p.b3[2], assets.textures[4])
    
                dxDrawText(v.from, p.b2[1], p.b2[2]+sY+p.b2[4]+p.b2[4]/2, p.b2[3], p.b2[4], tocolor(200, 200, 200), 1, assets.fonts[1], "left", "top")
                dxDrawText(v.from+(v.to-v.from)/2, p.b2[1], p.b2[2]+sY+p.b2[4]+p.b2[4]/2, p.b2[1]+p.b2[3], p.b2[4], tocolor(200, 200, 200), 1, assets.fonts[1], "center", "top")
                dxDrawText(v.to, p.b2[1], p.b2[2]+sY+p.b2[4]+p.b2[4]/2, p.b2[1]+p.b2[3], p.b2[4], tocolor(200, 200, 200), 1, assets.fonts[1], "right", "top")
    
                if(isMouseInPosition(p.b2[1], p.b2[2]+sY, p.b2[3]+1, p.b2[4]) and getKeyState("mouse1"))then
                    local sx,sy=getCursorPosition()
                    sx,sy=sx*sw,sy*sh
            
                    sx=sx-p.b2[1]
                    sx=sx/p.b2[3]
            
                    v.progress=sx*100
                end
            elseif(v.type == "check")then
                dxDrawText(v.name, p.b1[1]+p.b1[6], p.b1[2]+sY, p.b1[3], p.b1[4]+p.b1[2]+sY, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
    
                for k,value in pairs(v.types) do
                    local sX=p.bc[5]*(k-1)
                    dxDrawImage(p.bc[1]+sX, p.bc[2]+sY, p.bc[3], p.bc[4], assets.textures[v.selected == k and 6 or 5])
                    dxDrawText(value, p.bc[1]+sX+p.bc[6], p.bc[2]+sY, p.bc[3], p.bc[4]+p.bc[2]+sY, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
    
                    onClick(p.bc[1]+sX, p.bc[2]+sY, p.bc[3], p.bc[4], function()
                        v.selected=k
                    end)
                end
            end
        end

        onClick(sw/2-148/2/zoom, sh/2+130/zoom, 148/zoom, 39/zoom, function()
            if(SPAM.getSpam())then return end

            triggerLatentServerEvent("set.mk1", resourceRoot, ui.veh, ui.upgrades)
            ui.toggleUI() 
        end)
    else
        ui.toggleUI() 
    end
end

ui.toggleUI=function(toggle, veh)
    if(toggle)then
        noti=exports.px_noti
        buttons=exports.px_buttons
        blur=exports.blur

        ui.veh=veh
        assets.create()
        
        addEventHandler("onClientRender", root, ui.onRender)
        showCursor(true,false)
        
        ui.buttons[1]=buttons:createButton(sw/2-148/2/zoom, sh/2+130/zoom, 148/zoom, 39/zoom, "USTAW", 255, 10/zoom, false, false)

        local hand=getVehicleHandling(ui.veh)
        local oHand=getOriginalHandling(getElementModel(ui.veh))
        local start,stop=oHand.mass-400,oHand.mass+1200
        ui.upgrades={
            {name="Promień skrętu (stopnie)", type="slider", from=15, to=45, progress=math.floor((hand.steeringLock-15)/(45-15)*100)},
            {name="Masa pojazdu (kg)", type="slider", from=start, to=stop, progress=math.floor((hand.mass-start)/(stop-start)*100)},
            {name="Napęd pojazdu", type="check", types={"Przód", "Tył", "4x4"}, selected=hand.driveType == "awd" and 3 or hand.driveType == "fwd" and 1 or 2}
        }
    else
        showCursor(false)

        removeEventHandler("onClientRender", root, ui.onRender)

        for i = 1,#ui.buttons do
            buttons:destroyButton(ui.buttons[i])
        end
        ui.buttons={}

        assets.destroy()
    end
end

addEvent("ui.toggleUI", true)
addEventHandler("ui.toggleUI", resourceRoot, ui.toggleUI)

-- useful by asper

function isMouseInPosition(x, y, w, h)
	if(not isCursorShowing())then return end

	local cx,cy=getCursorPosition()
	cx,cy=cx*sw,cy*sh

    if(isCursorShowing() and (cx >= x and cx <= (x + w)) and (cy >= y and cy <= (y + h)))then
        return true
    end
    return false
end

function getPosition(myX, myY, x, y, w, h)
    if(isCursorShowing() and (myX >= x and myX <= (x + w)) and (myY >= y and myY <= (y + h)))then
        return true
    end
    return false
end

local mouseState=false
local mouseTick=getTickCount()
local mouseClicks=0
local mouseClick=false
function onClick(x, y, w, h, fnc)
	if(not isCursorShowing())then return end

	if((getTickCount()-mouseTick) > 1000 and mouseClicks > 0)then
		mouseClicks=mouseClicks-1
	end

	if(not mouseState and getKeyState("mouse1"))then
		local cursor={getCursorPosition()}
        mouseState=cursor
    elseif(not getKeyState("mouse1") and (mouseClick or mouseState))then
        mouseClick=false
        mouseState=false
    end

    if(mouseState and mouseClicks < 10 and not mouseClick)then
		local cx,cy=unpack(mouseState)
        cx,cy=cx*sw,cy*sh

        if(getPosition(cx, cy, x, y, w, h))then
			fnc()

			mouseClicks=mouseClicks+1
            mouseTick=getTickCount()
            mouseClick=true
        end
	end
end