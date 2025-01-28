--[[
    @author: psychol.
    @mail: nezymr69@gmail.com
    @project: Pixel (MTA)
]]

local vehs={}

-- create

local fonts={}
local listFonts={
    {":px_assets/fonts/Font-Medium.ttf", 22},
    {":px_assets/fonts/Font-Regular.ttf", 15},
    {":px_assets/fonts/Font-Medium.ttf", 11},
    {":px_assets/fonts/Font-Regular.ttf", 8},
    {":px_assets/fonts/Font-Medium.ttf", 10}
}

function shaderFontsCreate()
    for i,v in pairs(listFonts) do
        fonts[#fonts+1]=dxCreateFont(v[1], v[2])
    end
end

function shaderFontsDestroy()
    for i,v in pairs(fonts) do
        if(v and isElement(v))then
            destroyElement(v)
            fonts[i]=nil
        end
    end
    fonts={}
end

function createShader(v)
    local data=getElementData(v, "salon:data")
    if(data)then
        if(#fonts < 1)then
            shaderFontsCreate()
        end

        if(data.info.tex == "info")then
            vehs[v]={element=v,shader=dxCreateShader("shaders/shader.fx"),target=dxCreateRenderTarget(129, 231, true), data=data}
        else
            vehs[v]={element=v,shader=dxCreateShader("shaders/shader.fx"),target=dxCreateRenderTarget(604, 228, true), data=data}
        end

        applyShader(vehs[v])

        if(#fonts > 0)then
            shaderFontsDestroy()
        end
    end
end

function destroyShader(v)
    if(vehs[v])then
        engineRemoveShaderFromWorldTexture(vehs[v].shader, vehs[v].data.info.tex)
        destroyElement(vehs[v].shader)
        destroyElement(vehs[v].target)
        vehs[v]=nil
    end
end

function applyShader(v)
    v.info=v.data.info

    local name=getVehicleName(v.element)
    local bak=v.info.bak
    local fuel=v.info.fuel
    local type=v.info.type
    local engine=exports.px_custom_vehicles:getVehicleEngineFromName(name) or "1.0"
    local fuel_usage=exports.px_custom_vehicles:getFuelUsage(engine)
    local naped=getVehicleHandling(v.element).driveType
    local value=v.info.value
    local cost=v.info.cost
    type=type == "Petrol" and "Benzyna" or type

    if(v.info.tex == "info")then
        local infos={
            {"Silnik", engine.."dm³ "..type},
            {"Napęd", naped == "awd" and "na dwie osie" or naped == "rwd" and "na tył" or naped == "fwd" and "na przód"},
            {"Spalanie", fuel_usage.."l/100km"},
            {"Cena", convertNumber(cost).."$"},
            {'Przebieg', v.info.distance..'km'},
            {"Ilość", value},
        }

        dxSetRenderTarget(v.target, true)
            dxDrawRectangle(0, 0, 129, 231, tocolor(30, 30, 30))

            dxDrawText(name, 0, 0, 129, 231, tocolor(200, 200, 200, 255), 1, fonts[3], "center", "top", false)
            dxDrawRectangle(25/2, 25, 129-25, 1, tocolor(100, 100, 100))

            for i,v in pairs(infos) do
                local sY=33*(i-1)
                dxDrawText(v[1], 0, 30+sY, 129, 228, tocolor(200, 200, 200, 255), 1, fonts[4], "center", "top", false)
                dxDrawText(v[2], 0, 45+sY, 129, 228, tocolor(200, 200, 200, 255), 1, fonts[5], "center", "top", false)
            end
        dxSetRenderTarget()

        dxSetShaderValue(v.shader, "shader", v.target)
        engineApplyShaderToWorldTexture(v.shader, v.info.tex, v.info.object)
    else
        dxSetRenderTarget(v.target, true)
            dxDrawRectangle(0, 0, 604, 228, tocolor(30,30,30))
            dxDrawText(name, 0, 3, 604, 228, tocolor(200, 200, 200, 255), 1, fonts[1], "center", "top", false)
            dxDrawRectangle(50, 45, 604-100, 1, tocolor(85, 85, 85))

            dxDrawText("Paliwo\nSilnik\nBak\nNapęd\nCena\nIlość", 55, 60, 604, 228, tocolor(200, 200, 200, 255), 1, fonts[2], "left", "top", false)
            dxDrawText(type.." ("..fuel_usage.."#1f5378l#c9c9c9/100#1f5378km#c9c9c9)\n"..engine.."dm³ #c9c9c9\n"..bak.."#1f5378l#c9c9c9\n"..(string.upper(naped)).."\n"..convertNumber(cost).."#5fa324$#c9c9c9\n"..value, 55, 60, 604-50-5, 228, tocolor(200, 200, 200, 255), 1, fonts[2], "right", "top", false, false, false, true)
        dxSetRenderTarget()

        dxSetShaderValue(v.shader, "shader", v.target)
        engineApplyShaderToWorldTexture(v.shader, v.info.tex)
    end
end

-- tutaj stojo

addEventHandler("onClientElementDataChange", root, function(data, last, new)
    if(getElementType(source) == "vehicle")then
        if(data == "salon:data")then
            destroyShader(source)
            createShader(source)
        end
    end
end)

addEventHandler("onClientElementStreamIn", root, function()
  if(getElementType(source) == "vehicle")then
    createShader(source)
  end
end)

addEventHandler("onClientElementStreamOut", root, function()
  if(getElementType(source) == "vehicle")then
    destroyShader(source)
  end
end)

addEventHandler("onClientResourceStart", resourceRoot, function()
  for i,v in pairs(getElementsByType("vehicle", root, true)) do
    createShader(v)
  end
end)

addEventHandler("onClientRestore", root, function(clear)
    if(clear)then
      for i,v in pairs(getElementsByType("vehicle", root, true)) do
        createShader(v)
      end
  end
end)

addEventHandler("onClientElementDestroy", resourceRoot, function()
    destroyShader(source)
end)

function convertNumber ( number )
	local formatted = number
	while true do
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if ( k==0 ) then
			break
		end
	end
	return formatted
end