--[[
    @author: Xyrusek
    @mail: xyrusowski@gmail.com
    @project: Pixel (MTA)
]]

sx, sy = guiGetScreenSize() 
zoom = sx < 1920 and math.min(2, 1920 / sx) or 1

assets = {}
    assets.list = {
        textures = {
            "textures/bg.png",
            "textures/button-minus.png",
            "textures/button-plus.png",
            "textures/car.png",
            "textures/close.png",
            "textures/crown.png",
            "textures/garage.png",
            "textures/row.png",
            "textures/row-big.png",
            "textures/share.png",
            "textures/user.png",
            "textures/default-avatar.png",
        },
        fonts = {
            {"Medium", 12},
            {"Regular", 11},
            {"Medium", 13},
            {"SemiBold", 14},
            {"Regular", 10},
        },
    }

assets.create = function()
    assets.textures = {}
    for i, v in ipairs(assets.list.textures) do
        assets.textures[i] = dxCreateTexture(v, "argb", false, "clamp")
    end

    assets.fonts = {}
    for i, v in ipairs(assets.list.fonts) do
        assets.fonts[i] = dxCreateFont(":px_assets/fonts/Font-"..v[1]..".ttf", v[2]/zoom)
    end
end

assets.clear = function()
    for i, v in ipairs((assets.textures or {})) do
        if isElement(v) then destroyElement(v) end
    end
    assets.textures = {}

    for i, v in ipairs((assets.fonts or {})) do
        if isElement(v) then destroyElement(v) end
    end
    assets.fonts = {}
end