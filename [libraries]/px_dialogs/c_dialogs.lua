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
        exports.px_noti:noti("Zaczekaj chwilkę.", "error")
        block=true
    end

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 500, 1)

    return block
end

-- global variables

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

-- exports

local blur=exports.blur

-- assets

local assets={}
assets.list={
    texs={
        "textures/window.png",
        "textures/window_circle.png",
        "textures/icon.png",
        "textures/button.png",
        "textures/button_hover.png",
        "textures/circle.png",
    },

    fonts={
        {"Medium", 13},
        {"Medium", 11},
        {"SemiBold", 13},
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

ui.dialog={}
ui.selectedDialog=1
ui.pedName=false
ui.mainAlpha=0
ui.centerAlpha=0

-- functions

ui.onRender=function()
    local px,py=410/zoom, sh-236/zoom
    dxDrawImage(290/zoom, sh-275/zoom, 598/zoom, 201/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))
    px,py=315/zoom, sh-275/zoom

    local currentDialog=ui.dialog[ui.selectedDialog]
    if(currentDialog)then
        -- header
        dxDrawImage(px+23/zoom, py+(30-18)/2/zoom, 19/zoom, 18/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255, ui.mainAlpha))
        dxDrawText(ui.pedName, px+19/zoom+10/zoom+23/zoom, py, 0, py+30/zoom, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[3], "left", "center")
        dxDrawText(currentDialog.localPlayer or " mówi:", px+19/zoom+10/zoom+23/zoom+dxGetTextWidth(" "..ui.pedName, 1, assets.fonts[1]), py, 0, py+30/zoom, tocolor(200, 200, 200, ui.mainAlpha), 1, assets.fonts[1], "left", "center")
        dxDrawRectangle(px+(575-557)/2/zoom, py+30/zoom, 557/zoom, 1, tocolor(85, 85, 85, ui.mainAlpha))
    
        dxDrawText(currentDialog.text, px+23/zoom, py+35/zoom, px+(575-557)/2/zoom+19/zoom+10/zoom+23/zoom+500/zoom, py+30/zoom, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[2], "left", "top", false, true)
    
        for i,v in pairs(currentDialog.options) do
            v.hoverAlpha=v.hoverAlpha or 0
            v.alpha=v.alpha or 255

            local sY=(38/zoom)*(i-1)
    
            if(isMouseInPosition(px+23/zoom, py+80/zoom+sY, 533/zoom, 35/zoom) and not v.animate and v.hoverAlpha < 255)then
                v.animate=true
                animate(0, 255, "Linear", 250, function(a)
                    v.hoverAlpha=a
                    v.alpha=255-a
                end, function()
                    v.animate=false
                end)
            elseif(not isMouseInPosition(px+23/zoom, py+80/zoom+sY, 533/zoom, 35/zoom) and not v.animate and v.hoverAlpha > 0)then
                v.animate=true
                animate(255, 0, "Linear", 250, function(a)
                    v.hoverAlpha=a
                    v.alpha=255-a
                end, function()
                    v.animate=false
                end)
            end
    
            local a1=v.alpha > ui.centerAlpha and ui.centerAlpha or v.alpha
            local a2=v.hoverAlpha > ui.centerAlpha and ui.centerAlpha or v.hoverAlpha
            dxDrawImage(px+23/zoom, py+80/zoom+sY, 533/zoom, 35/zoom, assets.textures[4], 0, 0, 0, tocolor(255, 255, 255, a1))
            dxDrawImage(px+23/zoom, py+80/zoom+sY, 533/zoom, 35/zoom, assets.textures[5], 0, 0, 0, tocolor(255, 255, 255, a2))
    
            dxDrawImage(px+23/zoom+12/zoom, py+80/zoom+sY+(35-8)/2/zoom, 8/zoom, 8/zoom, assets.textures[6], 0, 0, 0, tocolor(255, 255, 255, a1))
            dxDrawImage(px+23/zoom+12/zoom, py+80/zoom+sY+(35-8)/2/zoom, 8/zoom, 8/zoom, assets.textures[6], 0, 0, 0, tocolor(43, 155, 182, a2))
    
            dxDrawText(v.text, px+23/zoom+28/zoom, py+80/zoom+sY, 533/zoom+px+23/zoom, 35/zoom+py+80/zoom+sY, tocolor(200, 200, 200, ui.centerAlpha), 1, assets.fonts[1], "left", "center")
            if(v.ended)then
                dxDrawText("  [ Zakończ rozmowę ]", px+23/zoom+28/zoom+dxGetTextWidth(v.text.." ", 1, assets.fonts[1]), py+80/zoom+sY, 533/zoom+px+23/zoom, 35/zoom+py+80/zoom+sY, tocolor(134, 134, 134, ui.centerAlpha), 1, assets.fonts[3], "left", "center")
            end

            onClick(px+23/zoom, py+80/zoom+sY, 533/zoom, 35/zoom, function()
                if(SPAM.getSpam())then return end

                if(ui.animate)then return end

                if(v.ended)then
                    if(v.resourceName)then
                        exports[v.resourceName]:dialogFunction(ui.selectedDialog, i, ui.pedName)
                    end
                    
                    return ui.destroy()
                else
                    if(v.resourceName)then
                        exports[v.resourceName]:dialogFunction(ui.selectedDialog, i, ui.pedName)

                        if(not v.next or v.next == 0)then
                            return
                        end
                    end

                    local next=v.next or ui.selectedDialog+1
                    if(ui.dialog[next])then
                        ui.animate=true
                        animate(255, 0, "Linear", 250, function(a)
                            ui.centerAlpha=a
                        end, function()
                            ui.selectedDialog=next
                            animate(0, 255, "Linear", 250, function(a)
                                ui.centerAlpha=a
                            end, function()
                                ui.animate=false
                            end)
                        end)
                    else
                        return ui.destroy()
                    end
                end
            end)
        end
    end
