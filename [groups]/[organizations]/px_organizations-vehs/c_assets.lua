--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

-- global variables

sw,sh=guiGetScreenSize()
zoom=1920/sw

-- exports

noti=exports.px_noti
blur=exports.blur
btns=exports.px_buttons
scroll=exports.px_scroll
avatars=exports.px_avatars

-- variables

ui={}

ui.btns={}
ui.scroll=false
ui.rt=false
ui.logo=false
ui.selected=false
ui.scrollPosition=0

ui.info={}

ui.clicks={}

ui.pos={
    {
        "blur", -- type
        {sw/2-689/2/zoom, sh/2-586/2/zoom, 689/zoom, 586/zoom}, -- pos
    },

    {
        "image", -- type
        {sw/2-689/2/zoom, sh/2-586/2/zoom, 689/zoom, 586/zoom}, -- pos
        1, -- texture id
    },

    {
        "text",
        "Udostępnianie pojazdów",
        {sw/2-689/2/zoom, sh/2-586/2/zoom, sw/2-689/2/zoom+689/zoom, sh/2-586/2/zoom+53/zoom},
        1, -- font id
        "center", "center"
    },

    {
        "image", -- type
        {sw/2-689/2/zoom+689/zoom-10/zoom-(53-10)/2/zoom, sh/2-586/2/zoom+(53-10)/2/zoom, 10/zoom, 10/zoom}, -- pos
        2, -- texture id
        function()
            ui.info={}
            ui.clicks={}
        
            removeEventHandler("onClientRender", root, ui.onRender)
        
            showCursor(false)
        
            setElementData(localPlayer, "user:gui_showed", false)

            assets.destroy()

            destroyElement(ui.rt)
            ui.rt=false

            scroll:dxDestroyScroll(ui.scroll)

            for i,v in pairs(ui.btns) do
                btns:destroyButton(v)
            end
            ui.btns={}
        end,
    },

    {
        "rec",
        {sw/2-607/2/zoom, sh/2-586/2/zoom+53/zoom, 607/zoom, 1},
        {80,80,80}
    },

    {
        "image",
        {sw/2-689/2/zoom, sh/2-586/2/zoom+53/zoom+1, 689/zoom, 27/zoom},
        3
    },
    {
        "text",
        "Model",
        {sw/2-689/2/zoom+61/zoom, sh/2-586/2/zoom+53/zoom+1, 689/zoom, sh/2-586/2/zoom+53/zoom+1+27/zoom},
        2,
        "left", "center"
    },
    {
        "text",
        "ID",
        {sw/2-689/2/zoom+61/zoom+188/zoom, sh/2-586/2/zoom+53/zoom+1, 689/zoom, sh/2-586/2/zoom+53/zoom+1+27/zoom},
        2,
        "left", "center"
    },
    {
        "text",
        "Przebieg",
        {sw/2-689/2/zoom+61/zoom+380/zoom, sh/2-586/2/zoom+53/zoom+1, 689/zoom, sh/2-586/2/zoom+53/zoom+1+27/zoom},
        2,
        "left", "center"
    },

    {
        "rt",
        {math.floor(sw/2-689/2/zoom), math.floor(sh/2-586/2/zoom+82/zoom), math.floor(689/zoom), math.floor((586-82)/zoom)},
    }
}

-- main variables

assets={
    fonts={},
    fonts_paths={
        {":px_assets/fonts/Font-Medium.ttf", 15},
        {":px_assets/fonts/Font-Regular.ttf", 12},
        {":px_assets/fonts/Font-Medium.ttf", 13},
    },

    textures={},
    textures_paths={
        "textures/bg.png",
        "textures/close.png",
        "textures/grid.png",

        "textures/row.png",
        "textures/car.png",
        "textures/plus.png",
        "textures/minus.png",
        "textures/subgrid.png",
        "textures/subrow.png",
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

-- useful

function createButton(x,y,w,h,name,alpha,size,_,_,_,color)
    local p={ui.pos[#ui.pos][2][1], ui.pos[#ui.pos][2][2], ui.pos[#ui.pos][2][3], ui.pos[#ui.pos][2][4]}
    if((y < (p[2]+p[4]-h)) and y > p[2])then
        return btns:createButton(x,y,w,h,name,alpha,size,_,_,_,color)
    end
    return false
end

function buttonSetPosition(id,pos)
    local p={ui.pos[#ui.pos][2][1], ui.pos[#ui.pos][2][2], ui.pos[#ui.pos][2][3], ui.pos[#ui.pos][2][4]}
    if((pos[2] < (p[2]+p[4]-pos[4])) and pos[2] > p[2])then
        btns:buttonSetAlpha(ui.btns[id],255)
        btns:buttonSetPosition(ui.btns[id],pos)
    else
        btns:buttonSetAlpha(ui.btns[id],0)
    end
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
    end
end)