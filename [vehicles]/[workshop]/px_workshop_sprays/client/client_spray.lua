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

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

-- main variables

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-ExtraBold.ttf", 14/zoom},
        {":px_assets/fonts/Font-Medium.ttf", 10/zoom},
        {":px_assets/fonts/Font-ExtraBold.ttf", 11/zoom},
        {":px_assets/fonts/Font-Medium.ttf", 15/zoom},
    },

    textures={},
    textures_paths={
        "assets/images/bg.png",
        "assets/images/nav.png",
        "assets/images/nav_icon.png",
        "assets/images/close.png",
        "assets/images/header.png",
        "assets/images/color.png",
    },
}

assets.create = function()
    for k,t in pairs(assets) do
        if(k=="fonts_paths")then
            for i,v in pairs(t) do
                assets.fonts[i] = dxCreateFont(v[1], v[2])
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

-- variables

local UI={}

UI.btns={}

UI.color=1
UI.colors={
    [1]={255,255,255},
    [2]={255,255,255},
    [3]={255,255,255},
}

UI.veh=false
UI.target=false
UI.edits={}
UI.window=false
UI.alpha=0
UI.border=false

UI.onRender=function()
    if(UI.veh and isElement(UI.veh) and UI.target and isElement(UI.target))then
        -- bg
        blur:dxDrawBlur(sw/2-639/2/zoom, sh/2-523/2/zoom, 639/zoom, 523/zoom, tocolor(255,255,255))
        dxDrawImage(sw/2-639/2/zoom, sh/2-523/2/zoom, 639/zoom, 523/zoom, assets.textures[1])

        -- nav
        dxDrawImage(sw/2-637/2/zoom, sh/2-523/2/zoom, 637/zoom, 54/zoom, assets.textures[2])
        dxDrawImage(sw/2-637/2/zoom+18/zoom, sh/2-523/2/zoom+(54-22)/2/zoom, 22/zoom, 22/zoom, assets.textures[3])
        dxDrawText("Lakiernia", sw/2-637/2/zoom+58/zoom, sh/2-523/2/zoom, 0, sh/2-523/2/zoom+54/zoom, tocolor(200,200,200), 1, assets.fonts[1], "left", "center")
        dxDrawImage(sw/2-637/2/zoom+637/zoom-10/zoom-(54-10)/2/zoom, sh/2-523/2/zoom+(54-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[4])

        -- header
        dxDrawImage(sw/2-637/2/zoom, sh/2-523/2/zoom+54/zoom, 637/zoom, 49/zoom, assets.textures[5])

        local last=0
        for i,v in pairs(UI.colors) do
            local x,y,w,h=sw/2-637/2/zoom+145/zoom, sh/2-523/2/zoom+54/zoom, 50/zoom, 49/zoom
            w=dxGetTextWidth("Kolor "..i, 1, assets.fonts[2])
            y=y+(49/zoom-h)/2

            x=x+last

            if(not UI.border)then
                UI.border={x,y+h-1,w,1}
                UI.color=1
            end

            if(UI.color == i)then
                dxDrawText("Kolor "..i, x,y,w+x,y+h, tocolor(200, 200, 200, 255), 1, assets.fonts[1], "center", "center")
            else
                dxDrawText("Kolor "..i, x,y,w+x,y+h, tocolor(160, 160, 160, 255), 1, assets.fonts[1], "center", "center")
            end

            onClick(x,y,w,h,function()
                if(not UI.animate)then
                    UI.animate=true
                    UI.color=i

                    animate(UI.border[1], x, "Linear", 250, function(a)
                        UI.border[1]=a
                    end, function()
                        UI.animate=false
                    end)

                    animate(UI.border[3], w, "Linear", 250, function(a)
                        UI.border[3]=a
                    end)
                end
            end)

            last=last+w+88/zoom
        end
        dxDrawRectangle(sw/2-637/2/zoom, UI.border[2]-UI.border[4], 637/zoom, 1, tocolor(80,80,80))
        dxDrawRectangle(UI.border[1],UI.border[2]-UI.border[4],UI.border[3],UI.border[4],tocolor(33,147,176, 255))

        -- body
        dxDrawText("PALETA KOLORÓW", sw/2-637/2/zoom+28/zoom, sh/2-523/2/zoom+125/zoom, 0, 0, tocolor(200,200,200), 1, assets.fonts[2], "left", "top")

        dxDrawText("WŁASNY KOLOR", sw/2-637/2/zoom+28/zoom+306/zoom, sh/2-523/2/zoom+125/zoom, 0, 0, tocolor(200,200,200), 1, assets.fonts[2], "left", "top")

        dxDrawText("R", sw/2-637/2/zoom+28/zoom+306/zoom, sh/2-523/2/zoom+125/zoom+30/zoom, 0, 0, tocolor(200,200,200), 1, assets.fonts[1], "left", "top")
        dxDrawText("G", sw/2-637/2/zoom+28/zoom+306/zoom+90/zoom, sh/2-523/2/zoom+125/zoom+30/zoom, 0, 0, tocolor(200,200,200), 1, assets.fonts[1], "left", "top")
        dxDrawText("B", sw/2-637/2/zoom+28/zoom+306/zoom+90/zoom+90/zoom, sh/2-523/2/zoom+125/zoom+30/zoom, 0, 0, tocolor(200,200,200), 1, assets.fonts[1], "left", "top")

        local r,g,b=cpicker:getCPickerSelectedColor()
        local ra,ga,ba=edit:dxGetEditText(UI.edits.R),edit:dxGetEditText(UI.edits.G),edit:dxGetEditText(UI.edits.B)
        local hex=edit:dxGetEditText(UI.edits.HEX)
        if(#ra > 0 or #ga > 0 or #ba > 0)then
            r,g,b=tonumber(ra),tonumber(ba),tonumber(ga)
            r,g,b=r or 0, g or 0, b or 0
        elseif(#hex > 0)then
            r,g,b=hex2rgb(hex)
            r,g,b=tonumber(r),tonumber(b),tonumber(g)
            r,g,b=r or 0, g or 0, b or 0
        end
        r,g,b=r > 255 and 255 or r, g > 255 and 255 or g, b > 255 and 255 or b

        dxDrawText("HEX", sw/2-637/2/zoom+28/zoom+306/zoom, sh/2-523/2/zoom+125/zoom+30/zoom+58/zoom, 0, 0, tocolor(200,200,200), 1, assets.fonts[1], "left", "top")

        dxDrawText("WYBRANY KOLOR", sw/2-637/2/zoom+28/zoom, sh/2-523/2/zoom+125/zoom+250/zoom, 0, 0, tocolor(200,200,200), 1, assets.fonts[2], "left", "top")
        dxDrawRectangle(sw/2-637/2/zoom+28/zoom,sh/2-523/2/zoom+125/zoom+250/zoom+20/zoom,200/zoom,27/zoom,tocolor(r,g,b, 255))
        dxDrawText(r..", "..g..", "..b, sw/2-637/2/zoom+28/zoom+231/zoom, sh/2-523/2/zoom+125/zoom+250/zoom+20/zoom, 0, sh/2-523/2/zoom+125/zoom+250/zoom+20/zoom+27/zoom, tocolor(200,200,200), 1, assets.fonts[3], "left", "center")
        dxDrawText(rgb2hex(r,g,b), sw/2-637/2/zoom+28/zoom+231/zoom+105/zoom, sh/2-523/2/zoom+125/zoom+250/zoom+20/zoom, 0, sh/2-523/2/zoom+125/zoom+250/zoom+20/zoom+27/zoom, tocolor(200,200,200), 1, assets.fonts[3], "left", "center")

        onClick(sw/2-639/2/zoom+639/zoom-132/zoom, sh/2-523/2/zoom+523/zoom-125/zoom, 105/zoom, 27/zoom,function()
            UI.colors[UI.color]={r,g,b}
            exports['px_noti']:noti('Pomyślnie zapisano kolor '..UI.color..'.', 'success')
        end)

        dxDrawRectangle(sw/2-637/2/zoom, sh/2-523/2/zoom+523/zoom-70/zoom, 637/zoom, 1, tocolor(80,80,80))

        for i,v in pairs(UI.colors) do
            local sx=(44/zoom)*(i-1)
            dxDrawImage(sw/2-639/2/zoom+28/zoom+sx, sh/2-523/2/zoom+523/zoom-29/zoom-(70-29)/2/zoom, 29/zoom, 29/zoom, assets.textures[6], 0, 0, 0, tocolor(v[1],v[2],v[3]))

            local r,g,b=255,255,255
            if(v[1] > 30 and v[2] > 30 and v[3] > 30)then
                r,g,b=0,0,0
            end
            dxDrawText(i, sw/2-639/2/zoom+28/zoom+sx, sh/2-523/2/zoom+523/zoom-29/zoom-(70-29)/2/zoom, sw/2-639/2/zoom+28/zoom+sx+29/zoom, sh/2-523/2/zoom+523/zoom-29/zoom-(70-29)/2/zoom+29/zoom, tocolor(r,g,b), 1, assets.fonts[3], "center", "center")
        end

        dxDrawText("Koszt: $ 150", sw/2-637/2/zoom+345/zoom, sh/2-523/2/zoom+523/zoom-70/zoom+22/zoom, 0, 0, tocolor(200,200,200), 1, assets.fonts[4], "left", "top")

        onClick(sw/2-637/2/zoom+637/zoom-177/zoom, sh/2-523/2/zoom+523/zoom-38/zoom-(70-38)/2/zoom, 147/zoom, 38/zoom, function()
            if(SPAM.getSpam())then return end

            triggerServerEvent("give:spray", resourceRoot, UI.target, UI.veh, {tonumber(UI.colors[1][1]), tonumber(UI.colors[1][2]), tonumber(UI.colors[1][3]), tonumber(UI.colors[2][1]), tonumber(UI.colors[2][2]), tonumber(UI.colors[2][3]), tonumber(UI.colors[3][1]), tonumber(UI.colors[3][2]), tonumber(UI.colors[3][3])})

            showCursor(false)

            removeEventHandler("onClientRender",root,UI.onRender)

            assets.destroy()

            cpicker:destroyCPicker()

            setElementData(localPlayer, "user:gui_showed", false, false)

            for i,v in pairs(UI.btns) do
                buttons:destroyButton(v)
            end
            UI.btns={}
            
            for i,v in pairs(UI.edits) do
                edit:dxDestroyEdit(v)
            end
            UI.edits={}

            UI.target=false
            UI.veh=false
        end)

        onClick(sw/2-637/2/zoom+637/zoom-10/zoom-(54-10)/2/zoom, sh/2-523/2/zoom+(54-10)/2/zoom, 10/zoom, 10/zoom, function()
            if(SPAM.getSpam())then return end

            showCursor(false)

            removeEventHandler("onClientRender",root,UI.onRender)

            assets.destroy()

            cpicker:destroyCPicker()

            for i,v in pairs(UI.btns) do
                buttons:destroyButton(v)
            end
            UI.btns={}
            
            for i,v in pairs(UI.edits) do
                edit:dxDestroyEdit(v)
            end
            UI.edits={}

            setElementData(localPlayer, "user:gui_showed", false, false)

            noti:noti("Pomyślnie anulowano oferte malowania od gracza "..getPlayerName(UI.target)..".")
            triggerServerEvent("notis", resourceRoot, getPlayerName(localPlayer).." anulował oferte malowania.", UI.target)

            toggleControl('accelerate', true)
            toggleControl('enter_exit', true)
            toggleControl('brake_reverse', true)
            toggleControl('forwards', true)
            toggleControl('backwards', true)
            toggleControl('left', true)
            toggleControl('right', true)

            UI.target=false
            UI.veh=false
        end)
    end
end

addEvent("set:spray", true)
addEventHandler("set:spray", resourceRoot, function(vehicle, offer_player)
    if(getElementData(localPlayer, "user:gui_showed") or UI.target)then return end

    cpicker=exports.px_cpicker
    buttons=exports.px_buttons
    noti=exports.px_noti
    edit=exports.px_editbox
    blur=exports.blur

    UI.target=offer_player
    UI.veh=vehicle

    showCursor(true)

    addEventHandler("onClientRender",root,UI.onRender)

    assets.create()

    cpicker:createPicker(sw/2-637/2/zoom+28/zoom, sh/2-523/2/zoom+148/zoom, 197/zoom, 197/zoom, 15/zoom)

    setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

    toggleControl('accelerate', false)
    toggleControl('enter_exit', false)
    toggleControl('brake_reverse', false)
    toggleControl('forwards', false)
    toggleControl('backwards', false)
    toggleControl('left', false)
    toggleControl('right', false)

    noti:noti("Pamiętaj że koszt malowania wynosi 150$.")

    UI.edits.R=edit:dxCreateEdit("", sw/2-637/2/zoom+28/zoom+306/zoom+23/zoom, sh/2-523/2/zoom+125/zoom+25/zoom, 57/zoom, 30/zoom, false, 11/zoom, 255, false, false)
    UI.edits.B=edit:dxCreateEdit("", sw/2-637/2/zoom+28/zoom+306/zoom+23/zoom+90/zoom, sh/2-523/2/zoom+125/zoom+25/zoom, 57/zoom, 30/zoom, false, 11/zoom, 255, false, false)
    UI.edits.G=edit:dxCreateEdit("", sw/2-637/2/zoom+28/zoom+306/zoom+23/zoom+90/zoom+90/zoom, sh/2-523/2/zoom+125/zoom+25/zoom, 57/zoom, 30/zoom, false, 11/zoom, 255, false, false)
    UI.edits.HEX=edit:dxCreateEdit("", sw/2-637/2/zoom+28/zoom+306/zoom+45/zoom, sh/2-523/2/zoom+125/zoom+25/zoom+58/zoom, 125/zoom, 30/zoom, false, 11/zoom, 255, false, false)

    UI.btns[1]=buttons:createButton(sw/2-639/2/zoom+639/zoom-132/zoom, sh/2-523/2/zoom+523/zoom-125/zoom, 105/zoom, 27/zoom, "ZAPISZ", 255, 10/zoom, false, false, false, {56,100,122})    
    UI.btns[2]=buttons:createButton(sw/2-637/2/zoom+637/zoom-177/zoom, sh/2-523/2/zoom+523/zoom-38/zoom-(70-38)/2/zoom, 147/zoom, 38/zoom, "PRZEMALUJ", 255, 9/zoom, false, false, ":px_workshop_sprays/assets/images/button.png")    
end)

-- offer

addEventHandler("onClientPlayerWeaponFire", localPlayer, function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
    local data=getElementData(localPlayer, "color:spray")
    if(weapon == 41 and hitElement and getElementType(hitElement) == "vehicle" and data and data.veh and data.veh == hitElement)then
        triggerServerEvent("set:color", resourceRoot, hitElement)
    end
end)

function sendOffer(player, vehicle, mechanic)
    if(getElementHealth(vehicle) < 1000)then
        noti:noti("Aby ulepszyć pojazd, musi on być sprawny.", "error")
    else
        local uid=getElementData(player, "user:uid")    
        local owner=getElementData(vehicle, "vehicle:owner") or getElementData(vehicle, "vehicle:liderUID")
        if(not uid or not owner or (owner and owner ~= uid))then 
            noti:noti("Pojazd nie należy do kierowcy.", "error")
            return 
        end

        triggerServerEvent("send.offer", resourceRoot, vehicle)
    end
end

addEvent("workshop->leaveZone", true)
addEventHandler("workshop->leaveZone", root, function(player)
    if(UI.target and UI.target == player)then
        showCursor(false)

        removeEventHandler("onClientRender",root,UI.onRender)

        assets.destroy()

        cpicker:destroyCPicker()
        buttons:destroyButton(UI.btns[1])

        setElementData(localPlayer, "user:gui_showed", false, false)

        for i,v in pairs(UI.edits) do
            edit:dxDestroyEdit(v)
        end

        toggleControl('accelerate', true)
        toggleControl('enter_exit', true)
        toggleControl('brake_reverse', true)
        toggleControl('forwards', true)
        toggleControl('backwards', true)
        toggleControl('left', true)
        toggleControl('right', true)

        UI.target=false
        UI.veh=false
    end
end)

-- useful

function rgb2hex(r,g,b)
	
	local hex_table = {[10] = 'A',[11] = 'B',[12] = 'C',[13] = 'D',[14] = 'E',[15] = 'F'}
	
	local r1 = math.floor(r / 16)
	local r2 = r - (16 * r1)
	local g1 = math.floor(g / 16)
	local g2 = g - (16 * g1)
	local b1 = math.floor(b / 16)
	local b2 = b - (16 * b1)
	
	if r1 > 9 then r1 = hex_table[r1] end
	if r2 > 9 then r2 = hex_table[r2] end
	if g1 > 9 then g1 = hex_table[g1] end
	if g2 > 9 then g2 = hex_table[g2] end
	if b1 > 9 then b1 = hex_table[b1] end
	if b2 > 9 then b2 = hex_table[b2] end
	
	return "#" .. r1 .. r2 .. g1 .. g2 .. b1 .. b2

end

function hex2rgb(hex)
    local hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

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

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)

        toggleControl('accelerate', true)
        toggleControl('enter_exit', true)
        toggleControl('brake_reverse', true)
        toggleControl('forwards', true)
        toggleControl('backwards', true)
        toggleControl('left', true)
        toggleControl('right', true)
    end

    exports.px_cpicker:destroyCPicker()
end)

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

function RGBToHex(red, green, blue, alpha)
	
	-- Make sure RGB values passed to this function are correct
	if( ( red < 0 or red > 255 or green < 0 or green > 255 or blue < 0 or blue > 255 ) or ( alpha and ( alpha < 0 or alpha > 255 ) ) ) then
		return nil
	end

	-- Alpha check
	if alpha then
		return string.format("#%.2X%.2X%.2X%.2X", red, green, blue, alpha)
	else
		return string.format("#%.2X%.2X%.2X", red, green, blue)
	end

end