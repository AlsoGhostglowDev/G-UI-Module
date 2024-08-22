local helper = {}

function helper.mouseOverlaps(obj, camera)
    local mX = getMouseX(camera or 'camHUD') + getProperty((camera or 'camHUD') .. '.scroll.x')
    local mY = getMouseY(camera or 'camHUD') + getProperty((camera or 'camHUD') .. '.scroll.y')
    local x = getProperty(obj .. '.x')
    local y = getProperty(obj .. '.y')
    local width = getProperty(obj .. '.width')
    local height = getProperty(obj .. '.height')
    return (mX > x) and (mX < x + width) and (mY > y) and (mY < y + height)
end

return helper