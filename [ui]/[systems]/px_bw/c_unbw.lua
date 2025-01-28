--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local blur=exports.blur
local noti=exports.px_noti

local assets={}
assets.list={
    texs={
        "textures/window.png",
        "textures/star.png",
    },

    fonts={
        {"Medium", 17},
        {"Medium", 11},
        {"Regular", 13},
        {"Medium", 25},
    },
}

assets.create=function()
    assets.textures={}
    for i,v in pairs(assets.list.texs) do
        assets.textures[i]=dxCreateTexture(v, "argb", false, "clamp")
    end

    assets.fonts={}
    for i,v in pairs(assets.list.fonts) do
        assets.fonts[i]=dxCreateFont(":px_assets/fonts/Font-"..v[1]..".ttf", v[2]/zoom)
    end
end

assets.destroy=function()
    for i,v in pairs(assets.textures) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.textures={}

    for i,v in pairs(assets.fonts) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end
    assets.fonts={}
end

-- variables

local ui={}

ui.tick=getTickCount()
ui.rot=0
ui.player=localPlayer
ui.dots={}

ui.onRender=function()
    if(not ui.player or (ui.player and not isElement(ui.player)))then
        return ui.destroy()
    end

    if(not getElementData(ui.player, "user:bw"))then
        return ui.destroy()
    end

    -- camera
    local pos = {getElementPosition(ui.player)}
	pos[3] = pos[3]+5

    ui.rot=ui.rot+0.5

    local a1,a2=interpolateBetween(3,1,0,5,-1,0,(getTickCount()-ui.tick)/1500,"SineCurve")
    pos[1]=pos[1]-a2
    pos[2]=pos[2]-a2

	cPos = {getPointFromDistanceRotation(pos[1], pos[2], a1, ui.rot)}
	setCameraMatrix(cPos[1], cPos[2], pos[3], pos[1], pos[2], pos[3]-5)
    --

    local time=getElementData(ui.player, "user:bw") or 0
    local hours = math.floor(time/60)
    local minutes = math.floor(time-(hours*60))
    time=(hours > 0 and string.format("%02d", hours)..":" or "00:")..(minutes > 0 and string.format("%02d", minutes) or "00")

    dxDrawText("Aby anulować naciśnij 'ESC'.", sw/2-460/2/zoom+1, 20/zoom+1, 460/zoom+sw/2-460/2/zoom+1, 96/zoom, tocolor(0, 0, 0), 1, assets.fonts[2], "center", "top")
    dxDrawText("Aby anulować naciśnij 'ESC'.", sw/2-460/2/zoom, 20/zoom, 460/zoom+sw/2-460/2/zoom, 96/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "center", "top")

    blur:dxDrawBlur(sw/2-460/2/zoom, 51/zoom, 460/zoom, 159/zoom)
    dxDrawImage(sw/2-460/2/zoom, 51/zoom, 460/zoom, 159/zoom, assets.textures[1])
    dxDrawText("NIEPRZYTOMNY", sw/2-460/2/zoom, 51/zoom, 460/zoom+sw/2-460/2/zoom, 96/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "center", "center")
    dxDrawRectangle(sw/2-409/2/zoom, 96/zoom, 409/zoom, 1, tocolor(85,85,85))
    dxDrawText("#c2c2c2Gracz ["..getElementData(ui.player, "user:id").."] "..getPlayerName(ui.player).." stracił całe zdrowie, pomóż mu się odrodzić\nzbierając wszystkie #f8bc07gwiazdki#c2c2c2 nad jego głową.", sw/2-460/2/zoom, 96/zoom, 460/zoom+sw/2-460/2/zoom, 145/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "center", "center", false, false, false, true)
    dxDrawRectangle(sw/2-409/2/zoom, 145/zoom, 409/zoom, 1, tocolor(85,85,85))
    dxDrawText("Czas na wykonanie zadania:", sw/2-460/2/zoom, 156/zoom, 460/zoom+sw/2-460/2/zoom, 145/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "center", "top", false, false, false, true)
    dxDrawText(time, sw/2-460/2/zoom, 156/zoom+18/zoom, 460/zoom+sw/2-460/2/zoom, 145/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "center", "top", false, false, false, true)

    -- icons
    local x,y,z=getPedBonePosition(ui.player, 6)
    local sx,sy=getScreenFromWorldPosition(x,y,z)
    if(sx and sy)then
        local dist=getDistanceBetweenPoints3D(x,y,z,cPos[1],cPos[2],pos[3])
        local scale=dist/3

        local exists=true
        local x,y,w,h=sx, sy, 221/zoom/scale, 218/zoom/scale

        for i=1,2 do
            if(not ui.dots[i])then
                local sY=(200/zoom/scale)*(i-1)
                local pw,ph=i == 1 and w or w/1.7,i == 1 and h or h/1.7
                dxDrawImage(x-pw/2,y-sY-ph/2,pw,ph, assets.textures[2])

                onClick(x-pw/2,y-sY-ph/2,pw,ph, function()
                    ui.dots[i]=true
                end)

                exists=false
            end
        end

        for i=1,2 do
            local dot=i+4
            if(not ui.dots[dot])then
                local sX=(150/zoom/scale)*(i-1)
                local pw,ph=w/1.5, h/1.5
                dxDrawImage(x-pw/2+sX-75/scale/zoom,y-ph/2-150/scale/zoom,pw,ph, assets.textures[2])

                onClick(x-pw/2+sX-75/scale/zoom,y-ph/2-150/scale/zoom,pw,ph, function()
                    ui.dots[dot]=true
                end)

                exists=false
            end
        end

        for i=1,2 do
            local dot=i+6
            if(not ui.dots[dot])then
                local sX=(180/zoom/scale)*(i-1)
                local pw,ph=w/1.2, h/1.2
                dxDrawImage(x-pw/2+sX-180/scale/2/zoom,y-ph/2-70/scale/zoom,pw,ph, assets.textures[2])

                onClick(x-pw/2+sX-180/scale/2/zoom,y-ph/2-70/scale/zoom,pw,ph, function()
                    ui.dots[dot]=true
                end)

                exists=false
            end
        end

        if(exists)then
            noti:noti("Po udanej próbie reanimacji udało Ci się podnieść "..getPlayerName(ui.player)..".", "success")
            triggerServerEvent("bw.spawn", resourceRoot, ui.player)
            ui.destroy()
        end
    end
    --
