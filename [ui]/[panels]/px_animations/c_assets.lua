--[[
    @author: Xyrusek
    @mail: xyrusowski@gmail.com
    @project: Pixel (MTA)
]]

local baseX = 1920
local minZoom = 2
sx, sy = guiGetScreenSize()
zoom = 1

if sx < baseX then
    zoom = math.min(minZoom, baseX/sx)
end

blur=exports.blur
noti=exports.px_noti
scroll=exports.px_scroll

assets = {}
    assets.list = {
        textures = {
            "textures/animation_option.png",
            "textures/animation_option_hoverAndChecked.png",
            "textures/category_released.png",
            "textures/category_unreleased.png",
            "textures/full_breakline.png",
            "textures/half_breakline.png",
            "textures/header_animationName.png",
            "textures/icon_all.png",
            "textures/icon_favourite.png",
            "textures/icon_favourite_unchecked.png",
            "textures/icon_favourite_unchecked_hovered_bg.png",
            "textures/icon_minus.png",
            "textures/icon_plus.png",
            "textures/main_background.png",
            "textures/main_icon.png",
            "textures/W.png",
            "textures/W_hover.png",
            "textures/A.png",
            "textures/A_hover.png",
            "textures/S.png",
            "textures/S_hover.png",
            "textures/D.png",
            "textures/D_hover.png",
            "textures/arrow.png",
            "textures/arrow_hover.png",
            "textures/space.png",
            "textures/space_hover.png",
        },
        fonts = {
            {"Regular", 16},
            {"Regular", 12},
            {"Regular", 14},
            {"SemiBold", 14},
            {"Regular", 10},
        },
    }

assets.create = function()
    assets.textures = {}
    for i, v in pairs(assets.list.textures) do
        assets.textures[i] = dxCreateTexture(v, "argb", false, "clamp")
    end

    assets.fonts = {}
    for i, v in pairs(assets.list.fonts) do
        assets.fonts[i] = dxCreateFont(":px_assets/fonts/Font-"..v[1]..".ttf", v[2]/zoom)
    end
end
addEventHandler("onClientResourceStart", getResourceRootElement(), assets.create)

assets.clear = function()
    for i, v in pairs((assets.textures or {})) do
        if isElement(v) then destroyElement(v) end
    end
    assets.textures = {}

    for i, v in pairs((assets.fonts or {})) do
        if isElement(v) then destroyElement(v) end
    end
    assets.fonts = {}
end
addEventHandler("onClientResourceStop", getResourceRootElement(), assets.clear)