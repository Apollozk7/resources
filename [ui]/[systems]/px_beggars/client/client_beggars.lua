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

--

local assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Medium.ttf", 17},
        {":px_assets/fonts/Font-Regular.ttf", 15},
    },

    textures={},
    textures_paths={
        "assets/images/window.png",
        "assets/images/button.png",
        "assets/images/close.png",
        "assets/images/edit.png",
        "assets/images/hajs.png",
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

for i,v in pairs(getElementsByType("ped", resourceRoot)) do
    setPedAnimation(v, "BEACH", "ParkSit_M_loop", -1, true, false, false, true, 500)
end

addEvent("update", true)
addEventHandler("update", resourceRoot, function(ped)
    setPedAnimation(ped, "BEACH", "ParkSit_M_loop", -1, true, false, false, true, 500)
end)

--

UI={}

UI.btns={}
UI.edits={}

UI.info=false

UI.onRender=function()
    blur:dxDrawBlur(sw/2-557/2/zoom, sh/2-294/2/zoom, 557/zoom, 294/zoom, tocolor(255, 255, 255, 255))
    dxDrawImage(sw/2-557/2/zoom, sh/2-294/2/zoom, 557/zoom, 294/zoom, assets.textures[1])

    dxDrawText("Przekaż pieniądze", sw/2-557/2/zoom, sh/2-294/2/zoom, 557/zoom+sw/2-557/2/zoom, sh/2-294/2/zoom+55/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "center", "center")

    dxDrawRectangle(sw/2-518/2/zoom, sh/2-294/2/zoom+55/zoom, 518/zoom, 1, tocolor(88,88,88))

    dxDrawText("Wprowadź sume gotówki którą chcesz przekazać\ndla potrzebującego żebraka.", sw/2-557/2/zoom, sh/2-294/2/zoom+80/zoom, 557/zoom+sw/2-557/2/zoom, sh/2-294/2/zoom+55/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "center", "top")

    onClick(sw/2+10/zoom, sh/2+75/zoom, 175/zoom, 40/zoom, function()
        removeEventHandler("onClientRender",root,UI.onRender)
        showCursor(false)

        buttons:destroyButton(UI.btns[1])
        buttons:destroyButton(UI.btns[2])

        editbox:dxDestroyEdit(UI.edits[1])

        assets.destroy()

        setElementData(localPlayer, "user:gui_showed", false, false)
    end)

    onClick(sw/2-185/zoom, sh/2+75/zoom, 175/zoom, 40/zoom, function()
        if(SPAM.getSpam())then return end

        noti = exports.px_noti

        local cost = editbox:dxGetEditText(UI.edits[1])
        if(#cost >= 1 and #cost < 10 and tonumber(cost))then
            cost = tonumber(cost)
            cost = math.floor(cost)
            if(cost < 1 or cost > 1000000)then
                noti:noti("Wprowadziłeś błędną wartość.")
                return
            end

            removeEventHandler("onClientRender",root,UI.onRender)
            showCursor(false)

            buttons:destroyButton(UI.btns[1])
            buttons:destroyButton(UI.btns[2])

            editbox:dxDestroyEdit(UI.edits[1])

            assets.destroy()

            triggerServerEvent("get", resourceRoot, cost, UI.info)

            setElementData(localPlayer, "user:gui_showed", false, false)
        else
            noti:noti("Wprowadzona wartość jest nieprawidłowa.")
        end
    end)
end

function action(i, ped, name, id)
    if(name == "Przekaż pieniądze")then
        if(getElementData(localPlayer, "user:gui_showed"))then return end

        buttons=exports.px_buttons
        editbox=exports.px_editbox
        noti=exports.px_noti
        blur=exports.blur

        assets.create()

        addEventHandler("onClientRender",root,UI.onRender)
        showCursor(true)

        UI.btns[1] = buttons:createButton(sw/2-185/zoom, sh/2+75/zoom, 175/zoom, 40/zoom, "PRZEKAŻ", 255, 10, false, false, ":px_beggars/assets/images/button.png")
        UI.btns[2] = buttons:createButton(sw/2+10/zoom, sh/2+75/zoom, 175/zoom, 40/zoom, "ANULUJ", 255, 10, false, false, ":px_beggars/assets/images/close.png", {132,39,39})

        UI.edits[1] = editbox:dxCreateEdit("Wprowadź ilość", sw/2-271/2/zoom, sh/2+15/zoom, 271/zoom, 35/zoom, false, 10/zoom, 255, true, false, ":px_beggars/assets/images/edit.png")

        setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

        UI.info=id
    end
end

-- click

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
    end
end)

local sound=false
addEvent("sound", true)
addEventHandler("sound", resourceRoot, function(x,y,z)
    if(sound and isElement(sound))then return end

    sound=playSound3D("assets/sound/dejno5zl.wav", x, y, z)
    setSoundMaxDistance(sound, 15)
end)