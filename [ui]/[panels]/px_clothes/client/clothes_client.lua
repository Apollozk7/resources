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

-- variables

local sw, sh = guiGetScreenSize()
local baseX = 1920
local zoom = 1
local minZoom = 2

if sw < baseX then
    zoom = math.min(minZoom, baseX/sw)
end

local scroll=exports.px_scroll
local blur=exports.blur

-- useful

function getPointFromDistanceRotation(x, y, dist, angler)
    local a = math.rad(270 - angler)
    local dx = math.cos(a) * dist
    local dy = math.sin(a) * dist
    return x+dx, y+dy
end

--

CLOTHES.POSITIONS = {
    {2097.1433,2264.7612,11.0234},
}

CLOTHES.TEXTURES = {
	"assets/textures/window.png",
	"assets/textures/header_icon.png",
	"assets/textures/close.png",
	"assets/textures/category.png",
	"assets/textures/category_selected.png",
    "assets/textures/category_premium.png",
    "assets/textures/category_woman.png",
    "assets/textures/category_men.png",
	"assets/textures/category_all.png",
	"assets/textures/row.png",
	"assets/textures/row_lvl.png",
	"assets/textures/row_premium.png",
	"assets/textures/button_icon.png",
	"assets/textures/window2.png",
	"assets/textures/row_selected.png",
}

CLOTHES.img = {}
CLOTHES.FONTS={}

CLOTHES.PAGE = "Wszystkie"
CLOTHES.actualSkin = false
CLOTHES.ped = false
CLOTHES.row = 1
CLOTHES.alpha = 0
CLOTHES.scroll=false
CLOTHES.btn={}
CLOTHES.zoom=2
CLOTHES.tbl={}

CLOTHES.MARKER_HIT = function(element, dim)
    if(element ~= localPlayer or not dim)then return end

    if(getElementData(localPlayer, "user:gui_showed"))then return end

    if(getElementData(localPlayer, "user:job") or getElementData(localPlayer, "user:faction"))then
        noti:noti("Najpierw zakończ pracę.")
        return
    end

    scroll=exports.px_scroll
    blur=exports.blur

    local _,_,z1=getElementPosition(source)
    local _,_,z2=getElementPosition(localPlayer)
    if(z2 > (z1+1))then return end

    setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

    scroll = exports.px_scroll
    noti = exports.px_noti

	addEventHandler("onClientRender", root, CLOTHES.DRAW)
	addEventHandler("onClientKey", root, CLOTHES.key)

    CLOTHES.PAGE = "Wszystkie"
    CLOTHES.btn[1]=exports.px_buttons:createButton((649-180)/2/zoom, sh-60/zoom, 180/zoom, 45/zoom, "ZAKUP", 0, 11, false, false, ":px_clothes/assets/textures/button_icon.png")
    CLOTHES.scroll = scroll:dxCreateScroll(631/zoom, 275/zoom, 4/zoom, 4/zoom, 0, 30, CLOTHES.OPTIONS[CLOTHES.PAGE], 726/zoom, 0, 5, {0, 0, 649/zoom, sh})

    animate(CLOTHES.alpha, 255, "Linear", 500, function(a)
        CLOTHES.alpha = a
        exports.px_buttons:buttonSetAlpha(CLOTHES.btn[1], a)
        scroll:dxScrollSetAlpha(CLOTHES.scroll, a)
    end)

    CLOTHES.FONTS={
        dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 18/zoom),
        dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 15/zoom),
        dxCreateFont(":px_assets/fonts/Font-Regular.ttf", 11/zoom),
    }

    showCursor(true)

	CLOTHES.actualSkin = false
    CLOTHES.row=1

    for i,v in pairs(CLOTHES.TEXTURES) do
        CLOTHES.img[i] = dxCreateTexture(v, "argb", false, "clamp")
    end

    CLOTHES.ped=createPed(getElementModel(localPlayer), 2094.1934,2261.0635,11.0234,271.4225)

    CLOTHES.tbl={}
    for i=1,6 do
        local sY=(121/zoom)*(i-1)
        for i=1,5 do
            local sX=(121/zoom)*(i-1)
    
            table.insert(CLOTHES.tbl, {sX=sX,sY=sY})
        end
    end

    showChat(false)
end

CLOTHES.MARKER_LEAVE=function()
    animate(CLOTHES.alpha, 0, "Linear", 500, function(a)
        CLOTHES.alpha = a
        exports.px_buttons:buttonSetAlpha(CLOTHES.btn[1], a)
        scroll:dxScrollSetAlpha(CLOTHES.scroll, a)
    end, function()
        removeEventHandler("onClientRender", root, CLOTHES.DRAW)
        removeEventHandler("onClientKey", root, CLOTHES.key)

        for i,v in pairs(CLOTHES.img) do
            destroyElement(v)
        end

        if(CLOTHES.ped and isElement(CLOTHES.ped))then
            destroyElement(CLOTHES.ped)
            CLOTHES.ped = false
        end

        for i,v in pairs(CLOTHES.FONTS) do
            if(v and isElement(v))then
                destroyElement(v)
            end
        end

        exports.px_buttons:destroyButton(CLOTHES.btn[1])
        scroll:dxDestroyScroll(CLOTHES.scroll)

        setCameraTarget(localPlayer)

        showChat(true)
    end)

    setElementData(localPlayer, "user:gui_showed", false, false)

    showCursor(false)
