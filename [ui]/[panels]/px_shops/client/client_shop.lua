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

    SPAM.blockSpamTimer=setTimer(function() SPAM.blockSpamTimer=nil end, 1000, 1)

    return block
end

-- global variables

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

-- exports

local blur=exports.blur
local dialogs=exports.px_dialogs
local eq=exports.px_eq
local buttons=exports.px_buttons
local noti=exports.px_noti

-- assets

local assets={}
assets.list={
    texs={
        "assets/images/window.png",
        "assets/images/header_icon.png",
        "assets/images/row.png",
        "assets/images/row_name.png",

        "assets/images/window_koszyk.png",
        "assets/images/koszyk_infolist.png",
        "assets/images/koszyk_row.png",
        "assets/images/button_buy.png",
        "assets/images/button_close.png",
        "assets/images/remove.png",
    },

    fonts={
        {"Regular", 15},
        {"Medium", 11},
        {"Bold", 8},
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

ui.buttons={}

-- triggers

ui.dialog={
    ["Sklepikarz"]={
        [1]={
            text="Dzień dobry, w czym mogę pomóc?",
            options={
                {text="Chciałbym coś kupić", resourceName="px_shops", fnc=function(id)
                    ui.create()
                    dialogs:destroyDialog()
                end},

                {text="Dobre tu macie rzeczy?", next=2},
                {text="Tak się tylko rozglądam", ended=true}, 
            }
        },

        [2]={
            text="Jeśli mówimy oficjalnie to tak, ale osobiście to bym nie wydała tu zbyt dużej gotówki",
            options={
                {text="Dlaczego?", next=3},
                {text="Dobrze, proszę mi pokazać ofertę"},
                {text="Rozumiem, ja też nie wydam", ended=true}, 
            }
        },

        [3]={
            text="W 2003 roku dostałam tu solidnej biegunki. Mąż musiał specjalnie jechać do innego miasta po tabletki, a do dziś śni mi się ta tortilla...",
            options={
                {text="Zaryzykuję, zobaczmy o tu jest", resourceName="px_shops", fnc=function(id)
                    ui.create()
                    dialogs:destroyDialog()
                end},

                {text="To ja jednak już sobię pójdę", ended=true}, 
            }
        },
    }
}

function dialogFunction(id, index)
    local v=ui.dialog["Sklepikarz"][id].options[index]
    if(v)then
        v.fnc(id)
    end
end

function action(id,element,name)
    if(name == "Rozpocznij rozmowę")then
        local data=getElementData(element, "dialog:name")
        if(data and ui.dialog[data])then
            dialogs:createDialog(ui.dialog, data)
        end
    end
end

-- shops

ui.tablica={}
ui.items={
    {cost=100,type="Kanistry",name="Kanister 5L"},

    {cost=150,type="Naprawki",name="Zestaw naprawczy"},
    {cost=800,type="Naprawki",name="Zestaw naprawczy +"},
    {cost=200,type="Naprawki",name="Zestaw naprawczy opon"},

    {cost=50,type="Inne",name="Paczka papierosów"},
    {cost=60,type="Inne",name="Blant CBD"},
    {cost=40,type="Inne",name="Browar"},
    {cost=80,type="Inne",name="Wódka"},
    {cost=250,type="Inne",name="Apteczka"},
} 

for i=1,3 do
    local sY=(175/zoom)*(i-1)
    for i=1,5 do
        local sX=(175/zoom)*(i-1)
        ui.tablica[#ui.tablica+1]={sX=sX,sY=sY}
    end
end

ui.koszyk={}
ui.alpha=0

ui.onRender=function()
    blur:dxDrawBlur(sw/2-680/zoom, sh/2-617/2/zoom, 917/zoom, 617/zoom,tocolor(255,255,255, ui.alpha))
    dxDrawImage(sw/2-680/zoom, sh/2-617/2/zoom, 917/zoom, 617/zoom, assets.textures[1],0,0,0,tocolor(255,255,255, ui.alpha))
    dxDrawText("Sklep wielobranżowy", sw/2-680/zoom, sh/2-617/2/zoom, 917/zoom+sw/2-680/zoom, sh/2-617/2/zoom+55/zoom, tocolor(200,200,200, ui.alpha), 1, assets.fonts[1], "center", "center")
    dxDrawImage(sw/2-680/zoom+(917/2)/zoom+dxGetTextWidth("Sklep wielobranżowy", 1, assets.fonts[1])/2+5/zoom, sh/2-617/2/zoom+(55-17)/2/zoom, 19/zoom, 17/zoom, assets.textures[2],0,0,0,tocolor(255,255,255, ui.alpha))
    dxDrawRectangle(sw/2-680/zoom+(917-865)/2/zoom, sh/2-617/2/zoom+50/zoom, 865/zoom, 1, tocolor(85,85,85, ui.alpha))
    for i,v in pairs(ui.tablica) do
        local k=ui.items[i]
        if(k)then
            v.hoverAlpha=not v.hoverAlpha and 0 or v.hoverAlpha
            v.alpha=not v.alpha and 150 or v.alpha

            if(isMouseInPosition(sw/2-680/zoom+(917-865)/2/zoom+v.sX, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY, 165/zoom, 165/zoom) and not v.animate and v.hoverAlpha < 150)then
                v.animate=true
                animate(0, 150, "Linear", 250, function(a)
                    v.hoverAlpha=a
                    v.alpha=150-a
                end, function()
                    v.animate=false
                end)
            elseif(v.hoverAlpha and not isMouseInPosition(sw/2-680/zoom+(917-865)/2/zoom+v.sX, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY, 165/zoom, 165/zoom) and not v.animate and v.hoverAlpha > 0)then
                v.animate=true
                animate(150, 0, "Linear", 250, function(a)
                    v.hoverAlpha=a
                    v.alpha=100-a
                end, function()
                    v.animate=false
                end)
            end

            dxDrawImage(sw/2-680/zoom+(917-865)/2/zoom+v.sX, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY, 165/zoom, 165/zoom, assets.textures[3],0,0,0,tocolor(255,255,255, ui.alpha))
            dxDrawRectangle(sw/2-680/zoom+(917-865)/2/zoom+v.sX, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY+165/zoom-1, 165/zoom, 1, tocolor(117,188,121,v.hoverAlpha > ui.alpha and ui.alpha or v.hoverAlpha))
            dxDrawRectangle(sw/2-680/zoom+(917-865)/2/zoom+v.sX, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY+165/zoom-1, 165/zoom, 1, tocolor(85,85,85,v.alpha > ui.alpha and ui.alpha or v.alpha))

            dxDrawText(k.type, sw/2-680/zoom+(917-865)/2/zoom+v.sX+10/zoom, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY, 165/zoom, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY+26/zoom, tocolor(200,200,200, ui.alpha), 1, assets.fonts[2], "left", "center")
            dxDrawText("#75bc79$ #c8c8c8"..k.cost, sw/2-680/zoom+(917-865)/2/zoom+v.sX+10/zoom, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY, sw/2-680/zoom+(917-865)/2/zoom+v.sX+165/zoom-10/zoom, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY+26/zoom, tocolor(200,200,200, ui.alpha), 1, assets.fonts[2], "right", "center", false, false, false, true)
            dxDrawRectangle(sw/2-680/zoom+(917-865)/2/zoom+v.sX, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY+26/zoom, 165/zoom, 1, tocolor(85,85,85, ui.alpha))

            if(k.tex and isElement(k.tex))then
                dxDrawImage(sw/2-680/zoom+(917-865)/2/zoom+v.sX+(165-64)/2/zoom, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY+26/zoom+((98-26)-64)/zoom, 64/zoom, 64/zoom, k.tex,0,0,0,tocolor(255,255,255, ui.alpha))
            end

            dxDrawImage(sw/2-680/zoom+(917-865)/2/zoom+v.sX, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY+98/zoom, 165/zoom, 22/zoom, assets.textures[4],0,0,0,tocolor(255,255,255, ui.alpha))
            dxDrawText(k.name, sw/2-680/zoom+(917-865)/2/zoom+v.sX, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY+98/zoom, 165/zoom+sw/2-680/zoom+(917-865)/2/zoom+v.sX, 22/zoom+sh/2-617/2/zoom+50/zoom+26/zoom+v.sY+98/zoom, tocolor(200,200,200, ui.alpha), 1, assets.fonts[2], "center", "center", false, false, false, true)
        
            --dxDrawRectangle(sw/2-680/zoom+(917-865)/2/zoom+v.sX+(165-104)/2/zoom, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY+98/zoom+22/zoom+(46-15)/2/zoom, 104/zoom, 15/zoom, tocolor(0,0,0))
            dxDrawImage(sw/2-680/zoom+(917-865)/2/zoom+v.sX+(165-104)/2/zoom+6/zoom, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY+98/zoom+22/zoom+(46-15)/2/zoom+(15-10)/2/zoom, 12/zoom, 10/zoom, assets.textures[2],0,0,0,tocolor(255,255,255, ui.alpha))
            dxDrawRectangle(sw/2-680/zoom+(917-865)/2/zoom+v.sX+(165-104)/2/zoom+19/zoom+6/zoom, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY+98/zoom+22/zoom+(46-15)/2/zoom, 1, 15/zoom, tocolor(200,200,200, ui.alpha))
            dxDrawText("DO KOSZYKA", sw/2-680/zoom+(917-865)/2/zoom+v.sX+(165-104)/2/zoom+19/zoom+6/zoom+8/zoom, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY+98/zoom+22/zoom+(46-15)/2/zoom, 104/zoom, 15/zoom+sh/2-617/2/zoom+50/zoom+26/zoom+v.sY+98/zoom+22/zoom+(46-15)/2/zoom, tocolor(200,200,200, ui.alpha), 1, assets.fonts[3], "left", "center")
        
            onClick(sw/2-680/zoom+(917-865)/2/zoom+v.sX, sh/2-617/2/zoom+50/zoom+26/zoom+v.sY, 165/zoom, 165/zoom, function()
                if(ui.koszyk[k.name])then
                    ui.koszyk[k.name].value=ui.koszyk[k.name].value+1
                else
                    ui.koszyk[k.name]={cost=k.cost,tex=k.tex,value=1}
                end
            end)
        end
    end

    -- koszyk

    blur:dxDrawBlur(sw/2-680/zoom+917/zoom+34/zoom, sh/2-617/2/zoom, 417/zoom, 617/zoom,tocolor(255,255,255, ui.alpha))
    dxDrawImage(sw/2-680/zoom+917/zoom+34/zoom, sh/2-617/2/zoom, 417/zoom, 617/zoom, assets.textures[5],0,0,0,tocolor(255,255,255, ui.alpha))
    dxDrawText("Koszyk", sw/2-680/zoom+917/zoom+34/zoom, sh/2-617/2/zoom, 417/zoom+sw/2-680/zoom+917/zoom+34/zoom, sh/2-617/2/zoom+55/zoom, tocolor(200,200,200, ui.alpha), 1, assets.fonts[1], "center", "center")
    dxDrawImage(sw/2-680/zoom+917/zoom+34/zoom+(417/2)/zoom+dxGetTextWidth("Koszyk", 1, assets.fonts[1])/2+5/zoom, sh/2-617/2/zoom+(55-17)/2/zoom, 19/zoom, 17/zoom, assets.textures[2],0,0,0,tocolor(255,255,255, ui.alpha))
    dxDrawRectangle(sw/2-680/zoom+917/zoom+34/zoom+(417-316)/2/zoom, sh/2-617/2/zoom+50/zoom, 316/zoom, 1, tocolor(85,85,85, ui.alpha))

    dxDrawImage(sw/2-680/zoom+917/zoom+34/zoom, sh/2-617/2/zoom+50/zoom+2, 417/zoom, 34/zoom, assets.textures[5],0,0,0,tocolor(255,255,255, ui.alpha))
    dxDrawText("Przedmiot", sw/2-680/zoom+917/zoom+34/zoom+25/zoom, sh/2-617/2/zoom+50/zoom+2, 417/zoom, 34/zoom+sh/2-617/2/zoom+50/zoom+2, tocolor(200,200,200, ui.alpha), 1, assets.fonts[2], "left", "center")
    dxDrawText("Ilość", sw/2-680/zoom+917/zoom+34/zoom+270/zoom, sh/2-617/2/zoom+50/zoom+2, 417/zoom, 34/zoom+sh/2-617/2/zoom+50/zoom+2, tocolor(200,200,200, ui.alpha), 1, assets.fonts[2], "left", "center")
    dxDrawText("Cena", sw/2-680/zoom+917/zoom+34/zoom+316/zoom, sh/2-617/2/zoom+50/zoom+2, 417/zoom, 34/zoom+sh/2-617/2/zoom+50/zoom+2, tocolor(200,200,200, ui.alpha), 1, assets.fonts[2], "left", "center")

    local x=0
    local cost=0
    for i,v in pairs(ui.koszyk) do
        x=x+1
        cost=cost+(v.cost*v.value)
        if(x < 8)then
            v.hoverAlpha=not v.hoverAlpha and 0 or v.hoverAlpha
            v.alpha=not v.alpha and 150 or v.alpha

            local sY=(59/zoom)*(x-1)

            if(isMouseInPosition(sw/2-680/zoom+917/zoom+34/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, 417/zoom, 57/zoom) and not v.animate and v.hoverAlpha < 150)then
                v.animate=true
                animate(0, 150, "Linear", 250, function(a)
                    v.hoverAlpha=a
                    v.alpha=150-a
                end, function()
                    v.animate=false
                end)
            elseif(v.hoverAlpha and not isMouseInPosition(sw/2-680/zoom+917/zoom+34/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, 417/zoom, 57/zoom) and not v.animate and v.hoverAlpha > 0)then
                v.animate=true
                animate(150, 0, "Linear", 250, function(a)
                    v.hoverAlpha=a
                    v.alpha=100-a
                end, function()
                    v.animate=false
                end)
            end

            dxDrawImage(sw/2-680/zoom+917/zoom+34/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, 417/zoom, 57/zoom, assets.textures[7],0,0,0,tocolor(255,255,255, ui.alpha))
            dxDrawRectangle(sw/2-680/zoom+917/zoom+34/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom+57/zoom-1, 417/zoom, 1, tocolor(117,188,121,v.hoverAlpha > ui.alpha and ui.alpha or v.hoverAlpha))
            dxDrawRectangle(sw/2-680/zoom+917/zoom+34/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom+57/zoom-1, 417/zoom, 1, tocolor(85,85,85,v.alpha > ui.alpha and ui.alpha or v.alpha))

            if(v.tex and isElement(v.tex))then
                dxDrawImage(sw/2-680/zoom+917/zoom+34/zoom+25/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom+(57-36)/2/zoom, 36/zoom, 36/zoom, v.tex, 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
            end

            dxDrawText(i, sw/2-680/zoom+917/zoom+34/zoom+80/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, 417/zoom, 57/zoom+sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, tocolor(200,200,200, ui.alpha), 1, assets.fonts[2], "left", "center")
            dxDrawText("x"..v.value, sw/2-680/zoom+917/zoom+34/zoom+270/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, 417/zoom, 57/zoom+sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, tocolor(200,200,200, ui.alpha), 1, assets.fonts[2], "left", "center")
            dxDrawText("#75bc79$ #c8c8c8"..(v.cost*v.value), sw/2-680/zoom+917/zoom+34/zoom+316/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, 417/zoom, 57/zoom+sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, tocolor(200,200,200, ui.alpha), 1, assets.fonts[2], "left", "center", false, false, false, true)
            
            dxDrawImage(sw/2-680/zoom+917/zoom+34/zoom+417/zoom-16/zoom-(57-16)/2/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom+(57-16)/2/zoom, 16/zoom, 16/zoom, assets.textures[10], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))

            onClick(sw/2-680/zoom+917/zoom+34/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, 417/zoom, 57/zoom, function()
                ui.koszyk[i]=nil
            end)
        end
    end

    local i=8
    local sY=(59/zoom)*(i-1)
    dxDrawImage(sw/2-680/zoom+917/zoom+34/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, 417/zoom, 57/zoom, assets.textures[7], 0, 0, 0, tocolor(255, 255, 255, ui.alpha))
    dxDrawRectangle(sw/2-680/zoom+917/zoom+34/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom+57/zoom-1, 417/zoom, 1, tocolor(85,85,85, ui.alpha))
    dxDrawText("Łącznie "..x.." przedmioty", sw/2-680/zoom+917/zoom+34/zoom+24/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, 417/zoom, 57/zoom+sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[2], "left", "center")
    dxDrawText("Cena: #75bc79$ #c8c8c8"..cost, sw/2-680/zoom+917/zoom+34/zoom, sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, 417/zoom+sw/2-680/zoom+917/zoom+34/zoom-24/zoom, 57/zoom+sh/2-617/2/zoom+50/zoom+2+sY+35/zoom, tocolor(200, 200, 200, ui.alpha), 1, assets.fonts[2], "right", "center", false, false, false, true)

    onClick(sw/2-680/zoom+917/zoom+34/zoom+51/zoom, sh/2-617/2/zoom+617/zoom-48/zoom, 147/zoom, 39/zoom, function()
        ui.destroy()
    end)

    onClick(sw/2-680/zoom+917/zoom+34/zoom+51/zoom+164/zoom, sh/2-617/2/zoom+617/zoom-48/zoom, 147/zoom, 39/zoom, function()
        local items=0
        for i,v in pairs(ui.koszyk) do items=items+1 break end
        if(items > 0)then
            if(SPAM.getSpam())then return end

            triggerServerEvent("buy.items", resourceRoot, ui.koszyk)
            ui.destroy()
        else
            noti:noti("Nie posiadasz żadnych przedmiotów w koszyku.", "error")
        end
    end)
end

ui.create=function()
    local res=getElementData(localPlayer, "user:gui_showed")
    if(res and res ~= "px_dialogs")then return end

    blur=exports.blur
    dialogs=exports.px_dialogs
    eq=exports.px_eq
    buttons=exports.px_buttons
    noti=exports.px_noti

    addEventHandler("onClientRender", root, ui.onRender)

    assets.create()

    ui.buttons[1]=buttons:createButton(sw/2-680/zoom+917/zoom+34/zoom+51/zoom, sh/2-617/2/zoom+617/zoom-48/zoom, 147/zoom, 39/zoom, "ANULUJ", 0, 9, false, false, ":px_shops/assets/images/button_close.png", {132,39,39})
    ui.buttons[2]=buttons:createButton(sw/2-680/zoom+917/zoom+34/zoom+51/zoom+164/zoom, sh/2-617/2/zoom+617/zoom-48/zoom, 147/zoom, 39/zoom, "ZAKUP", 0, 9, false, false, ":px_shops/assets/images/button_buy.png")

    showCursor(true)

    ui.koszyk={}
    ui.alpha=0
    ui.animate=true
    animate(0, 255, "Linear", 500, function(a)
        ui.alpha=a

        buttons:buttonSetAlpha(ui.buttons[1], a)
        buttons:buttonSetAlpha(ui.buttons[2], a)
    end, function()
        ui.animate=false
    end)

    setElementData(localPlayer, "user:gui_showed", resourceRoot, false)

    for i,v in pairs(ui.items) do
        v.tex=eq:getItemTexture(v.name)
    end
end

ui.destroy=function()
    ui.alpha=255
    ui.animate=true

    showCursor(false)

    animate(255, 0, "Linear", 500, function(a)
        ui.alpha=a

        buttons:buttonSetAlpha(ui.buttons[1], a)
        buttons:buttonSetAlpha(ui.buttons[2], a)
    end, function()
        ui.animate=false

        removeEventHandler("onClientRender", root, ui.onRender)

        assets.destroy()
    
        for i = 1,#ui.buttons do
            buttons:destroyButton(ui.buttons[i])
        end

        setElementData(localPlayer, "user:gui_showed", false, false)
    end)
end

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
    if(ui.animate)then return end
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

addEventHandler("onClientResourceStop", resourceRoot, function()
    local gui = getElementData(localPlayer, "user:gui_showed")
    if(gui and gui == source)then
        setElementData(localPlayer, "user:gui_showed", false, false)
    end
end)