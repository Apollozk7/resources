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

local ui={}

-- assets

local assets={}
assets.list={
    texs={
        "textures/circle.png",

        "textures/arrow_up.png",
        "textures/arrow_up_light.png",
        "textures/arrow_down.png",
        "textures/arrow_down_light.png",

        "textures/wheel_width.png",
        "textures/wheel_offset.png",
        "textures/wheel_negative.png",
        "textures/wheel_color.png",
    
        "textures/space_button.png",
        "textures/space_button_light.png",

        "textures/right_button.png",
        "textures/right_button_light.png",
        "textures/middle_bg.png",
        "textures/enter_button.png",
        "textures/x_button.png",
    
        "textures/elipse.png",
        "textures/elipse_border.png",
    },

    fonts={
        {"Regular", 20},
        {"Bold", 15},
        {"Regular", 15},
        {"Regular", 13},
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

function dxDrawShadowText(text,x,y,w,h,color,size,font,alignX,alignY)
    dxDrawText(text,x+1,y+1,w+1,h+1,tocolor(0,0,0),size,font,alignX,alignY)
    dxDrawText(text,x,y,w,h,color,size,font,alignX,alignY)
end

function dxDrawBlurImage(x,y,w,h,tex,rx,ry,rz,color)
    e_blur:dxDrawBlur(x,y,w,h,color)
    dxDrawImage(x,y,w,h,tex,rx,ry,rz,color)
end

-- variables

ui.blur=false
ui.savedData={}
ui.optionMenu=1
ui.selectedMenu=false

ui.refreshOptions=function()
    for i,v in pairs(ui.menu) do
        if(v.info)then
            for i,v in pairs(v.info) do
                v.selected=0
            end
        end

        if(v.info)then
            for i,v in pairs(v.info) do
                v.selected=0
            end
        end
    end
end

ui.setOption=function(veh, name, values, type, infoName, colors)
    local data=getElementData(veh, "vehicle:wheelsSettings") or {}
    if(veh and isElement(veh) and name and values)then
        if(infoName ~= "Kolory felg" and not data[name])then
            data[name]={0,0,0,0}

            values=string.format("%.2f", values)
        elseif(infoName == "Kolory felg" and not data.color)then
            data.color={
                felga={255,255,255},
                hamulec={255,255,255},
                szprycha={255,255,255},
                tarcza={255,255,255}
            }
        end

        values=tonumber(values)

        if(type == "top")then
            data[name][1]=values
            data[name][2]=values
        elseif(type == "bottom")then
            data[name][3]=values
            data[name][4]=values
        else
            data.color[type]=colors[values].rgb
        end

        setElementData(veh, "vehicle:wheelsSettings", data, false)
    end
end

ui.menu={
    {x=60/zoom, name="Poszerzanie kół", icon=6, keys={["enter"]="save",["arrow_u"]=1,["arrow_d"]=-1,["x"]="back",["arrow_r"]={"info","selected",0.1,1,-1,"size","info","selected"},["arrow_l"]={"info","selected",-0.1,1,-1,"size","info","selected"}}, selected=1, maxSelected=2, 

    info={
        {name="Poszerzanie kół przedniej osi", selected=0, cost=7500, type="top"},
        {name="Poszerzanie kół tylnej osi", selected=0, cost=7500, type="bottom"},
    }, 

    render=function(self)
        -- back
        dxDrawBlurImage(27/zoom, sh-260/zoom, 49/zoom, 49/zoom, assets.textures[16])
        dxDrawShadowText("POWRÓT", 27/zoom+58/zoom, sh-260/zoom, 49/zoom, 49/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
        dxDrawShadowText("do kategorii", 27/zoom+58/zoom, sh-260/zoom, 49/zoom, sh-260/zoom+49/zoom, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "bottom")
        --

        for i,v in pairs(self.info) do
            local sY=(75/zoom)*(i-1)

            local c=self.selected == i and {100,175,114} or {200,200,200}
            local a=self.selected == i and 0 or 125
            dxDrawShadowText(v.name, 27/zoom+49/zoom-1, sh-195/zoom+sY, 493/zoom+27/zoom+49/zoom-1, 49/zoom, tocolor(200, 200, 200, 255-a), 1, assets.fonts[4], "center", "top")
            dxDrawBlurImage(27/zoom, sh-171/zoom+sY, 49/zoom, 49/zoom, (self.selected == i and getKeyState("arrow_l")) and assets.textures[13] or assets.textures[12], 180, 0, 0, tocolor(255, 255, 255, 255-a))
            dxDrawBlurImage(27/zoom+49/zoom-1, sh-171/zoom+sY, 493/zoom, 49/zoom, assets.textures[14], 0, 0, 0, tocolor(255, 255, 255, 255-a))
            dxDrawBlurImage(27/zoom+493/zoom+49/zoom-2, sh-171/zoom+sY, 49/zoom, 49/zoom, (self.selected == i and getKeyState("arrow_r")) and assets.textures[13] or assets.textures[12], 0, 0, 0, tocolor(255, 255, 255, 255-a))
    
            dxDrawRectangle(27/zoom+49/zoom-1+6/zoom, sh-171/zoom+(49-2)/2/zoom+sY, 493/zoom-12/zoom, 2, tocolor(49,51,49,255-a))
            dxDrawRectangle(27/zoom+49/zoom-1+6/zoom+(493/zoom-12/zoom)/2-1, sh-171/zoom+(49-2)/2/zoom-(12)/2/zoom+1+sY, 2, 12/zoom, tocolor(49,51,49,255-a))

            local progress=(v.selected+1)*50
            dxDrawRectangle(27/zoom+49/zoom-1+6/zoom, sh-171/zoom+(49-2)/2/zoom+sY, (493/zoom-12/zoom)*(progress/100), 2, tocolor(c[1],c[2],c[3],255-a))
            dxDrawRectangle(27/zoom+49/zoom-1+6/zoom+(493/zoom-12/zoom)*(progress/100), sh-171/zoom+(49-2)/2/zoom-(12)/2/zoom+1+sY, 2, 12/zoom, tocolor(c[1],c[2],c[3],255-a))

            if(self.selected == i)then
                local veh=getPedOccupiedVehicle(localPlayer)
                local cost=v.cost
                local org=getElementData(veh, "vehicle:liderUID")
                if(org)then
                    cost=cost*2
                end

                dxDrawBlurImage(27/zoom+493/zoom+49/zoom+49/zoom+14/zoom, sh-171/zoom+sY, 119/zoom, 49/zoom, assets.textures[15], 0, 0, 0, tocolor(255, 255, 255, 255-a))
                dxDrawShadowText("KUP", 27/zoom+493/zoom+49/zoom+49/zoom+14/zoom+9/zoom+119/zoom, sh-171/zoom+sY, 49/zoom, 49/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
                dxDrawText("$"..cost, 27/zoom+493/zoom+49/zoom+49/zoom+14/zoom+9/zoom+119/zoom+1, sh-171/zoom+1+sY, 49/zoom+1, sh-171/zoom+49/zoom+1+sY, tocolor(0, 0, 0), 1, assets.fonts[3], "left", "bottom")
                dxDrawText("#65ad69$#cdcdcd"..cost, 27/zoom+493/zoom+49/zoom+49/zoom+14/zoom+9/zoom+119/zoom, sh-171/zoom+sY, 49/zoom, sh-171/zoom+49/zoom+sY, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "bottom", false, false, false, true)
            end
        end
    end},

    {x=88/zoom, name="Odstęp osiowy", icon=7, keys={["enter"]="save",["arrow_u"]=1,["arrow_d"]=-1,["x"]="back",["arrow_r"]={"info","selected",0.1,1,-1,"axis","info","selected"},["arrow_l"]={"info","selected",-0.1,1,-1,"axis","info","selected"}}, selected=1, maxSelected=2, 

    info={
        {name="Odstęp kół przedniej osi", selected=0, cost=7500, type="top"},
        {name="Odstęp kół tylnej osi", selected=0, cost=7500, type="bottom"},
    }, 
    
    render=function(self)
        -- back
        dxDrawBlurImage(27/zoom, sh-260/zoom, 49/zoom, 49/zoom, assets.textures[16])
        dxDrawShadowText("POWRÓT", 27/zoom+58/zoom, sh-260/zoom, 49/zoom, 49/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
        dxDrawShadowText("do kategorii", 27/zoom+58/zoom, sh-260/zoom, 49/zoom, sh-260/zoom+49/zoom, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "bottom")
        --

        for i,v in pairs(self.info) do
            local sY=(75/zoom)*(i-1)

            local c=self.selected == i and {100,175,114} or {200,200,200}
            local a=self.selected == i and 0 or 125
            dxDrawShadowText(v.name, 27/zoom+49/zoom-1, sh-195/zoom+sY, 493/zoom+27/zoom+49/zoom-1, 49/zoom, tocolor(200, 200, 200, 255-a), 1, assets.fonts[4], "center", "top")
            dxDrawBlurImage(27/zoom, sh-171/zoom+sY, 49/zoom, 49/zoom, (self.selected == i and getKeyState("arrow_l")) and assets.textures[13] or assets.textures[12], 180, 0, 0, tocolor(255, 255, 255, 255-a))
            dxDrawBlurImage(27/zoom+49/zoom-1, sh-171/zoom+sY, 493/zoom, 49/zoom, assets.textures[14], 0, 0, 0, tocolor(255, 255, 255, 255-a))
            dxDrawBlurImage(27/zoom+493/zoom+49/zoom-2, sh-171/zoom+sY, 49/zoom, 49/zoom, (self.selected == i and getKeyState("arrow_r")) and assets.textures[13] or assets.textures[12], 0, 0, 0, tocolor(255, 255, 255, 255-a))
            
            dxDrawRectangle(27/zoom+49/zoom-1+6/zoom, sh-171/zoom+(49-2)/2/zoom+sY, 493/zoom-12/zoom, 2, tocolor(49,51,49,255-a))
            dxDrawRectangle(27/zoom+49/zoom-1+6/zoom+(493/zoom-12/zoom)/2-1, sh-171/zoom+(49-2)/2/zoom-(12)/2/zoom+1+sY, 2, 12/zoom, tocolor(49,51,49,255-a))
            
            local progress=(v.selected+1)*50
            dxDrawRectangle(27/zoom+49/zoom-1+6/zoom, sh-171/zoom+(49-2)/2/zoom+sY, (493/zoom-12/zoom)*(progress/100), 2, tocolor(c[1],c[2],c[3],255-a))
            dxDrawRectangle(27/zoom+49/zoom-1+6/zoom+(493/zoom-12/zoom)*(progress/100), sh-171/zoom+(49-2)/2/zoom-(12)/2/zoom+1+sY, 2, 12/zoom, tocolor(c[1],c[2],c[3],255-a))
    
            if(self.selected == i)then
                local veh=getPedOccupiedVehicle(localPlayer)
                local cost=v.cost
                local org=getElementData(veh, "vehicle:liderUID")
                if(org)then
                    cost=cost*2
                end

                dxDrawBlurImage(27/zoom+493/zoom+49/zoom+49/zoom+14/zoom, sh-171/zoom+sY, 119/zoom, 49/zoom, assets.textures[15], 0, 0, 0, tocolor(255, 255, 255, 255-a))
                dxDrawShadowText("KUP", 27/zoom+493/zoom+49/zoom+49/zoom+14/zoom+9/zoom+119/zoom, sh-171/zoom+sY, 49/zoom, 49/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
                dxDrawText("$"..cost, 27/zoom+493/zoom+49/zoom+49/zoom+14/zoom+9/zoom+119/zoom+1, sh-171/zoom+1+sY, 49/zoom+1, sh-171/zoom+49/zoom+1+sY, tocolor(0, 0, 0), 1, assets.fonts[3], "left", "bottom")
                dxDrawText("#65ad69$#cdcdcd"..cost, 27/zoom+493/zoom+49/zoom+49/zoom+14/zoom+9/zoom+119/zoom, sh-171/zoom+sY, 49/zoom, sh-171/zoom+49/zoom+sY, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "bottom", false, false, false, true)
            end
        end
    end},

    {x=88/zoom, name="Negatyw kół", icon=8, keys={["enter"]="save",["arrow_u"]=1,["arrow_d"]=-1,["x"]="back",["arrow_r"]={"info","selected",0.1,1,-1,"rot","info","selected"},["arrow_l"]={"info","selected",-0.1,1,-1,"rot","info","selected"}}, selected=1, maxSelected=2, 

    info={
        {name="Negatyw kół przedniej osi", selected=0, cost=7500, type="top"},
        {name="Negatyw kół tylnej osi", selected=0, cost=7500, type="bottom"},
    },
    
    render=function(self)
        -- back
        dxDrawBlurImage(27/zoom, sh-260/zoom, 49/zoom, 49/zoom, assets.textures[16])
        dxDrawShadowText("POWRÓT", 27/zoom+58/zoom, sh-260/zoom, 49/zoom, 49/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
        dxDrawShadowText("do kategorii", 27/zoom+58/zoom, sh-260/zoom, 49/zoom, sh-260/zoom+49/zoom, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "bottom")
        --
        
        for i,v in pairs(self.info) do
            local sY=(75/zoom)*(i-1)

            local c=self.selected == i and {100,175,114} or {200,200,200}
            local a=self.selected == i and 0 or 125
            dxDrawShadowText(v.name, 27/zoom+49/zoom-1, sh-195/zoom+sY, 493/zoom+27/zoom+49/zoom-1, 49/zoom, tocolor(200, 200, 200, 255-a), 1, assets.fonts[4], "center", "top")
            dxDrawBlurImage(27/zoom, sh-171/zoom+sY, 49/zoom, 49/zoom, (self.selected == i and getKeyState("arrow_l")) and assets.textures[13] or assets.textures[12], 180, 0, 0, tocolor(255, 255, 255, 255-a))
            dxDrawBlurImage(27/zoom+49/zoom-1, sh-171/zoom+sY, 493/zoom, 49/zoom, assets.textures[14], 0, 0, 0, tocolor(255, 255, 255, 255-a))
            dxDrawBlurImage(27/zoom+493/zoom+49/zoom-2, sh-171/zoom+sY, 49/zoom, 49/zoom, (self.selected == i and getKeyState("arrow_r")) and assets.textures[13] or assets.textures[12], 0, 0, 0, tocolor(255, 255, 255, 255-a))
    
            dxDrawRectangle(27/zoom+49/zoom-1+6/zoom, sh-171/zoom+(49-2)/2/zoom+sY, 493/zoom-12/zoom, 2, tocolor(49,51,49,255-a))
            dxDrawRectangle(27/zoom+49/zoom-1+6/zoom+(493/zoom-12/zoom)/2-1, sh-171/zoom+(49-2)/2/zoom-(12)/2/zoom+1+sY, 2, 12/zoom, tocolor(49,51,49,255-a))

            local progress=(v.selected+1)*50
            dxDrawRectangle(27/zoom+49/zoom-1+6/zoom, sh-171/zoom+(49-2)/2/zoom+sY, (493/zoom-12/zoom)*(progress/100), 2, tocolor(c[1],c[2],c[3],255-a))
            dxDrawRectangle(27/zoom+49/zoom-1+6/zoom+(493/zoom-12/zoom)*(progress/100), sh-171/zoom+(49-2)/2/zoom-(12)/2/zoom+1+sY, 2, 12/zoom, tocolor(c[1],c[2],c[3],255-a))
    
            if(self.selected == i)then
                local veh=getPedOccupiedVehicle(localPlayer)
                local cost=v.cost
                local org=getElementData(veh, "vehicle:liderUID")
                if(org)then
                    cost=cost*2
                end

                dxDrawBlurImage(27/zoom+493/zoom+49/zoom+49/zoom+14/zoom, sh-171/zoom+sY, 119/zoom, 49/zoom, assets.textures[15], 0, 0, 0, tocolor(255, 255, 255, 255-a))
                dxDrawShadowText("KUP", 27/zoom+493/zoom+49/zoom+49/zoom+14/zoom+9/zoom+119/zoom, sh-171/zoom+sY, 49/zoom, 49/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
                dxDrawText("$"..cost, 27/zoom+493/zoom+49/zoom+49/zoom+14/zoom+9/zoom+119/zoom+1, sh-171/zoom+1+sY, 49/zoom+1, sh-171/zoom+49/zoom+1+sY, tocolor(0, 0, 0), 1, assets.fonts[3], "left", "bottom")
                dxDrawText("#65ad69$#cdcdcd"..cost, 27/zoom+493/zoom+49/zoom+49/zoom+14/zoom+9/zoom+119/zoom, sh-171/zoom+sY, 49/zoom, sh-171/zoom+49/zoom+sY, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "bottom", false, false, false, true)
            end
        end
    end},

    {x=60/zoom, name="Kolory felg", icon=9, keys={["enter"]="save",["arrow_u"]=-1,["arrow_d"]=1,["x"]="back",["arrow_r"]={"info","selected",1,"colors",false,"color","info","selected","colors"},["arrow_l"]={"info","selected",-1,"colors",false,"color","info","selected","colors"}}, selected=1, maxSelected=4, 

    colors={
        {"Standardowy",rgb={255,255,255},cost=0},

        {"Lapis Lazuli",rgb={6,31,155}, cost=2490},
        {"Blueberry",rgb={12,2,104}, cost=3950},
        {"Arctic",rgb={7,244,197 }, cost=3950},
        {"Bloom",rgb={13,98,81}, cost=3950},
        {"Emerald",rgb={1,66,32}, cost=3950},
        {"Greexy",rgb={70,227,45}, cost=4500},
        {"Lime",rgb={152,227,45}, cost=4500},
        {"Lion Gold",rgb={244,193,17}, cost=4400},
        {"Retrivers",rgb={244,193,17}, cost=4400},
        {"Bahama",rgb={250,190,113}, cost=3550},
        {"Interpastel",rgb={250,158,113}, cost=3550},
        {"Corals",rgb={255, 79, 79}, cost=4500},
        {"DeadEye",rgb={38,6,2}, cost=3750},
        {"Rose",rgb={96,17,28}, cost=3150},
        {"Pinkers",rgb={225,36,209}, cost=3900},
        {"Lovele",rgb={169,36,225}, cost=4750},
        {"Heartbeat",rgb={206,90,255}, cost=4290},
        {"Grey",rgb={50,50,50},cost=1550},
        {"Black",rgb={0,0,0},cost=1550},
    },

    info={
        {name="Kolor szprych", cost=1000, selected=1, type="szprycha"},
        {name="Kolor obwodu", cost=1000, selected=1, type="felga"},
        {name="Kolor tarcz", cost=1000, selected=1, type="tarcza"},
        {name="Kolor klocków", cost=1000, selected=1, type="hamulec"},
    },
    
    alphaTable={
        [1]=125,
        [2]=75,
        [3]=50,
        [4]=20,
    },
    
    render=function(self)
        -- back
        dxDrawBlurImage(27/zoom, sh-400/zoom, 49/zoom, 49/zoom, assets.textures[16])
        dxDrawShadowText("POWRÓT", 27/zoom+58/zoom, sh-400/zoom, 49/zoom, 49/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
        dxDrawShadowText("do kategorii", 27/zoom+58/zoom, sh-400/zoom, 49/zoom, sh-400/zoom+49/zoom, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "bottom")
        --

        for i,value in pairs(self.info) do
            local veh=getPedOccupiedVehicle(localPlayer)
            local org=getElementData(veh, "vehicle:liderUID")

            local sY=(75/zoom)*(i-1)

            local c=self.selected == i and {100,175,114} or {200,200,200}
            local a=self.selected == i and 0 or 125
            local check=self.selected == i

            dxDrawShadowText(value.name, 27/zoom, sh-330/zoom+sY, 227/zoom+27/zoom+49/zoom-1, 49/zoom, tocolor(200, 200, 200, 255-a), 1, assets.fonts[4], "left", "top")

            dxDrawBlurImage(27/zoom, sh-330/zoom+sY+24/zoom, 49/zoom, 49/zoom, (self.selected == i and getKeyState("arrow_l")) and assets.textures[13] or assets.textures[12], 180, 0, 0, tocolor(255, 255, 255, 255-a))
            dxDrawBlurImage(27/zoom+49/zoom-1, sh-330/zoom+sY+24/zoom, 227/zoom, 49/zoom, assets.textures[14], 0, 0, 0, tocolor(255, 255, 255, 255-a))
            dxDrawBlurImage(27/zoom+227/zoom+49/zoom-2, sh-330/zoom+sY+24/zoom, 49/zoom, 49/zoom, (self.selected == i and getKeyState("arrow_r")) and assets.textures[13] or assets.textures[12], 0, 0, 0, tocolor(255, 255, 255, 255-a))

            local name=""
            local addCost=0
            local x=0
            local k=0
            for i=value.selected-4,value.selected+4 do
                local v=self.colors[i]
                if(v)then
                    if(i == value.selected)then
                        local cost=v.cost
                        if(org)then
                            cost=cost*2
                        end

                        addCost=cost

                        dxDrawImage(27/zoom+49/zoom-2+227/2/zoom-23/2/zoom+13/2/zoom,sh-330/zoom+sY+24/zoom+(49-13)/2/zoom, 13/zoom, 13/zoom, assets.textures[17], 0, 0, 0, tocolor(v.rgb[1], v.rgb[2], v.rgb[3], 255-a))
                        
                        if(check)then
                            dxDrawImage(27/zoom+49/zoom-1+227/2/zoom-23/2/zoom, sh-330/zoom+sY+24/zoom+(49-13)/2/zoom-(23-13)/2/zoom, 23/zoom, 23/zoom, assets.textures[18], 0, 0, 0, tocolor(255,255,255,255-a))
                        end

                        dxDrawShadowText(v[1], 27/zoom+49/zoom-1, sh-330/zoom+sY, 227/zoom+27/zoom+49/zoom-1+49/zoom, 49/zoom, tocolor(v.rgb[1], v.rgb[2], v.rgb[3], 255-a), 1, assets.fonts[4], "right", "top")
                    
                        name=v[1]
                    elseif(i < value.selected)then
                        local left=value.selected-1
                        if(value.selected > 4)then
                            left=4
                        end

                        local pos=27/zoom+49/zoom-2+227/2/zoom-23/2/zoom+13/2/zoom-((24/zoom)*left)

                        x=x+1
                        pos=pos+((24/zoom)*(x-1))
        
                        local aa=self.alphaTable[left+1-x] or 255
                        dxDrawImage(pos,sh-330/zoom+sY+24/zoom+(49-13)/2/zoom, 13/zoom, 13/zoom, assets.textures[17], 0, 0, 0, tocolor(v.rgb[1], v.rgb[2], v.rgb[3], aa))
                    else
                        k=k+1
        
                        local sX=(24/zoom)*(k)
                        local aa=self.alphaTable[k] or 255
                        dxDrawImage(27/zoom+49/zoom-2+227/2/zoom-23/2/zoom+13/2/zoom+sX, sh-330/zoom+sY+24/zoom+(49-13)/2/zoom, 13/zoom, 13/zoom, assets.textures[17], 0, 0, 0, tocolor(v.rgb[1], v.rgb[2], v.rgb[3], aa))
                    end
                end
            end

            if(self.selected == i)then
                local cost=name == "Standardowy" and 0 or value.cost
                if(org)then
                    cost=cost*2
                end

                cost=(cost+addCost)
                dxDrawBlurImage(27/zoom+227/zoom+49/zoom+49/zoom+14/zoom, sh-330/zoom+sY+24/zoom, 119/zoom, 49/zoom, assets.textures[15], 0, 0, 0, tocolor(255, 255, 255, 255-a))
                dxDrawShadowText("KUP", 27/zoom+227/zoom+49/zoom+49/zoom+14/zoom+9/zoom+119/zoom, sh-330/zoom+sY+24/zoom, 49/zoom, 49/zoom, tocolor(200, 200, 200), 1, assets.fonts[2], "left", "top")
                dxDrawText("$"..cost, 27/zoom+227/zoom+49/zoom+49/zoom+14/zoom+9/zoom+119/zoom+1, sh-330/zoom+1+sY+24/zoom, 49/zoom+1, sh-330/zoom+49/zoom+1+sY+24/zoom, tocolor(0, 0, 0), 1, assets.fonts[3], "left", "bottom")
                dxDrawText("#65ad69$#cdcdcd"..cost, 27/zoom+227/zoom+49/zoom+49/zoom+14/zoom+9/zoom+119/zoom, sh-330/zoom+sY+24/zoom, 49/zoom, sh-330/zoom+49/zoom+sY+24/zoom, tocolor(200, 200, 200), 1, assets.fonts[3], "left", "bottom", false, false, false, true)
            end
        end
    end},
}

-- rendering, etc

ui.onRender=function()
    local veh=getPedOccupiedVehicle(localPlayer)
    if(not veh)then ui.destroy() return end

    if(not ui.selectedMenu)then
        local x=20/zoom
        dxDrawImage(x, sh/2-536/2/zoom, 173/zoom, 536/zoom, assets.textures[1])

        dxDrawImage(x+17/zoom, sh/2-536/2/zoom+15/zoom, 67/zoom, 67/zoom, getKeyState("arrow_u") and assets.textures[3] or assets.textures[2])
        dxDrawImage(x+17/zoom, sh/2-536/2/zoom+536/zoom-67/zoom-15/zoom, 67/zoom, 67/zoom, getKeyState("arrow_d") and assets.textures[5] or assets.textures[4])

        for i,v in pairs(ui.menu) do
            local sY=(100/zoom)*(i-1)
            dxDrawImage(x+v.x, sh/2-536/2/zoom+81/zoom+sY, 66/zoom, 66/zoom, assets.textures[v.icon], 0, 0, 0, tocolor(255, 255, 255, ui.optionMenu == i and 255 or 125))

            if(ui.optionMenu == i)then
                dxDrawShadowText(v.name, x+v.x+44/zoom+66/zoom, sh/2-536/2/zoom+81/zoom+sY, 0, sh/2-536/2/zoom+81/zoom+sY+66/zoom, tocolor(200, 200, 200), 1, assets.fonts[1], "left", "center")
                dxDrawBlurImage(x+v.x+44/zoom+66/zoom+dxGetTextWidth(v.name, 1, assets.fonts[1])+17/zoom, sh/2-536/2/zoom+81/zoom+sY+15/zoom, 88/zoom, 36/zoom, getKeyState("space") and assets.textures[11] or assets.textures[10], 0, 0, 0, tocolor(255, 255, 255, 255))
            end
        end
    else
        local render=ui.menu[ui.selectedMenu].render
        render(ui.menu[ui.selectedMenu])
    end
end

ui.onKey=function(key, press)
    if(not press)then return end

    local veh=getPedOccupiedVehicle(localPlayer)
    if(not veh)then ui.destroy() return end

    if(not ui.selectedMenu)then
        if(key == "arrow_u")then
            ui.optionMenu=(ui.optionMenu-1 < 1 and #ui.menu or ui.optionMenu-1)
        elseif(key == "arrow_d")then
            ui.optionMenu=(ui.optionMenu+1 == #ui.menu+1 and 1 or ui.optionMenu+1)
        elseif(key == "space")then
            ui.savedData=getElementData(veh, "vehicle:wheelsSettings") or {}
            ui.selectedMenu=ui.optionMenu
        end
    else
        local info=ui.menu[ui.selectedMenu]
        for i,v in pairs(info.keys) do
            if(i == key)then
                if(v == "save")then
                    local cost=info.info[info.selected].cost
                    local selected=info.info[info.selected].selected

                    if(selected and info.colors and info.colors[selected])then
                        cost=cost+info.colors[selected].cost

                        if(info.colors[selected][1] == "Standardowy")then
                            cost=0
                        end
                    end

                    local org=getElementData(veh, "vehicle:liderUID")
                    if(org)then
                        cost=cost*2
                    end

                    if(SPAM.getSpam())then return end

                    triggerServerEvent("buy.wheels", resourceRoot, veh, tonumber(cost), getElementData(veh, "vehicle:wheelsSettings") or {})
                elseif(v == "back")then
                    ui.selectedMenu=false

                    ui.restoreData(veh)
                    ui.refreshOptions()
                else
                    if(type(v) == "table")then
                        local tbl=info[v[1]]
                        local row=tbl[info[v[2]]]

                        local next=row[v[2]]+v[3]

                        local max=tonumber(v[4]) and v[4] or #info[v[4]]
                        local min=tonumber(v[5]) and v[5] or 1

                        next=math.max(min,next)
                        next=math.min(max,next)

                        row[v[2]]=next

                        if(v[6])then
                            local x=info[v[8]]
                            local type=info[v[7]][x].type
                            ui.setOption(veh, v[6], next, type, info.name, info[v[9]])
                        end
                    else
                        ui.restoreData(veh)
                        
                        local next=info.selected+v
                        if(next < 1)then
                            next=info.maxSelected
                        elseif(next > info.maxSelected)then
                            next=1
                        end

                        info.selected=next
                    end
                end

                break
            end
        end
    end
end

-- create

addEvent("saveData", true)
addEventHandler("saveData", resourceRoot, function(veh)
    ui.savedData=getElementData(veh, "vehicle:wheelsSettings") or {}
end)

ui.restoreData=function(veh)
    setElementData(veh, "vehicle:wheelsSettings", ui.savedData)
end

ui.create=function()
    local vehicle=getPedOccupiedVehicle(localPlayer)
    if(not vehicle)then return end

    if(getElementHealth(vehicle) < 1000)then
        exports.px_noti:noti("Aby ulepszyć pojazd, musi on być sprawny.", "error")
        return
    end

    if(getVehicleController(vehicle) ~= localPlayer)then return end

    local uid=getElementData(localPlayer, "user:uid")    
    local owner=getElementData(vehicle, "vehicle:owner") or getElementData(vehicle, "vehicle:liderUID")
    if(not uid or not owner or (owner and owner ~= uid))then 
        exports.px_noti:noti("Pojazd nie należy do Ciebie.", "error")
        return 
    end

    e_blur=exports.blur

    addEventHandler("onClientRender", root, ui.onRender)
    addEventHandler("onClientKey", root, ui.onKey)

    assets.create()

    ui.savedData=getElementData(vehicle, "vehicle:wheelsSettings") or {}

    setElementData(localPlayer, "user:hud_disabled", true)

    ui.optionMenu=1
    ui.selectedMenu=false

    toggleControl("enter_exit", false)
end

ui.destroy=function()
    if(assets.textures == nil) then return end
    if(#assets.textures == 0) then return end
    
    local vehicle=getPedOccupiedVehicle(localPlayer)
    if(not vehicle)then return end

    if(getVehicleController(vehicle) ~= localPlayer)then return end

    local uid=getElementData(localPlayer, "user:uid")    
    local owner=getElementData(vehicle, "vehicle:owner") or getElementData(vehicle, "vehicle:liderUID")
    if(not uid or not owner or (owner and owner ~= uid))then 
        exports.px_noti:noti("Pojazd nie należy do Ciebie.", "error")
        return 
    end

    removeEventHandler("onClientRender", root, ui.onRender)
    removeEventHandler("onClientKey", root, ui.onKey)

    assets.destroy()

    setElementData(localPlayer, "user:hud_disabled", false)

    toggleControl("enter_exit", true)

    ui.restoreData(vehicle)

    ui.savedData = {}

    ui.refreshOptions()
end

-- triggers

addEvent("open.ui", true)
addEventHandler("open.ui", resourceRoot, function()
    local vehicle=getPedOccupiedVehicle(localPlayer)
    if(not vehicle)then return end

    if(getVehicleUpgradeOnSlot(vehicle, 12) == 0)then
        exports.px_noti:noti("Najpierw zamontuj felgi do pojazdu!", "error")
        return
    end

    ui.create()
end)

addEvent("destroy.ui", true)
addEventHandler("destroy.ui", resourceRoot, function()
    ui.destroy()
end)

function table.size(tab)
    local length = 0
    for _ in pairs(tab) do length = length + 1 end
    return length
end