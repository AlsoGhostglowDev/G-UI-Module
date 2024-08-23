local checkbox = {}
local tab = require 'ui.tab'
local helper = require 'ui.helper'

-- should contains = { .. {tag, curValue, group, section, func, x, y} .. }
checkbox.checkboxes = {}

function checkbox.makeCheckbox(tag, defaultValue, display, group, section, func, x, y)
    if tab.groupExists(group) then
        x, y = (x or 0), (y or 0)
        local _tag = tag .. 'UiCheckBG'
        makeLuaSprite(_tag)
        makeGraphic(_tag, 24, 24, '000000')
        setObjectCamera(_tag, 'other')
        addLuaSprite(_tag)
        tab.addAttachedSprite(_tag, group, x, y)
        
        local _tag = tag .. 'UiCheck'
        makeLuaSprite(_tag)
        makeGraphic(_tag, 12, 12, 'FFFFFF')
        setObjectCamera(_tag, 'other')
        addLuaSprite(_tag)
        setProperty(_tag .. '.visible', defaultValue)
        tab.addAttachedSprite(_tag, group, x + 6, y + 6)

        local _tag = tag .. 'UiCheckTxt'
        makeLuaText(_tag)
        makeLuaText(_tag, display, 0)
        setTextSize(_tag, 22)
        setTextBorder(_tag, 0)
        setObjectCamera(_tag, 'other')
        addLuaText(_tag)
        tab.addAttachedSprite(_tag, group, x + 28, y)

        table.insert(checkbox.checkboxes, {tag, defaultValue, group, section, func, x, y})
    end
end

function checkbox.update() 
    for i, checkData in ipairs(checkbox.checkboxes) do
        local tag, value, group, section, func = checkData[1], checkData[2], checkData[3], checkData[4], checkData[5]
        setProperty(tag .. 'UiCheck.alpha', checkData[2] and 1 or 0)
        if helper.mouseOverlaps(tag .. 'UiCheckBG', 'camOther') then
            if not checkData[2] then
                setProperty(tag .. 'UiCheck.alpha', 0.5)
            end

            if mouseClicked('left') then
                checkData[2] = not checkData[2]
                if func ~= nil then
                    func(checkData[2])
                end
            end
        end

        setProperty(tag .. 'UiCheckBG.visible', tab.getGroupCurSelected(group) == section)
        setProperty(tag .. 'UiCheck.visible', tab.getGroupCurSelected(group) == section)
        setProperty(tag .. 'UiCheckTxt.visible', tab.getGroupCurSelected(group) == section)
    end
end

return checkbox