end

for i,v in pairs(CLOTHES.POSITIONS) do
    CLOTHES.MARKER = createMarker(CLOTHES.POSITIONS[i][1], CLOTHES.POSITIONS[i][2], CLOTHES.POSITIONS[i][3]-0.7, "cylinder", 1.5, 0, 0, 0)
    setElementData(CLOTHES.MARKER, "icon", ":px_clothes/assets/textures/skinchangerMarker.png")
    setElementData(CLOTHES.MARKER, "text", {text="Przebieralnia",desc="Tutaj się przebierzesz"})
end
addEventHandler("onClientMarkerHit", resourceRoot, CLOTHES.MARKER_HIT)

CLOTHES.DRAW=function()
    local pos={getElementPosition(CLOTHES.ped)}
    pos[2]=pos[2]-0.5
    local x,y = getPointFromDistanceRotation(pos[1], pos[2], CLOTHES.zoom, 270)
    setCameraMatrix(x, y, pos[3]+1, pos[1], pos[2], pos[3])

    blur:dxDrawBlur(0, 0, 649/zoom, sh, tocolor(255,255,255,CLOTHES.alpha))
    dxDrawImage(0, 0, 649/zoom, sh, CLOTHES.img[1], 0, 0, 0, tocolor(255, 255, 255, CLOTHES.alpha))

    -- header
    dxDrawText("Wybór skina", 0, 0, 649/zoom, 54/zoom, tocolor(200, 200, 200, CLOTHES.alpha), 1, CLOTHES.FONTS[1], "center", "center")
    dxDrawImage(649/2/zoom+dxGetTextWidth("Wybór skina", 1, CLOTHES.FONTS[1])/2+10/zoom, (54-27)/2/zoom, 27/zoom, 23/zoom, CLOTHES.img[2], 0, 0, 0, tocolor(255, 255, 255, CLOTHES.alpha))

    dxDrawImage(605/zoom+10/zoom, (54-10)/2/zoom, 10/zoom, 10/zoom, CLOTHES.img[3], 0, 0, 0, tocolor(255, 255, 255, CLOTHES.alpha))
    onClick(605/zoom+10/zoom, (54-10)/2/zoom, 10/zoom, 10/zoom, function()
        CLOTHES.MARKER_LEAVE()
    end)
    --

    dxDrawRectangle((649-605)/2/zoom, 54/zoom, 605/zoom, 1, tocolor(85,85,85, CLOTHES.alpha))

    -- categories
    dxDrawText("Filtry - "..CLOTHES.PAGE, (649-605)/2/zoom, 93/zoom, 649/zoom, 54/zoom, tocolor(200, 200, 200, CLOTHES.alpha), 1, CLOTHES.FONTS[1], "left", "top")

    for i=1,4 do
        local name=i == 4 and "Wszystkie" or i == 3 and "Męskie" or i == 2 and "Kobiece" or i == 1 and "Premium"

        local sX=(50+32)/zoom*(i-1)
        dxDrawImage(649/zoom-18/zoom-50/zoom-sX, 79/zoom, 50/zoom, 50/zoom, CLOTHES.PAGE == name and CLOTHES.img[5] or CLOTHES.img[4], 0, 0, 0, tocolor(255, 255, 255, CLOTHES.alpha))

        local w,h=dxGetMaterialSize(CLOTHES.img[5+i])
        dxDrawImage(649/zoom-18/zoom-50/zoom-sX+(50-w)/2/zoom, 79/zoom+(50-h)/2/zoom, w/zoom, h/zoom, CLOTHES.img[5+i], 0, 0, 0, tocolor(255, 255, 255, CLOTHES.alpha))

        onClick(649/zoom-18/zoom-50/zoom-sX, 79/zoom, 50/zoom, 50/zoom, function()
            CLOTHES.PAGE=name

            scroll:dxDestroyScroll(CLOTHES.scroll)
            CLOTHES.scroll = scroll:dxCreateScroll(631/zoom, 275/zoom, 4/zoom, 4/zoom, 0, 30, CLOTHES.OPTIONS[CLOTHES.PAGE], 726/zoom, 0, 20, {0, 0, 649/zoom, sh})
            scroll:dxScrollSetAlpha(CLOTHES.scroll, CLOTHES.alpha)
        end)
    end

    -- info
    dxDrawText("#c2c2c2Aby zakupić skina musisz go wybrać, następnie go przydziać\ni na nacisnąć przycisk #54b16dzakup#c2c2c2.", 0, 165/zoom, 649/zoom, 54/zoom, tocolor(200, 200, 200, CLOTHES.alpha), 1, CLOTHES.FONTS[2], "center", "top", false, false, false, true)

    -- list
    dxDrawRectangle((649-556)/2/zoom, 240/zoom, 556/zoom, 1, tocolor(85,85,85, CLOTHES.alpha))

    CLOTHES.row = math.floor(scroll:dxScrollGetPosition(CLOTHES.scroll)+1)

    local cat="?"
    local lvl=1
    local cost=0
    local id=0

    local x = 0
    for i = CLOTHES.row,CLOTHES.row+29 do
        local v = CLOTHES.OPTIONS[CLOTHES.PAGE][i]
        if(v)then
            x=x+1
            
            local k=CLOTHES.tbl[x] or {sX=0,sY=0}

            dxDrawImage((649-556)/2/zoom+k.sX, 240/zoom+k.sY+42/zoom, 80/zoom, 80/zoom, CLOTHES.actualSkin == v and CLOTHES.img[15] or CLOTHES.img[10], 0, 0, 0, tocolor(255, 255, 255, CLOTHES.alpha))
            dxDrawImage((649-556)/2/zoom+k.sX+(80-33)/2/zoom, 240/zoom+k.sY+42/zoom+70/zoom, 33/zoom, 19/zoom, CLOTHES.img[11], 0, 0, 0, tocolor(255, 255, 255, CLOTHES.alpha))
            dxDrawText(v.id, (649-556)/2/zoom+k.sX+(80-33)/2/zoom, 240/zoom+k.sY+42/zoom+70/zoom, 33/zoom+(649-556)/2/zoom+k.sX+(80-33)/2/zoom, 19/zoom+240/zoom+k.sY+42/zoom+70/zoom, tocolor(200, 200, 200, CLOTHES.alpha), 1, CLOTHES.FONTS[3], "center", "center")
            
            if((v.category == "Premium") or CLOTHES.page == "Premium")then
                dxDrawImage((649-556)/2/zoom+k.sX+(80-12)/2/zoom, 240/zoom+k.sY+42/zoom+95/zoom, 12/zoom, 12/zoom, CLOTHES.img[12], 0, 0, 0, tocolor(255, 255, 255, CLOTHES.alpha))
            end
            
            dxDrawImageSection(35/zoom+k.sX, 285/zoom+k.sY, 100/zoom, 60/zoom, 0, 0, 200, 120, "skiny/"..v.id..".png", 0, 0, 0, tocolor(255, 255, 255, CLOTHES.alpha))

            onClick((649-556)/2/zoom+k.sX, 240/zoom+k.sY+42/zoom, 80/zoom, 80/zoom, function()
                setElementModel(CLOTHES.ped, v.id)
                CLOTHES.actualSkin=v
            end)
        end
    end

    -- right
    if(CLOTHES.actualSkin)then
        cat=CLOTHES.actualSkin.category or CLOTHES.PAGE
        cat=cat == "Męskie" and "Męski" or cat == "Kobiece" and "Kobiecy" or cat

        blur:dxDrawBlur(sw-317/zoom, sh-154/zoom, 317/zoom, 114/zoom, tocolor(255,255,255,CLOTHES.alpha))
        dxDrawImage(sw-317/zoom, sh-154/zoom, 317/zoom, 114/zoom, CLOTHES.img[14])
        dxDrawText(cat.." ("..CLOTHES.actualSkin.id..")", sw-317/zoom+19/zoom, sh-154/zoom+19/zoom, 317/zoom, 114/zoom, tocolor(200, 200, 200,CLOTHES.alpha), 1, CLOTHES.FONTS[1], "left", "top")
        dxDrawText(CLOTHES.actualSkin.rp.." reputacji", sw-317/zoom+19/zoom, sh-154/zoom+50/zoom, 317/zoom, 114/zoom, tocolor(196,192,86,CLOTHES.alpha), 1, CLOTHES.FONTS[2], "left", "top")
        dxDrawText(CLOTHES.actualSkin.cost.."$", sw-317/zoom+19/zoom, sh-154/zoom+75/zoom, 317/zoom, 114/zoom, tocolor(79,161,101,CLOTHES.alpha), 1, CLOTHES.FONTS[2], "left", "top")

        onClick((649-180)/2/zoom, sh-60/zoom, 180/zoom, 45/zoom, function()
            if((cat == "Premium") and (not getElementData(localPlayer, "user:premium") and not getElementData(localPlayer, "user:gold")))then
                noti = exports.px_noti
                noti:noti("Nie posiadasz konta premium.", "error", "dashboard")
            else
                if(SPAM.getSpam())then return end

                triggerServerEvent("clothes.accept", resourceRoot, CLOTHES.actualSkin.id, CLOTHES.actualSkin.cost, CLOTHES.actualSkin.rp)
            end
        end)
    end
end

CLOTHES.key=function(btn,press)
    if(press and not isMouseInPosition(0, 0, 649/zoom, sh))then
        if(btn == "mouse_wheel_down" and CLOTHES.zoom < 5)then
            CLOTHES.zoom=CLOTHES.zoom+0.1
        elseif(btn == "mouse_wheel_up" and CLOTHES.zoom > 2)then
            CLOTHES.zoom=CLOTHES.zoom-0.1
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

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)

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