--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local MAP = {}

local buttons=exports.px_buttons
local blur=exports.blur
local alogo=exports.px_alogos
local noti=exports.px_noti
local scroll=exports.px_scroll

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local blipsTexture = {}

-- variables

MAP.showed = false

MAP.alpha = 0
MAP.animate = false

assets={}
assets.textures={
    arrow = dxCreateTexture("assets/images/blips/arrow.png", "argb", false, "clamp"),
    window = dxCreateTexture("assets/images/left_bar.png", "argb", false, "clamp"),
    map_texture = dxCreateTexture("assets/images/map.png", "argb", false, "clamp"),
    maskTexture = dxCreateTexture("assets/images/mask.png", "argb", false, "clamp"),
    circleRadar = dxCreateTexture("assets/images/circle_radar.png", "argb", false, "clamp"),
    blip_hover=dxCreateTexture("assets/images/blip_hover.png", "argb", false, "clamp"),
}

MAP.fonts = {
    dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 20/zoom),
    dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 15/zoom),
    dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 13/zoom),
    dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 11/zoom),
}


-- events

MAP.btns={}
MAP.row=0
MAP.scroll=false
MAP.blipHover=false
MAP.hoverTick=getTickCount()
MAP.newZoom=1
MAP.lastZoom=1
MAP.tickZoom=getTickCount()

MAP.pos={293/zoom, 0, sw-293/zoom, sh}

MAP.unit=3000
MAP.mapSize=2048
MAP.zoom=0.5

MAP.mPos={0,0}
MAP.catchPos=false