end

ui.create=function(dialog, pedName, selected)
    if(getElementData(localPlayer, "user:gui_showed"))then return end

    blur=exports.blur

    assets.create()

    addEventHandler("onClientRender", root, ui.onRender)

    showCursor(true)

    ui.dialog=dialog[pedName]
    ui.pedName=pedName
    ui.selectedDialog=selected or 1
    ui.animate=true

    animate(0, 255, "Linear", 250, function(a)
        ui.mainAlpha=a
        ui.centerAlpha=a
    end, function()
        ui.animate=false
    end)

    setElementData(localPlayer, "user:gui_showed", "px_dialogs", false)
end
function createDialog(...) ui.create(...) end

function getSettingState(name, element)
    local data=getElementData(element or localPlayer, "user:dash_settings") or {}
    return data[name] or false
end

ui.destroy=function()
    showCursor(false)

    ui.animate=true
    animate(255, 0, "Linear", 250, function(a)
        ui.mainAlpha=a
        ui.centerAlpha=a
    end, function()
        removeEventHandler("onClientRender", root, ui.onRender)

        assets.destroy()
        
        ui.dialog={}
        ui.pedName=false
        ui.selectedDialog=1
        ui.animate=false

        setElementData(localPlayer, "user:gui_showed", false, false)
    end)
end
function destroyDialog(...) ui.destroy(...) end

function refreshDialog(dialog) ui.dialog=dialog end

-- triggers

-- useful

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

-- test
--[[local dialogs={
    ["Janusz"]={
        [1]={
            text="Siema. Czego chcesz?",
            options={
                {text="Spierdalaj dzifko!"},
                {text="Spierdalaj dzifko!", next=3},
                {text="Spierdalaj dzifko!", ended=true}, 
            }
        },

        [2]={
            text="Siema. Czego chcesz?2",
            options={
                {text="Spierdalaj dzifko!"},
                {text="Spierdalaj dzifko!"},
                {text="Spierdalaj dzifko!", ended=true}, 
            }
        },

        [3]={
            text="Siema. Czego chcesz?3",
            options={
                {text="Spierdalaj dzifko!"},
                {text="Spierdalaj dzifko!"},
                {text="Spierdalaj dzifko!", ended=true}, 
            }
        },
    }
}

ui.create(dialogs, "Janusz")]]

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == "px_dialogs")then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)