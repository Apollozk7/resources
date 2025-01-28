--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local sx,sy=guiGetScreenSize()

-- core functions

local scroll={}

scroll.scrolls={}
scroll.showed=false
scroll.resources={}

scroll.createScroll=function(x, y, w, h, row, showed, tbl, height, alpha, plus, strefa, postGUI, maxPos, rtHeight, nextHeight, animate)
    local id=#scroll.scrolls+1
    scroll.scrolls[id]={
        pos={x,y,w,height},
        startRow=row or 0,
        visibledRows=showed,
        alpha=alpha or 255,
        plus=plus or 1,
        strefa=strefa or {0,0,sx,sy},
        postGUI=postGUI,
        posY=0,
        maxRows=(tbl and #tbl or 1)-showed,
        maxVisibledRows=tbl and #tbl or 1,
        clicked=false,
        maxPos=maxPos,
        rtHeight=rtHeight,
        nextHeight=nextHeight,
        animate=animate
    }

    if(tbl)then
        local row_height=scroll.scrolls[id].pos[4]/#tbl
        scroll.scrolls[id].height=row_height*(showed/2)
        scroll.scrolls[id].maxPos=1
        scroll.scrolls[id].rtHeight=0
    else
        scroll.scrolls[id].maxRows=1
        scroll.scrolls[id].visibledRows=0
        scroll.scrolls[id].height=nextHeight
    end

    if(not scroll.showed)then
        addEventHandler("onClientRender", root, scroll.onRender)
        addEventHandler("onClientKey", root, scroll.onKey)

        scroll.showed=true
    end

    if(sourceResource)then
        if(not scroll.resources[sourceResource])then
            scroll.resources[sourceResource]={}
        end

		scroll.resources[sourceResource][#scroll.resources[sourceResource]+1]=id
		addEventHandler("onClientResourceStop", getResourceRootElement(sourceResource), function(resource)
            if(scroll.resources[resource])then
                for i,v in pairs(scroll.resources[resource]) do
                    scroll.destroyScroll(v)
                end
                scroll.resources[resource]=nil
            end
		end)
	end

    return id
end

scroll.destroyScroll=function(id)
    if(scroll.scrolls[id])then
        scroll.scrolls[id]=nil

        if(#scroll.scrolls < 1 and scroll.showed)then
            removeEventHandler("onClientRender", root, scroll.onRender)
            removeEventHandler("onClientKey", root, scroll.onKey)
    
            scroll.showed=false
        end
    end
end

-- events

scroll.onRender=function()
    for i,v in pairs(scroll.scrolls) do
        if(v.maxVisibledRows > v.visibledRows and v.rtHeight < v.maxPos)then
            if(v.heightAnimate)then
                v.posY=interpolateBetween(v.lastY, 0, 0, v.newY, 0, 0, (getTickCount()-v.heightAnimate)/250, "InOutQuad")
                if((getTickCount()-v.heightAnimate) > 250)then
                    v.posY=v.newY
                    v.heightAnimate=nil
                    v.lastY=nil
                    v.newY=nil
                end
            end

            local px=1
            dxDrawRectangle(v.pos[1], v.pos[2], v.pos[3], v.pos[4], tocolor(51,51,51, v.alpha), v.postGUI)
            dxDrawRectangle(v.pos[1]+px, v.pos[2]+v.posY+px, v.pos[3]-(px*2), v.height-(px*2), tocolor(178,175,175, v.alpha), v.postGUI)
            
            if(v.clicked)then
                local cx,cy=getCursorPosition()
                cx,cy=cx*sx,cy*sy
                
                local nc=cy-v.pos[2]-v.height/2
                local max=(v.pos[4]-v.height)
                
                nc=nc < 0 and 0 or nc
                nc=nc > max and max or nc
            
                v.posY=nc
            end
            
            if(getKeyState("mouse1") and not v.clicked and isMouseInPosition(v.pos[1], v.pos[2], v.pos[3], v.pos[4]))then
                v.clicked=true
            elseif(not getKeyState("mouse1") and v.clicked)then
                v.clicked=false
            end
        end
    end
end

scroll.onKey=function(key, press)
    if(not press)then return end

    if(key == "mouse_wheel_up")then
        for i,v in pairs(scroll.scrolls) do
            if(isMouseInPosition(unpack(v.strefa)) and v.maxVisibledRows > v.visibledRows and v.rtHeight < v.maxPos and not v.heightAnimate)then
                local plus=v.nextHeight and v.nextHeight/2 or math.round((v.pos[4]-v.height)/(v.maxRows/v.plus))
                local nc=(v.newY or v.posY)-plus

                nc=math.floor(nc)
                nc=nc < 0 and 0 or nc
                if(v.posY > nc)then
                    if(v.animate)then
                        v.posY=nc
                    else
                        v.heightAnimate=getTickCount()
                        v.lastY=(v.newY or v.posY)
                        v.newY=nc
                    end
                end
            end
        end
    elseif(key == "mouse_wheel_down")then
        for i,v in pairs(scroll.scrolls) do
            if(isMouseInPosition(unpack(v.strefa)) and v.maxVisibledRows > v.visibledRows and v.rtHeight < v.maxPos and not v.heightAnimate)then
                local plus=v.nextHeight and v.nextHeight/2 or math.round((v.pos[4]-v.height)/(v.maxRows/v.plus))
                local max=(v.pos[4]-v.height)
                local nc=(v.newY or v.posY)+plus

                nc=math.floor(nc)
                nc=nc > max and max or nc
                if(v.posY < nc)then
                    if(v.animate)then
                        v.posY=nc
                    else
                        v.heightAnimate=getTickCount()
                        v.lastY=(v.newY or v.posY)
                        v.newY=nc
                    end
                end
            end
        end
    end
end

-- functions

scroll.setPosition=function(id,pos)
    if(scroll.scrolls[id])then
        scroll.scrolls[id].pos[1]=pos[1]
        scroll.scrolls[id].pos[2]=pos[2]
        scroll.scrolls[id].posY=0
    end
end

scroll.getActuallyRow=function(id)
    if(scroll.scrolls[id])then
        if(scroll.scrolls[id].maxVisibledRows > scroll.scrolls[id].visibledRows)then
            return scroll.scrolls[id].maxRows * ( scroll.scrolls[id].posY / ( scroll.scrolls[id].pos[4]-scroll.scrolls[id].height ) )
        else
            return 0
        end
    end
    return 0
end

scroll.getActuallyPosition=function(id)
    if(scroll.scrolls[id])then
        if(scroll.scrolls[id].rtHeight > scroll.scrolls[id].maxPos)then
            return 0
        else
            return (scroll.scrolls[id].maxPos-scroll.scrolls[id].rtHeight) * ( scroll.scrolls[id].posY / ( scroll.scrolls[id].pos[4]-scroll.scrolls[id].height ) )
        end
    end
    return 0
end

scroll.updateTable=function(id, tbl)
    if(scroll.scrolls[id] and scroll.pos and scroll.pos[4])then
        scroll.scrolls[id].maxRows=#tbl-scroll.scrolls[id].visibledRows
        local row_height=scroll.pos[4]/#tbl
        scroll.scrolls[id].height=row_height*(scroll.scrolls[id].visibledRows/2)
    end
end

scroll.updateRTSize=function(id,size)
    if(scroll.scrolls[id])then
        scroll.scrolls[id].maxPos=size
    end
end

scroll.setAlpha=function(id, a)
    if(scroll.scrolls[id])then
        scroll.scrolls[id].alpha=a
    end
end

-- export functions

function dxCreateScroll(...)
    return scroll.createScroll(...)
end

function dxDestroyScroll(id)
    return scroll.destroyScroll(id)
end

function dxScrollGetPosition(id)
    return scroll.getActuallyRow(id)
end

function dxScrollSetPosition(id,pos)
    return scroll.setPosition(id,pos)
end

function dxScrollUpdateTable(...)
    return scroll.updateTable(...)
end

function dxScrollSetAlpha(id, alpha)
    return scroll.setAlpha(id, alpha)
end

function dxScrollGetRTPosition(id)
    return scroll.getActuallyPosition(id)
end

function dxScrollUpdateRTSize(...)
    return scroll.updateRTSize(...)
end

-- useful

function math.round(number)
    local _, decimals = math.modf(number)
    if decimals < 0.5 then return math.floor(number) end
    return math.ceil(number)
end

-- test create
--[[
local rt=dxCreateRenderTarget(500,500,true)

local row=0
function updateRT()
    local scrollPos=dxScrollGetRTPosition(id) or 0

    dxSetRenderTarget(rt, true)
        dxDrawRectangle(0,0,500,500,tocolor(0,0,0,200))

        local max=0
        for i=1,20 do
            local sY=100*(i-1)

            dxDrawRectangle(0,sY-scrollPos,500,98,tocolor(255,0,0,100))
            dxDrawText(i, 0,sY-scrollPos,500,98)

            max=max+100
        end
    dxSetRenderTarget()

    scroll.updateRTSize(id,max)
end
updateRT()

addEventHandler("onClientRender", root, function()
    local scrollPos=dxScrollGetRTPosition(id) or 0
    if(row ~= scrollPos)then
        row=scrollPos
        updateRT()
    end

    dxDrawImage(sx/2-500/2, sy/2-500/2, 500, 500, rt)
end)

id=scroll.createScroll(sx/2-500/2+500+4, sy/2-500/2, 4, 0, 0, 1, false, 500, 255, 0, false, false, 0, 500, 60)
showCursor(true,false)
]]
-- useful

function isMouseInPosition(x, y, w, h)
	if not isCursorShowing() then return end

	local pos = {getCursorPosition()}
	pos[1], pos[2] = (pos[1] * sx), (pos[2] * sy)

	if pos[1] >= x and pos[1] <= (x + w) and pos[2] >= y and pos[2] <= (y + h) then
		return true
	end
	return nil
end