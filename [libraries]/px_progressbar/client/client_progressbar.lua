--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local PG={}

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

PG.progress={0,0,0,0,"(?)"}

PG.font=false
PG.texs={}
PG.x=0
PG.w=0
PG.tick=getTickCount()
PG.time=false
PG.a=0

PG.onRender=function()
    PG.progress[8]=PG.progress[8] > 100 and 100 or PG.progress[8]
    
    local time="0"
    local h=dxGetFontHeight(1, PG.font)/2
    if(PG.progress[7])then
        PG.w=PG.progress[3]*(PG.progress[8]/100)
    else
        PG.w=interpolateBetween(0, 0, 0, PG.progress[3], 0, 0, (getTickCount()-PG.tick)/PG.progress[6], "Linear")
        time=math.floor(100*((getTickCount()-PG.tick)/PG.progress[6])).."%"

        dxDrawText(time, PG.progress[1]+1, PG.progress[2]-21/zoom-h+1, PG.progress[3]+PG.progress[1]+1, PG.progress[4]+PG.progress[2]+h+16/zoom, tocolor(0, 0, 0, 255), 1, PG.font2, "right", "bottom", false)
        dxDrawText(time, PG.progress[1], PG.progress[2]-21/zoom-h, PG.progress[3]+PG.progress[1], PG.progress[4]+PG.progress[2]+h+16/zoom, tocolor(145, 145, 145, 255), 1, PG.font2, "right", "bottom", false)    
    end

    dxDrawText(PG.progress[5], PG.progress[1]+1, PG.progress[2]-21/zoom-h+1, PG.progress[3]+PG.progress[1]+1, PG.progress[4]+PG.progress[2]-21/zoom-h+1, tocolor(0, 0, 0, 255), 1, PG.font, "center", "center", false)
    dxDrawText(PG.progress[5], PG.progress[1], PG.progress[2]-21/zoom-h, PG.progress[3]+PG.progress[1], PG.progress[4]+PG.progress[2]-21/zoom-h, tocolor(145, 145, 145, 255), 1, PG.font, "center", "center", false)    

    dxDrawImage(PG.progress[1], PG.progress[2], PG.progress[3], PG.progress[4], PG.texs[1], 0, 0, 0, tocolor(255, 255, 255, 255), false)
    dxDrawImage(PG.progress[1], PG.progress[2], PG.w, PG.progress[4], PG.texs[2], 0, 0, 0, tocolor(255, 255, 255, 255), false)

    if(PG.time)then
        PG.a=interpolateBetween(0, 0, 0, 255, 0, 0, (getTickCount()-PG.time)/500, "Linear")
    end
        
    local h=53/zoom
    local w=PG.progress[3]/2.8
    if(PG.w > w)then
        if(not PG.time)then
            PG.time=getTickCount()
        end
        
        dxDrawImage(PG.progress[1]+PG.w-PG.progress[3]+w, PG.progress[2]+(PG.progress[4]-h)/2, PG.progress[3], h, PG.texs[3], 0, 0, 0, tocolor(255, 255, 255, PG.a))
    end
end

function updateProgressbar(text,progress)
    PG.progress[5]=text
    PG.progress[8]=progress
end

function createProgressbar(x,y,w,h,text,fontSize,time,downloading,progress)
    if(PG.font)then return end

    addEventHandler("onClientRender", root, PG.onRender)

    PG.tick=getTickCount()
    PG.progress={x,y,w,h,text,time,downloading,progress}
    PG.font=dxCreateFont(":px_assets/fonts/Font-SemiBold.ttf", fontSize)
    PG.font2=dxCreateFont(":px_assets/fonts/Font-Regular.ttf", fontSize)
    PG.texs={
        dxCreateTexture("assets/images/back.png", "argb", false, "clamp"),
        dxCreateTexture("assets/images/progress.png", "argb", false, "clamp"),
        dxCreateTexture("assets/images/progress2.png", "argb", false, "clamp"),
    }

    setElementData(localPlayer, "user:progress_bar", true, false)
end

function destroyProgressbar()
    removeEventHandler("onClientRender", root, PG.onRender)

    PG.progress={}

    if(PG.font and isElement(PG.font))then
        destroyElement(PG.font)
    end

    if(PG.font2 and isElement(PG.font2))then
        destroyElement(PG.font2)
    end

    for i,v in pairs(PG.texs) do
        if(v and isElement(v))then
            destroyElement(v)
        end
    end

    PG.texs={}
    PG.font=false

    setElementData(localPlayer, "user:progress_bar", false, false)
end