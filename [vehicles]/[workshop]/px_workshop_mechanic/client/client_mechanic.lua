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

local noti = exports.px_noti
local buttons = exports.px_buttons
local scroll = exports.px_scroll
local blur=exports.blur

sw,sh = guiGetScreenSize()
zoom = 1920/sw

-- assets

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Regular.ttf", 17},
        {":px_assets/fonts/Font-Medium.ttf", 13},
        {":px_assets/fonts/Font-Regular.ttf", 11},
        {":px_assets/fonts/Font-Regular.ttf", 13},
        {":px_assets/fonts/Font-Regular.ttf", 15},
    },

    textures={},
    textures_paths={
        "assets/images/window.png",
        "assets/images/header_icon.png",
        "assets/images/close_icon.png",
        "assets/images/list.png",
        "assets/images/nazwa_icon.png",
        "assets/images/stan_icon.png",
        "assets/images/koszt_icon.png",
        "assets/images/row.png",
        "assets/images/checkbox.png",
        "assets/images/checkbox_selected.png",
        "assets/images/footer.png",
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

local FIX = {}

FIX.alpha = 0
FIX.part_row = 1
FIX.allCost = 0

FIX.scroll = false
FIX.veh = false
FIX.target = false
FIX.offer=false

FIX.parts = {}
FIX.buttons = {}

FIX.onRender = function()
    if(not isPedInVehicle(localPlayer))then
        if(SPAM.getSpam())then return end

        triggerServerEvent("send.offer.info", resourceRoot, "Gracz "..getPlayerName(localPlayer).." anulował oferte naprawy.")

        toggleControl('accelerate', true)
        toggleControl('enter_exit', true)
        toggleControl('brake_reverse', true)
        toggleControl('forwards', true)
        toggleControl('backwards', true)
        toggleControl('left', true)
        toggleControl('right', true)

        FIX.offer=false
        FIX.target=false

        FIX.toggleUI()
        return
    end

    if(FIX.offer and FIX.veh and isElement(FIX.veh) and FIX.target and isElement(FIX.target))then
        blur:dxDrawBlur(sw/2-695/2/zoom, sh/2-608/2/zoom, 695/zoom, 608/zoom, tocolor(255, 255, 255, FIX.alpha))
        dxDrawImage(sw/2-695/2/zoom, sh/2-608/2/zoom, 695/zoom, 608/zoom, assets.textures[1], 0, 0, 0, tocolor(255, 255, 255, FIX.alpha))
    
        -- header
        dxDrawText("Oferta naprawy", sw/2-695/2/zoom, sh/2-608/2/zoom, 695/zoom+sw/2-695/2/zoom, sh/2-608/2/zoom+55/zoom, tocolor(200, 200, 200, FIX.alpha), 1, assets.fonts[1], "center", "center")
        local w=dxGetTextWidth("Oferta naprawy", 1, assets.fonts[1])
        dxDrawImage(sw/2-695/2/zoom+695/2/zoom-20/2+w/2+20/zoom, sh/2-608/2/zoom+(60-20)/2/zoom, 20/zoom, 20/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, FIX.alpha))
    
        -- close
        dxDrawImage(sw/2-695/2/zoom+695/zoom-10/zoom-(55-10)/2/zoom, sh/2-608/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, FIX.alpha))
        --
    
        dxDrawText(getVehicleName(FIX.veh).." #"..(getElementData(FIX.veh, "vehicle:id") or 0), sw/2-695/2/zoom+20/zoom, sh/2-608/2/zoom, 695/zoom+sw/2-695/2/zoom, sh/2-608/2/zoom+55/zoom, tocolor(170, 170, 170,FIX.alpha), 1, assets.fonts[2], "left", "center")
        --
    
        dxDrawRectangle(sw/2-654/2/zoom, sh/2-608/2/zoom+55/zoom-1, 654/zoom, 1, tocolor(85,85,85,FIX.alpha))
    
        -- list
        dxDrawImage(sw/2-695/2/zoom, sh/2-608/2/zoom+55/zoom, 695/zoom, 22/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, FIX.alpha))
    
        dxDrawImage(sw/2-695/2/zoom+40/zoom, sh/2-608/2/zoom+55/zoom+(22-12)/2/zoom, 16/zoom, 12/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, FIX.alpha))
        dxDrawText("Nazwa części", sw/2-695/2/zoom+65/zoom, sh/2-608/2/zoom+55/zoom, 695/zoom, 22/zoom+sh/2-608/2/zoom+55/zoom, tocolor(170, 170, 170,FIX.alpha), 1, assets.fonts[3])
    
        dxDrawImage(sw/2-695/2/zoom+283/zoom, sh/2-608/2/zoom+55/zoom+(22-12)/2/zoom, 12/zoom, 12/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, FIX.alpha))
        dxDrawText("Stan części", sw/2-695/2/zoom+283/zoom, sh/2-608/2/zoom+55/zoom, sw/2-695/2/zoom+283/zoom+115/zoom, 22/zoom+sh/2-608/2/zoom+55/zoom, tocolor(170, 170, 170,FIX.alpha), 1, assets.fonts[3], "center")
    
        dxDrawImage(sw/2-695/2/zoom+500/zoom, sh/2-608/2/zoom+55/zoom+(22-15)/2/zoom, 15/zoom, 15/zoom, assets.textures[7], 0, 0, 0, tocolor(255, 255, 255, FIX.alpha))
        dxDrawText("Koszt naprawy", sw/2-695/2/zoom+500/zoom, sh/2-608/2/zoom+55/zoom, sw/2-695/2/zoom+500/zoom+140/zoom, 22/zoom+sh/2-608/2/zoom+55/zoom, tocolor(170, 170, 170,FIX.alpha), 1, assets.fonts[3], "center")
    
        FIX.part_row = math.floor(scroll:dxScrollGetPosition(FIX.scroll)+1)
    
        local fixParts={}
        local k=0
        for i,v in pairs(FIX.parts) do
            if(v.selected)then
                fixParts[#fixParts+1]=v
            end
    
            if(i >= FIX.part_row and i <= (FIX.part_row+6))then
                k=k+1
    
                local cost=100
                local hex=v.stan >= 50 and "#2193b0" or "#973232"
                local color=v.stan >= 50 and {58,116,131} or {150,48,48}
    
                local sY=(59/zoom)*(k-1)
                dxDrawImage(sw/2-694/2/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY, 693/zoom, 57/zoom, assets.textures[8], 0, 0, 0, tocolor(255, 255, 255, FIX.alpha))
                dxDrawRectangle(sw/2-694/2/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY+57/zoom-1, 693/zoom, 1, tocolor(85, 85, 85,FIX.alpha))
                dxDrawRectangle(sw/2-694/2/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY+57/zoom-1, (693/zoom)*(v.stan/100), 1, tocolor(color[1], color[2], color[3],FIX.alpha))
    
                dxDrawText(v.name, sw/2-695/2/zoom+65/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY, 695/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY+57/zoom, tocolor(220, 220, 220,FIX.alpha), 1, assets.fonts[4], "left", "center")
                dxDrawText(v.stan..hex.."%", sw/2-695/2/zoom+283/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY, sw/2-695/2/zoom+283/zoom+115/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY+57/zoom, tocolor(220, 220, 220,FIX.alpha), 1, assets.fonts[2], "center", "center", false, false, false, true)
                dxDrawText(v.cost.."#2193b0$", sw/2-695/2/zoom+500/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY, sw/2-695/2/zoom+500/zoom+140/zoom, sh/2-608/2/zoom+55/zoom+20/zoom+2+sY+57/zoom, tocolor(220, 220, 220,FIX.alpha), 1, assets.fonts[2], "center", "center", false, false, false, true)
    
                if(v.selected)then
                    onClick(sw/2-694/2/zoom+(57-42)/2/zoom, sh/2-608/2/zoom+(57-42)/2/zoom+55/zoom+20/zoom+2+sY, 42/zoom, 42/zoom, function()
                        v.selected=false
                        FIX.allCost=FIX.allCost-v.cost
    
                        local parts=0
                        for i,v in pairs(FIX.parts) do
                            if(v.selected)then
                                parts=parts+1
                            end
                        end
    
                        if(parts == 0)then
                            FIX.allSelected=false
                        else
                            FIX.allSelected=true
                        end
                    end)
                else
                    onClick(sw/2-694/2/zoom+(57-42)/2/zoom, sh/2-608/2/zoom+(57-42)/2/zoom+55/zoom+20/zoom+2+sY, 42/zoom, 42/zoom, function()
                        v.selected=true
                        FIX.allCost=FIX.allCost+v.cost
                        FIX.allSelected=true
                    end)
                end
    
                dxDrawImage(sw/2-694/2/zoom+(57-42)/2/zoom, sh/2-608/2/zoom+(57-42)/2/zoom+55/zoom+20/zoom+2+sY, 42/zoom, 42/zoom, not v.selected and assets.textures[9] or assets.textures[10], 0, 0, 0, tocolor(255, 255, 255, FIX.alpha))
            end
        end
    
        -- footer
        dxDrawImage(sw/2-694/2/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom, 693/zoom, 57/zoom, assets.textures[11], 0, 0, 0, tocolor(255, 255, 255, FIX.alpha))
    
        dxDrawImage(sw/2-694/2/zoom+(57-42)/2/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom+(57-42)/2/zoom, 42/zoom, 42/zoom, FIX.allSelected and assets.textures[10] or assets.textures[9], 0, 0, 0, tocolor(255, 255, 255, FIX.alpha))

        onClick(sw/2-694/2/zoom+(57-42)/2/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom+(57-42)/2/zoom, 42/zoom, 42/zoom, function()
            if(FIX.allSelected)then
                FIX.allSelected=false
    
                for i,v in pairs(FIX.parts) do
                    v.selected=false
                end

                FIX.allCost=0
            else
                FIX.allSelected=true
    
                FIX.allCost=0
                for i,v in pairs(FIX.parts) do
                    v.selected=true
                    FIX.allCost=FIX.allCost+v.cost
                end
            end
        end)
    
        dxDrawText("Wybrano "..#fixParts.." części", sw/2-694/2/zoom+(57-42)/2/zoom+60/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom, 0, sh/2-608/2/zoom+608/zoom-50/zoom, tocolor(200, 200, 200,FIX.alpha), 1, assets.fonts[4], "left", "center")
        
        dxDrawText("#dcdcdcŁączny koszt: "..FIX.allCost.."#3c7886$", sw/2-694/2/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom, sw/2-694/2/zoom+693/zoom, sh/2-608/2/zoom+608/zoom-50/zoom, tocolor(200, 200, 200,FIX.alpha), 1, assets.fonts[4], "center", "center", false, false, false, true)
    
        dxDrawRectangle(sw/2-694/2/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-1, 693/zoom, 1, tocolor(85, 85, 85,FIX.alpha))
    
        -- infos
        local name=getPlayerName(FIX.target)
        local id=getElementData(FIX.target, "user:id")
        dxDrawText("#929293Mechanik: [#e5e322"..id.."#929293] "..name, sw/2-695/2/zoom, sh/2-608/2/zoom+608/zoom-50/zoom, 695/zoom+sw/2-695/2/zoom, sh/2-608/2/zoom+608/zoom, tocolor(255, 255, 255,FIX.alpha), 1, assets.fonts[4], "center", "center", false, false, false, true)    

        onClick(sw/2-694/2/zoom+524/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom+(57-39)/2/zoom, 148/zoom, 39/zoom, function()
            if(FIX.target and isElement(FIX.target))then
                if(SPAM.getSpam())then return end

                if(getPlayerMoney(localPlayer) >= FIX.allCost)then
                    if(#fixParts > 0)then
                        noti:noti("Przyjąłeś oferte naprawy od gracza "..getPlayerName(FIX.target))
                        triggerServerEvent("send.offer.info", resourceRoot, "Gracz "..getPlayerName(localPlayer).." przyjął oferte naprawy.", FIX.target, fixParts, FIX.allCost)
                    else
                        noti:noti("Najpierw zaznacz części.")
                        return
                    end
                else
                    noti:noti("Nie stać Cię na opłate oferty naprawy od gracza "..getPlayerName(FIX.target))
                    triggerServerEvent("send.offer.info", resourceRoot, "Gracz "..getPlayerName(localPlayer).." anulował oferte naprawy.")

                    toggleControl('accelerate', true)
                    toggleControl('enter_exit', true)
                    toggleControl('brake_reverse', true)
                    toggleControl('forwards', true)
                    toggleControl('backwards', true)
                    toggleControl('left', true)
                    toggleControl('right', true)

                    FIX.offer=false
                    FIX.target=false
                end
            end

            FIX.toggleUI()
        end)

        onClick(sw/2-695/2/zoom+695/zoom-10/zoom-(55-10)/2/zoom, sh/2-608/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, function()
            if(FIX.target and isElement(FIX.target))then
                if(SPAM.getSpam())then return end

                noti:noti("Anulowałeś oferte naprawy od gracza "..getPlayerName(FIX.target))
                triggerServerEvent("send.offer.info", resourceRoot, "Gracz "..getPlayerName(localPlayer).." anulował oferte naprawy.", FIX.target)
            end

            FIX.offer=false
            FIX.target=false
            FIX.toggleUI()
        end)
    else
        FIX.offer=false
        FIX.target=false
        FIX.toggleUI() 
    end
end

FIX.toggleUI=function(toggle, veh, target, rabat, parts)
    if(toggle)then
        if(getElementData(localPlayer, "user:gui_showed") or FIX.offer or FIX.animation)then return end

        FIX.parts=parts
        if(#FIX.parts > 0)then
            noti = exports.px_noti
            buttons = exports.px_buttons
            scroll = exports.px_scroll
            blur=exports.blur

            FIX.allCost = 0
            FIX.veh = veh
            FIX.target = target
            FIX.discount=rabat
            FIX.animation = true
            FIX.offer=true
        
            addEventHandler("onClientRender", root, FIX.onRender)
            showCursor(true)
            setElementData(localPlayer, "user:gui_showed", resourceRoot, false)
            setElementFrozen(localPlayer, true)

            toggleControl('accelerate', false)
            toggleControl('enter_exit', false)
            toggleControl('brake_reverse', false)
            toggleControl('forwards', false)
            toggleControl('backwards', false)
            toggleControl('left', false)
            toggleControl('right', false)

            assets.create()
            noti:noti("Wybierz części na liście, które chcesz naprawić.")

            FIX.buttons[1]=buttons:createButton(sw/2-694/2/zoom+524/zoom, sh/2-608/2/zoom+608/zoom-50/zoom-57/zoom+(57-39)/2/zoom, 148/zoom, 39/zoom, "PRZYJMIJ", 255, 10/zoom, false, false, ":px_workshop_mechanic/assets/images/button_icon.png")
            FIX.scroll=scroll:dxCreateScroll(sw/2-695/2/zoom+695/zoom-4/zoom, sh/2-608/2/zoom+55/zoom+22/zoom, 4/zoom, 4/zoom, 0, 8, FIX.parts, 410/zoom, 255)
        
            animate(FIX.alpha, 255, "Linear", 200, function(a)
                FIX.alpha = a
        
                for i = 1,#FIX.buttons do
                    buttons:buttonSetAlpha(i, a)
                end
        
                scroll:dxScrollSetAlpha(FIX.scroll, a)
            end, function()
                setElementFrozen(localPlayer, false)
                FIX.animation=nil
            end)
        end
    else
        toggleControl('accelerate', true)
        toggleControl('enter_exit', true)
        toggleControl('brake_reverse', true)
        toggleControl('forwards', true)
        toggleControl('backwards', true)
        toggleControl('left', true)
        toggleControl('right', true)

        showCursor(false)

        FIX.animation = true
        animate(FIX.alpha, 0, "Linear", 200, function(a)
            FIX.alpha = a

            for i = 1,#FIX.buttons do
                buttons:buttonSetAlpha(i, a)
            end

            scroll:dxScrollSetAlpha(FIX.scroll, a)
        end, function()
            removeEventHandler("onClientRender", root, FIX.onRender)

            for i = 1,#FIX.buttons do
                buttons:destroyButton(FIX.buttons[i])
            end

            FIX.animation = nil

            if(FIX.scroll)then
                scroll:dxDestroyScroll(FIX.scroll)
                FIX.scroll = false
            end

            setElementData(localPlayer, "user:gui_showed", false, false)

            assets.destroy()
        end)
    end
end

-- offer

function sendOffer(player, vehicle, rabat)
    triggerServerEvent("send.offer", resourceRoot, player, vehicle, rabat)
end

-- triggers

addEvent("workshop->leaveZone", true)
addEventHandler("workshop->leaveZone", root, function(player)
    if(FIX.target and FIX.target == player)then
        toggleControl('accelerate', true)
        toggleControl('enter_exit', true)
        toggleControl('brake_reverse', true)
        toggleControl('forwards', true)
        toggleControl('backwards', true)
        toggleControl('left', true)
        toggleControl('right', true)

        FIX.offer=false
        FIX.target=false
    end
end)

addEvent("cancel.offer", true)
addEventHandler("cancel.offer", resourceRoot, function()
    toggleControl('accelerate', true)
    toggleControl('enter_exit', true)
    toggleControl('brake_reverse', true)
    toggleControl('forwards', true)
    toggleControl('backwards', true)
    toggleControl('left', true)
    toggleControl('right', true)

    FIX.offer=false
    FIX.target=false
end)

addEvent("playSound", true)
addEventHandler("playSound", resourceRoot, function(pos)
    playSound3D("assets/sounds/repair.mp3", pos[1], pos[2], pos[3])
end)

addEvent("send.offer", true)
addEventHandler("send.offer", resourceRoot, function(veh, target, rabat, parts)
    FIX.toggleUI(true, veh, target, rabat, parts)
end)

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