MAP.onPreRender=function()
    toggleControl("fire",false)
    
    -- gps
    local gps=getGPSPositionsMax()
    if(gps and #gps > 0)then
        for i,v in pairs(gps) do
            if(v.marker and getElementDimension(v.marker) == getElementDimension(localPlayer) and getElementInterior(v.marker) == getElementInterior(localPlayer))then
                local blipX, blipY = worldPosToMapPos(v.posX, v.posY)
                local next=gps[i+1]
                if(blipX and blipY and next)then
                    local x,y=worldPosToMapPos(next.posX,next.posY)
                    if(x and y)then
                        dxDrawLine(blipX, blipY, x, y, tocolor(255, 0, 0, MAP.alpha), 5, true)
                    end
                end
            end
        end

        local next=gps[2]
        if(next)then
            local x,y=worldPosToMapPos(next.posX,next.posY)
            if(x and y and blip and isElement(blip))then
                local bx,by=getElementPosition(blip)
                bx,by=worldPosToMapPos(bx,by)
                dxDrawLine(x, y, bx, by, tocolor(255, 0, 0, MAP.alpha), 5, true)
            end
        end
    end

    -- blipy
	for i,v in pairs(getElementsByType("blip")) do
        local x,y=getElementPosition(v)
		local x,y=worldPosToMapPos(x,y)
        if(x and y and localPlayer ~= getElementAttachedTo(v) and getElementDimension(v) == getElementDimension(localPlayer) and getElementInterior(v) == getElementInterior(localPlayer))then
            local blip_icon = getBlipIcon(v)
            local blip_size = getBlipIcon(v) == 0 and (15/zoom / 2) * getBlipSize(v) or 35/zoom
            --blip_size=blip_size*(0.5+(MAP.zoom/1.5))

            local a=MAP.alpha
            if(blip_icon == 18 or blip_icon == 24 or blip_icon == 45 or blip_icon == 2 or blip_icon == 9 or blip_icon == 17)then
                blip_size=20/zoom
            end

            local blip_color = getBlipIcon(v) == 0 and {getBlipColor(v)} or {255, 255, 255, a}
            blip_color[4]=blip_color[4] > a and a or blip_color[4]

            local current_blip = findBlipTexture(blip_icon)

            local attached=getElementAttachedTo(v)
            if(attached and getElementType(attached) == "player" and isPlayerInFriends(attached))then
                blip_color={59, 186, 38, blip_color[4]}

                if(not getElementData(v, "friend:blip"))then
                    setElementData(v, "friend:blip", getPlayerName(attached), false)
                end
            else
                if(getElementData(v, "friend:blip"))then
                    setElementData(v, "friend:blip", false, false)
                end
            end

            a=a > MAP.alpha and MAP.alpha or a

            if(MAP.blipHover == v)then
                dxDrawImage(x - (77/zoom / 2), y - (77/zoom / 2), 77/zoom, 77/zoom, assets.textures.blip_hover, 0, 0, 0, tocolor(255, 255, 255, blip_color[4]), true)
            end
            
            dxDrawImage(x - (blip_size / 2), y - (blip_size / 2), blip_size, blip_size, current_blip, 0, 0, 0, tocolor(blip_color[1], blip_color[2], blip_color[3], blip_color[4]), true)
		end
	end

    -- player arrow
    local playerRotation = getPedRotation(localPlayer)
    local x, y, z = getElementPosition(localPlayer)
	local blipX, blipY = worldPosToMapPos(x,y)
    if(blipX and blipY)then
	    dxDrawImage(blipX - (18 / 2)/zoom, blipY - (18 / 2)/zoom, 18/zoom, 18/zoom, assets.textures.arrow, 360 - playerRotation, 0, 0, tocolor(255, 255, 255, MAP.alpha), true)
    end
end

MAP.onRender = function()
    blur:dxDrawBlur(0, 0, sw, sh, tocolor(100, 100, 100, MAP.alpha))

    if(MAP.clickTick)then        
        if((getTickCount()-MAP.clickTick) < 500)then
            MAP.mPos[1], MAP.mPos[2] = interpolateBetween(MAP.mPos[1], MAP.mPos[2], 0, MAP.clickPos[1], MAP.clickPos[2], 0, (getTickCount()-MAP.clickTick)/500, "Linear")
        elseif((getTickCount()-MAP.clickTick) > 5000)then
            MAP.clickTick = nil
            MAP.blipHover=false
        end
    end

    local m=MAP.mapSize*MAP.zoom
	--local map={(MAP.pos[3]-m)/2+MAP.mPos[1], (MAP.pos[4]-m)/2+MAP.mPos[2], m, m}
    local map={MAP.mPos[1]+MAP.pos[1]-(MAP.pos[3]*(1*(MAP.zoom-0.5))), MAP.mPos[2]+MAP.pos[2]-(MAP.pos[4]*(1*(MAP.zoom-0.5)))}
    dxDrawImageSection(MAP.pos[1], MAP.pos[2], MAP.pos[3], MAP.pos[4], -map[1]/MAP.zoom + MAP.pos[1]/MAP.zoom, -map[2]/MAP.zoom + MAP.pos[2]/MAP.zoom, MAP.pos[3]/MAP.zoom, MAP.pos[4]/MAP.zoom, getMapTexture(), 0, 0, 0, tocolor(200, 200, 200, MAP.alpha))

    if(MAP.tickZoom)then
        local zoom=interpolateBetween(MAP.lastZoom, 0, 0, MAP.newZoom, 0, 0, (getTickCount()-MAP.tickZoom)/200, "Linear")
        local last=MAP.zoom
        MAP.zoom=zoom
        MAP.mPos[1]=MAP.mPos[1]*(MAP.zoom/last)
        MAP.mPos[2]=MAP.mPos[2]*(MAP.zoom/last)

        if((getTickCount()-MAP.tickZoom) > 200)then
            MAP.tickZoom=false
        end
    end

    if(not MAP.moved)then
        local x,y=getElementPosition(localPlayer)
        setMapPos(x,y)
    end

	if(isMouseInPosition(MAP.pos[1], MAP.pos[2], MAP.pos[3], MAP.pos[4]))then
		if(getKeyState("mouse1"))then
			local cx,cy=getCursorPosition()
			cx,cy=cx*sw,cy*sh

			if(not MAP.catchPos)then
				local cx, cy = cx - MAP.mPos[1], cy - MAP.mPos[2]
				MAP.catchPos = {cx, cy}
			else
				MAP.mPos[1], MAP.mPos[2] = cx - MAP.catchPos[1], cy - MAP.catchPos[2]
			end

            MAP.moved=true
		else
			MAP.catchPos=false
		end
	end

	if(isCursorShowing())then
		local cx,cy=getCursorPosition()
		cx,cy=cx*sw,cy*sh

		onClick2(MAP.pos[1], MAP.pos[2], MAP.pos[3], MAP.pos[4], function()
            if(MAP.blip)then
                MAP.blip=false

                setGPSClear()
            else
                setGPSClear()
                
                local x,y=mapPosToWorldPos(cx,cy)
                local z=getGroundPosition(x,y,100)
                setGPSPosition(x,y,z)

                local zone1=getZoneName(x,y,z,true)
                local zone2=getZoneName(x,y,z,false)
                noti:noti("Trasa do "..zone1..", "..zone2.." została wyznaczona.", "success")

                MAP.blip=true
            end
		end)
	end
    
    -- left window
    dxDrawImage(0, 0, 292/zoom, sh, assets.textures.window, 0, 0, 0, tocolor(255, 255, 255, MAP.alpha))

    -- header
    local xw,xh=612/3,198/3
    alogo:dxDrawMiniLogo((292-xw)/2/zoom, (110-xh)/2/zoom, xw/zoom, xh/zoom, MAP.alpha)
    dxDrawRectangle(0, 110/zoom, 292/zoom, 1, tocolor(59, 59, 59, MAP.alpha))

    -- list
    dxDrawText("LEGENDA", 0, 136/zoom, 292/zoom, sh, tocolor(200, 200, 200, MAP.alpha), 1, MAP.fonts[2], "center", "top", false)
    dxDrawText("Mapy San Andreas", 0, 160/zoom, 292/zoom, sh, tocolor(200, 200, 200, MAP.alpha), 1, MAP.fonts[4], "center", "top", false)

    -- footer
    dxDrawRectangle(0, sh-135/zoom, 292/zoom, 1, tocolor(59, 59, 59, MAP.alpha))

    dxDrawText("KLAWISZOLOGIA", 0, sh-112/zoom, 292/zoom, sh, tocolor(200, 200, 200, MAP.alpha), 1, MAP.fonts[2], "center", "top", false)
    dxDrawText("Rolka myszy - powiększanie/oddalanie\nLPM - ruszanie mapą\nPPM - GPS", 10/zoom, sh-80/zoom, 455/zoom, sh, tocolor(200, 200, 200, MAP.alpha), 1, MAP.fonts[4], "left", "top", false)

    MAP.row=math.floor(scroll:dxScrollGetPosition(MAP.scroll)+1)

    local x = 0
    for i = MAP.row, MAP.row+14 do
        local v=MAP.legendBlips[i]
        if(v and v[6])then
            x = x+1

            local w=dxGetTextWidth(v[1], 1, MAP.fonts[3])+30/zoom

            local sY=(50/zoom)*(x-1)

            -- alpha
            if(isMouseInPosition(56/zoom, 192/zoom+sY-2/zoom, w, 35/zoom) and not v.animate)then
                v.animate=true

                animate(v.alpha, 100, "Linear", 200, function(a)
                    if(v.animate)then
                        v.alpha = a
                    end
                end)
            elseif(not isMouseInPosition(56/zoom, 192/zoom+sY-2/zoom, w, 35/zoom) and v.animate)then
                v.animate = false

                animate(v.alpha, 0, "Linear", 200, function(a)
                  if(not v.animate)then
                    v.alpha = a
                  end
                end)
            end
            --

			if(v[5] and isElement(v[5]))then
            	dxDrawImage(15/zoom, 192/zoom+sY-2/zoom, 35/zoom, 35/zoom, v[5], 0, 0, 0, tocolor(255, 255, 255, MAP.alpha), false)
                dxDrawRectangle(56/zoom, 192/zoom+sY-2/zoom, w, 35/zoom, tocolor(0, 0, 0, MAP.alpha > 50 and 50 or MAP.alpha))
                dxDrawRectangle(56/zoom, 192/zoom+sY-2/zoom, w, 35/zoom, tocolor(0, 0, 0, MAP.alpha > v.alpha and v.alpha or MAP.alpha))
                dxDrawText(v[1], 56/zoom, 192/zoom+sY-2/zoom, w+56/zoom, 35/zoom+192/zoom+sY-2/zoom, tocolor(200, 200, 200, MAP.alpha), 1, MAP.fonts[3], "center", "center", false)
			end

            onClick(56/zoom, 192/zoom+sY-2/zoom, w, 35/zoom, function()
                local randomBlip,friend=getRandomBlipWithID(v[2])
                if(randomBlip)then
                    MAP.mapIsMoving = false
                    MAP.mapMoved = true
                    MAP.clickTick = getTickCount()
                    
                    local pos={getElementPosition(randomBlip)}
                    local x,y=getMapPos(pos[1],pos[2])
                    MAP.clickPos={x,y}

                    MAP.blipHover=randomBlip

                    if(friend)then
                        v[1]=friend
                    end

                    MAP.moved=true
                end
            end)
        end
    end
end

MAP.onKey = function(key, press)
    if(press)then
        if(key == "F11" and isDim(localPlayer))then
            if(MAP.showed)then
                if(MAP.animate)then return end

                MAP.animate = true
                animate(MAP.alpha, 0, "Linear", 500, function(a)
                    MAP.alpha = a
                    scroll:dxScrollSetAlpha(MAP.scroll, a)
                end, function()
                    removeEventHandler("onClientRender", root, MAP.onRender)
                    removeEventHandler("onClientPreRender", root, MAP.onPreRender)

                    MAP.showed = false
                    MAP.animate = false
                    MAP.moved=false

                    scroll:dxDestroyScroll(MAP.scroll)

                    for i,v in pairs(MAP.btns) do
                        buttons:destroyButton(v)
                    end
                end)

                showCursor(false)
                showChat(true)

                setElementData(localPlayer, "user:hud_disabled", false, false)
                setElementData(localPlayer, "user:gui_showed", false, false)
            else
                if(getElementData(localPlayer, "user:gui_showed") or getElementData(localPlayer, "user:hud_disabled"))then return end

                if(MAP.animate)then return end

                buttons=exports.px_buttons
                blur=exports.blur
                alogo=exports.px_alogos
                noti=exports.px_noti
                scroll=exports.px_scroll

                -- update legend
                MAP.legendBlips={}
                MAP.blipHover=false

                local friends=0
                local img=false
                for i,v in pairs(replaceBlips) do
                    if(v[2] == 21)then
                        for _,k in pairs(getElementsByType("blip")) do
                            if(getBlipIcon(k) == 0 and getElementData(k, "friend:blip"))then
                                friends=friends+1
                                img=v[5]
                            end
                        end
                    else
                        local blip = isBlipExists(v[2])
                        if(blip)then
                            if(v[2] == 21 and getElementData(blip[1], "friend:blip"))then
                                v[6]={getElementPosition(blip[1])}
                                v[7]=blip[2]

                                v.animate=false
                                v.alpha=0

                                MAP.legendBlips[#MAP.legendBlips+1]=v
                            elseif(v[2] ~= 21)then
                                v[6]={getElementPosition(blip[1])}
                                v[7]=blip[2]

                                v.animate=false
                                v.alpha=0

                                MAP.legendBlips[#MAP.legendBlips+1]=v
                            end
                        else
                            v[6]=false
                        end
                    end
                end

                MAP.legendBlips[#MAP.legendBlips+1]={"Znajomy", 21, _, _, img, true, friends, animate=false, alpha=0}

                addEventHandler("onClientRender", root, MAP.onRender)
                addEventHandler("onClientPreRender", root, MAP.onPreRender)

                -- off
                setPedControlState('radar',false)
                toggleControl('radar',false)
                --

                local x,y=getElementPosition(localPlayer)
                setMapPos(x,y)

                MAP.scroll=scroll:dxCreateScroll(275/zoom, 187/zoom, 4, 4, 0, 16, MAP.legendBlips, 733/zoom, 0, 1, {0, 0, 455/zoom, sh})

                showCursor(true, false)
                showChat(false)

                MAP.showed = true

                setElementData(localPlayer, "user:hud_disabled", true, false)
                setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

                MAP.animate = true
                animate(MAP.alpha, 255, "Linear", 500, function(a)
                    MAP.alpha = a
                    scroll:dxScrollSetAlpha(MAP.scroll, a)
                end, function()
                    MAP.animate = false
                end)
            end
        elseif(MAP.showed and key == "mouse_wheel_up" and isMouseInPosition(MAP.pos[1], MAP.pos[2], MAP.pos[3], MAP.pos[4]) and not MAP.tickZoom and MAP.zoom < 2)then
            MAP.lastZoom=MAP.zoom
            MAP.newZoom=MAP.zoom+0.2
            MAP.tickZoom=getTickCount()
        elseif(MAP.showed and key == "mouse_wheel_down" and isMouseInPosition(MAP.pos[1], MAP.pos[2], MAP.pos[3], MAP.pos[4]) and not MAP.tickZoom and MAP.zoom > 0.5)then
            MAP.lastZoom=MAP.zoom
            MAP.newZoom=MAP.zoom-0.2
            MAP.tickZoom=getTickCount()
        end
    end
end

addEventHandler("onClientKey", root, MAP.onKey) -- on key

-- useful

MAP.legendBlips={}

function isBlipExists(id)
    local value=0
    local exist=false
    for i,v in pairs(getElementsByType("blip")) do
        if(getBlipIcon(v) == tonumber(id))then
            value=value+1
            exist=v
        end
    end
    return exist and {exist,value} or false
end

function getRandomBlipWithID(id)
    local blips={}
    for i,v in pairs(getElementsByType("blip")) do
        if(getBlipIcon(v) == id)then
            blips[#blips+1]=v
        elseif(id == 21 and getBlipIcon(v) == 0 and getElementData(v, "friend:blip"))then
            blips[#blips+1]=v
        end
    end

    if(#blips > 0)then
        return blips[math.random(1,#blips)], getElementData(blips[math.random(1,#blips)], "friend:blip")
    end
    return false
end

function worldPosToMapPos(v1,v2)
    local m=MAP.mapSize*MAP.zoom
    local map={MAP.mPos[1]+MAP.pos[1]-(MAP.pos[3]*(1*(MAP.zoom-0.5))), MAP.mPos[2]+MAP.pos[2]-(MAP.pos[4]*(1*(MAP.zoom-0.5))), m, m}
    
	local xx,yy=v1/MAP.unit,v2/MAP.unit
	local x,y=map[1]+m/2,map[2]+m/2
	x,y=x+m/2*xx,y-m/2*yy

    if( ( x >= MAP.pos[1] and x <= (MAP.pos[1]+MAP.pos[3]) ) and  (y >= MAP.pos[2] and y <= (MAP.pos[2] + MAP.pos[4]) ) )then
	    return x,y
    end
    
    return false
end

function mapPosToWorldPos(x, y)
	local m=MAP.mapSize*MAP.zoom
    local map={MAP.mPos[1]+MAP.pos[1]-(MAP.pos[3]*(1*(MAP.zoom-0.5))), MAP.mPos[2]+MAP.pos[2]-(MAP.pos[4]*(1*(MAP.zoom-0.5))), m, m}

	x, y = (x - map[1])/map[3], (y - map[2])/map[4]
	return x*6000-3000, -(y*6000-3000)
end

function setMapPos(v1,v2)
    local m=MAP.mapSize*MAP.zoom
	local xx,yy=(v1/-6000),v2/6000
    MAP.mPos={(MAP.pos[1]*MAP.zoom)*2+(m*xx),(m*yy)}
end

function getMapPos(v1,v2)
    if(not MAP.tickZoom)then
        MAP.lastZoom=MAP.zoom
        MAP.newZoom=0.5
        MAP.tickZoom=getTickCount()
    end

    local m=MAP.mapSize*MAP.newZoom
	local xx,yy=(v1/-6000),v2/6000
    return (MAP.pos[1]*MAP.newZoom)*2+(m*xx),(m*yy)
end

function setGPSPos(x,y,z)
    setGPSClear()
    setGPSPosition(x,y,z)

    local zone1=getZoneName(x,y,z,true)
    local zone2=getZoneName(x,y,z,false)

    noti:noti("Trasa do "..zone1..", "..zone2.." została wyznaczona.", "success")
end

--

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)

-- uttilits

for i = 0,63 do
	if(fileExists("assets/images/blips/"..i..".png"))then
		blipsTexture[i] = dxCreateTexture("assets/images/blips/"..i..".png", "argb", false, "clamp")
	end
end

replaceBlips = {
	{"Giełda samochodowa", 3, {{2799.1077,1292.1305,10.7576}}},
	{"Salon samochodowy", 4, {{2195.9233,1402.5507,11.1641},{113.9212,1829.5773,18.3763},{1956.9728,2063.5959,11.8999}}},
	{"Przebieralnia", 5, {{2105.4270019531,2250.4943847656,11.030031204224}}},
	{"Szkoła jazdy", 8, {{1170.2564697266,1355.6450195313,10.921875}}},
	{"Stacja paliw", 10, {}},
	{"Praca dorywcza", 11, {}},
	{"Warsztat", 13, {{2651.3816,1204.6494,10.8500}}},
	{"Komisariat policji", 14, {{2264.4753417969,2459.9572753906,9.8599615097046}}},
	{"Sklep 24/7", 15, {{2194.775390625,1991.4515380859,12.296875},{-176.2639,1025.2185,19.7422},{244.6749,1865.9500,19.6453}}},
	{"Ratusz miasta", 16, {{948.07153320313,1732.2634277344,8.8515625}}},
	{"Checkpoint", 19, {}},
	{"Znajomy", 21, {}},
	{"GPS", 22, {}},
	{"Podziemny parking", 25, {{2393.5081,1504.6885,10.8203}}},
    {"Myjnia pojazdów", 28, {}},
    {"Szkola lotnicza", 30, {{414.6942,2533.5461,19.1484}}},
    {"Radio X69", 32, {{-148.6799,1073.7050,19.7500},{2546.9180,2307.8325,10.8268}}},
    {"Punkt tuningowy", 31, {{1067.4585,2359.6489,10.9609},{2385.1543,1051.5853,10.8203},{-87.5488,1117.0424,19.7797},{-9.0668,1841.3323,18.3672}}},
    {"Taxi", 39, {{2503.7202,920.2532,10.8281}}},
	{"Handlarz", 26, {{771.08514404297,1975.6014404297,5.3431529998779},{-895.9365,1530.5881,25.8103}}},
    {"Parking policyjny", 43, {}},

    -- mini blipy
	{"Bankomat", 18, {}},
    {"Pojazd prywatny", 24, {}},
    {"Pojazd organizacyjny", 45, {}},

    -- domki
    {"Zajęty dom", 2, {}},
	{"Twój dom", 9, {}},
	{"Wolny dom", 17, {}},
}

function findBlipTexture(id)
    return blipsTexture[id] or blipsTexture[0]
end

for i,v in ipairs(replaceBlips) do
    v[5] = blipsTexture[v[2]] or blipsTexture[0]

    for index,k in ipairs(v[3]) do
        v[4] = {}
        v[4][index] = createBlip(k[1], k[2], k[3], v[2])
        if(v[4][index])then
            setBlipVisibleDistance(v[4][index], 500)
        end
    end
end

-- animate

local anims = {}
local rendering = false

local function renderAnimations()
    local now = getTickCount()
    for k,v in pairs(anims) do
        v.onChange(interpolateBetween(v.from, 0, 0, v.to, 0, 0, (now - v.start) / v.duration, v.easing))
        if(now >= v.start+v.duration)then
            table.remove(anims, k)
			if(type(v.onEnd) == "function")then
                v.onEnd()
            end
        end
    end

    if(#anims == 0)then
        rendering = false
        removeEventHandler("onClientRender", root, renderAnimations)
    end
end

function animate(f, t, easing, duration, onChange, onEnd)
	if(#anims == 0 and not rendering)then
		addEventHandler("onClientRender", root, renderAnimations)
		rendering = true
	end

    assert(type(f) == "number", "Bad argument @ 'animate' [expected number at argument 1, got "..type(f).."]")
    assert(type(t) == "number", "Bad argument @ 'animate' [expected number at argument 2, got "..type(t).."]")
    assert(type(easing) == "string", "Bad argument @ 'animate' [Invalid easing at argument 3]")
    assert(type(duration) == "number", "Bad argument @ 'animate' [expected number at argument 4, got "..type(duration).."]")
    assert(type(onChange) == "function", "Bad argument @ 'animate' [expected function at argument 5, got "..type(onChange).."]")
    table.insert(anims, {from = f, to = t, easing = easing, duration = duration, start = getTickCount( ), onChange = onChange, onEnd = onEnd})

    return #anims
end

function destroyAnimation(id)
    if(anims[id])then
        anims[id] = nil
    end
end

-- by asper

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

local mouseState=false
local mouseTick=getTickCount()
local mouseClicks=0
local mouseClick=false
function onClick2(x, y, w, h, fnc)
	if(not isCursorShowing())then return end

	if((getTickCount()-mouseTick) > 1000 and mouseClicks > 0)then
		mouseClicks=mouseClicks-1
	end

	if(not mouseState and getKeyState("mouse2"))then
		local cursor={getCursorPosition()}
        mouseState=cursor
    elseif(not getKeyState("mouse2") and (mouseClick or mouseState))then
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

-- friends

function isPlayerInFriends(player)
    local friends=getElementData(localPlayer, "friends:data") or {}
    local uid=getElementData(player, "user:uid")
    local inFriends=false
    for i,v in pairs(friends) do
        if(v.uid == uid)then
            inFriends=true
            break
        end
    end
    return inFriends
end

--  

toggleControl("radar", false)

-- export

function getMapTexture()
    local state=exports.px_dashboard:getSettingState("street_map")
    if(fileExists("assets/images/new_map.png") and not assets.textures.new_texture)then
        assets.textures.new_texture=dxCreateTexture("assets/images/new_map.png", "argb", false, "clamp")
    elseif(state and not assets.textures.streets)then
        assets.textures.streets=dxCreateTexture("assets/images/streets.png", "argb", false, "clamp")
    elseif(not assets.textures.map_texture)then
        assets.textures.map_texture=dxCreateTexture("assets/images/map.png", "argb", false, "clamp")
    end

    if(not state and assets.textures.streets)then
        destroyElement(assets.textures.streets)
        assets.textures.streets=nil
    end

    local tex=assets.textures.new_texture or assets.textures.streets or assets.textures.map_texture
    dxSetTextureEdge(tex, "border", tocolor(0,0,0,0))

    return tex
end

function getMapTextureWithBlips()
    local w,h=dxGetMaterialSize(assets.textures.map_texture)
    local rt=dxCreateRenderTarget(w,h,true)
    local p={0,0,w,h}
    dxSetRenderTarget(rt,true)
        dxSetBlendMode('modulate_add')
        dxDrawImage(p[1],p[2],p[3],p[4],assets.textures.map_texture)

        for i,v in pairs(getElementsByType("blip")) do
            if(localPlayer ~= getElementAttachedTo(v))then
                local pos={getElementPosition(v)}
                local p1,p2=pos[1]+3000,pos[2]-3000
                local p1,p2=p[1]+(p[3]*(p1/6000)),p[2]+(p[4]*(p2/-6000))

                local blip_icon = getBlipIcon(v)
                local blip_size = getBlipIcon(v) == 0 and (15/zoom / 2) * getBlipSize(v) or 35/zoom
                local blip_color = getBlipIcon(v) == 0 and {getBlipColor(v)} or {255, 255, 255, 255}
                local current_blip = findBlipTexture(blip_icon)

                dxDrawImage(p1 - (blip_size / 2), p2 - (blip_size / 2), blip_size, blip_size, current_blip, 0, 0, 0, tocolor(blip_color[1], blip_color[2], blip_color[3], 255))
            end
        end
        dxSetBlendMode('blend')
    dxSetRenderTarget()
    return rt
end