end

ui.onKey=function(key,press)
    if(press and key == "escape")then
        cancelEvent()
        ui.destroy()
    end
end

ui.create=function(player)
    blur=exports.blur
    noti=exports.px_noti

    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)
    addEventHandler("onClientKey", root, ui.onKey)

    ui.player=player
    ui.dots={}

    showCursor(true)

    setElementData(localPlayer, "user:hud_disabled", true, false)
end

ui.destroy=function()
    removeEventHandler("onClientRender", root, ui.onRender)
    removeEventHandler("onClientKey", root, ui.onKey)

    assets.destroy()

    ui.player=false
    ui.dots={}

    setCameraTarget(localPlayer)

    showCursor(false)

    setElementData(localPlayer, "user:hud_disabled", false, false)
end

function action(i, element, name, info)
    if(name == "Reanimuj")then
        if(element and getElementData(element, "user:bw"))then
            ui.create(element)
        else
            noti:noti("Podany gracz nie potrzebuje reanimacji.", "error")
        end
    end
end

-- useful

function getPointFromDistanceRotation(x, y, dist, angle)

    local a = math.rad(90 - angle);

    local dx = math.cos(a) * dist;
    local dy = math.sin(a) * dist;

    return x+dx, y+dy;

end

-- useful function created by Asper

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
function onClick(x, y, w, h, fnc, key)
	if(not isCursorShowing())then return end

	if((getTickCount()-mouseTick) > 1000 and mouseClicks > 0)then
		mouseClicks=mouseClicks-1
	end

	if(not mouseState and getKeyState(key or "mouse1"))then
		local cursor={getCursorPosition()}
        mouseState=cursor
    elseif(not getKeyState(key or "mouse1") and (mouseClick or mouseState))then
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