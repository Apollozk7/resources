--[[ 

    author: Asper (© 2019)
    mail: nezymr69@gmail.com
    all rights reserved.

]]

local banner = {}
  
function banner:Load()
    self["banners"] = {
        {txd="images/okno.png", world_texture="carshowwin2"},
        {txd="images/okno.png", world_texture="carshowroom1"},
    }

    for i,v in pairs(self["banners"]) do
        local object = false
        
        if v["pos"] then
            object = createObject(v["object_id"], v["pos"][1], v["pos"][2], v["pos"][3], v["rot"][1], v["rot"][2], v["rot"][3])
            setElementDimension(object, v["dim"])
            setElementInterior(object, v["int"])
        end

        local shader = dxCreateShader("shaders/shader.fx")
        local txd = dxCreateTexture(v["txd"], "argb", false, "clamp")
        dxSetShaderValue(shader, "shader", txd)

        if object then
            engineApplyShaderToWorldTexture(shader, v["world_texture"], object)
        else
            engineApplyShaderToWorldTexture(shader, v["world_texture"])
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    banner:Load()
end)