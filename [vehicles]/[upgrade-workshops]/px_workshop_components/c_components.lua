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

-- global variables

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

local e_blur=exports.blur

local floor=math.floor

local ui={}

-- assets

local assets={}
assets.textures={}
assets.fonts={}

assets.list={
    texs={
        "textures/window.png",
        "textures/arrow.png",
        "textures/buy.png",
        "textures/circle_choose.png",
        "textures/enter_button.png",
        "textures/have.png",

        "textures/bg.png",
        "textures/accept.png",
        "textures/cancel.png",
    },

    fonts={
        {"Medium", 17},
        {"Regular", 15},
        {"Bold", 15},
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

ui.selected=1
ui.selectedMenu=1
ui.vehicleComponents={}
ui.apply=false
ui.acceptMenu=false

-- rendering, etc

ui.onRender=function()
    local veh=getPedOccupiedVehicle(localPlayer)
    if(not veh)then ui.destroy() return end

    local t,categories=ui.getVehicleComponentsList(veh)

    local tbl=t[categories[ui.selected]]
    if(tbl)then
        -- variables
        local sy=sh/2-((51/zoom)*((table.size(tbl)+2)/2))
        local e=0

        -- start
        dxDrawText("Warsztat komponentów", 50/zoom+1, sy+1, 366/zoom+50/zoom+1, 49/zoom+sy+1, tocolor(0, 0, 0), 1, assets.fonts[1], "center", "center")
        dxDrawText("Warsztat komponentów", 50/zoom, sy, 366/zoom+50/zoom, 49/zoom+sy, tocolor(200, 200, 200), 1, assets.fonts[1], "center", "center")
        --

        -- kategoria
        e_blur:dxDrawBlur(50/zoom, sy+51/zoom, 366/zoom, 49/zoom)
        dxDrawImage(50/zoom, sy+51/zoom, 366/zoom, 49/zoom, assets.textures[1])

        local text=categories[ui.selected] == "Podstawowe" and "Domyślne" or categories[ui.selected]
        dxDrawText(text, 50/zoom, sy+51/zoom, 366/zoom+50/zoom, 49/zoom+sy+51/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "center", "center")

        dxDrawImage(50/zoom+(49-17)/2/zoom, sy+51/zoom+(49-17)/2/zoom, 21/zoom, 17/zoom, assets.textures[2], 180)
        dxDrawImage(50/zoom+366/zoom-21/zoom-(49-17)/2/zoom, sy+51/zoom+(49-17)/2/zoom, 21/zoom, 17/zoom, assets.textures[2], 0)
        --

        -- rows
        local k=0
        for i,v in pairs(tbl) do
            k=k+1

            local sY=(51/zoom)*(k+1)
            e_blur:dxDrawBlur(50/zoom, sy+sY, 366/zoom, 49/zoom)
            dxDrawImage(50/zoom, sy+sY, 366/zoom, 49/zoom, assets.textures[1])

            local x=16/zoom
            if(ui.selectedMenu == k)then
                e_blur:dxDrawBlur(50/zoom+366/zoom+3, sy+sY, 119/zoom, 49/zoom)
                dxDrawImage(50/zoom+366/zoom+3, sy+sY, 119/zoom, 49/zoom, assets.textures[5])

                if(v.have or i == "Podstawowy")then
                    dxDrawText("WYBIERZ", 50/zoom+366/zoom+3+119/zoom+10/zoom+1, sy+sY+1, 119/zoom+1, sy+sY+49/zoom, tocolor(0, 0, 0), 1, assets.fonts[3], "left", "center")
                    dxDrawText("WYBIERZ", 50/zoom+366/zoom+3+119/zoom+10/zoom, sy+sY, 119/zoom, sy+sY+49/zoom, tocolor(222, 222, 222), 1, assets.fonts[3], "left", "center")
                else
                    dxDrawText("KUP", 50/zoom+366/zoom+3+119/zoom+10/zoom+1, sy+sY-25/zoom+1, 119/zoom+1, 49/zoom+sy+sY+1, tocolor(0, 0, 0), 1, assets.fonts[3], "left", "center")
                    dxDrawText("KUP", 50/zoom+366/zoom+3+119/zoom+10/zoom, sy+sY-25/zoom, 119/zoom, 49/zoom+sy+sY, tocolor(222, 222, 222), 1, assets.fonts[3], "left", "center")

                    dxDrawText("$"..v.cost, 50/zoom+366/zoom+3+119/zoom+10/zoom+1, sy+sY+25/zoom+1, 119/zoom+1, 49/zoom+sy+sY+1, tocolor(0, 0, 0), 1, assets.fonts[1], "left", "center")
                    dxDrawText("#69b46d$#ffffff"..v.cost, 50/zoom+366/zoom+3+119/zoom+10/zoom, sy+sY+25/zoom, 119/zoom, 49/zoom+sy+sY, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center", false, false, false, true)
                end

                dxDrawRectangle(50/zoom, sy+sY+49/zoom-1, 366/zoom, 1, tocolor(46,116,59))

                dxDrawImage(50/zoom+x, sy+sY+(49-12)/2/zoom, 12/zoom, 12/zoom, assets.textures[4])

                x=x+25/zoom

                if(not ui.apply)then
                    ui.applyClientComponent(veh, i)
                    ui.apply=true
                end

                if(ui.buy)then
                    ui.buy=false

                    if(v.have and i ~= "Podstawowy")then
                        exports.px_noti:noti("Posiadasz już zamontowany owy komponent.", "error")
                    else
                        ui.acceptMenu={name=i, cost=v.cost}
                        showCursor(true,false)
                    end
                end
            end

            local text=i == "Podstawowy" and "Domyślne" or i
            dxDrawText(text, 50/zoom+x, sy+sY, 366/zoom, 49/zoom+sy+sY, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "center")

            if(v.have or i == "Podstawowy")then
                dxDrawImage(50/zoom+366/zoom-17/zoom-18/zoom, sy+sY+(49-17)/2/zoom, 17/zoom, 17/zoom, assets.textures[6])
            else
                dxDrawImage(50/zoom+366/zoom-19/zoom-18/zoom, sy+sY+(49-17)/2/zoom, 19/zoom, 17/zoom, assets.textures[3])
            end
        end
    end
    --

    if(ui.acceptMenu)then
        e_blur:dxDrawBlur(sw/2-520/2/zoom, sh/2-307/2/zoom, 520/zoom, 307/zoom)
        dxDrawImage(sw/2-520/2/zoom, sh/2-307/2/zoom, 520/zoom, 307/zoom, assets.textures[7])

        dxDrawImage(floor(sw/2-520/2/zoom+14/zoom), floor(sh/2-307/2/zoom+(307-281)/2/zoom), floor(240/zoom), floor(281/zoom), assets.textures[9], 0, 0, 0, tocolor(255, 255, 255, isMouseInPosition(floor(sw/2-520/2/zoom+14/zoom), floor(sh/2-307/2/zoom+(307-281)/2/zoom), floor(240/zoom), floor(281/zoom)) and 200 or 255))
        dxDrawImage(floor(sw/2-520/2/zoom+28/zoom+240/zoom), floor(sh/2-307/2/zoom+(307-281)/2/zoom), floor(240/zoom), floor(281/zoom), assets.textures[8], 0, 0, 0, tocolor(255,255,255,isMouseInPosition(floor(sw/2-520/2/zoom+28/zoom+240/zoom), floor(sh/2-307/2/zoom+(307-281)/2/zoom), floor(240/zoom), floor(281/zoom)) and 200 or 255))
    
        onClick(floor(sw/2-520/2/zoom+14/zoom), floor(sh/2-307/2/zoom+(307-281)/2/zoom), floor(240/zoom), floor(281/zoom), function()
            exports.px_noti:noti("Pomyślnie anulowano zakup komponentu "..ui.acceptMenu.name, "info")

            ui.acceptMenu=false
            showCursor(false)
        end)

        onClick(floor(sw/2-520/2/zoom+28/zoom+240/zoom), floor(sh/2-307/2/zoom+(307-281)/2/zoom), floor(240/zoom), floor(281/zoom), function()
            triggerServerEvent("buy.component", resourceRoot, ui.acceptMenu, veh)
            ui.acceptMenu=false
            showCursor(false)
        end)
    end
end

ui.onKey=function(key, press)
    if(press)then return end

    if(ui.acceptMenu)then return end

    local veh=getPedOccupiedVehicle(localPlayer)
    if(not veh)then ui.destroy() return end

    local t,categories=ui.getVehicleComponentsList(veh)
    if(not t)then return end

    if(key == "arrow_l")then
        if(ui.selected > 1)then
            ui.selected=ui.selected-1
            ui.selectedMenu=1
            ui.apply=false
        end
    elseif(key == "arrow_r")then
        if(ui.selected < #categories)then
            ui.selected=ui.selected+1
            ui.selectedMenu=1
            ui.apply=false
        end
    elseif(key == "arrow_u")then
        if(ui.selectedMenu > 1)then
            ui.selectedMenu=ui.selectedMenu-1
            ui.apply=false
        end
    elseif(key == "arrow_d")then
        local tx=t[categories[ui.selected]]
        if(not tx)then return end

        if(ui.selectedMenu < table.size(tx))then
            ui.selectedMenu=ui.selectedMenu+1
            ui.apply=false
        end
    elseif(key == "enter")then
        ui.buy=true
    end
end

-- create

ui.create=function()
    local vehicle=getPedOccupiedVehicle(localPlayer)
    if(not vehicle)then return end

    if(getVehicleController(vehicle) ~= localPlayer)then return end

    if(getElementHealth(vehicle) < 1000)then
        exports.px_noti:noti("Aby ulepszyć pojazd, musi on być sprawny.", "error")
        return
    end

    local uid=getElementData(localPlayer, "user:uid")    
    local owner=getElementData(vehicle, "vehicle:owner") or getElementData(vehicle, "vehicle:liderUID")
    if(not uid or not owner or (owner and owner ~= uid))then 
        exports.px_noti:noti("Pojazd nie należy do Ciebie.", "error")
        return 
    end

    local t,categories=ui.getVehicleComponentsList(vehicle)
    if(t and categories)then
        local tbl=t[categories[ui.selected]]
        if(tbl)then
            ui.acceptMenu=false

            e_blur=exports.blur
            
            assets.create()

            addEventHandler("onClientRender", root, ui.onRender)
            addEventHandler("onClientKey", root, ui.onKey)

            setElementData(localPlayer, "user:hud_disabled", true)

            ui.selected=1
            ui.selectedMenu=1
            ui.vehicleComponents=getElementData(vehicle, "vehicle:components") or {}
            setElementData(vehicle, "vehicle:client_components", ui.vehicleComponents, false)

            exports.px_components:setVehicleClientComponent(vehicle)

            toggleControl("enter_exit", false)

            ui.apply=false
        else
            exports.px_noti:noti("Ten pojazd nie posiada komponentów do zmiany.", "error")
        end
    else
        exports.px_noti:noti("Ten pojazd nie posiada komponentów do zmiany.", "error")
    end
end

ui.destroy=function()
    local vehicle=getPedOccupiedVehicle(localPlayer)
    if(not vehicle)then return end

    if(getVehicleController(vehicle) ~= localPlayer)then return end

    removeEventHandler("onClientRender", root, ui.onRender)
    removeEventHandler("onClientKey", root, ui.onKey)

    assets.destroy()

    setElementData(localPlayer, "user:hud_disabled", false)

    showCursor(false)

    toggleControl("enter_exit", true)

    if(getElementHealth(vehicle) < 1000)then
        return
    end

    local uid=getElementData(localPlayer, "user:uid")    
    local owner=getElementData(vehicle, "vehicle:owner") or getElementData(vehicle, "vehicle:liderUID")
    if(not uid or not owner or (owner and owner ~= uid))then 
        return 
    end

    local t,categories=ui.getVehicleComponentsList(vehicle)
    local tbl=t[categories[ui.selected]]
    if(tbl)then
        setElementData(vehicle, "vehicle:client_components", false, false)
        exports.px_components:setVehicleClientComponent(vehicle)

        setElementData(vehicle, "vehicle:components", ui.vehicleComponents or {})
    end
end

-- triggers

addEvent("buy.component", true)
addEventHandler("buy.component", resourceRoot, function(info)
    local veh=getPedOccupiedVehicle(localPlayer)
    if(not veh)then ui.destroy() return end
    
    local data=exports.px_components:addVehicleComponent(veh, info.name)
    if(data)then
        triggerServerEvent('update.components', resourceRoot, veh, data)
    end

    ui.vehicleComponents=getElementData(veh, "vehicle:components") or {}
    setElementData(veh, "vehicle:client_components", ui.vehicleComponents, false)
    exports.px_components:addVehicleClientComponent(veh, info.name)
    exports.px_components:setVehicleClientComponent(veh)
end)

addEvent("open.ui", true)
addEventHandler("open.ui", resourceRoot, function()
    ui.create()
end)

addEvent("destroy.ui", true)
addEventHandler("destroy.ui", resourceRoot, function()
    ui.destroy()
end)

-- useful

ui.applyClientComponent=function(veh, name)
    setElementData(veh, "vehicle:client_components", ui.vehicleComponents, false)
    exports.px_components:addVehicleClientComponent(veh, name)
    exports.px_components:setVehicleClientComponent(veh)
end

ui.getVehicleComponentsList=function(vehicle)
    local data=getElementData(vehicle, "vehicle:components") or {}
    if(#data < 1)then
        data={"Podstawowy"}
    end

    local t=exports.px_components:getVehicleComponents(vehicle) or {}
    local categories={}

    local mx=getElementData(vehicle, "vehicle:group_owner") and 2 or 1

    for i,v in pairs(t) do
        if(i ~= "Interakcja")then
            categories[#categories+1]=i
            for componentName,c in pairs(v) do
                for _,dataName in pairs(data) do
                    if(componentName == dataName)then
                        t[i][componentName].have=true
                    end
                    t[i][componentName].cost=(c.cost or 0)*mx
                end
            end
        end
    end

    return t, categories
end

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
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
	if(not isCursorShowing() or ui.animate)then return end

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