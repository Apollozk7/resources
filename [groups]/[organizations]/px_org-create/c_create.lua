--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local sw,sh = guiGetScreenSize()
local zoom = 1920/sw

local UI={}

UI.btns={}
UI.edits={}

-- main variables

local assets={
    fonts={},
    fonts2={},
    fonts_paths={
        {":px_assets/fonts/Font-Regular.ttf", 15},
        {":px_assets/fonts/Font-Bold.ttf", 14},
        {":px_assets/fonts/Font-Medium.ttf", 13},
        {":px_assets/fonts/Font-Regular.ttf", 12},
        {":px_assets/fonts/Font-Regular.ttf", 12},
    },

    textures={},
    textures_paths={
        "textures/bg.png",
        "textures/header_icon.png",
        "textures/close.png",
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

UI.check=false
UI.cost=50000

UI.draw=function()
    -- bg
    blur:dxDrawBlur(sw/2-640/2/zoom, sh/2-563/2/zoom, 640/zoom, 563/zoom, tocolor(255, 255, 255, 255))
    dxDrawImage(sw/2-640/2/zoom, sh/2-563/2/zoom, 640/zoom, 563/zoom, assets.textures[1])

    -- header
    dxDrawText("Zakładanie organizacji", sw/2-640/2/zoom, sh/2-563/2/zoom, sw/2-640/2/zoom+640/zoom, sh/2-563/2/zoom+55/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "center", "center")

    local w=dxGetTextWidth("Zakładanie organizacji", 1, assets.fonts[1])
    dxDrawImage(sw/2-640/2/zoom+10/zoom+640/2/zoom+w/2, sh/2-563/2/zoom+(55-17)/2/zoom, 21/zoom, 17/zoom, assets.textures[2], 0, 0, 0, tocolor(255, 255, 255))

    dxDrawImage(sw/2-640/2/zoom+640/zoom-(55-10)/2/zoom-10/zoom, sh/2-563/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, assets.textures[3], 0, 0, 0, tocolor(255, 255, 255))

    dxDrawRectangle(sw/2-607/2/zoom, sh/2-563/2/zoom+55/zoom, 607/zoom, 1, tocolor(80,80,80))

    -- body
    dxDrawText("Nazwa organizacji", sw/2-640/2/zoom+30/zoom, sh/2-563/2/zoom+80/zoom, 640/zoom, 563/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
    dxDrawText("Nazwa powinna być składać się z od 5 do 20 liter oraz być unikatowa.", sw/2-640/2/zoom+30/zoom, sh/2-563/2/zoom+107/zoom, 640/zoom, 563/zoom, tocolor(150, 150, 150), 1, assets.fonts[3], "left", "top")
    
    
    dxDrawText("Skrót organizacji", sw/2-640/2/zoom+30/zoom, sh/2-563/2/zoom+214/zoom, 640/zoom, 563/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
    dxDrawText("Skrót ma zawierać od 3 do 4 znaków. Powinien reprezentować nazwę.", sw/2-640/2/zoom+30/zoom, sh/2-563/2/zoom+240/zoom, 640/zoom, 563/zoom, tocolor(150, 150, 150), 1, assets.fonts[3], "left", "top")
    
    
    dxDrawText("Wymagania", sw/2-640/2/zoom+30/zoom, sh/2-563/2/zoom+350/zoom, 640/zoom, 563/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
    dxDrawText("- Przegrane minimum 100 godzin\n- Minimalnie 300 reputacji\n- Posiadanie $"..UI.cost, sw/2-640/2/zoom+30/zoom, sh/2-563/2/zoom+378/zoom, 640/zoom, 563/zoom, tocolor(150, 150, 150), 1, assets.fonts[3], "left", "top")

    dxDrawRectangle(sw/2-607/2/zoom, sh/2-563/2/zoom+492/zoom, 607/zoom, 1, tocolor(80,80,80))

    -- footer
    dxDrawImage(sw/2-640/2/zoom+29/zoom, sh/2-563/2/zoom+563/zoom-45/zoom, 19/zoom, 19/zoom, UI.check and assets.textures[5] or assets.textures[4])
    onClick(sw/2-640/2/zoom+29/zoom, sh/2-563/2/zoom+563/zoom-45/zoom, 19/zoom, 19/zoom, function()
        UI.check=not UI.check
    end)

    dxDrawText("Akceptuję #40a7d6regulamin organizacji", sw/2-640/2/zoom+61/zoom, sh/2-563/2/zoom+563/zoom-45/zoom, 640/zoom, 563/zoom, tocolor(150, 150, 150), 1, assets.fonts[4], "left", "top", false, false, false, true)

    -- clicks
    onClick(sw/2-640/2/zoom+640/zoom-(55-10)/2/zoom-10/zoom, sh/2-563/2/zoom+(55-10)/2/zoom, 10/zoom, 10/zoom, function()
        UI.open(true)
    end)

    onClick(sw/2-607/2/zoom+607/zoom-140/zoom, sh/2-563/2/zoom+563/zoom-54/zoom, 140/zoom, 37/zoom, function()
        local name=edits:dxGetEditText(UI.edits[1]) or ""
        local tag=edits:dxGetEditText(UI.edits[2]) or ""
        if(#name >= 5 and #name < 20 and #tag >= 3 and #tag <= 4)then
            if(UI.check)then
                if(getPlayerMoney(localPlayer) >= UI.cost)then
                    local data=getElementData(localPlayer, "user:online_time")
                    if(math.floor(data/60) >= 100)then
                        local rp=getElementData(localPlayer, "user:reputation")
                        if(rp >= 300)then
                            triggerServerEvent("create.organization", resourceRoot, name, tag, UI.cost)
    
                            UI.open(true)
                        else
                            noti:noti("Aby założyć konto musisz posiadasz minimalnie 300 reputacji.", "error")
                        end
                    else
                        noti:noti("Musisz mieć przegrane 100 godzin aby założyć organizację.", "error")
                    end
                else
                    noti:noti("Założenie organizacji kosztuje $"..UI.cost, "error")
                end
            else
                noti:noti("Najpierw zaakceptuj regulamin organizacji.", "error")
            end
        else
            noti:noti("Wprowadziłeś błędną nazwę i/lub tag.", "error")
        end
    end)
end

UI.opened=false

UI.open=function(self)
    if(UI.opened or self)then
        removeEventHandler("onClientRender", root, UI.draw)
        showCursor(false)
        UI.opened=false
        assets.destroy()

        for i,v in pairs(UI.btns) do
            btns:destroyButton(v)
        end

        for i,v in pairs(UI.edits) do
            edits:dxDestroyEdit(v)
        end

        setElementData(localPlayer, "user:gui_showed", false, false)
    else
        if(getElementData(localPlayer, "user:gui_showed"))then return end

        noti = exports.px_noti
        blur=exports.blur
        btns=exports.px_buttons
        edits=exports.px_editbox

        setElementData(localPlayer, "user:gui_showed", sourceResource, false)

        addEventHandler("onClientRender", root, UI.draw)
        showCursor(true)
        UI.opened=true
        assets.create()

        UI.check=false

        UI.btns[1]=btns:createButton(sw/2-607/2/zoom+607/zoom-140/zoom, sh/2-563/2/zoom+563/zoom-54/zoom, 140/zoom, 37/zoom, "WYŚLIJ WNIOSEK", 255, 7, false, false, ":px_org-create/textures/button.png")
    
        UI.edits[1]=edits:dxCreateEdit("Wprowadź nazwe", sw/2-640/2/zoom+30/zoom, sh/2-563/2/zoom+146/zoom, 291/zoom, 30/zoom, false, 11/zoom, 255, false, false, ":px_org-create/textures/edit_name.png")
        UI.edits[2]=edits:dxCreateEdit("Wprowadź skrót", sw/2-640/2/zoom+30/zoom, sh/2-563/2/zoom+281/zoom, 291/zoom, 30/zoom, false, 11/zoom, 255, false, false, ":px_org-create/textures/edit_name.png")
    end
end

-- triggers

addEvent("open.interface", true)
addEventHandler("open.interface", resourceRoot, function(self)
    UI.open(self)
end)

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