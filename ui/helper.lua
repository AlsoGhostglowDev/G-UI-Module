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

function helper.getTag(boxName, type) 
    local suffix = 'UiText'
    if type:lower() == 'bg' then suffix = 'UiBG' end
    return boxName .. suffix
end

function helper.setBoxProperty(boxName, type, property, value)
    setProperty(helper.getTag(boxName, type) .. '.' .. property, value)
end

function helper.getBoxProperty(boxName, type, property)
    return getProperty(helper.getTag(boxName, type) .. '.' .. property)
end

function helper.makeUIText(tag, id, display, x, y)
    local _tag = ('%sUi%sTxt'):format(tag, id)
    makeLuaText(_tag)
    makeLuaText(_tag, display, 0)
    setTextSize(_tag, 20)
    setTextBorder(_tag, 0)
    setObjectCamera(_tag, 'other')
    addLuaText(_tag)
end

helper.buttons = {}
function helper.makeButton(tag, id, display, func, x, y, width) 
    local _tag = ('%sUi%sBG'):format(tag, id)
    makeLuaSprite(_tag, nil, x, y)
    makeGraphic(_tag, (width or 120), 24, 'FFFFFF')
    setObjectCamera(_tag, 'other')
    addLuaSprite(_tag)

    helper.makeUIText(tag, id, display, x, y)
    table.insert(helper.buttons, {tag, id, func})
end

function helper.update()
    for _, buttonData in ipairs(helper.buttons) do
        local _tag = buttonData[1]..'Ui'..buttonData[2]
        setProperty(_tag .. 'Txt.x', getProperty(_tag .. 'BG.x') + ((getProperty(_tag .. 'BG.width') - getProperty(_tag .. 'Txt.width')) / 2))
        setProperty(_tag .. 'Txt.y', getProperty(_tag .. 'BG.y') + ((getProperty(_tag .. 'BG.height') - getProperty(_tag .. 'Txt.height')) / 2))

        if helper.mouseOverlaps(_tag .. 'BG') and getProperty(_tag ..'BG.visible') then
            for _, lmr in ipairs({'left', 'middle', 'right'}) do
                if mouseClicked(lmr) then
                    if buttonData[3] ~= nil then
                        buttonData[3](lmr)
                    end
                end
            end
        end
    end
end

return helper