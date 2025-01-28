--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local sw,sh=guiGetScreenSize()
local zoom=1920/sw

local font=dxCreateFont(":px_assets/fonts/Font-Medium.ttf", 13/zoom)

-- variables

CLASS={}

CLASS.barriers={
    ["SAPD"]={
        {1228, -0.5},
        {1238, -0.7},
        {1434, -1},
        {2892, -1, 5, 90},
        
        {"znak_dui"},
        {"znak1", -0.3},
        {"znak2", -0.3},
        {"znak3", -0.3},

        {"trojkat_ostrzegawczy", -0.55},
    },

    ["SARA"]={
        {1238, -0.7},
        {1434, -1},
        {1459, -0.38},

        {"znak1", -0.3},
        {"znak2", -0.3},
        {"znak3", -0.3},

        {"A-14a", -1},
        {"A-30", -1},

        {"trojkat_ostrzegawczy", -0.55},

        {1428,0.5},
        {1437,-1},
    },

    ["PSP"]={
        {"parawanpsp", -0.15, 0, 0, 90},
        {"trojkat_ostrzegawczy", -0.55},

        {1238, -0.7},

        {"znak1", -0.3},
        {"znak2", -0.3},
        {"znak3", -0.3},
    },
}

CLASS.index=1
CLASS.have=false
CLASS.object=false

CLASS.getObject=function(list)
    if(CLASS.object and isElement(CLASS.object))then
        destroyElement(CLASS.object)
    end

    CLASS.object=createObject(tonumber(list[CLASS.index][1]) and list[CLASS.index][1] or 1337, 0, 0, 0)
    if(not tonumber(list[CLASS.index][1]))then
        setElementData(CLASS.object, "custom_name", list[CLASS.index][1])
    end

    attachElements(CLASS.object, localPlayer, 0, 1.25+(list[CLASS.index][3] or 0), list[CLASS.index][2], list[CLASS.index][5] or 0, 0, 90+(list[CLASS.index][4] or 0))

    setElementAlpha(CLASS.object, 150)
    setElementCollisionsEnabled(CLASS.object, false)
end

CLASS.onRender=function()
    local barriers=getElementData(localPlayer, "faction:objects") or 0
    local info="F7 - anuluj\nLPM - postaw obiekt\nPPM - usuń ostatni obiekt\nInterakcja (E) - więcej opcji\nMaksymalnie 100 blokad"
    dxDrawText(info, 1, 1, sw+1, sh-15/zoom+1, tocolor(0, 0, 0), 1, font, "right", "bottom")
    dxDrawText(info, 0, 0, sw, sh-15/zoom, tocolor(200, 200, 200), 1, font, "right", "bottom")

    toggleControl("fire",false)
end

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

CLASS.key=function(key, press)
    if(press)then
        local faction=getElementData(localPlayer, "user:faction")
        if(not faction or isCursorShowing())then return end
        local list=CLASS.barriers[faction]
        if(not list or isPedInVehicle(localPlayer))then return end

        if(key == "mouse1")then
            if(SPAM.getSpam())then return end

            local pos={getElementPosition(CLASS.object)}
            local rot={getElementRotation(CLASS.object)}
            triggerServerEvent("create:object", resourceRoot, getElementData(CLASS.object, "custom_name") or getElementModel(CLASS.object), pos, rot)
        elseif(key == "mouse2")then
            if(SPAM.getSpam())then return end

            triggerServerEvent("destroy:last:object", resourceRoot)
        elseif(key == "mouse_wheel_up")then
            local k=CLASS.index+1
            if(list[k])then
                CLASS.index=k
                CLASS.getObject(list)
            end
        elseif(key == "mouse_wheel_down")then
            local k=CLASS.index-1
            if(list[k])then
                CLASS.index=k
                CLASS.getObject(list)
            end
        end
    end
end

-- bind

bindKey("F7", "down", function()
    local faction=getElementData(localPlayer, "user:faction")
    if(not faction or isCursorShowing() or isPedInVehicle(localPlayer))then return end

    local list=CLASS.barriers[faction]
    if(list)then
        CLASS.have=not CLASS.have
        if(not CLASS.have)then
            destroyElement(CLASS.object)
            CLASS.object=false

            removeEventHandler("onClientKey", root, CLASS.key)
            removeEventHandler("onClientRender", root, CLASS.onRender)
        else
            CLASS.index=1
            CLASS.getObject(list)

            addEventHandler("onClientKey", root, CLASS.key)
            addEventHandler("onClientRender", root, CLASS.onRender)
        end
    end
end)

-- event

addEvent("setBreakable", true)
addEventHandler("setBreakable", resourceRoot, function(object)
	setObjectBreakable(object, false)
end)

-- quiver

local info={}
local wheels={"wheel_lf_dummy", "wheel_lb_dummy", "wheel_rf_dummy", "wheel_rb_dummy"}

function render()
    if(#info < 4)then return end

    local o={getVehicleWheelStates(info[4])}
    for i,v in pairs(wheels) do
        local x1,y1,z1 = getVehicleComponentPosition(info[4], v, "world")
        local dist=getDistanceBetweenPoints3D(info[1], info[2], info[3], x1, y1, z1)
        if(dist < 3)then
            o[i]=1
        end
    end
    setVehicleWheelStates(info[4], unpack(o))
end

addEvent("hit:quiver", true)
addEventHandler("hit:quiver", resourceRoot, function(x, y, z, veh)
    if(x and y and z)then
        info={x,y,z,veh}
        addEventHandler("onClientRender", root, render)
    else
        info={}
        removeEventHandler("onClientRender", root, render)
    end
end)