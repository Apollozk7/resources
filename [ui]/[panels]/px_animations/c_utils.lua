--[[
    @author: Xyrusek
    @mail: xyrusowski@gmail.com
    @project: Pixel (MTA)
]]

function click(x, y, w, h)
    if not animations.clickblock and getKeyState("mouse1") and isMouseInPosition(x, y, w, h) then return true end
    return false
end

function click2()
    if not animations.clickblock2 and getKeyState("space") then return true end
    return false
end

function isMouseInPosition(x, y, w, h)
    if not isCursorShowing() then return false end
    local cx, cy = getCursorPosition()
    local cx, cy = sx*cx, sy*cy
    return (( cx >= x and cx <= x + w ) and ( cy >= y and cy <= y + h ))
end

function sendNotification(text)
    noti:noti(text, "info")
end